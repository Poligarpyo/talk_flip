// ignore: file_names
import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:string_similarity/string_similarity.dart';

class PronounceChecker {
  final DoubleMetaphone dm = DoubleMetaphone();
  final Soundex soundex = Soundex();

  // Normalize words - maarte mode: extra strict!
  String normalize(String word) {
    return word.toLowerCase().trim();
  }

  double textScore(String expected, String spoken) {
    expected = normalize(expected);
    spoken = normalize(spoken);

    // Only EXACT match gets perfect score
    if (expected == spoken) return 100.0;

    double similarity = expected.similarityTo(spoken);
    
    // MAARTE PENALTIES: Any imperfection gets heavy punishment!
    if (similarity < 0.98) similarity *= 0.5;  // 98% similar? Still not good enough!
    if (similarity < 0.95) similarity *= 0.3;  // 95%? You call that trying?
    if (similarity < 0.90) similarity *= 0.1;  // 90%? That's basically wrong!

    // Length must be PERFECT
    double lengthPenalty = (spoken.length == expected.length) ? 1.0 : 0.6;

    // Short words? Better be PERFECT!
    if (expected.length <= 5 && expected != spoken) {
      similarity *= 0.2; // Nuclear option for short word errors
    }

    // Vowel positions must match exactly
    double vowelPenalty = _calculateVowelPositionPenalty(expected, spoken);
    similarity *= vowelPenalty;

    return (similarity * lengthPenalty * 100).clamp(0, 100);
  }

  double _calculateVowelPositionPenalty(String expected, String spoken) {
    List<int> expectedVowelPositions = [];
    List<int> spokenVowelPositions = [];
    
    for (int i = 0; i < expected.length; i++) {
      if (_isVowel(expected[i])) expectedVowelPositions.add(i);
    }
    for (int i = 0; i < spoken.length; i++) {
      if (_isVowel(spoken[i])) spokenVowelPositions.add(i);
    }
    
    if (expectedVowelPositions.length != spokenVowelPositions.length) {
      return 0.5; // Wrong number of vowels? Unacceptable!
    }
    
    int vowelPositionErrors = 0;
    for (int i = 0; i < expectedVowelPositions.length; i++) {
      if (expectedVowelPositions[i] != spokenVowelPositions[i]) {
        vowelPositionErrors++;
      }
    }
    
    return vowelPositionErrors == 0 ? 1.0 : (1.0 - (vowelPositionErrors * 0.3)).clamp(0.3, 1.0);
  }

  double phoneticScore(String expected, String spoken) {
    expected = normalize(expected);
    spoken = normalize(spoken);

    // DoubleMetaphone - must be PERFECT
    var dmExpected = dm.encode(expected);
    var dmSpoken = dm.encode(spoken);
    
    int dmScore = 0;
    if (dmExpected != null && dmSpoken != null) {
      // Both primary AND alternates must match exactly
      if (dmExpected.primary == dmSpoken.primary && 
          dmExpected.alternates == dmSpoken.alternates) {
        dmScore = 100;
      } else if (dmExpected.primary == dmSpoken.primary) {
        dmScore = 60; // Only primary matches? Meh.
      } else {
        dmScore = 20; // Barely recognizable
      }
    }

    // Soundex - must be IDENTICAL
    PhoneticEncoding? sxExpected = soundex.encode(expected);
    PhoneticEncoding? sxSpoken = soundex.encode(spoken);
    int sxScore = (sxExpected != null && sxSpoken != null && sxExpected == sxSpoken) ? 100 : 30;

    // Levenshtein distance - ZERO TOLERANCE
    int levenshteinDistance = _calculateLevenshtein(expected, spoken);
    double levenshteinScore = 0.0;
    if (levenshteinDistance == 0) {
      levenshteinScore = 100.0;
    } else if (levenshteinDistance == 1) {
      levenshteinScore = 50.0; // One character wrong? That's 50% off!
    } else {
      levenshteinScore = 10.0; // More than one error? Basically failed.
    }

    // Critical letters - FIRST, LAST, and MOST IMPORTANT must match
    int criticalLettersScore = _calculateCriticalLettersScore(expected, spoken);

    // Combined phonetic score - we demand excellence!
    return (dmScore * 0.35 + sxScore * 0.25 + levenshteinScore * 0.25 + criticalLettersScore * 0.15).toDouble();
  }

  int _calculateCriticalLettersScore(String expected, String spoken) {
    if (expected.isEmpty || spoken.isEmpty) return 0;
    
    int score = 0;
    int criticalCount = 0;
    
    // First letter - MUST match
    if (expected[0] == spoken[0]) {
      score += 40;
      criticalCount++;
    }
    
    // Last letter - MUST match
    if (expected[expected.length - 1] == spoken[spoken.length - 1]) {
      score += 40;
      criticalCount++;
    }
    
    // Middle important consonants - should match
    String expectedConsonants = _extractConsonants(expected);
    String spokenConsonants = _extractConsonants(spoken);
    
    if (expectedConsonants.isNotEmpty && spokenConsonants.isNotEmpty) {
      int matchingConsonants = 0;
      for (int i = 0; i < expectedConsonants.length && i < spokenConsonants.length; i++) {
        if (expectedConsonants[i] == spokenConsonants[i]) {
          matchingConsonants++;
        }
      }
      double consonantAccuracy = expectedConsonants.isNotEmpty ? 
          matchingConsonants / expectedConsonants.length : 1.0;
      score += (consonantAccuracy * 20).toInt();
      criticalCount++;
    }
    
    return criticalCount > 0 ? (score / criticalCount).toInt() : 0;
  }

  double syllableAwareScore(String expected, String spoken) {
    expected = normalize(expected);
    spoken = normalize(spoken);
    
    List<String> expectedSyllables = _extractSyllables(expected);
    List<String> spokenSyllables = _extractSyllables(spoken);
    
    // Syllable count MUST be exact
    if (expectedSyllables.length != spokenSyllables.length) {
      return 20.0; // Wrong number of syllables? Terrible!
    }
    
    double syllableScore = 0.0;
    for (int i = 0; i < expectedSyllables.length; i++) {
      if (expectedSyllables[i] == spokenSyllables[i]) {
        syllableScore += 1.0; // Perfect match
      } else if (_areSyllablesMaarteSimilar(expectedSyllables[i], spokenSyllables[i])) {
        syllableScore += 0.4; // Barely acceptable
      } else {
        syllableScore += 0.1; // Basically wrong
      }
    }
    
    return (syllableScore / expectedSyllables.length * 100).clamp(0, 100);
  }

  bool _areSyllablesMaarteSimilar(String syl1, String syl2) {
    // Super strict similarity - almost no tolerance
    if (syl1.length != syl2.length) return false;
    
    int differences = 0;
    for (int i = 0; i < syl1.length; i++) {
      if (syl1[i] != syl2[i]) {
        // Only allow VERY similar vowels, no consonant changes
        bool bothVowels = _isVowel(syl1[i]) && _isVowel(syl2[i]);
        bool maarteVowelSimilar = bothVowels && _areVowelsMaarteSimilar(syl1[i], syl2[i]);
        if (!maarteVowelSimilar) {
          return false; // Any consonant difference = FAIL
        }
        differences++;
        if (differences > 1) return false; // Max 1 tiny vowel difference
      }
    }
    return differences <= 1;
  }

  bool _areVowelsMaarteSimilar(String vowel1, String vowel2) {
    // Only allow the most similar vowel substitutions
    Map<String, List<String>> maarteVowelGroups = {
      'a': ['a'],        // 'a' is only similar to 'a'
      'e': ['e', 'i'],   // 'e' and 'i' are somewhat similar
      'i': ['i', 'e'],   // 'i' and 'e' are somewhat similar  
      'o': ['o'],        // 'o' is only similar to 'o'
      'u': ['u', 'o'],   // 'u' and 'o' are somewhat similar
      'y': ['y', 'i']    // 'y' and 'i' are somewhat similar
    };
    
    return maarteVowelGroups[vowel1]?.contains(vowel2) == true;
  }

  double fluencyScore(String expected, String spoken) {
    expected = normalize(expected);
    spoken = normalize(spoken);
    
    double baseScore = 100.0;

    // MAARTE FLUENCY DEDUCTIONS:

    // 1. Syllable rhythm must be PERFECT
    List<String> expectedSyllables = _extractSyllables(expected);
    List<String> spokenSyllables = _extractSyllables(spoken);
    if (expectedSyllables.length != spokenSyllables.length) {
      baseScore -= 50; // Wrong rhythm? Half points gone!
    }

    // 2. Stress pattern MUST be correct
    if (expectedSyllables.length > 1 && spokenSyllables.length > 1) {
      bool expectedStressOnFirst = expectedSyllables[0].length >= expectedSyllables[1].length;
      bool spokenStressOnFirst = spokenSyllables[0].length >= spokenSyllables[1].length;
      if (expectedStressOnFirst != spokenStressOnFirst) {
        baseScore -= 40; // Wrong stress? Unacceptable!
      }
    }

    // 3. Consonant crispness - must be sharp and clear
    double consonantCrispness = _calculateConsonantCrispness(expected, spoken);
    baseScore *= consonantCrispness;

    // 4. Vowel purity - no lazy vowels!
    double vowelPurity = _calculateVowelPurity(expected, spoken);
    baseScore *= vowelPurity;

    return baseScore.clamp(0, 100);
  }

  double _calculateConsonantCrispness(String expected, String spoken) {
    String expectedConsonants = _extractConsonants(expected);
    String spokenConsonants = _extractConsonants(spoken);
    
    if (expectedConsonants.isEmpty) return 1.0;
    
    int crispMatches = 0;
    for (int i = 0; i < expectedConsonants.length && i < spokenConsonants.length; i++) {
      if (expectedConsonants[i] == spokenConsonants[i]) {
        crispMatches++;
      }
    }
    
    double crispness = expectedConsonants.isNotEmpty ? 
        crispMatches / expectedConsonants.length : 1.0;
    
    // Extra penalty for missing final consonants
    if (expectedConsonants.isNotEmpty && spokenConsonants.isNotEmpty) {
      if (expectedConsonants[expectedConsonants.length - 1] != 
          spokenConsonants[spokenConsonants.length - 1]) {
        crispness *= 0.7; // Dropping final consonant? Lazy!
      }
    }
    
    return crispness;
  }

  double _calculateVowelPurity(String expected, String spoken) {
    List<String> expectedVowels = _extractVowelGroups(expected);
    List<String> spokenVowels = _extractVowelGroups(spoken);
    
    if (expectedVowels.isEmpty) return 1.0;
    
    double purityScore = 0.0;
    int minLength = expectedVowels.length < spokenVowels.length ? 
        expectedVowels.length : spokenVowels.length;
    
    for (int i = 0; i < minLength; i++) {
      if (expectedVowels[i] == spokenVowels[i]) {
        purityScore += 1.0; // Perfect vowel purity
      } else if (_areVowelsMaarteSimilar(expectedVowels[i], spokenVowels[i])) {
        purityScore += 0.5; // Acceptable but not perfect
      } else {
        purityScore += 0.1; // Impure vowels!
      }
    }
    
    return purityScore / expectedVowels.length;
  }

  double finalScore(String expected, String spoken) {
    // MAARTE FINAL SCORE: We expect PERFECTION!
    double ts = textScore(expected, spoken);
    double ps = phoneticScore(expected, spoken);
    double ss = syllableAwareScore(expected, spoken);
    double fs = fluencyScore(expected, spoken);

    // Only PERFECT scores get high marks
    double weightedScore = 0.0;

    if (expected.length <= 4) {
      // Short words: MUST be perfect
      weightedScore = (ts * 0.45 + ps * 0.45 + ss * 0.05 + fs * 0.05);
      if (expected != spoken) weightedScore *= 0.8; // Extra penalty for imperfection
    } else if (expected.length <= 7) {
      // Medium words: Very high standards
      weightedScore = (ts * 0.4 + ps * 0.35 + ss * 0.15 + fs * 0.1);
    } else {
      // Long words: Still demanding but slightly more forgiving
      weightedScore = (ts * 0.35 + ps * 0.3 + ss * 0.2 + fs * 0.15);
    }

    // BONUS: Only for absolute perfection
    if (expected.toLowerCase() == spoken.toLowerCase()) {
      return 100.0;
    }

    // PENALTY: If any component is less than excellent
    if (ts < 90 || ps < 80 || ss < 85 || fs < 80) {
      weightedScore *= 0.85; // Not excellent enough? Penalty!
    }

    return weightedScore.clamp(0, 100);
  }

  // MAARTE FEEDBACK: Nothing is ever good enough! 😤
  String getFeedback(double score) {
    if (score >= 98) return "Almost perfect... but I've heard better";
    if (score >= 95) return "Good, but your vowels could be purer";
    if (score >= 90) return "Acceptable, but work on your consonants";
    if (score >= 85) return "Mediocre - practice each syllable carefully";
    if (score >= 75) return "Poor - are you even trying?";
    if (score >= 60) return "Terrible - listen to native speakers";
    return "Unacceptable - start over from the beginning";
  }

  // Get detailed breakdown - because we need to know EXACTLY what's wrong
  Map<String, dynamic> getDetailedAnalysis(String expected, String spoken) {
    double ts = textScore(expected, spoken);
    double ps = phoneticScore(expected, spoken);
    double ss = syllableAwareScore(expected, spoken);
    double fs = fluencyScore(expected, spoken);
    double finalScoreValue = finalScore(expected, spoken);

    return {
      'textScore': ts,
      'phoneticScore': ps,
      'syllableScore': ss,
      'fluencyScore': fs,
      'finalScore': finalScoreValue,
      'isAcceptable': finalScoreValue >= 90, // Only excellence is acceptable!
      'breakdown': {
        'exactMatch': expected.toLowerCase() == spoken.toLowerCase(),
        'syllableCountMatch': _extractSyllables(expected).length == _extractSyllables(spoken).length,
        'firstLetterMatch': expected.isNotEmpty && spoken.isNotEmpty && expected[0] == spoken[0],
        'lastLetterMatch': expected.isNotEmpty && spoken.isNotEmpty && 
            expected[expected.length - 1] == spoken[spoken.length - 1],
        'vowelPositionsMatch': _calculateVowelPositionPenalty(expected, spoken) == 1.0,
        'consonantCrispness': _calculateConsonantCrispness(expected, spoken),
        'vowelPurity': _calculateVowelPurity(expected, spoken),
        'levenshteinDistance': _calculateLevenshtein(expected, spoken),
        'similarity': expected.similarityTo(spoken),
      },
      'maarteComment': _getMaarteComment(expected, spoken)
    };
  }

  String _getMaarteComment(String expected, String spoken) {
    if (expected.toLowerCase() == spoken.toLowerCase()) {
      return "Finally! Someone who can pronounce properly!";
    }
    
    List<String> comments = [
      "Your vowels sound lazy... try harder!",
      "Consonants should be crisp, not mushy!",
      "Is that how your teacher taught you?",
      "I've heard better from a text-to-speech app!",
      "Put some effort into it!",
      "Your mouth isn't even trying!",
      "That pronunciation... oof!",
      "Did you even listen to the example?",
      "My ears are bleeding!",
      "Let me play the example again... slowly this time"
    ];
    
    return comments[DateTime.now().millisecond % comments.length];
  }

  // Helper methods
  int _calculateLevenshtein(String a, String b) {
    List<List<int>> matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    
    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }

  List<String> _extractSyllables(String word) {
    List<String> syllables = [];
    String currentSyllable = '';
    
    for (int i = 0; i < word.length; i++) {
      currentSyllable += word[i];
      if (i < word.length - 1 && _isVowel(word[i]) && !_isVowel(word[i + 1])) {
        syllables.add(currentSyllable);
        currentSyllable = '';
      }
    }
    
    if (currentSyllable.isNotEmpty) {
      syllables.add(currentSyllable);
    }
    
    return syllables.isNotEmpty ? syllables : [word];
  }

  bool _isVowel(String char) {
    return 'aeiouy'.contains(char);
  }

  String _extractConsonants(String word) {
    return word.replaceAll(RegExp(r'[aeiouy\s]'), '');
  }

  List<String> _extractVowelGroups(String word) {
    List<String> vowels = [];
    String currentGroup = '';
    
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if ('aeiouy'.contains(char)) {
        currentGroup += char;
      } else if (currentGroup.isNotEmpty) {
        vowels.add(currentGroup);
        currentGroup = '';
      }
    }
    
    if (currentGroup.isNotEmpty) {
      vowels.add(currentGroup);
    }
    
    return vowels;
  }
}