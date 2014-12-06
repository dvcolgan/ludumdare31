(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = {
  SCREEN_WIDTH: 960,
  SCREEN_HEIGHT: 540,
  DEBUG: false
};



},{}],2:[function(require,module,exports){
var DifficultyManager,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = DifficultyManager = (function() {
  function DifficultyManager(enemyFactory, framerate, difficulty) {
    this.enemyFactory = enemyFactory;
    this.framerate = framerate;
    this.maybeCreateNewEnemy = __bind(this.maybeCreateNewEnemy, this);
    this.update = __bind(this.update, this);
    this.changeDifficulty = __bind(this.changeDifficulty, this);
    this.changeDifficulty(difficulty);
  }

  DifficultyManager.prototype.changeDifficulty = function(difficulty) {
    return this.frameProbability = 1 / this.framerate * difficulty;
  };

  DifficultyManager.prototype.update = function() {
    return this.maybeCreateNewEnemy();
  };

  DifficultyManager.prototype.maybeCreateNewEnemy = function() {
    if (Math.random() < this.frameProbability) {
      return this.enemyFactory.createMedium();
    }
  };

  return DifficultyManager;

})();



},{}],3:[function(require,module,exports){
var Enemy, EnemyFactory, G,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Enemy = (function(_super) {
  __extends(Enemy, _super);

  function Enemy(game, x, y, key) {
    Enemy.__super__.constructor.call(this, game, x, y, key);
  }

  Enemy.prototype.update = function() {
    return console.log(x, y);
  };

  return Enemy;

})(Phaser.Sprite);

module.exports = EnemyFactory = (function() {
  function EnemyFactory(game) {
    this.game = game;
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
    enemy = this.game.add.sprite(0, this.getY(), 'enemy-small');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.damping = 100;
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    return enemy;
  };

  EnemyFactory.prototype.createMedium = function() {
    var enemy;
    enemy = this.game.add.sprite(100, this.getY(), 'enemy-medium');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.damping = 100;
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    enemy.body.moveRight(300);
    return enemy;
  };

  EnemyFactory.prototype.createLarge = function() {
    var enemy;
    enemy = new Enemy(this.game, 0, this.getY(), 'enemy-large');
    enemy.anchor.setTo(0.5, 0.5);
    this.game.physics.p2.enable(enemy, G.DEBUG);
    enemy.body.damping = 100;
    enemy.body.clearShapes();
    enemy.body.addCircle(enemy.width / 2);
    return enemy;
  };

  return EnemyFactory;

})();



},{"./constants":1}],4:[function(require,module,exports){
var DifficultyManager, EnemyFactory, G, PlayState,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

DifficultyManager = require('./difficulty-manager');

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
    this.small = this.enemyFactory.createSmall();
    this.medium = this.enemyFactory.createMedium();
    this.large = this.enemyFactory.createLarge();
    return this.difficultyManager = new DifficultyManager(this.enemyFactory, 60, 1);
  };

  PlayState.prototype.update = function() {
    return this.difficultyManager.update();
  };

  PlayState.prototype.render = function() {
    return this.game.debug.text(this.game.time.fps || '--', 2, 14, "#00ff00");
  };

  return PlayState;

})(Phaser.State);

window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState());



},{"./constants":1,"./difficulty-manager":2,"./enemy":3}]},{},[4])