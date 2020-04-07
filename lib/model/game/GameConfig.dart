enum GameMode { BEST_OF, FIRST_TO }

enum GameType { LEGS, SETS }

class GameConfig {
  GameMode mode;
  GameType type;
  int size;
  int startingPoints;
  bool showCheckout;
  bool speechActivated;

  GameConfig() {
    mode = GameMode.FIRST_TO;
    type = GameType.SETS;
    size = 1;
    startingPoints = 501;
    showCheckout = false;
    speechActivated = false;
  }

  GameConfig.fromJson(Map<String, dynamic> json) {
    mode = _modeFromString(json['mode']);
    type = _typeFromString(json['type']);
    size = json['size'];
    startingPoints = json['startingPoints'];
    showCheckout = json['showCheckout'];
    speechActivated = json['speechActivated'];
  }

  GameMode _modeFromString(String json) {
    switch(json) {
      case 'BEST_OF':
        return GameMode.BEST_OF;
      case 'FIRST_TO':
        return GameMode.FIRST_TO;
      default :
        return null;
    }
  }

  GameType _typeFromString(String json) {
    switch(json) {
      case 'LEGS':
        return GameType.LEGS;
      case 'SETS':
        return GameType.SETS;
      default :
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'mode' : mode.toString().replaceAll('GameMode.', ''),
    'type' : type.toString().replaceAll('GameType.', ''),
    'size' : size,
    'startingPoints' : startingPoints,
    'showCheckout' : showCheckout,
    'speechActivated' : speechActivated,
  };

  @override
  String toString() {
    return 'GameConfig{mode: $mode, type: $type, size: $size, startingPoints: $startingPoints, showCheckout: $showCheckout, speechActivated: $speechActivated}';
  }

  @override
  bool operator ==(other) {
    GameConfig o = other as GameConfig;
    return this.mode == o.mode &&
        this.type == o.type &&
        this.size == o.size &&
        this.startingPoints == o.startingPoints &&
        this.showCheckout == o.showCheckout &&
        this.speechActivated == o.speechActivated;
  }
}
