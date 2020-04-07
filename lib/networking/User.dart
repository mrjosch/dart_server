import 'dart:io';

import 'package:server/networking/Connection.dart';

import 'Friend.dart';



class User {

  String id;
  Connection connection;

  User(WebSocket ws) {
    connection = Connection(ws);
  }

  Future<List<Friend>> get friends async {
    // TODO
  }

  bool get active {
    return id != null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

}