// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';

// =====================================================
// SUPABASE CONFIG
// =====================================================

class SupabaseConfig {
  SupabaseConfig._();

  static const String _urlFromDartDefine = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const String _keyFromDartDefine = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String get url {
    if (_urlFromDartDefine.isNotEmpty) {
      return _urlFromDartDefine;
    }

    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get publishableKey {
    if (_keyFromDartDefine.isNotEmpty) {
      return _keyFromDartDefine;
    }

    return dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  }

  static void validate() {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw Exception(
        'Missing Supabase config. Please check your .env file or dart-define values.',
      );
    }
  }
}
