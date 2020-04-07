
import 'package:server/artefacts/ConfigChange.dart';
import 'package:server/artefacts/GameJoin.dart';
import 'package:server/artefacts/PerformThrow.dart';
import 'package:server/artefacts/ServerJoin.dart';
import 'package:server/artefacts/Snapshot.dart';

import 'Packet.dart';


class Container {

  int timestamp;
  String type;
  Packet payload;

  Container(this.type, this.payload){
    timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Container.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    type = json['type'];
    payload = _payloadFromJsonString(json['payload']);
  }

  Map<String, dynamic> toJson() => {
    'timestamp' : timestamp,
    'type' : type,
    'payload' : payload
  };

  dynamic _payloadFromJsonString(json) {
    switch(type) {
      case 'snapshot':
        return Snapshot.fromJson(json);
      case 'performThrow':
        return PerformThrow.fromJson(json);
      case 'gameJoin':
        return GameJoin.fromJson(json);
      case 'serverJoin':
        return ServerJoin.fromJson(json);
      case 'configChange':
        return ConfigChange.fromJson(json);
      default:
        return null;
    }
  }

  @override
  String toString() {
    return 'Container{timestamp: $timestamp, type: $type, payload: $payload}';
  }

}