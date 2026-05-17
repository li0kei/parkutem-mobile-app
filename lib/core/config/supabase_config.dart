// =====================================================
// SUPABASE CONFIG
// =====================================================

class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void validate() {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw Exception(
        'Missing Supabase config. Please check your .vscode/launch.json '
        'and make sure SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are set.',
      );
    }
  }
}