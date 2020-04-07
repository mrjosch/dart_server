

import 'package:server/networking/User.dart';

class Player {

  User user;

  String name;
  bool isNext;

  int lastThrow;
  int pointsLeft;
  int dartsThrown;

  int sets;
  int legs;

  String average;
  String checkoutPercentage;

  Player(User user) {
    this.user = user;

    name ??= '';
  }

  Player.fromJson(Map<String, dynamic> json) {
    user.id = json['id'];
    name = json['name'];
    isNext = json['isNext'];
    lastThrow = json['lastThrow'];
    pointsLeft = json['pointsLeft'];
    dartsThrown = json['dartsThrown'];
    sets = json['sets'];
    legs = json['legs'];
    average = json['average'];
    checkoutPercentage = json['checkoutPercentage'];
  }

  Map<String, dynamic> toJson() => {
        'id': user.id,
        'name': name,
        'isNext': isNext,
        'lastThrow': lastThrow,
        'pointsLeft': pointsLeft,
        'dartsThrown': dartsThrown,
        'sets': sets,
        'legs': legs,
        'average': average,
        'checkoutPercentage': checkoutPercentage,
      };

  @override
  String toString() {
    return 'Player{id: $user.id, name: $name, lastThrow: $lastThrow, pointsLeft: $pointsLeft, dartsThrown: $dartsThrown, sets: $sets, legs: $legs, average: $average, checkoutPercentage: $checkoutPercentage}';
  }

  @override
  bool operator ==(other) {
    Player o = other as Player;
    return this.user.id == o.user.id;
  }
}
