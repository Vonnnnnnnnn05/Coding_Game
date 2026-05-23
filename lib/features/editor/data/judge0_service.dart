import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/utils/output_compare.dart';
import '../../submissions/domain/submission.dart';

class Judge0RunResult {
  const Judge0RunResult({
    required this.status,
    required this.stdout,
    required this.stderr,
    required this.compileOutput,
    required this.runtimeMs,
    required this.memoryKb,
  });

  final SubmissionStatus status;
  final String stdout;
  final String stderr;
  final String compileOutput;
  final int? runtimeMs;
  final int? memoryKb;

  String? get errorText {
    final text = [compileOutput, stderr].where((e) => e.trim().isNotEmpty);
    return text.isEmpty ? null : text.join('\n');
  }
}

class Judge0Service {
  final http.Client _client;

  Judge0Service({http.Client? client}) : _client = client ?? http.Client();

  Future<Judge0RunResult> run({
    required int languageId,
    required String sourceCode,
    required String stdin,
    required String expectedOutput,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.judge0BaseUrl}/submissions?base64_encoded=false&wait=true',
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (AppConfig.hasJudge0ApiKey)
              'X-Auth-Token': AppConfig.judge0ApiKey,
          },
          body: jsonEncode({
            'language_id': languageId,
            'source_code': sourceCode,
            'stdin': stdin,
            'expected_output': expectedOutput,
            'cpu_time_limit': 2,
            'memory_limit': 128000,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Judge0 request failed (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _fromResponse(body, expectedOutput);
  }

  Judge0RunResult _fromResponse(
    Map<String, dynamic> body,
    String expectedOutput,
  ) {
    final statusId = (body['status']?['id'] as num?)?.toInt() ?? 1;
    final stdout = (body['stdout'] as String?) ?? '';
    final stderr = (body['stderr'] as String?) ?? '';
    final compileOutput = (body['compile_output'] as String?) ?? '';
    return Judge0RunResult(
      status: mapJudge0Status(statusId, stdout, expectedOutput),
      stdout: stdout,
      stderr: stderr,
      compileOutput: compileOutput,
      runtimeMs: _secondsToMs(body['time']),
      memoryKb: (body['memory'] as num?)?.toInt(),
    );
  }
}

SubmissionStatus mapJudge0Status(
  int statusId,
  String stdout,
  String expectedOutput,
) {
  return switch (statusId) {
    1 || 2 => SubmissionStatus.processing,
    3 =>
      outputsMatch(stdout, expectedOutput)
          ? SubmissionStatus.accepted
          : SubmissionStatus.wrongAnswer,
    4 => SubmissionStatus.wrongAnswer,
    5 => SubmissionStatus.timeLimitExceeded,
    6 => SubmissionStatus.compilationError,
    _ => SubmissionStatus.runtimeError,
  };
}

int? _secondsToMs(Object? value) {
  if (value == null) return null;
  final seconds = num.tryParse(value.toString());
  if (seconds == null) return null;
  return (seconds * 1000).round();
}
