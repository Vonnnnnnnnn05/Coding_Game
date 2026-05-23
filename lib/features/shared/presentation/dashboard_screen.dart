import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../submissions/data/submission_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).asData?.value;
    final challenges = ref.watch(challengesProvider).asData?.value ?? const [];
    final submissions =
        ref.watch(submissionControllerProvider).asData?.value ?? const [];
    final daily = challenges.isEmpty ? null : challenges.first;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'GamingCode',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Practice algorithms, run code, and climb the leaderboard.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(label: 'XP', value: '${profile?.xp ?? 0}'),
            _MetricCard(label: 'Level', value: '${profile?.level ?? 1}'),
            _MetricCard(
              label: 'Solved',
              value: '${profile?.solvedChallengeIds.length ?? 0}',
            ),
            _MetricCard(label: 'Streak', value: '${profile?.streak ?? 0}d'),
          ],
        ),
        const SizedBox(height: 20),
        if (daily != null)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Challenge',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        daily.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    DifficultyChip(difficulty: daily.difficulty),
                  ],
                ),
                const SizedBox(height: 10),
                Text(daily.description),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/challenges/${daily.id}'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start coding'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'Recent Submissions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (submissions.isEmpty)
          const AppCard(
            child: Text('No submissions yet. Run a challenge to begin.'),
          )
        else
          ...submissions
              .take(4)
              .map(
                (submission) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(submission.challengeTitle),
                      subtitle: Text(submission.languageName),
                      trailing: SubmissionStatusChip(status: submission.status),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
