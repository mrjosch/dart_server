import 'dart:convert';
import 'dart:io';

import 'package:server/artefacts/Container.dart';
import 'package:server/artefacts/Packet.dart';


class Connection {

  WebSocket ws;

  Connection(this.ws);

  void send(String type, Packet packet) {
    Container container = Container(type, packet);
    _send(jsonEncode(container));
  }

  void _send(String json) {
    print('Sent: $json');
    if (ws?.readyState == WebSocket.open) {
      ws.add(json);
    } else {
      print("Couldn't send Message");
    }
  }

}
