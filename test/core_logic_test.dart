import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_code/core/utils/output_compare.dart';
import 'package:gaming_code/features/challenges/domain/challenge.dart';
import 'package:gaming_code/features/editor/data/judge0_service.dart';
import 'package:gaming_code/features/gamification/data/gamification_service.dart';
import 'package:gaming_code/features/submissions/domain/submission.dart';
import 'package:gaming_code/shared/data/seed_data.dart';

void main() {
  test('normalizes trailing whitespace when comparing outputs', () {
    expect(outputsMatch('1 2  \r\n3\n', '1 2\n3'), isTrue);
    expect(outputsMatch('1 2', '2 1'), isFalse);
  });

  test('maps Judge0 statuses to platform statuses', () {
    expect(mapJudge0Status(3, 'ok\n', 'ok'), SubmissionStatus.accepted);
    expect(mapJudge0Status(3, 'no', 'ok'), SubmissionStatus.wrongAnswer);
    expect(mapJudge0Status(5, '', ''), SubmissionStatus.timeLimitExceeded);
    expect(mapJudge0Status(6, '', ''), SubmissionStatus.compilationError);
    expect(mapJudge0Status(11, '', ''), SubmissionStatus.runtimeError);
  });

  test('calculates levels from XP', () {
    final service = GamificationService();
    expect(service.levelForXp(0), 1);
    expect(service.levelForXp(299), 1);
    expect(service.levelForXp(300), 2);
    expect(service.xpForNextLevel(300), 600);
  });

  test('filters seeded challenges by difficulty and search text', () {
    final easyStack = seedChallenges.where((challenge) {
      return challenge.difficulty == Difficulty.easy &&
          (challenge.title.toLowerCase().contains('valid') ||
              challenge.tags.contains('stack'));
    }).toList();

    expect(easyStack.single.id, 'valid-parentheses');
  });
}
