
import 'package:collection/collection.dart';

import 'Throw.dart';

class Leg {
  List pointsLeft;
  List dartsThrown;
  List dartsOnDouble;
  List throws;
  int startIndex;

  Leg(this.startIndex, int numberOfPlayers, int startingPoints) {
    this.pointsLeft = new List<int>.filled(numberOfPlayers, startingPoints);
    this.dartsThrown = new List<int>.filled(numberOfPlayers, 0);
    this.dartsOnDouble = new List<int>.filled(numberOfPlayers, 0);
    this.throws = new List();
  }


  Leg.fromJson(Map<String, dynamic> json) {
    pointsLeft = json['pointsLeft'];
    dartsThrown = json['dartsThrown'];
    dartsOnDouble = json['dartsOnDouble'];
    throws = json['throws'] != null ? json['throws'].map((value) => value != null ? Throw.fromJson(value) : null).toList() : [];
    startIndex = json['startIndex'];
  }

  Map<String, dynamic> toJson() => {
    'pointsLeft': pointsLeft,
    'dartsThrown': dartsThrown,
    'dartsOnDouble': dartsOnDouble,
    'throws': throws,
    'startIndex': startIndex,
  };

  void performThrow(Throw t) {
    this.pointsLeft[t.playerIndex] -= t.points;
    this.dartsThrown[t.playerIndex] += t.dartsThrown;
    this.dartsOnDouble[t.playerIndex] += t.dartsOnDouble;
    this.throws.add(t);
  }

  Throw undoThrow() {
    Throw last = this.throws.last;
    this.pointsLeft[last.playerIndex] += last.points;
    this.dartsThrown[last.playerIndex] -= last.dartsThrown;
    this.dartsOnDouble[last.playerIndex] -= last.dartsOnDouble;
    this.throws.removeLast();

    return last;
  }

  int get winner {
    return pointsLeft.indexOf(0);
  }

  @override
  String toString() {
    return 'Leg{pointsLeft: $pointsLeft, dartsThrown: $dartsThrown, dartsOnDouble: $dartsOnDouble, throws: $throws, startIndex: $startIndex}';
  }

  @override
  bool operator ==(other) {
    var o = other as Leg;
    return ListEquality().equals(pointsLeft, o.pointsLeft) &&
        ListEquality().equals(dartsThrown, o.dartsThrown) &&
        ListEquality().equals(dartsOnDouble, o.dartsOnDouble) &&
        ListEquality().equals(throws, o.throws) &&
        startIndex == o.startIndex;
  }
}
