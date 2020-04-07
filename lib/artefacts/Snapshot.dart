
import 'package:server/model/game/GameConfig.dart';
import 'package:server/model/game/Set.dart';
import 'package:server/model/game/Player.dart';

import 'Packet.dart';

class Snapshot extends Packet {

  GameConfig config;
  String description;
  String status;
  List players;
  List sets;

  Snapshot(this.config, this.description, this.status, this.players, this.sets);

  Snapshot.fromJson(Map<String, dynamic> json) {
    config = json['config'] != null ? GameConfig.fromJson(json['config']) : null;
    description = json['description'];
    status = json['status'];
    players = json['players'] != null ? json['players'].map((value) => Player.fromJson(value)).toList() : [];
    sets = json['sets'] != null ? json['sets'].map((value) => Set.fromJson(value)).toList() : [];
  }

  Map<String, dynamic> toJson() => {
    'config' : config,
    'description' : description,
    'status' : status,
    'players' : players,
    'sets' : sets,
  };

  Player get currentTurn {
    for(Player player in players) {
      if(player.isNext) {
        return player;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'Snapshot{config: $config, description: $description, status: $status, players: $players, sets: $sets}';
  }


}