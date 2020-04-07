
import 'package:collection/collection.dart';

import 'Leg.dart';

class Set {
  List legs;
  int legsNeededToWin;
  int startIndex;

  Set(this.startIndex, int legsNeededToWin) {
    this.legs = new List();
    this.legsNeededToWin = legsNeededToWin;
  }

  Set.fromJson(Map<String, dynamic> json) {
    legs = json['legs'] != null ? json['legs'].map((value) => Leg.fromJson(value)).toList(): null;
    legsNeededToWin = json['legsNeededToWin'];
    startIndex = json['startIndex'];
  }

  Map<String, dynamic> toJson() => {
    'legs': legs,
    'legsNeededToWin': legsNeededToWin,
    'startIndex': startIndex
  };

  int get winner {
    List winners = new List();
    for (Leg leg in legs) {
      winners.add(leg.winner);
    }

    Map map = Map();
    winners.forEach((element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else {
        map[element] += 1;
      }
    });

    return map.keys
        .firstWhere((k) => map[k] == legsNeededToWin, orElse: () => -1);
  }

  @override
  String toString() {
    return 'Set{legs: $legs, legsNeededToWin: $legsNeededToWin, startIndex: $startIndex}';
  }

  @override
  bool operator ==(other) {
    var o = other as Set;
    return ListEquality().equals(legs, o.legs) &&
        legsNeededToWin == o.legsNeededToWin &&
        startIndex == o.startIndex;
  }
}
