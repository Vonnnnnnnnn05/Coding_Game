enum SubmissionStatus {
  accepted,
  wrongAnswer,
  runtimeError,
  compilationError,
  timeLimitExceeded,
  processing,
}

class Submission {
  const Submission({
    required this.id,
    required this.challengeId,
    required this.challengeTitle,
    required this.languageId,
    required this.languageName,
    required this.code,
    required this.status,
    required this.createdAt,
    this.runtimeMs,
    this.memoryKb,
    this.output,
    this.error,
  });

  final String id;
  final String challengeId;
  final String challengeTitle;
  final int languageId;
  final String languageName;
  final String code;
  final SubmissionStatus status;
  final DateTime createdAt;
  final int? runtimeMs;
  final int? memoryKb;
  final String? output;
  final String? error;
}

extension SubmissionStatusLabel on SubmissionStatus {
  String get label => switch (this) {
    SubmissionStatus.accepted => 'Accepted',
    SubmissionStatus.wrongAnswer => 'Wrong Answer',
    SubmissionStatus.runtimeError => 'Runtime Error',
    SubmissionStatus.compilationError => 'Compilation Error',
    SubmissionStatus.timeLimitExceeded => 'Time Limit Exceeded',
    SubmissionStatus.processing => 'Processing',
  };
}
