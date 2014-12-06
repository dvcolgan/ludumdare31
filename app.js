(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = {
  SCREEN_WIDTH: 960,
  SCREEN_HEIGHT: 540,
  DEBUG: false
};



},{}],2:[function(require,module,exports){
var EnemySpawner,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = EnemySpawner = (function() {
  function EnemySpawner(enemyFactory, framerate, difficulty) {
    this.enemyFactory = enemyFactory;
    this.framerate = framerate;
    this.maybeCreateNewEnemy = __bind(this.maybeCreateNewEnemy, this);
    this.update = __bind(this.update, this);
    this.changeDifficulty = __bind(this.changeDifficulty, this);
    this.changeDifficulty(difficulty);
  }

  EnemySpawner.prototype.changeDifficulty = function(difficulty) {
    return this.frameProbability = 1 / this.framerate * difficulty;
  };

  EnemySpawner.prototype.update = function() {
    return this.maybeCreateNewEnemy();
  };

  EnemySpawner.prototype.maybeCreateNewEnemy = function() {
    if (Math.random() < this.frameProbability) {
      return this.enemyFactory.createMedium();
    }
  };

  return EnemySpawner;

})();



},{}],3:[function(require,module,exports){
var Enemy, EnemyFactory, G,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Enemy = (function(_super) {
  __extends(Enemy, _super);

  function Enemy(game, x, y, key) {
    this.update = __bind(this.update, this);
    Enemy.__super__.constructor.call(this, game, x, y, key);
    game.add.existing(this);
  }

  Enemy.prototype.update = function() {};

  return Enemy;

})(Phaser.Sprite);

module.exports = EnemyFactory = (function() {
  function EnemyFactory(game) {
    this.game = game;
    this.createLarge = __bind(this.createLarge, this);
    this.createMedium = __bind(this.createMedium, this);
    this.createSmall = __bind(this.createSmall, this);
    this.getY = __bind(this.getY, this);
    this.preload = __bind(this.preload, this);
  }

  EnemyFactory.prototype.preload = function() {
    this.game.load.image('enemy-small', 'assets/enemy-small.png');
    this.game.load.image('enemy-medium', 'assets/enemy-medium.png');
    return this.game.load.image('enemy-large', 'assets/enemy-large.png');
  };

  EnemyFactory.prototype.getY = function() {
    return this.game.rnd.integerInRange(0, G.SCREEN_HEIGHT);
  };

  EnemyFactory.prototype.createSmall = function() {
    var enemy;
    enemy = new Enemy(this.game, 0, this.getY(), 'enemy-small');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    return enemy;
  };

  EnemyFactory.prototype.createMedium = function() {
    var enemy;
    enemy = new Enemy(this.game, 0, this.getY(), 'enemy-medium');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    return enemy;
  };

  EnemyFactory.prototype.createLarge = function() {
    var enemy;
    enemy = new Enemy(this.game, 0, this.getY(), 'enemy-large');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    return enemy;
  };

  return EnemyFactory;

})();



},{"./constants":1}],4:[function(require,module,exports){
var EnemyFactory, EnemySpawner, G, PlayState, Secret,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

EnemySpawner = require('./enemy-spawner');

EnemyFactory = require('./enemy');

Secret = require('./secret');

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
    this.game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT);
    this.game.camera.x = 0;
    this.groups = {
      enemy: this.game.physics.p2.createCollisionGroup()
    };
    window.controller = this;
    this.background = this.game.add.image(0, 0, 'background');
    this.game.time.advancedTiming = G.DEBUG;
    this.small = this.enemyFactory.createSmall();
    this.medium = this.enemyFactory.createMedium();
    this.large = this.enemyFactory.createLarge();
    this.secret = new Secret(this.game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT / 2);
    this.gameDifficulty = 1;
    return this.enemySpawner = new EnemySpawner(this.enemyFactory, 60, this.gameDifficulty);
  };

  PlayState.prototype.update = function() {
    return this.enemySpawner.update();
  };

  PlayState.prototype.render = function() {
    return this.game.debug.text(this.game.time.fps || '--', 2, 14, "#00ff00");
  };

  return PlayState;

})(Phaser.State);

window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState());



},{"./constants":1,"./enemy":3,"./enemy-spawner":2,"./secret":5}],5:[function(require,module,exports){
var G, Secret,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

module.exports = Secret = (function(_super) {
  __extends(Secret, _super);

  function Secret(game, x, y) {
    Secret.__super__.constructor.call(this, game, x, y, 'secret');
    game.add.existing(this);
    this.anchor.setTo(0.5, 0.5);
    game.physics.p2.enable(this, G.DEBUG);
    this.body.kinematic = true;
    this.body.clearShapes();
    this.body.addCircle(this.width / 2);
  }

  return Secret;

})(Phaser.Sprite);



},{"./constants":1}]},{},[4])