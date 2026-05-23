class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.xp,
    required this.level,
    required this.streak,
    required this.solvedChallengeIds,
  });

  final String id;
  final String email;
  final String displayName;
  final int xp;
  final int level;
  final int streak;
  final Set<String> solvedChallengeIds;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    int? xp,
    int? level,
    int? streak,
    Set<String>? solvedChallengeIds,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      solvedChallengeIds: solvedChallengeIds ?? this.solvedChallengeIds,
    );
  }
}
