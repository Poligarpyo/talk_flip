# Firebase Authentication Setup - TalkFlip

## 🎯 What's Been Implemented

A complete Firebase Authentication system with modern UI for your Flutter app. Users can:
- **Register** with email and password
- **Login** with email and password
- **Auto-redirect** based on login state via Splash screen
- **Password visibility toggle** on login/register screens
- **Modern gradient UI** with smooth animations

## 📁 File Structure

```
lib/
├── main.dart                                    # Updated with auth wrapper & Firebase init
├── firebase_options.dart                        # Platform-specific Firebase config
├── services/
│   └── auth_service.dart                       # All auth methods (login, register, logout)
└── features/
    └── auth/
        └── screens/
            ├── splash_screen.dart              # Checks auth state on app launch
            ├── login_screen.dart               # Modern login UI with email/password
            └── register_screen.dart            # Register UI with name/email/password/terms
```

## 🔧 Key Features

### AuthService (`lib/services/auth_service.dart`)
- `loginWithEmailPassword()` - Sign in user
- `registerWithEmailPassword()` - Create new account
- `signOut()` - Sign out user
- `resetPassword()` - Send password reset email
- `authStateChanges` - Stream of auth state changes
- `currentUser` - Get currently logged-in user

### Login Screen (`lib/features/auth/screens/login_screen.dart`)
- Email & password fields with validation
- Password visibility toggle
- "Forgot Password?" link (ready for implementation)
- Social login buttons (Google, Apple, Facebook placeholders)
- Navigation to Register screen
- Error messages display
- Loading state

### Register Screen (`lib/features/auth/screens/register_screen.dart`)
- Name, email, password, and confirm password fields
- Password validation & matching
- Terms & conditions checkbox
- All field validation
- Modern purple gradient
- Navigation to Login screen
- Error handling

### Splash Screen (`lib/features/auth/screens/splash_screen.dart`)
- Checks if user is already logged in
- Smooth fade + slide animations
- Auto-redirects to Home if logged in, Login if not
- Shows for 2 seconds

## ⚙️ Configuration Required

### 1. **Update `firebase_options.dart`**

Replace placeholder values with your actual Firebase credentials from [Firebase Console](https://console.firebase.google.com):

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  databaseURL: 'YOUR_DATABASE_URL',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);

// Do the same for iOS, macOS, and web...
```

**How to get these values:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. For Android: Settings → Project settings → Service Accounts → Generate new private key (JSON) and copy values
4. For iOS: Download `GoogleService-Info.plist` and add to `ios/Runner` in Xcode
5. For Web: Copy web config from project settings

### 2. **Android Setup**

Already configured! ✅ Your `android/app/google-services.json` is in place with Firebase classpath.

### 3. **iOS Setup**

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner` folder in Xcode (check "Copy items if needed")
3. Run: `cd ios && pod install`

### 4. **Run the App**

```bash
flutter pub get
flutter run
```

## 🚀 Quick Start

1. **First-time users:**
   - App shows Splash screen
   - Redirects to Login screen
   - Tap "Sign Up" → Register screen
   - Fill form & click "Create Account"
   - Auto-redirects to home screen

2. **Returning users:**
   - App shows Splash screen
   - Auto-redirects to home screen (already logged in)

3. **Logout:**
   - Add a logout button to your home screen:
   ```dart
   ElevatedButton(
     onPressed: () => AuthService().signOut(),
     child: Text('Logout'),
   )
   ```

## 🔐 Authentication Flow

```
App Start
    ↓
Firebase Init
    ↓
Splash Screen (2s animation)
    ↓
Check Auth State (AuthWrapper)
    ↓
    ├─ Logged In? → Home Screen
    └─ Not Logged In? → Login Screen
         ├─ Login ✓ → Home Screen
         └─ No Account? → Register → Home Screen
```

## 📋 Validation Rules

### Login
- Email: Must be valid email format
- Password: Min 6 characters

### Register
- Name: Min 3 characters
- Email: Valid email format
- Password: Min 6 characters
- Confirm: Must match password
- Terms: Must be checked

## ❌ Error Handling

Auth service catches Firebase exceptions and returns user-friendly messages:
- "Email already in use" → duplicate account
- "Wrong password" → incorrect credentials
- "User not found" → no account with this email
- "Too many requests" → rate limited
- And more...

## 🎨 Customization Tips

### Change Colors
- Login: Blue gradient (lines 63-70)
- Register: Purple gradient (lines 79-86)
- Splash: Multi-color gradient (lines 99-106)

### Change Fonts/Sizes
All text styles use `Theme.of(context).textTheme.*` for consistency

### Add Social Login
Uncomment social button logic and add Firebase providers:
```dart
// Example for Google Sign-In (you'd need google_sign_in package)
Future<void> _signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // ... implement Google login
  }
}
```

## 📦 Dependencies Added

```yaml
firebase_core: ^2.11.0        # Firebase foundation
firebase_auth: ^4.8.0         # Email/password auth
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Firebase not initialized" | Make sure `firebase_options.dart` has correct credentials |
| Blank screens after login | Check if `PronunciationScreen` is properly exported from `home_screen.dart` |
| iOS build fails | Run `cd ios && pod install && cd ..` |
| Android build fails | Ensure `google-services.json` is in `android/app/` |

## 📚 Next Steps (Optional)

1. **Add Email Verification**
   - Send verification email after register
   - Check `emailVerified` before allowing access

2. **Add Password Reset Flow**
   - Implement "Forgot Password?" screen
   - Use `AuthService().resetPassword()`

3. **Add Social Login**
   - Add `google_sign_in`, `facebook_flutter`, `sign_in_with_apple`
   - Wire into social buttons

4. **Add User Profile**
   - Store user data in Firestore
   - Update profile info after registration

5. **Add Persistent Login**
   - Already works! Firebase handles token refresh automatically

---

**Need help?** Check the comments in each file for additional guidance! 🎉
