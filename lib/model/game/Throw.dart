
class Throw {
  int points;
  int dartsOnDouble;
  int dartsThrown;
  int playerIndex;

  Throw(this.points, [this.dartsOnDouble, this.dartsThrown]) {
    if (dartsThrown == null) {
      dartsThrown = 3;
    }
    if (dartsOnDouble == null) {
      dartsOnDouble = 0;
    }
  }

  Throw.fromJson(Map<String, dynamic> json) {
    points = json['points'];
    dartsOnDouble = json['dartsOnDouble'];
    dartsThrown = json['dartsThrown'];
    playerIndex = json['playerIndex'];
  }

  Map<String, dynamic> toJson() => {
    'points' : points,
    'dartsOnDouble' : dartsOnDouble,
    'dartsThrown' : dartsThrown,
    'playerIndex' : playerIndex,
  };

  @override
  String toString() {
    return 'Throw{points: $points, dartsOnDouble: $dartsOnDouble, dartsThrown: $dartsThrown, playerIndex: $playerIndex}';
  }

  @override
  bool operator ==(other) {
    Throw t = other as Throw;
    return this.points == t.points &&
        this.dartsOnDouble == t.dartsOnDouble &&
        this.dartsThrown == t.dartsThrown &&
        this.playerIndex == t.playerIndex;
  }
}
