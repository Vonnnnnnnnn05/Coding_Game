import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_profile.dart';

final leaderboardProvider = FutureProvider<List<UserProfile>>((ref) {
  return ref.read(profileRepositoryProvider).fetchLeaderboard();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Leaderboard',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        leaderboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppCard(child: Text(error.toString())),
          data: (users) {
            final ranked = [...users]..sort((a, b) => b.xp.compareTo(a.xp));
            return Column(
              children: ranked.indexed.map((entry) {
                final rank = entry.$1 + 1;
                final user = entry.$2;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('$rank')),
                      title: Text(user.displayName),
                      subtitle: Text(
                        '${user.solvedChallengeIds.length} solved - ${user.streak} day streak',
                      ),
                      trailing: Text(
                        '${user.xp} XP',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
