import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/data/gamification_service.dart';
import '../../submissions/data/submission_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).asData?.value;
    final submissions =
        ref.watch(submissionControllerProvider).asData?.value ?? const [];
    final gamification = GamificationService();
    final nextXp = gamification.xpForNextLevel(profile?.xp ?? 0);
    final progress = nextXp == 0
        ? 0.0
        : ((profile?.xp ?? 0) % 300).clamp(0, 300) / 300;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              child: Text(
                (profile?.displayName ?? 'C').characters.first.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.displayName ?? 'Coder',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(profile?.email ?? 'Not signed in'),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text('${profile?.xp ?? 0} XP / $nextXp XP for next level'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Stat(label: 'Level', value: '${profile?.level ?? 1}'),
                  _Stat(
                    label: 'Solved',
                    value: '${profile?.solvedChallengeIds.length ?? 0}',
                  ),
                  _Stat(label: 'Streak', value: '${profile?.streak ?? 0} days'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(Icons.local_fire_department),
              label: Text('3 Day Streak'),
            ),
            Chip(avatar: Icon(Icons.code), label: Text('First Submit')),
            Chip(avatar: Icon(Icons.school), label: Text('Easy Solver')),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Submission History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (submissions.isEmpty)
          const AppCard(child: Text('Submission history will appear here.'))
        else
          ...submissions.map(
            (submission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(submission.challengeTitle),
                  subtitle: Text(
                    '${submission.languageName} - ${submission.createdAt.toLocal()}',
                  ),
                  trailing: SubmissionStatusChip(status: submission.status),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
