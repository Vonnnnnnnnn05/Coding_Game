class GamificationService {
  int levelForXp(int xp) => (xp ~/ 300) + 1;

  int xpForNextLevel(int xp) {
    final nextLevel = levelForXp(xp) + 1;
    return (nextLevel - 1) * 300;
  }
}
