class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const judge0BaseUrl = String.fromEnvironment(
    'JUDGE0_BASE_URL',
    defaultValue: 'https://ce.judge0.com',
  );
  static const judge0ApiKey = String.fromEnvironment('JUDGE0_API_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('http') && supabaseAnonKey.isNotEmpty;

  static bool get hasJudge0ApiKey => judge0ApiKey.isNotEmpty;
}
