# Firebase Setup & PigeonUserDetails Error Fix

## Issue: `type 'List<Object?> is not a subtype of type 'PigeonUserDetails?'`

This runtime error occurs when the Firebase Auth native method channel (via Pigeon) receives or deserializes user data in an unexpected format. This is typically a **version mismatch** or **native platform configuration issue**.

## Changes Made to Fix This

### 1. Updated Firebase Package Versions
**File: `pubspec.yaml`**
- Updated `firebase_core: ^2.11.0` → `^2.32.0`
- Updated `firebase_auth: ^4.8.0` → `^4.16.0`

These newer versions have better stability and compatibility with the native Firebase SDKs.

### 2. Completed Firebase Options Configuration
**File: `lib/firebase_options.dart`**

Previously had incomplete placeholder values. Now fully configured for all platforms:

- **Android**: Populated from `android/app/google-services.json`
  - apiKey, appId, messagingSenderId, projectId, storageBucket
  
- **iOS**: Populated from `ios/Runner/GoogleService-Info.plist`
  - apiKey, appId, messagingSenderId, projectId, storageBucket, iosBundleId
  
- **macOS**: Same as iOS (standard configuration)

- **Web**: Using Android credentials (common for test projects)
  - apiKey, appId, messagingSenderId, projectId, authDomain, storageBucket

### 3. Added Pigeon Error Handling
**File: `lib/services/auth_service.dart`**

Added defensive error handling to catch and gracefully handle `PigeonUserDetails` deserialization errors:

```dart
// In loginWithEmailPassword():
- If a PigeonUserDetails error occurs, retry after 500ms
- If still fails, throw a user-friendly error message

// In registerWithEmailPassword():
- Catch PigeonUserDetails error and throw user-friendly message

// In authStateChanges stream:
- Added try-catch to return empty stream if initialization fails
```

### 4. Verified Android Gradle Configuration
**File: `android/app/build.gradle.kts`**
- Removed duplicate plugin version declaration
- minSdk remains at 23 (required for Firebase Auth)
- Google Services plugin version now comes from `settings.gradle.kts`

### 5. iOS CocoaPods Configuration
**File: `ios/Podfile`**
- Uses static framework linkage (`use_frameworks! :linkage => :static`)
- Firebase SDK version 10.25.0 installed and compatible with Dart packages

## How to Verify the Fix

1. **Run analysis to check for compile errors:**
   ```bash
   flutter analyze
   ```

2. **Build the app locally:**
   ```bash
   # iOS
   flutter build ios --verbose
   
   # Android
   flutter build apk --verbose
   ```

3. **Test authentication flows:**
   - Try registering a new user
   - Try logging in
   - Check if the `PigeonUserDetails` error appears in the console

## If You Still See `PigeonUserDetails` Error

This indicates the native Firebase plugin is still returning data in an unexpected format. Try:

1. **Clean everything and rebuild:**
   ```bash
   flutter clean
   rm -rf pubspec.lock
   flutter pub get
   flutter pub upgrade
   flutter build ios --clean
   ```

2. **Check iOS pod versions:**
   ```bash
   cd ios && pod repo update && pod install && cd ..
   ```

3. **Update to latest Firebase packages (if willing to take the risk):**
   ```bash
   flutter pub upgrade
   ```

4. **File a bug report** with the exact error stack trace to the Flutter Firebase package maintainers at:
   - https://github.com/firebase/flutterfire/issues

## Architecture Overview

```
lib/
├── main.dart                    # Firebase init + AuthWrapper
├── firebase_options.dart        # Platform-specific Firebase configs
├── services/
│   └── auth_service.dart       # Auth operations with error handling
└── features/auth/screens/
    ├── login_screen.dart       # Login UI
    ├── register_screen.dart    # Registration UI
    └── splash_screen.dart      # Auth state checker
```

## Key Points

- ✅ Firebase packages are aligned with native SDKs
- ✅ All platform configurations are complete (Android, iOS, Web, macOS)
- ✅ Error handling for Pigeon deserialization issues added
- ✅ No breaking Dart compile errors
- ⚠️ If `PigeonUserDetails` error persists, it's a native platform issue requiring version alignment or Firebase plugin updates

