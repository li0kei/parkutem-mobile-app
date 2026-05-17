// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

// =====================================================
// SUPABASE SERVICE
// =====================================================

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    SupabaseConfig.validate();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
    );
  }
}