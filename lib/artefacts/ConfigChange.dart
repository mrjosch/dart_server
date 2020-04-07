import 'Packet.dart';

class ConfigChange extends Packet{

  String type;
  int param;

  ConfigChange(this.type, this.param);

  ConfigChange.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    param = json['param'];
  }

  Map<String, dynamic> toJson() => {
    'type' : type,
    'param' : param,
  };


}