class ThrowValidator {
  static bool isValidThrow(int pointsScored, int pointsLeft) {
    return pointsScored <= pointsLeft &&
        pointsScored >= 0 &&
        pointsScored <= 180 &&
        pointsScored != 179 &&
        pointsScored != 178 &&
        pointsScored != 176 &&
        pointsScored != 175 &&
        pointsScored != 173 &&
        pointsScored != 172 &&
        pointsScored != 169 &&
        pointsScored != 166 &&
        pointsScored != 163;
  }

  static bool isValidFinish(int pointsScored) {
    return pointsScored > 1 &&
        pointsScored <= 170 &&
        pointsScored != 169 &&
        pointsScored != 168 &&
        pointsScored != 166 &&
        pointsScored != 165 &&
        pointsScored != 163 &&
        pointsScored != 162 &&
        pointsScored != 159;
  }

  static bool isThreeDartFinish(int points) {
    if (isValidFinish(points)) {
      if (points > 110) {
        return true;
      } else if (points == 108 ||
          points == 109 ||
          points == 106 ||
          points == 105 ||
          points == 103 ||
          points == 102 ||
          points == 99) {
        return true;
      }
    }
    return false;
  }

  static bool isOneDartFinish(int points) {
    if (isValidFinish(points)) {
      if (points <= 40 && points % 2 == 0) {
        return true;
      } else if (points == 50) {
        return true;
      }
    }
    return false;
  }
}
