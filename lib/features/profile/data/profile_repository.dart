import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/data/seed_data.dart';
import 'user_profile.dart';

class ProfileRepository {
  SupabaseClient? get _client =>
      AppConfig.isSupabaseConfigured ? Supabase.instance.client : null;

  Future<void> updateProgress(UserProfile profile) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('profiles')
        .update({
          'xp': profile.xp,
          'level': profile.level,
          'streak': profile.streak,
          'solved_challenge_ids': profile.solvedChallengeIds.toList(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', profile.id);
  }

  Future<List<UserProfile>> fetchLeaderboard() async {
    final client = _client;
    if (client == null) return seedLeaderboard;
    final rows = await client
        .from('profiles')
        .select()
        .order('xp', ascending: false)
        .limit(50);
    return rows.map<UserProfile>((row) {
      return UserProfile(
        id: row['id'].toString(),
        email: (row['email'] as String?) ?? '',
        displayName: (row['display_name'] as String?) ?? 'Coder',
        xp: (row['xp'] as num?)?.toInt() ?? 0,
        level: (row['level'] as num?)?.toInt() ?? 1,
        streak: (row['streak'] as num?)?.toInt() ?? 0,
        solvedChallengeIds: ((row['solved_challenge_ids'] as List?) ?? const [])
            .map((id) => id.toString())
            .toSet(),
      );
    }).toList();
  }
}
