(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = {
  SCREEN_WIDTH: 960,
  SCREEN_HEIGHT: 540,
  DEBUG: false
};



},{}],2:[function(require,module,exports){
var Enemy, EnemyFactory, EnemyLarge, EnemyMedium, EnemySmall, G,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Enemy = (function(_super) {
  __extends(Enemy, _super);

  function Enemy(game, x, y, key) {
    Enemy.__super__.constructor.call(this, game, x, y, key);
  }

  return Enemy;

})(Phaser.Sprite);

Enemy.create = function(game, size, x, y) {
  var sprite;
  sprite = game.add.sprite(x, y, "enemy_" + size);
  sprite.anchor.setTo(0.5, 0.5);
  sprite.body.damping = 100;
  sprite.body.clearShapes();
  sprite.body.loadPolygon("enemy_" + size + "_collision", "enemy_" + size);
  return new Enemy(game, x, y, "something");
};

module.exports = EnemyFactory = (function() {
  function EnemyFactory(game) {
    this.game = game;
  }

  EnemyFactory.prototype.preload = function() {
    this.game.load.image('enemy-small', 'assets/enemy-small.png');
    this.game.load.image('enemy-medium', 'assets/enemy-medium.png');
    return this.game.load.image('enemy-large', 'assets/enemy-large.png');
  };

  return EnemyFactory;

})();

EnemySmall = (function(_super) {
  __extends(EnemySmall, _super);

  function EnemySmall(game, x, y) {
    this.speed = 10;
    EnemySmall.__super__.constructor.call(this, game, x, y, 'enemy-small');
  }

  return EnemySmall;

})(Enemy);

EnemyMedium = (function(_super) {
  __extends(EnemyMedium, _super);

  function EnemyMedium(game, x, y) {
    this.speed = 20;
    EnemyMedium.__super__.constructor.call(this, game, x, y, 'enemy-medium');
  }

  return EnemyMedium;

})(Enemy);

EnemyLarge = (function(_super) {
  __extends(EnemyLarge, _super);

  function EnemyLarge(game, x, y) {
    this.speed = 30;
    EnemyLarge.__super__.constructor.call(this, game, x, y, 'enemy-large');
  }

  return EnemyLarge;

})(Enemy);



},{"./constants":1}],3:[function(require,module,exports){
var EnemyFactory, G, PlayState,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

EnemyFactory = require('./enemy');

PlayState = (function(_super) {
  __extends(PlayState, _super);

  function PlayState() {
    return PlayState.__super__.constructor.apply(this, arguments);
  }

  PlayState.prototype.preload = function() {
    this.game.load.image('background', 'assets/background.png');
    this.game.load.image('secret', 'assets/secret.png');
    this.game.load.image('tower', 'assets/tower.png');
    this.enemyFactory = new EnemyFactory(this.game);
    return this.enemyFactory.preload();
  };

  PlayState.prototype.create = function() {
    this.game.physics.startSystem(Phaser.Physics.P2JS);
    this.game.physics.p2.setImpactEvents(true);
    this.groups = {
      enemy: this.game.physics.p2.createCollisionGroup()
    };
    window.controller = this;
    this.background = this.game.add.image(0, 0, 'background');
    this.game.time.advancedTiming = G.DEBUG;
    return this.small = this.enemyFactory.createSmall(100, 200);
  };

  PlayState.prototype.update = function() {};

  PlayState.prototype.render = function() {
    this.game.debug.text(this.game.time.fps || '--', 2, 14, "#00ff00");
    return this.game.debug.body(this.ship.sprite);
  };

  return PlayState;

})(Phaser.State);

window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState());



},{"./constants":1,"./enemy":2}]},{},[3])