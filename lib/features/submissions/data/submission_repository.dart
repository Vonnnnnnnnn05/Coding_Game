import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../challenges/domain/challenge.dart';
import '../../editor/data/judge0_service.dart';
import '../../editor/data/language_config.dart';
import '../domain/submission.dart';

final judge0ServiceProvider = Provider((ref) => Judge0Service());

final submissionControllerProvider =
    AsyncNotifierProvider<SubmissionController, List<Submission>>(
      SubmissionController.new,
    );

class SubmissionController extends AsyncNotifier<List<Submission>> {
  @override
  Future<List<Submission>> build() async => const [];

  Future<Submission> runCode({
    required Challenge challenge,
    required LanguageConfig language,
    required String code,
  }) async {
    final publicCase = challenge.testCases.firstWhere(
      (test) => test.isPublic,
      orElse: () => challenge.testCases.first,
    );
    final result = await ref
        .read(judge0ServiceProvider)
        .run(
          languageId: language.id,
          sourceCode: code,
          stdin: publicCase.input,
          expectedOutput: publicCase.expectedOutput,
        );
    return _record(challenge, language, code, result);
  }

  Future<Submission> submit({
    required Challenge challenge,
    required LanguageConfig language,
    required String code,
  }) async {
    Judge0RunResult? finalResult;
    for (final test in challenge.testCases) {
      final result = await ref
          .read(judge0ServiceProvider)
          .run(
            languageId: language.id,
            sourceCode: code,
            stdin: test.input,
            expectedOutput: test.expectedOutput,
          );
      finalResult = result;
      if (result.status != SubmissionStatus.accepted) break;
    }
    final submission = await _record(challenge, language, code, finalResult!);
    if (submission.status == SubmissionStatus.accepted) {
      await ref
          .read(authControllerProvider.notifier)
          .awardChallenge(challenge.id, challenge.xp);
    }
    return submission;
  }

  Future<Submission> _record(
    Challenge challenge,
    LanguageConfig language,
    String code,
    Judge0RunResult result,
  ) async {
    final submission = Submission(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      challengeId: challenge.id,
      challengeTitle: challenge.title,
      languageId: language.id,
      languageName: language.name,
      code: code,
      status: result.status,
      createdAt: DateTime.now(),
      runtimeMs: result.runtimeMs,
      memoryKb: result.memoryKb,
      output: result.stdout,
      error: result.errorText,
    );
    state = AsyncData([submission, ...state.asData?.value ?? const []]);
    await _persist(submission);
    return submission;
  }

  Future<void> _persist(Submission submission) async {
    if (!AppConfig.isSupabaseConfigured) return;
    final profile = ref.read(authControllerProvider).asData?.value;
    if (profile == null) return;
    await Supabase.instance.client.from('submissions').insert({
      'user_id': profile.id,
      'challenge_id': submission.challengeId,
      'language_id': submission.languageId,
      'language_name': submission.languageName,
      'code': submission.code,
      'status': submission.status.label,
      'runtime_ms': submission.runtimeMs,
      'memory_kb': submission.memoryKb,
      'output': submission.output,
      'error': submission.error,
    });
  }
}
