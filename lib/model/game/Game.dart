
import 'package:collection/collection.dart';
import 'package:server/artefacts/Snapshot.dart';
import 'package:uuid/uuid.dart';

import 'GameConfig.dart';
import 'Leg.dart';
import 'Player.dart';
import 'Set.dart';
import 'Throw.dart';

enum GameStatus { PENDING, RUNNING, FINISHED }

class Game {

  String id;
  
  GameConfig config;
  GameStatus status;

  List players;
  List sets;

  int turnIndex;

  Game() {
    init();
  }

  void init() {
    id = 'testGame';//Uuid().v4();
    config = GameConfig();
    status = GameStatus.PENDING;
    players = [];
    sets = [];
    turnIndex = 0;
  }

  Snapshot get snapshot {
    switch(status) {
      case GameStatus.PENDING:
        return Snapshot(config, description, 'PENDING', players, null);
      case GameStatus.RUNNING:
        return Snapshot(null, description, 'RUNNING', players, null);
      case GameStatus.FINISHED:
        return Snapshot(null, description, 'FINISHED', players, sets);
    }
    return null;
}

  Game.fromJson(Map<String, dynamic> json) {
    config = json['config'] != null ? GameConfig.fromJson(json['config']) : null;
    status = _statusFromString(json['status']);
    players = json['players'] != null ? json['players'].map((value) => Player.fromJson(value)).toList() : null;
  }

  GameStatus _statusFromString(String json) {
    switch(json) {
      case 'PENDING':
        return GameStatus.PENDING;
      case 'RUNNING':
        return GameStatus.RUNNING;
      case 'FINISHED':
        return GameStatus.FINISHED;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'config': config,
    'status': status.toString().replaceAll('GameStatus.', ''),
    'players': players
  };

  bool addPlayer(Player player) {
    if (players.length < 4) {
      players.add(player);
      return true;
    }
    return false;
  }

  void removePlayer(int index) {
    players.removeAt(index);
  }


  void start() {
    _createSet();
    _createLeg();
    _initPlayers();
    status = GameStatus.RUNNING;
  }

  bool performThrow(Throw t) {
    if (true) {
      // TODO THROW VALIDATION
      currentTurn.isNext = false;

      // sets the player who threw
      t.playerIndex = turnIndex;

      // updates the leg data
      _currentLeg.performThrow(t);

      // updates the player data
      currentTurn.lastThrow = t.points;
      currentTurn.pointsLeft -= t.points;
      currentTurn.dartsThrown += t.dartsThrown;
      currentTurn.average = this._averageCurrentTurn;
      currentTurn.checkoutPercentage = this._checkoutPercentageCurrentTurn;

      // updates the reference to the Player who has next turn
      // updates the player data and creates next leg and set when needed
      if (_currentLeg.winner != -1) {
        if (_currentSet.winner != -1) {
          int sets = -1;
          if (this.config.type == GameType.SETS) {
            sets = currentTurn.sets + 1;
          }
          int legs;
          if (this.config.type == GameType.LEGS) {
            legs = currentTurn.legs + 1;
          } else {
            legs = 0;
          }

          currentTurn.pointsLeft = 0;
          currentTurn.sets = sets;
          currentTurn.legs = legs;
          if (this.winner != null) {
            // GAME FINISHED
            this.status = GameStatus.FINISHED;
          } else {
            // CONTINUE NEW SET
            for (int i = 0; i < this.players.length; i++) {
              Player player = players[i];
              player.pointsLeft = this.config.startingPoints;
              player.dartsThrown = 0;
              player.legs = 0;
            }
            this.turnIndex = (_currentSet.startIndex + 1) % this.players.length;
            _createSet();
            _createLeg();
          }
        } else {
          // CONTINUE NEW LEG
          for (int i = 0; i < this.players.length; i++) {
            Player player = players[i];
            int legs = player.legs;
            if (i == this.turnIndex) {
              legs += 1;
            }
            player.pointsLeft = this.config.startingPoints;
            player.dartsThrown = 0;
            player.legs = legs;
          }
          this.turnIndex = (_currentLeg.startIndex + 1) % this.players.length;
          _createLeg();
        }
      } else {
        // CONTINUE
        this.turnIndex = (this.turnIndex + 1) % this.players.length;
      }

      currentTurn.isNext = true;
      return true;
    }
    return false;
  }

  void undoThrow() {
    if (sets.length == 1 &&
        sets[0].legs.length == 1 &&
        _currentLeg.throws.length == 0) {
      // NO THROW PERFORMED YET -> do nothing
      return;
    }

    currentTurn.isNext = false;

    if (sets.length == 1 &&
        sets[0].legs.length == 1 &&
        _currentLeg.throws.length == 1) {
      // UNDO FIRST THROW OF GAME
      Throw last = _currentLeg.undoThrow();
      this.turnIndex = last.playerIndex;
      currentTurn.lastThrow = -1;
      currentTurn.pointsLeft = this.config.startingPoints;
      currentTurn.dartsThrown = 0;
      currentTurn.average = "0.00";
      currentTurn.checkoutPercentage = "0.00";
    } else if (this.sets.length >= 2 &&
        _currentSet.legs.length == 1 &&
        _currentLeg.throws.length == 0) {
      // UNDO LAST THROW OF SET
      this.sets.removeLast();
      Throw last = _currentLeg.undoThrow();
      this.turnIndex = last.playerIndex;

      // restore player data
      for (int i = 0; i < this.players.length; i++) {
        Player player = this.players[i];

        if (this.turnIndex == i) {
          player.lastThrow = _currentLeg
              .throws[_currentLeg.throws.length - this.players.length].points;
          player.average = _averageCurrentTurn;
          player.checkoutPercentage = _checkoutPercentageCurrentTurn;
        }

        player.pointsLeft = _currentLeg.pointsLeft[i];
        player.dartsThrown = _currentLeg.dartsThrown[i];

        int s = 0;
        int l = 0;
        for (Set set in this.sets) {
          if (this.config.type == GameType.SETS) {
            if (set.winner == i) {
              s += 1;
            }
          } else {
            s = -1;
          }
        }

        for (Leg leg in _currentSet.legs) {
          if (leg.winner == i) {
            l += 1;
          }
        }

        player.sets = s;
        player.legs = l;
      }
    } else if (_currentSet.legs.length >= 2 && _currentLeg.throws.length == 0) {
      // UNDO LAST THROW OF LEG
      _currentSet.legs.removeLast();
      Throw last = _currentLeg.undoThrow();
      this.turnIndex = last.playerIndex;

      // restore player data
      for (int i = 0; i < this.players.length; i++) {
        Player player = this.players[i];

        if (this.turnIndex == i) {
          player.lastThrow = _currentLeg
              .throws[_currentLeg.throws.length - this.players.length].points;
          player.average = _averageCurrentTurn;
          player.checkoutPercentage = _checkoutPercentageCurrentTurn;
        }

        player.pointsLeft = _currentLeg.pointsLeft[i];
        player.dartsThrown = _currentLeg.dartsThrown[i];

        int l = 0;
        for (Leg leg in _currentSet.legs) {
          if (leg.winner == i) {
            l += 1;
          }
        }

        player.legs = l;
      }
    } else {
      // UNDO STANDARD THROW
      Throw last = _currentLeg.undoThrow();
      this.turnIndex = last.playerIndex;
      currentTurn.lastThrow = _currentLeg
          .throws[_currentLeg.throws.length - this.players.length].points;
      currentTurn.pointsLeft += last.points;
      currentTurn.dartsThrown -= last.dartsThrown;
    }

    currentTurn.isNext = true;
    currentTurn.average = _averageCurrentTurn;
    currentTurn.checkoutPercentage = _checkoutPercentageCurrentTurn;
  }

  String get description {
    return config.mode
            .toString()
            .replaceAll("GameMode.", " ")
            .replaceAll("_", " ") +
        " " +
        config.size.toString() +
        " " +
        config.type.toString().replaceAll("GameType.", " ");
  }

  Set get _currentSet {
    return this.sets.last;
  }

  Leg get _currentLeg {
    return this._currentSet.legs.last;
  }

  Player get currentTurn {
    return this.players[turnIndex];
  }

  String get _averageCurrentTurn {
    int totalDartsThrown = 0;
    int totalPointsScored = 0;
    for (Set set in this.sets) {
      for (Leg leg in set.legs) {
        totalDartsThrown += leg.dartsThrown[turnIndex];
        totalPointsScored +=
            (this.config.startingPoints - leg.pointsLeft[turnIndex]);
      }
    }
    if (totalDartsThrown == 0) {
      return "0.00";
    }
    return ((3 * totalPointsScored) / totalDartsThrown).toStringAsFixed(2);
  }

  String get _checkoutPercentageCurrentTurn {
    int totalLegsWon = 0;
    int totalDartsOnDouble = 0;
    for (Set set in this.sets) {
      for (Leg leg in set.legs) {
        if (leg.winner == this.turnIndex) {
          totalLegsWon += 1;
        }
        totalDartsOnDouble += leg.dartsOnDouble[turnIndex];
      }
    }

    if (totalDartsOnDouble == 0) {
      return "0.00";
    }
    return ((totalLegsWon / totalDartsOnDouble) * 100).toStringAsFixed(2);
  }

  Player get winner {
    switch (this.config.type) {
      case GameType.LEGS:
        int legsNeededToWin;
        switch (this.config.mode) {
          case GameMode.FIRST_TO:
            legsNeededToWin = this.config.size;
            for (Player player in this.players) {
              if (player.legs == legsNeededToWin) {
                return player;
              }
            }
            break;
          case GameMode.BEST_OF:
            legsNeededToWin = (this.config.size / 2).round();
            for (Player player in this.players) {
              if (player.legs == legsNeededToWin) {
                return player;
              }
            }
            break;
        }
        break;
      case GameType.SETS:
        int setsNeededToWin;
        switch (this.config.mode) {
          case GameMode.FIRST_TO:
            setsNeededToWin = this.config.size;
            for (Player player in this.players) {
              if (player.sets == setsNeededToWin) {
                return player;
              }
            }
            break;
          case GameMode.BEST_OF:
            setsNeededToWin = (this.config.size / 2).round();
            for (Player player in this.players) {
              if (player.sets == setsNeededToWin) {
                return player;
              }
            }
            break;
        }
        break;
    }
    return null;
  }

  void _createSet() {
    if (this.config.mode == GameMode.FIRST_TO) {
      if (this.config.type == GameType.LEGS) {
        this.sets.add(new Set(turnIndex, this.config.size));
      } else {
        this.sets.add(new Set(turnIndex, 3));
      }
    } else {
      if (config.type == GameType.LEGS) {
        this.sets.add(new Set(turnIndex, (this.config.size / 2).round()));
      } else {
        this.sets.add(new Set(turnIndex, 3));
      }
    }
  }

  void _createLeg() {
    this._currentSet.legs.add(new Leg(
        this.turnIndex, this.players.length, this.config.startingPoints));
  }

  void _initPlayers() {
    int index = 1;
    for (Player player in this.players) {
      if (player.name == "") {
        player.name = "Player ${index}";
        index++;
      }
      player.isNext = false;
      player.lastThrow = -1;
      player.pointsLeft = this.config.startingPoints;
      player.dartsThrown = 0;
      if (this.config.type == GameType.SETS) {
        player.sets = 0;
      } else {
        player.sets = -1;
      }
      player.legs = 0;
      player.average = "0.00";
      player.checkoutPercentage = "0.00";
    }
    this.players[turnIndex].isNext = true;
  }

  Player get owner {
    return players[0];
  }

  @override
  String toString() {
    return 'Game{config: $config, status: $status, players: $players, sets: $sets, turnIndex: $turnIndex}';
  }


  @override
  bool operator ==(other) {
    var o = other as Game;
    return config == o.config &&
        ListEquality().equals(players, o.players) &&
        ListEquality().equals(sets, o.sets) &&
        turnIndex == o.turnIndex;
  }
}
