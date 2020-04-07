import 'package:server/artefacts/Packet.dart';
import 'package:server/model/game/Throw.dart';

class PerformThrow extends Packet {

  Throw t;

  PerformThrow(this.t);

  PerformThrow.fromJson(Map<String, dynamic> json) {
    t = json['t'] != null ? Throw.fromJson(json['t']) : null;
  }

  Map<String, dynamic> toJson() => {
    't' : t,
  };

}