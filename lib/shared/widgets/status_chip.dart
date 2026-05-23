import 'package:flutter/material.dart';

import '../../features/challenges/domain/challenge.dart';
import '../../features/submissions/domain/submission.dart';

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      Difficulty.easy => Colors.green,
      Difficulty.intermediate => Colors.amber.shade800,
      Difficulty.hard => Colors.red,
    };
    return Chip(
      label: Text(difficulty.label),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      backgroundColor: color.withValues(alpha: 0.10),
    );
  }
}

class SubmissionStatusChip extends StatelessWidget {
  const SubmissionStatusChip({super.key, required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SubmissionStatus.accepted => Colors.green,
      SubmissionStatus.processing => Colors.blue,
      SubmissionStatus.wrongAnswer => Colors.orange,
      SubmissionStatus.compilationError ||
      SubmissionStatus.runtimeError ||
      SubmissionStatus.timeLimitExceeded => Colors.red,
    };
    return Chip(
      label: Text(status.label),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      backgroundColor: color.withValues(alpha: 0.10),
    );
  }
}
