import 'package:server/artefacts/Packet.dart';

class GameJoin extends Packet {

  String gameId;

  GameJoin(this.gameId);

  GameJoin.fromJson(Map<String, dynamic> json) {
    gameId = json['gameId'];
  }

  Map<String, dynamic> toJson() => {
    'gameId' : gameId,
  };

}