import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/seed_data.dart';
import '../../gamification/data/gamification_service.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/data/user_profile.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final gamificationServiceProvider = Provider((ref) => GamificationService());
final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserProfile?>(AuthController.new);

class AuthController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final current = await ref.read(authRepositoryProvider).currentUser();
    return current ?? seedProfile;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(email, password),
    );
  }

  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).resetPassword(email);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> awardChallenge(String challengeId, int xp) async {
    final profile = state.asData?.value;
    if (profile == null || profile.solvedChallengeIds.contains(challengeId)) {
      return;
    }
    final solved = {...profile.solvedChallengeIds, challengeId};
    final totalXp = profile.xp + xp;
    final level = ref.read(gamificationServiceProvider).levelForXp(totalXp);
    final updated = profile.copyWith(
      xp: totalXp,
      level: level,
      streak: profile.streak + 1,
      solvedChallengeIds: solved,
    );
    state = AsyncData(updated);
    await ref.read(profileRepositoryProvider).updateProgress(updated);
  }
}
