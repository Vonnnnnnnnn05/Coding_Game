import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../profile/data/user_profile.dart';

class AuthRepository {
  SupabaseClient? get _client =>
      AppConfig.isSupabaseConfigured ? Supabase.instance.client : null;

  Future<UserProfile> signIn(String email, String password) async {
    final client = _client;
    if (client == null) {
      return UserProfile(
        id: 'demo-user',
        email: email,
        displayName: email.split('@').first,
        xp: 170,
        level: 1,
        streak: 3,
        solvedChallengeIds: const {'two-sum'},
      );
    }

    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Login failed. Check your credentials.');
    }
    return _profileForUser(client, user);
  }

  Future<UserProfile> register(String email, String password) async {
    final client = _client;
    if (client == null) {
      return UserProfile(
        id: 'demo-user',
        email: email,
        displayName: email.split('@').first,
        xp: 0,
        level: 1,
        streak: 0,
        solvedChallengeIds: const {},
      );
    }

    final response = await client.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw const AuthException('Registration failed. Try again.');
    }
    await client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'display_name': email.split('@').first,
      'xp': 0,
      'level': 1,
      'streak': 0,
    });
    return _profileForUser(client, user);
  }

  Future<void> resetPassword(String email) async {
    final client = _client;
    if (client == null) return;
    await client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }

  Future<UserProfile?> currentUser() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;
    return _profileForUser(client, user);
  }

  Future<UserProfile> _profileForUser(SupabaseClient client, User user) async {
    final row = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) {
      final email = user.email ?? 'coder@gamingcode.local';
      return UserProfile(
        id: user.id,
        email: email,
        displayName: email.split('@').first,
        xp: 0,
        level: 1,
        streak: 0,
        solvedChallengeIds: const {},
      );
    }
    return UserProfile(
      id: user.id,
      email: (row['email'] as String?) ?? user.email ?? '',
      displayName: (row['display_name'] as String?) ?? 'Coder',
      xp: (row['xp'] as num?)?.toInt() ?? 0,
      level: (row['level'] as num?)?.toInt() ?? 1,
      streak: (row['streak'] as num?)?.toInt() ?? 0,
      solvedChallengeIds: ((row['solved_challenge_ids'] as List?) ?? const [])
          .map((id) => id.toString())
          .toSet(),
    );
  }
}
