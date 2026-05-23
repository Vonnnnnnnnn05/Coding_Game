enum Difficulty { easy, intermediate, hard }

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.slug,
    required this.difficulty,
    required this.description,
    required this.examples,
    required this.constraints,
    required this.tags,
    required this.starterCode,
    required this.testCases,
  });

  final String id;
  final String title;
  final String slug;
  final Difficulty difficulty;
  final String description;
  final List<ChallengeExample> examples;
  final List<String> constraints;
  final List<String> tags;
  final Map<String, String> starterCode;
  final List<TestCase> testCases;

  int get xp => switch (difficulty) {
    Difficulty.easy => 50,
    Difficulty.intermediate => 120,
    Difficulty.hard => 250,
  };
}

class ChallengeExample {
  const ChallengeExample({
    required this.input,
    required this.output,
    required this.explanation,
  });

  final String input;
  final String output;
  final String explanation;
}

class TestCase {
  const TestCase({
    required this.input,
    required this.expectedOutput,
    required this.isPublic,
  });

  final String input;
  final String expectedOutput;
  final bool isPublic;
}

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
    Difficulty.easy => 'Easy',
    Difficulty.intermediate => 'Intermediate',
    Difficulty.hard => 'Hard',
  };
}
