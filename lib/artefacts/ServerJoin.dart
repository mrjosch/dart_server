import 'package:server/artefacts/Packet.dart';

class ServerJoin extends Packet {

  String userId;

  ServerJoin(this.userId);

  ServerJoin.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() => {
    'userId' : userId,
  };

}