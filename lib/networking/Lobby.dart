

import 'package:server/model/game/Game.dart';

import 'User.dart';

class Lobby {

  Game game;

  List users;

  Lobby(this.game) {
    users = [];
  }

  bool addUser(User user) {
    if(users.length < 4) {
      users.add(user);
      return true;
    }
    return false;
  }

  void broadcast(String msg) {
    for(User user in users) {
      user.connection.ws.add(msg);
    }
  }

}