import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../domain/challenge.dart';

final challengeRepositoryProvider = Provider((ref) => ChallengeRepository());

final challengesProvider = FutureProvider<List<Challenge>>((ref) {
  return ref.read(challengeRepositoryProvider).fetchChallenges();
});
