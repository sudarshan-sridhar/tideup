import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/env.dart';

/// Gemini AI Service - Uses Gemini 3 Flash (stable)
class GeminiService {
  GenerativeModel? _model;
  GenerativeModel? _chatModel;
  bool _initialized = false;
  String? _initError;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    try {
      _model = GenerativeModel(
        model: Env.geminiModel,
        apiKey: Env.geminiApiKey,
        generationConfig: GenerationConfig(temperature: 0.7, maxOutputTokens: 2048),
      );
      _chatModel = GenerativeModel(
        model: Env.geminiModel,
        apiKey: Env.geminiApiKey,
        generationConfig: GenerationConfig(temperature: 0.8, maxOutputTokens: 1024),
        systemInstruction: Content.text(_systemPrompt),
      );
      _initialized = true;
      print('GeminiService: Initialized with model ${Env.geminiModel}');
    } catch (e) {
      _initError = e.toString();
      print('GeminiService: Failed to initialize: $e');
    }
  }

  static const _systemPrompt = '''
You are TideUp AI Assistant, a helpful assistant for the TideUp beach cleanup app.
TideUp connects volunteers with beach cleanup missions organized by environmental organizations.

Key features:
- Players join cleanup missions, earn XP, coins, and achievements
- Organizations create and manage cleanup events
- AI verifies cleanup photos using before/after comparison
- Coins can be converted to SOL (Solana cryptocurrency)
- Players level up from Beach Newbie (Level 1) to Ocean Legend (Level 20)

Your role:
- Help users understand the app
- Explain gamification (XP, coins, levels, achievements)
- Provide beach cleanup tips
- Answer marine conservation questions
- Help organizations create mission descriptions
- Be encouraging and positive

Be friendly, concise, and use ocean emojis 🌊🏖️🐠 occasionally!
''';

  Future<CleanupVerificationResult> verifyCleanup({
    required Uint8List beforePhoto,
    required Uint8List afterPhoto,
    String? missionDescription,
  }) async {
    if (!_initialized || _model == null) {
      return CleanupVerificationResult.error('AI service not available: ${_initError ?? "Not initialized"}');
    }

    try {
      final prompt = '''
Analyze these two beach cleanup photos. First is BEFORE, second is AFTER.

Tasks:
1. Determine if cleanup occurred
2. Identify trash types in before photo
3. Estimate trash collected (kg)
4. Assess cleanup quality
5. Give confidence score (0.0-1.0)

${missionDescription != null ? 'Mission: $missionDescription' : ''}

Respond in JSON:
{
  "isValidCleanup": true/false,
  "confidenceScore": 0.0-1.0,
  "trashTypes": ["plastic", "bottles", etc.],
  "estimatedTrashKg": number,
  "cleanupQuality": "excellent"/"good"/"moderate"/"poor",
  "analysis": "Brief description",
  "recommendation": "approve"/"review"/"reject",
  "feedback": "Message for volunteer"
}

Be generous but fair. Real cleanups often show subtle differences.
''';

      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', beforePhoto),
          DataPart('image/jpeg', afterPhoto),
        ])
      ]);
      
      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) return CleanupVerificationResult.error('Could not parse AI response');

      final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      return CleanupVerificationResult(
        isValidCleanup: json['isValidCleanup'] ?? false,
        confidenceScore: (json['confidenceScore'] ?? 0.5).toDouble(),
        trashTypes: List<String>.from(json['trashTypes'] ?? []),
        estimatedTrashKg: (json['estimatedTrashKg'] ?? 1.0).toDouble(),
        cleanupQuality: json['cleanupQuality'] ?? 'moderate',
        analysis: json['analysis'] ?? '',
        recommendation: json['recommendation'] ?? 'review',
        feedback: json['feedback'] ?? 'Thank you!',
      );
    } catch (e) {
      print('GeminiService verifyCleanup error: $e');
      return CleanupVerificationResult.error('Verification failed: $e');
    }
  }

  Future<String> chat(String message, {String? context, bool isOrganization = false}) async {
    if (!_initialized || _chatModel == null) {
      return 'AI assistant is temporarily unavailable. Please check your internet connection and try again. 🌊';
    }

    try {
      final roleContext = isOrganization
          ? 'The user is an organization admin managing cleanup events.'
          : 'The user is a player participating in beach cleanups.';

      final fullPrompt = '$roleContext\n${context != null ? 'Context: $context\n' : ''}User: $message';
      
      print('GeminiService: Sending chat request...');
      final response = await _chatModel!.generateContent([Content.text(fullPrompt)]);
      print('GeminiService: Got response');
      
      return response.text ?? 'I couldn\'t generate a response. Please try again. 🌊';
    } catch (e) {
      print('GeminiService chat error: $e');
      
      // Provide helpful error message based on error type
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('api key') || errorStr.contains('apikey')) {
        return 'There\'s an issue with the AI configuration. Please contact support. 🌊';
      } else if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('socket')) {
        return 'Unable to connect to AI service. Please check your internet connection and try again. 🌊';
      } else if (errorStr.contains('quota') || errorStr.contains('rate')) {
        return 'The AI service is busy right now. Please try again in a moment. 🌊';
      } else if (errorStr.contains('model')) {
        return 'AI service configuration error. Please try again later. 🌊';
      }
      
      return 'Sorry, I\'m having trouble connecting. Please try again in a moment. 🌊';
    }
  }

  Future<List<String>> getQuickSuggestions({bool isOrganization = false}) async {
    if (isOrganization) {
      return [
        'How do I create an effective mission?',
        'Tips for attracting volunteers',
        'How does verification work?',
        'Best practices for events',
      ];
    }
    return [
      'How do I earn more XP?',
      'What are the level rewards?',
      'How do I convert coins to SOL?',
      'Tips for beach cleanup',
    ];
  }

  Future<String> generateMissionDescription({
    required String title,
    required String location,
    required String difficulty,
    required int duration,
    String? additionalNotes,
  }) async {
    if (!_initialized || _model == null) {
      return 'Join us for a rewarding beach cleanup experience at $location! All supplies provided. Duration: $duration minutes. 🌊';
    }

    try {
      final prompt = '''
Generate a beach cleanup mission description (under 200 words):
- Title: $title
- Location: $location
- Difficulty: $difficulty
- Duration: $duration minutes
${additionalNotes != null ? '- Notes: $additionalNotes' : ''}

Be welcoming, mention what to expect, end with motivation.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Join us for this exciting beach cleanup mission at $location!';
    } catch (e) {
      print('GeminiService generateMissionDescription error: $e');
      return 'Join us for a rewarding beach cleanup experience at $location! All supplies provided. 🌊';
    }
  }

  Future<String> generateImpactSummary({
    required int totalCleanups,
    required double totalTrashKg,
    required int level,
    required int currentStreak,
    required List<String> achievements,
  }) async {
    if (!_initialized || _model == null) {
      return 'You\'ve completed $totalCleanups cleanups and collected ${totalTrashKg.toStringAsFixed(1)}kg of trash. You\'re making waves of change! 🌊';
    }

    try {
      final prompt = '''
Generate a brief (2-3 sentences) encouraging impact summary:
- Cleanups: $totalCleanups
- Trash collected: ${totalTrashKg.toStringAsFixed(1)} kg
- Level: $level
- Streak: $currentStreak days
- Achievements: ${achievements.length}

Highlight positive ocean impact, celebrate achievements, encourage continued participation.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Thank you for being an ocean champion! 🌊';
    } catch (e) {
      return 'You\'re making waves of change! Every piece helps protect marine life. 🐠🌊';
    }
  }

  Future<List<String>> getCleanupTips({required String difficulty}) async {
    if (!_initialized || _model == null) {
      return _defaultTips;
    }

    try {
      final prompt = 'Provide 5 practical tips for a $difficulty beach cleanup. Format as JSON array of strings.';
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (jsonMatch != null) {
        return (jsonDecode(jsonMatch.group(0)!) as List).map((t) => t.toString()).toList();
      }
      return _defaultTips;
    } catch (e) {
      return _defaultTips;
    }
  }

  static const _defaultTips = [
    'Wear sunscreen and bring water.',
    'Use gloves for protection.',
    'Separate recyclables when possible.',
    'Watch for wildlife.',
    'Take photos of your progress!',
  ];
  
  // Check if service is available
  bool get isAvailable => _initialized && _model != null;
  String? get errorMessage => _initError;
}

class CleanupVerificationResult {
  final bool isValidCleanup;
  final double confidenceScore;
  final List<String> trashTypes;
  final double estimatedTrashKg;
  final String cleanupQuality;
  final String analysis;
  final String recommendation;
  final String feedback;
  final bool hasError;
  final String? errorMessage;

  CleanupVerificationResult({
    required this.isValidCleanup,
    required this.confidenceScore,
    required this.trashTypes,
    required this.estimatedTrashKg,
    required this.cleanupQuality,
    required this.analysis,
    required this.recommendation,
    required this.feedback,
    this.hasError = false,
    this.errorMessage,
  });

  factory CleanupVerificationResult.error(String message) => CleanupVerificationResult(
    isValidCleanup: false, confidenceScore: 0.0, trashTypes: [], estimatedTrashKg: 0.0,
    cleanupQuality: 'unknown', analysis: '', recommendation: 'review', feedback: '',
    hasError: true, errorMessage: message,
  );

  bool get shouldAutoApprove => confidenceScore >= 0.85 && recommendation == 'approve';
  bool get shouldAutoReject => confidenceScore <= 0.3 && recommendation == 'reject';
  bool get needsManualReview => !shouldAutoApprove && !shouldAutoReject;
}
