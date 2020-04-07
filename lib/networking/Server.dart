import 'dart:convert';
import 'dart:io';

import 'package:server/artefacts/ConfigChange.dart';
import 'package:server/artefacts/Container.dart';
import 'package:server/artefacts/GameJoin.dart';
import 'package:server/artefacts/PerformThrow.dart';
import 'package:server/artefacts/ServerJoin.dart';
import 'package:server/artefacts/Snapshot.dart';
import 'package:server/model/game/Game.dart';
import 'package:server/model/game/GameConfig.dart';
import 'package:server/model/game/Player.dart';
import 'package:server/model/game/Throw.dart';
import 'package:http/http.dart' as http;

import 'User.dart';


class Server {

  //final HttpServer _httpServer;
  final List<User> users = [];
  final List<Game> games = [Game()];

  Server() {
    HttpServer.bind('192.168.178.108', 8002).then((HttpServer server) {
      print('DartServer running at -- ws://192.168.178.108:8002/');
      server.listen((HttpRequest request) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          var user = User(ws);
          user.connection.ws.listen(
                (json) {
                  print('$json\r\n');
                  handleMessage(json, user);
                },
            onDone: () => print('[+]Done :)'),
            onError: (err) => print('[!]Error -- ${err.toString()}'),
            cancelOnError: true,
          );
        }, onError: (err) => print('[!]Error -- ${err.toString()}'));
      }, onError: (err) => print('[!]Error -- ${err.toString()}'));
    }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  }

  void handleMessage(json, User user) {
    var container = Container.fromJson(jsonDecode(json));

    switch(container.type) {
      case 'serverJoin':
        onServerJoin(user, (container.payload as ServerJoin).userId);
        break;
      case 'createGame':
        onCreateGame(user);
        break;
      case 'configChange':
        ConfigChange change = container.payload;
        onConfigChange(user, change.type, change.param);
        break;
      case 'gameJoin':
        onGameJoin(user, (container.payload as GameJoin).gameId);
        break;
      case 'startGame':
        onStartGame(user);
        break;
      case 'performThrow':
        onPerformThrow(user, (container.payload as PerformThrow).t);
        break;
      case 'undoThrow':
        onUndoThrow(user);
        break;
    }
  }

  void onServerJoin(User user, String userId) async {
    var response = await fetchRegisteredUsers(userId);

    if(response.statusCode == 200) {
      user.id = userId;
    } else {
      // TODO remove user from users and close ws connection
      print('unregisterd user opened Websocket to this server');
    }

  }

  Future<http.Response> fetchRegisteredUsers(String userId)  {
     return http.get('https://firestore.googleapis.com/v1/projects/dartcounter-91fe2/databases/(default)/documents/users/$userId');
  }

  void onCreateGame(User user) {
    if(user.active && gameOf(user) == null) {
      Game game = Game();
      game.addPlayer(Player(user));
      games.add(game);
      broadcastSnapshot(game);
    }
  }

  void onGameJoin(User user, String gameId) {
    Game game = gameById(gameId);
    if(game != null) {
      game.addPlayer(Player(user));
      broadcastSnapshot(game);
    }
  }

  void onPerformThrow(User user, Throw t) {
    Game game = gameOf(user);
    if(game != null) {
      if(game.currentTurn.user == user) {
        game.performThrow(t);
        broadcastSnapshot(game);
      }
    }
  }

  void onUndoThrow(User user) {
    Game game = gameOf(user);
    if(game != null) {
      if(game.currentTurn.user == user) {
        game.undoThrow();
        broadcastSnapshot(game);
      }
    }
  }

  void onStartGame(User user) {
    Game game = gameOf(user);
    if(game != null) {
      if(game.owner.user == user && game.status == GameStatus.PENDING) {
        game.start();
        broadcastSnapshot(game);
      }
    }
  }

  void onConfigChange(User user, String type, int param) {
    Game game = gameOf(user);
    if(game != null) {
      if(game.owner.user == user && game.status == GameStatus.PENDING) {
        switch(type) {
          case 'toggleMode':
            toggleMode(game);
            broadcastSnapshot(game);
            break;
          case 'setSize':
            setSize(game, param);
            broadcastSnapshot(game);
            break;
          case 'toggleType':
            toggleType(game);
            broadcastSnapshot(game);
            break;
          case 'setStartingPoints':
            setSize(game, param);
            broadcastSnapshot(game);
            break;
        }
      }
    }
  }

  broadcastSnapshot(Game game) {
    Snapshot snapshot = game.snapshot;
    for(Player player in game.players) {
      player.user.connection.send('snapshot', snapshot);
    }
  }


  Game gameOf(User user) {
    for(Game game in games) {
      for(Player player in game.players) {
        if(player.user == user) {
          return game;
        }
      }
    }
    return null;
  }

  Game gameById(String id) {
    for(Game game in games) {
      if(game.id == id) {
        return game;
      }
    }
    return null;
  }

  void toggleMode(Game game) {
    if (game.config.mode == GameMode.FIRST_TO) {
      game.config.mode = GameMode.BEST_OF;
    } else {
      game.config.mode = GameMode.FIRST_TO;
    }
  }

  void setSize(Game game, int size) {
    game.config.size = size;
  }

  void toggleType(Game game) {
    if (game.config.type == GameType.LEGS) {
      game.config.type = GameType.SETS;
    } else {
      game.config.type = GameType.LEGS;
    }
  }

  void setStartingPoints(Game game, int startingPoints) {
    game.config.startingPoints = startingPoints;
  }
}