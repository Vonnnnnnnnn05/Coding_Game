import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/data/seed_data.dart';
import '../domain/challenge.dart';

class ChallengeRepository {
  SupabaseClient? get _client =>
      AppConfig.isSupabaseConfigured ? Supabase.instance.client : null;

  Future<List<Challenge>> fetchChallenges() async {
    final client = _client;
    if (client == null) return seedChallenges;

    final rows = await client
        .from('challenges')
        .select('*, test_cases(*)')
        .order('difficulty')
        .order('title');

    return rows.map<Challenge>(_fromSupabase).toList();
  }

  Challenge _fromSupabase(Map<String, dynamic> row) {
    final rawDifficulty = (row['difficulty'] as String?) ?? 'easy';
    final testRows = (row['test_cases'] as List?) ?? const [];
    return Challenge(
      id: row['id'].toString(),
      title: (row['title'] as String?) ?? 'Untitled',
      slug: (row['slug'] as String?) ?? row['id'].toString(),
      difficulty: Difficulty.values.firstWhere(
        (value) => value.name == rawDifficulty,
        orElse: () => Difficulty.easy,
      ),
      description: (row['description'] as String?) ?? '',
      examples: ((row['examples'] as List?) ?? const []).map((example) {
        final map = Map<String, dynamic>.from(example as Map);
        return ChallengeExample(
          input: (map['input'] as String?) ?? '',
          output: (map['output'] as String?) ?? '',
          explanation: (map['explanation'] as String?) ?? '',
        );
      }).toList(),
      constraints: ((row['constraints'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(),
      tags: ((row['tags'] as List?) ?? const []).map((e) => '$e').toList(),
      starterCode: Map<String, String>.from(row['starter_code'] as Map? ?? {}),
      testCases: testRows.map((test) {
        final map = Map<String, dynamic>.from(test as Map);
        return TestCase(
          input: (map['input'] as String?) ?? '',
          expectedOutput: (map['expected_output'] as String?) ?? '',
          isPublic: (map['visibility'] as String?) == 'public',
        );
      }).toList(),
    );
  }
}
