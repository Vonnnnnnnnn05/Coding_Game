import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/challenges/presentation/challenge_detail_screen.dart';
import '../../features/challenges/presentation/challenge_list_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shared/presentation/app_shell.dart';
import '../../features/shared/presentation/dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const AppShell(selectedIndex: 0, child: DashboardScreen()),
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) =>
            const AppShell(selectedIndex: 1, child: ChallengeListScreen()),
      ),
      GoRoute(
        path: '/challenges/:id',
        builder: (context, state) =>
            ChallengeDetailScreen(challengeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) =>
            const AppShell(selectedIndex: 2, child: LeaderboardScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const AppShell(selectedIndex: 3, child: ProfileScreen()),
      ),
    ],
  );
});
