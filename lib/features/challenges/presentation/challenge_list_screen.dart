import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/challenge.dart';
import 'challenge_providers.dart';

class ChallengeListScreen extends ConsumerStatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  ConsumerState<ChallengeListScreen> createState() =>
      _ChallengeListScreenState();
}

class _ChallengeListScreenState extends ConsumerState<ChallengeListScreen> {
  Difficulty? _difficulty;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengesProvider);
    final solved =
        ref.watch(authControllerProvider).asData?.value?.solvedChallengeIds ??
        const <String>{};

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Challenges',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search problems',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _difficulty == null,
              onSelected: (_) => setState(() => _difficulty = null),
            ),
            for (final difficulty in Difficulty.values)
              ChoiceChip(
                label: Text(difficulty.label),
                selected: _difficulty == difficulty,
                onSelected: (_) => setState(() => _difficulty = difficulty),
              ),
          ],
        ),
        const SizedBox(height: 16),
        challenges.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppCard(child: Text(error.toString())),
          data: (items) {
            final filtered = items.where(_matches).toList();
            if (filtered.isEmpty) {
              return const AppCard(
                child: Text('No challenges match the filters.'),
              );
            }
            return Column(
              children: filtered.map((challenge) {
                final isSolved = solved.contains(challenge.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(
                          isSolved
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                      ),
                      title: Text(challenge.title),
                      subtitle: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text('${challenge.xp} XP'),
                          ...challenge.tags.map((tag) => Text('#$tag')),
                        ],
                      ),
                      trailing: DifficultyChip(
                        difficulty: challenge.difficulty,
                      ),
                      onTap: () => context.go('/challenges/${challenge.id}'),
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

  bool _matches(Challenge challenge) {
    final matchesDifficulty =
        _difficulty == null || challenge.difficulty == _difficulty;
    final q = _query.toLowerCase().trim();
    final matchesSearch =
        q.isEmpty ||
        challenge.title.toLowerCase().contains(q) ||
        challenge.tags.any((tag) => tag.toLowerCase().contains(q));
    return matchesDifficulty && matchesSearch;
  }
}
