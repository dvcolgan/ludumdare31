(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = {
  SCREEN_WIDTH: 960,
  SCREEN_HEIGHT: 540,
  PHYSICS_BOUNDS_X_MIN: -200,
  PHYSICS_BOUNDS_X_MAX: 1160,
  PHYSICS_BOUNDS_Y_MIN: 64,
  PHYSICS_BOUNDS_Y_MAX: 476,
  events: {
    onGameOver: new Phaser.Signal(),
    onEnemyKilled: new Phaser.Signal(),
    onStoreItemPurchased: new Phaser.Signal(),
    onGoldAmountChanged: new Phaser.Signal(),
    onSecretDamaged: new Phaser.Signal(),
    onTowerPlaced: new Phaser.Signal(),
    onStoreOpen: new Phaser.Signal(),
    onStoreClose: new Phaser.Signal()
  },
  DEBUG: false
};



},{}],2:[function(require,module,exports){
var EnemySpawner,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = EnemySpawner = (function() {
  function EnemySpawner(enemyFactory, framerate, difficulty) {
    this.enemyFactory = enemyFactory;
    this.framerate = framerate;
    this.difficulty = difficulty;
    this.stop = __bind(this.stop, this);
    this.maybeCreateNewEnemy = __bind(this.maybeCreateNewEnemy, this);
    this.update = __bind(this.update, this);
    this.calculateProbability = __bind(this.calculateProbability, this);
    this.calculateProbability();
    this.secondsUntilSpawnRateDoubled = 60;
    this.framesUntilSpawnRateDoubled = this.framerate * this.secondsUntilSpawnRateDoubled;
    this.stopped = false;
  }

  EnemySpawner.prototype.calculateProbability = function() {
    return this.frameProbability = 0.1 / this.framerate * this.difficulty;
  };

  EnemySpawner.prototype.update = function(frame) {
    if (this.stopped) {
      return;
    }
    return this.maybeCreateNewEnemy(frame);
  };

  EnemySpawner.prototype.maybeCreateNewEnemy = function(frame) {
    if (Math.random() < this.frameProbability * (frame / this.framesUntilSpawnRateDoubled + 1)) {
      return this.enemyFactory.createEnemy();
    }
  };

  EnemySpawner.prototype.stop = function() {
    return this.stopped = true;
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

  Enemy.framesUntilGrowthRateDoubled = 60 * 120;

  Enemy.baseRadius = 32;

  Enemy.healthScale = 60;

  Enemy.thrustAmount = 10;

  function Enemy(game, towerGroup, secret, x, y, key, health) {
    this.game = game;
    this.towerGroup = towerGroup;
    this.secret = secret;
    this.damage = __bind(this.damage, this);
    this.setScaleForHealth = __bind(this.setScaleForHealth, this);
    this.updateAnimationDelay = __bind(this.updateAnimationDelay, this);
    this.moveTowardSecret = __bind(this.moveTowardSecret, this);
    this.updateHealth = __bind(this.updateHealth, this);
    this.update = __bind(this.update, this);
    Enemy.__super__.constructor.call(this, this.game, x, y, key);
    this.health = health;
    this.stunDuration = 0;
    this.game.physics.p2.enable(this, G.DEBUG);
    this.anchor.setTo(0.5, 0.69);
    this.setScaleForHealth();
    this.body.clearShapes();
    this.body.addCircle(this.radius);
    this.body.setCollisionGroup(game.collisionGroups.enemy);
    this.body.collides([this.game.collisionGroups.enemy, this.game.collisionGroups.tower, this.game.collisionGroups.secret]);
    this.game.add.existing(this);
    this.animations.add('walk', [0, 1, 2, 3, 4, 5, 6, 7], 10, true);
    this.play('walk');
  }

  Enemy.prototype.update = function() {
    if (!this.alive || this.game.isPaused) {
      return;
    }
    this.updateHealth();
    this.moveTowardSecret(this.secret);
    this.updateAnimationDelay();
    return this.setScaleForHealth();
  };

  Enemy.prototype.updateHealth = function() {
    var speed;
    speed = Phaser.Point.parse(this.body.velocity).getMagnitude();
    return this.health += speed / 9000 * this.game.difficulty * (this.game.frame / Enemy.framesUntilGrowthRateDoubled + 1);
  };

  Enemy.prototype.moveTowardSecret = function(secret) {
    var vector;
    if (this.stunDuration-- > 0) {
      return;
    }
    if (!secret.alive) {
      return;
    }
    vector = Phaser.Point.subtract(this, secret);
    this.body.rotation = vector.angle(new Phaser.Point()) + Math.PI / 2;
    this.body.thrust(Enemy.thrustAmount * (this.game.difficulty / 2 + 0.5));
    return this.body.rotation = 0;
  };

  Enemy.prototype.updateAnimationDelay = function() {
    var delay, magnitude;
    magnitude = Phaser.Point.parse(this.body.velocity).getMagnitude();
    delay = 100 - (magnitude / 2);
    if (delay < 10) {
      delay = 10;
    }
    return this.animations.currentAnim.delay = delay;
  };

  Enemy.prototype.setScaleForHealth = function() {
    this.scale.x = this.health / Enemy.healthScale + 0.2;
    this.scale.y = this.health / Enemy.healthScale + 0.2;
    this.body.clearShapes();
    this.radius = Enemy.baseRadius * this.scale.x;
    this.body.addCircle(this.radius);
    this.body.setCollisionGroup(this.game.collisionGroups.enemy);
    return this.body.collides([this.game.collisionGroups.enemy, this.game.collisionGroups.tower, this.game.collisionGroups.secret]);
  };

  Enemy.prototype.damage = function(damage) {
    Enemy.__super__.damage.call(this, damage);
    this.setScaleForHealth();
    if (this.health <= 0) {
      this.game.sounds.dyingSnowman.play();
      this.game.snowBurster.x = this.body.x;
      this.game.snowBurster.y = this.body.y;
      this.game.snowBurster.start(true, 1500, null, 10);
      return G.events.onEnemyKilled.dispatch(this);
    }
  };

  return Enemy;

})(Phaser.Sprite);

module.exports = EnemyFactory = (function() {
  EnemyFactory.defaultHealth = 10;

  EnemyFactory.defaultRadius = Enemy.baseRadius * (EnemyFactory.defaultHealth / Enemy.healthScale + 0.2);

  function EnemyFactory(game, towerGroup, secret) {
    this.game = game;
    this.towerGroup = towerGroup;
    this.secret = secret;
    this.createEnemy = __bind(this.createEnemy, this);
    this.intersectsWithExistingEnemy = __bind(this.intersectsWithExistingEnemy, this);
    this.getY = __bind(this.getY, this);
    this.getX = __bind(this.getX, this);
  }

  EnemyFactory.prototype.getX = function() {
    return this.game.rnd.integerInRange(-100, 0);
  };

  EnemyFactory.prototype.getY = function() {
    var maxY, minY;
    minY = G.PHYSICS_BOUNDS_Y_MIN + EnemyFactory.defaultRadius + 1;
    maxY = G.PHYSICS_BOUNDS_Y_MAX - EnemyFactory.defaultRadius - 1;
    return this.game.rnd.integerInRange(minY, maxY);
  };

  EnemyFactory.prototype.intersectsWithExistingEnemy = function(x, y, enemyGroup) {
    var intersects;
    intersects = false;
    enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        if (Phaser.Math.distance(enemy.x, enemy.y, x, y) <= enemy.radius + EnemyFactory.defaultRadius + 2) {
          intersects = true;
        }
      };
    })(this));
    return intersects;
  };

  EnemyFactory.prototype.createEnemy = function() {
    var enemy, i, x, y;
    i = 0;
    while (true) {
      x = this.getX();
      y = this.getY();
      if (!this.intersectsWithExistingEnemy(x, y, this.game.groups.enemy) || i++ > 10) {
        break;
      }
    }
    enemy = new Enemy(this.game, this.towerGroup, this.secret, x, y, 'snowman', EnemyFactory.defaultHealth);
    this.game.groups.enemy.add(enemy);
    return enemy;
  };

  return EnemyFactory;

})();



},{"./constants":1}],4:[function(require,module,exports){
var FanAnimation, FanTower, G, Tower,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Tower = require('./tower');

FanAnimation = require('./fan');

module.exports = FanTower = (function(_super) {
  __extends(FanTower, _super);

  function FanTower() {
    this.fire = __bind(this.fire, this);
    return FanTower.__super__.constructor.apply(this, arguments);
  }

  FanTower.properties = {
    cooldown: 120,
    range: 100,
    damage: 10,
    animationCls: FanAnimation,
    drawRangeMarker: false
  };

  FanTower.prototype.fire = function() {
    if (!FanTower.__super__.fire.call(this)) {
      return;
    }
    this.animation.blast();
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dx, dy;
        dx = _this.x - enemy.x;
        dy = _this.y - enemy.y;
        if (Math.abs(dy) < _this.height / 2 && dx >= 0 && dx <= _this.range) {
          enemy.body.moveLeft(_this.range);
          return enemy.damage(_this.damage);
        }
      };
    })(this));
  };

  return FanTower;

})(Tower);



},{"./constants":1,"./fan":5,"./tower":16}],5:[function(require,module,exports){
var Fan,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = Fan = (function() {
  Fan.spriteKey = 'fan';

  function Fan(game, sprite) {
    var x, y;
    this.game = game;
    this.sprite = sprite;
    this.blast = __bind(this.blast, this);
    x = this.sprite.x;
    y = this.sprite.y;
    this.sprite.animations.add('normal', [0, 1, 2, 3], 60, true);
    this.sprite.animations.play('normal');
    this.emitter = this.game.add.emitter(x - 4, y - 5, 20);
    this.emitter.makeParticles('snowflake-particles', [0, 1, 2, 3, 4]);
    this.emitter.width = 6;
    this.emitter.height = this.sprite.height / 2;
    this.emitter.gravity = 10;
    this.emitter.setXSpeed(-200, -100);
    this.emitter.setYSpeed(-10, 10);
    this.emitter.setAlpha(1, 0.0, 1500);
    this.emitter.start(false, 1500, 60);
    this.game.groups.tower.add(this.emitter);
    this.game.sounds.fanActivate.play();
  }

  Fan.prototype.blast = function() {
    return this.game.sounds.fanActivate.play();
  };

  return Fan;

})();



},{}],6:[function(require,module,exports){
var FireAnimation, FireTower, G, Tower,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Tower = require('./tower');

FireAnimation = require('./fire');

module.exports = FireTower = (function(_super) {
  __extends(FireTower, _super);

  function FireTower() {
    this.doConstantEffect = __bind(this.doConstantEffect, this);
    this.fire = __bind(this.fire, this);
    return FireTower.__super__.constructor.apply(this, arguments);
  }

  FireTower.properties = {
    cooldown: 120,
    range: 70,
    damage: 15,
    animationCls: FireAnimation,
    framesToDoOccasionalDamage: 120,
    drawRangeMarker: true
  };

  FireTower.prototype.fire = function() {
    if (!FireTower.__super__.fire.call(this)) {
      return;
    }
    this.animation.blast();
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dist;
        dist = Phaser.Math.distance(enemy.x, enemy.y, _this.x, _this.y);
        if (dist < enemy.radius / 2 + _this.range) {
          return enemy.damage(_this.damage);
        }
      };
    })(this));
  };

  FireTower.prototype.doConstantEffect = function() {
    if (!FireTower.__super__.doConstantEffect.call(this)) {
      return;
    }
    if (this.game.frame % FireTower.properties.framesToDoOccasionalDamage !== 0) {
      return;
    }
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dist;
        dist = Phaser.Math.distance(enemy.x, enemy.y, _this.x, _this.y);
        if (dist < enemy.radius / 2 + _this.range) {
          return enemy.damage(1);
        }
      };
    })(this));
  };

  return FireTower;

})(Tower);



},{"./constants":1,"./fire":7,"./tower":16}],7:[function(require,module,exports){
var Fire,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = Fire = (function() {
  Fire.spriteKey = 'firewood';

  function Fire(game, sprite) {
    var x, y;
    this.game = game;
    this.sprite = sprite;
    this.blast = __bind(this.blast, this);
    x = this.sprite.x;
    y = this.sprite.y;
    this.flames = this.game.add.sprite(x, y + 5, 'flames');
    this.flames.animations.add('burn', [0, 1, 2, 3, 4], 10, true);
    this.flames.animations.play('burn');
    this.flames.anchor.setTo(0.5, 0.91);
    this.flames.scale.setTo(0.8);
    this.game.groups.tower.add(this.flames);
    this.game.sounds.fireActivate.play();
  }

  Fire.prototype.blast = function() {
    this.game.sounds.fireActivate.play();
    return this.game.add.tween(this.flames.scale).to({
      x: 1.5,
      y: 2
    }, 500, Phaser.Easing.Circular.Out).to({
      x: 1,
      y: 1
    }, 600, Phaser.Easing.Circular.In).start();
  };

  return Fire;

})();



},{}],8:[function(require,module,exports){
var BootState, EnemyFactory, EnemySpawner, Fan, FanTower, Fire, FireTower, G, HowToPlayState, LoseOverlay, PlayState, PreloadState, RockManager, SaltPatch, SaltTower, Secret, Stats, Store, TitleState, WeatherGenerator,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

RockManager = require('./rock-manager');

EnemySpawner = require('./enemy-spawner');

EnemyFactory = require('./enemy');

FireTower = require('./fire-tower');

FanTower = require('./fan-tower');

SaltTower = require('./salt-tower');

LoseOverlay = require('./lose-overlay');

Store = require('./store');

Secret = require('./secret');

Stats = require('./stats');

Fire = require('./fire');

Fan = require('./fan');

SaltPatch = require('./salt-patch');

WeatherGenerator = require('./weather-generator');

BootState = (function() {
  function BootState() {}

  BootState.prototype.preload = function() {
    return this.load.image('loading-bar', 'assets/loading-bar.png');
  };

  BootState.prototype.create = function() {
    return this.game.state.start('Preload');
  };

  return BootState;

})();

PreloadState = (function() {
  function PreloadState() {
    this.initializeMusic = __bind(this.initializeMusic, this);
  }

  PreloadState.prototype.preload = function() {
    this.game.stage.backgroundColor = 'black';
    this.loadingBar = this.game.add.sprite(G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT / 2, 'loading-bar');
    this.loadingBar.anchor.setTo(0.5);
    this.game.load.setPreloadSprite(this.loadingBar);
    this.game.load.image('background', 'assets/background.png');
    this.game.load.image('secret', 'assets/secret.png');
    this.game.load.image('tower', 'assets/tower.png');
    this.game.load.image('title-screen', 'assets/title-screen.png');
    this.game.load.image('how-to-play', 'assets/how-to-play.png');
    this.game.load.image('lose-overlay', 'assets/lose-overlay.png');
    this.game.load.image('store-overlay', 'assets/store-overlay.png');
    this.game.load.image('store-slot', 'assets/store-slot.png');
    this.game.load.image('firewood', 'assets/firewood.png');
    this.game.load.image('fire-particle', 'assets/fire-particle.png');
    this.game.load.image('fire-store-icon', 'assets/fire-store-icon.png');
    this.game.load.spritesheet('flames', 'assets/flames.png', 64, 82, 5);
    this.game.load.spritesheet('fan', 'assets/fan.png', 64, 64, 4);
    this.game.load.spritesheet('snow-particles', 'assets/snow-particles.png', 4, 4, 4);
    this.game.load.spritesheet('snowflake-particles', 'assets/snowflake-particles.png', 16, 16, 5);
    this.game.load.spritesheet('cooldown', 'assets/cooldown.png', 96, 96, 13);
    this.game.load.image('salt-patch', 'assets/salt-patch.png', 64, 64);
    this.game.load.image('salt-particle', 'assets/salt-particle.png');
    this.game.load.spritesheet('snowman', 'assets/snowman.png', 94, 101, 8);
    this.game.load.audio('play-bgm', 'assets/happybgm.ogg');
    this.game.load.audio('gameover-bgm', 'assets/gameoverbgm.ogg');
    this.game.load.spritesheet('rocks', 'assets/rocks.png', 48, 32, 3);
    this.game.load.audio('snow-hit1', 'assets/snow-hit1.ogg');
    this.game.load.audio('snow-hit2', 'assets/snow-hit2.ogg');
    this.game.load.audio('click', 'assets/click.ogg');
    this.game.load.audio('dying-snowman', 'assets/dying-snowman.ogg');
    this.game.load.audio('fan-activate', 'assets/fan-activate.ogg');
    this.game.load.audio('fire-activate', 'assets/fire-activate.ogg');
    this.game.load.audio('item-buy', 'assets/item-buy.ogg');
    this.game.load.audio('nuke-explosion', 'assets/nuke-explosion.ogg');
    this.game.load.audio('open-store', 'assets/open-store.ogg');
    this.game.load.audio('rock-woosh', 'assets/rock-woosh.ogg');
    this.game.load.image('music-on', 'assets/speaker-on.png');
    this.game.load.image('music-off', 'assets/speaker-off.png');
    this.game.load.bitmapFont('font', 'assets/font.png', 'assets/font.fnt');
    this.game.load.image('fire-upgrade', 'assets/fire-upgrade.png');
    this.game.load.image('salt-upgrade', 'assets/salt-upgrade.png');
    this.game.load.image('fan-upgrade', 'assets/fan-upgrade.png');
    this.game.load.image('secret-heal', 'assets/secret-heal.png');
    this.game.load.image('mini-nuke', 'assets/mini-nuke.png');
    this.game.load.image('nuke-blast', 'assets/nuke-blast.png');
    this.game.load.spritesheet('button', 'assets/button.png', 150, 48, 3);
    return this.initializeMusic();
  };

  PreloadState.prototype.create = function() {
    return this.game.state.start('Title');
  };

  PreloadState.prototype.initializeMusic = function() {
    this.game.music = this.game.add.audio('play-bgm', 0.2);
    this.game.music.loop = true;
    return this.game.music.play();
  };

  return PreloadState;

})();

TitleState = (function() {
  function TitleState() {}

  TitleState.prototype.create = function() {
    var continueText, titleImage, titleText;
    titleText = this.game.add.bitmapText(0, 0, 'font', 'Snowman Attack', 100);
    titleText.x = G.SCREEN_WIDTH / 2 - titleText.width / 2;
    titleText.y = 20;
    titleImage = this.game.add.sprite(G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT - 60, 'title-screen');
    titleImage.anchor.set(0.5, 1);
    continueText = this.game.add.text(G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT - 20, "Tap/Click to Continue", {
      font: "Bold 16px Droid Sans",
      fill: "white"
    });
    continueText.anchor.setTo(0.5, 1);
    return this.game.input.onDown.add((function(_this) {
      return function() {
        return _this.game.state.start('HowToPlay');
      };
    })(this));
  };

  return TitleState;

})();

HowToPlayState = (function() {
  function HowToPlayState() {
    this.startGame = __bind(this.startGame, this);
    this.startHard = __bind(this.startHard, this);
    this.startMedium = __bind(this.startMedium, this);
    this.startEasy = __bind(this.startEasy, this);
  }

  HowToPlayState.prototype.create = function() {
    var button, buttons, i, overlay, _i, _len;
    overlay = this.game.add.sprite(0, 0, 'how-to-play');
    this.clickSound = this.game.add.audio('click');
    buttons = [];
    buttons.push(this.game.add.button(0, 0, 'button', this.startEasy, this, 1, 0, 2));
    buttons.push(this.game.add.button(0, 0, 'button', this.startMedium, this, 1, 0, 2));
    buttons.push(this.game.add.button(0, 0, 'button', this.startHard, this, 1, 0, 2));
    for (i = _i = 0, _len = buttons.length; _i < _len; i = ++_i) {
      button = buttons[i];
      button.text = this.game.add.text(button.width / 2, button.height / 2, '', {
        font: '20px Droid Sans',
        fill: 'white'
      });
      button.text.anchor.setTo(0.5);
      button.addChild(button.text);
      button.x = 20 + (i * 200);
      button.y = overlay.height - 150 + overlay.y + 10;
      overlay.addChild(button);
    }
    buttons[0].text.text = 'Easy';
    buttons[1].text.text = 'Medium';
    return buttons[2].text.text = 'Hard';
  };

  HowToPlayState.prototype.startEasy = function() {
    this.game.difficulty = 1;
    return this.startGame();
  };

  HowToPlayState.prototype.startMedium = function() {
    this.game.difficulty = 2;
    return this.startGame();
  };

  HowToPlayState.prototype.startHard = function() {
    this.game.difficulty = 3;
    return this.startGame();
  };

  HowToPlayState.prototype.startGame = function() {
    this.clickSound.play();
    return this.game.state.start('Play');
  };

  return HowToPlayState;

})();

PlayState = (function(_super) {
  __extends(PlayState, _super);

  function PlayState() {
    this.resumeGame = __bind(this.resumeGame, this);
    this.pauseGame = __bind(this.pauseGame, this);
    this.render = __bind(this.render, this);
    this.update = __bind(this.update, this);
    this.handleStoreItemPurchased = __bind(this.handleStoreItemPurchased, this);
    this.handleGameOver = __bind(this.handleGameOver, this);
    this.handlePointerDownOnBackground = __bind(this.handlePointerDownOnBackground, this);
    this.initializeSecret = __bind(this.initializeSecret, this);
    this.initializeEnemySpawner = __bind(this.initializeEnemySpawner, this);
    this.initializeBackground = __bind(this.initializeBackground, this);
    this.initializeGroups = __bind(this.initializeGroups, this);
    this.initializePhysicsEngine = __bind(this.initializePhysicsEngine, this);
    this.initializeGame = __bind(this.initializeGame, this);
    this.create = __bind(this.create, this);
    this.initializeSnowExplosion = __bind(this.initializeSnowExplosion, this);
    this.initializeMusic = __bind(this.initializeMusic, this);
    this.initializeSoundEffects = __bind(this.initializeSoundEffects, this);
    return PlayState.__super__.constructor.apply(this, arguments);
  }

  PlayState.prototype.initializeSoundEffects = function() {
    return this.game.sounds = {
      snowHit1: this.game.add.audio('snow-hit1'),
      snowHit2: this.game.add.audio('snow-hit2'),
      click: this.game.add.audio('click'),
      dyingSnowman: this.game.add.audio('dying-snowman'),
      fanActivate: this.game.add.audio('fan-activate'),
      fireActivate: this.game.add.audio('fire-activate'),
      itemBuy: this.game.add.audio('item-buy'),
      nukeExplosion: this.game.add.audio('nuke-explosion'),
      openStore: this.game.add.audio('open-store'),
      rockWoosh: this.game.add.audio('rock-woosh')
    };
  };

  PlayState.prototype.initializeMusic = function() {
    var pauseBtn, resumeBtn;
    pauseBtn = this.game.add.sprite(G.SCREEN_WIDTH, 0, 'music-on');
    pauseBtn.anchor.setTo(1, 0);
    pauseBtn.inputEnabled = true;
    pauseBtn.events.onInputDown.add((function(_this) {
      return function() {
        _this.game.music.pause();
        resumeBtn.visible = true;
        return pauseBtn.visible = false;
      };
    })(this));
    resumeBtn = this.game.add.sprite(G.SCREEN_WIDTH, 0, 'music-off');
    resumeBtn.anchor.setTo(1, 0);
    resumeBtn.visible = false;
    resumeBtn.inputEnabled = true;
    return resumeBtn.events.onInputDown.add((function(_this) {
      return function() {
        _this.game.music.play();
        resumeBtn.visible = false;
        return pauseBtn.visible = true;
      };
    })(this));
  };

  PlayState.prototype.initializeSnowExplosion = function() {};

  PlayState.prototype.create = function() {
    this.initializeGame();
    this.initializePhysicsEngine();
    this.initializeGroups();
    this.initializeSoundEffects();
    this.initializeMusic();
    this.game.physics.p2.updateBoundsCollisionGroup();
    this.stats = new Stats(this.game);
    this.store = new Store(this.game, this.stats);
    this.rockManager = new RockManager(this.game);
    this.initializeBackground();
    this.initializeSecret();
    this.loseOverlay = new LoseOverlay(this.game);
    this.initializeEnemySpawner();
    this.weatherGenerator = new WeatherGenerator(this.game);
    this.game.snowBurster = this.game.add.emitter(0, 0, 100);
    this.game.snowBurster.makeParticles('snowflake-particles', [0, 1, 2, 3, 4]);
    this.game.snowBurster.gravity = 10;
    this.game.snowBurster.setXSpeed(-100, 100);
    this.game.snowBurster.setYSpeed(-80, 80);
    this.game.snowBurster.setAlpha(1, 0.0, 1500);
    this.game.groups.overlay.add(this.game.snowBurster);
    G.events.onGameOver.add(this.handleGameOver);
    G.events.onStoreItemPurchased.add(this.handleStoreItemPurchased);
    G.events.onStoreOpen.add(this.pauseGame);
    G.events.onStoreClose.add(this.resumeGame);
    this.game.frame = 0;
    return this.game.isPaused = false;
  };

  PlayState.prototype.initializeGame = function() {
    this.game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT);
    this.game.camera.x = 0;
    this.game.time.advancedTiming = G.DEBUG;
    window.controller = this;
    this.boughtItem = null;
    return this.cursorSprite = null;
  };

  PlayState.prototype.initializePhysicsEngine = function() {
    this.game.physics.startSystem(Phaser.Physics.P2JS);
    this.game.physics.p2.setImpactEvents(true);
    return this.game.physics.p2.setBounds(G.PHYSICS_BOUNDS_X_MIN, G.PHYSICS_BOUNDS_Y_MIN, G.PHYSICS_BOUNDS_X_MAX, G.PHYSICS_BOUNDS_Y_MAX);
  };

  PlayState.prototype.initializeGroups = function() {
    this.game.groups = {};
    this.game.groups.background = this.game.add.group();
    this.game.groups.tower = this.game.add.group();
    this.game.groups.enemy = this.game.add.group();
    this.game.groups.secret = this.game.add.group();
    this.game.groups.overlay = this.game.add.group();
    this.game.groups.foreground = this.game.add.group();
    return this.game.collisionGroups = {
      secret: this.game.physics.p2.createCollisionGroup(),
      tower: this.game.physics.p2.createCollisionGroup(),
      enemy: this.game.physics.p2.createCollisionGroup()
    };
  };

  PlayState.prototype.initializeBackground = function() {
    this.background = this.game.add.image(0, 0, 'background');
    this.background.inputEnabled = true;
    this.background.events.onInputDown.add(this.handlePointerDownOnBackground);
    return this.game.groups.background.add(this.background);
  };

  PlayState.prototype.initializeEnemySpawner = function() {
    var enemyFactory;
    enemyFactory = new EnemyFactory(this.game, this.game.groups.tower, this.secret);
    return this.enemySpawner = new EnemySpawner(enemyFactory, 60, this.game.difficulty);
  };

  PlayState.prototype.initializeSecret = function() {
    return this.secret = new Secret(this.game, G.SCREEN_WIDTH - 50, G.SCREEN_HEIGHT / 2);
  };

  PlayState.prototype.handlePointerDownOnBackground = function(image, pointer) {
    var tower;
    if (this.boughtItem) {
      tower = new this.boughtItem["class"](this.game, pointer.x, pointer.y);
      this.boughtItem = null;
      this.cursorSprite.destroy();
      return G.events.onTowerPlaced.dispatch(tower);
    } else {
      return this.rockManager.throwRock(pointer.x, pointer.y);
    }
  };

  PlayState.prototype.handleGameOver = function() {
    this.enemySpawner.stop();
    this.rockManager.stop();
    return this.loseOverlay.show(this.stats.score, this.stats.enemiesKilled);
  };

  PlayState.prototype.handleStoreItemPurchased = function(itemData) {
    var arg, args, _i, _len, _ref;
    this.boughtItem = itemData;
    if (this.boughtItem.placeable) {
      this.cursorSprite = this.game.add.sprite(this.game.input.x, this.game.input.y, itemData.imageKey);
      this.game.groups.overlay.add(this.cursorSprite);
      this.cursorSprite.anchor.setTo(0.5, 0.5);
      this.cursorSprite.alpha = 0.5;
      return this.cursorSprite.update = (function(_this) {
        return function() {
          _this.cursorSprite.x = _this.game.input.x;
          return _this.cursorSprite.y = _this.game.input.y;
        };
      })(this);
    } else {
      args = [];
      _ref = this.boughtItem.requires;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        arg = _ref[_i];
        args.push(this[arg]);
      }
      this.boughtItem.createFn.apply(this, args);
      return this.boughtItem = null;
    }
  };

  PlayState.prototype.update = function() {
    if (this.game.isPaused) {
      return;
    }
    this.game.frame++;
    this.enemySpawner.update(this.game.frame);
    this.rockManager.update(this.game.frame);
    if (this.game.frame % 10 === 0) {
      this.game.groups.enemy.sort('y', Phaser.Group.SORT_ASCENDING);
      return this.game.groups.tower.sort('y', Phaser.Group.SORT_ASCENDING);
    }
  };

  PlayState.prototype.render = function() {
    if (G.DEBUG) {
      return this.game.debug.text(this.game.time.fps || '--', 2, 14, "#00ff00");
    }
  };

  PlayState.prototype.pauseGame = function() {
    this.game.isPaused = true;
    return this.game.physics.p2.pause();
  };

  PlayState.prototype.resumeGame = function() {
    this.game.isPaused = false;
    return this.game.physics.p2.resume();
  };

  return PlayState;

})(Phaser.State);

window.game = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container');

window.game.state.add('Boot', BootState);

window.game.state.add('Preload', PreloadState);

window.game.state.add('Title', TitleState);

window.game.state.add('HowToPlay', HowToPlayState);

window.game.state.add('Play', PlayState);

window.game.state.start('Boot');



},{"./constants":1,"./enemy":3,"./enemy-spawner":2,"./fan":5,"./fan-tower":4,"./fire":7,"./fire-tower":6,"./lose-overlay":9,"./rock-manager":10,"./salt-patch":11,"./salt-tower":12,"./secret":13,"./stats":14,"./store":15,"./weather-generator":17}],9:[function(require,module,exports){
var G, LoseOverlay;

G = require('./constants');

module.exports = LoseOverlay = (function() {
  function LoseOverlay(game) {
    var button, gameOverText, restartText;
    this.game = game;
    this.sprite = this.game.add.sprite(0, 0, 'lose-overlay');
    this.game.groups.overlay.add(this.sprite);
    gameOverText = this.game.add.bitmapText(0, 0, 'font', 'Game Over', 80);
    gameOverText.x = G.SCREEN_WIDTH / 2 - gameOverText.width / 2;
    gameOverText.y = 100;
    this.sprite.addChild(gameOverText);
    this.text = this.game.add.text(200, 250, '', {
      font: 'bold 40px Droid Sans',
      fill: 'black',
      align: 'left'
    });
    button = this.game.add.button(this.sprite.width / 2, this.sprite.height - 110, 'button', ((function(_this) {
      return function() {
        _this.game.state.start('HowToPlay');
        return _this.game.sounds.click.play();
      };
    })(this)), this, 1, 0, 2);
    button.anchor.set(0.5);
    this.sprite.addChild(button);
    restartText = this.game.add.text(0, 0, 'Restart', {
      font: 'bold 20px Droid Sans',
      fill: 'black'
    });
    restartText.anchor.set(0.5);
    button.addChild(restartText);
    this.hide();
  }

  LoseOverlay.prototype.show = function(score, enemiesKilled) {
    this.sprite.visible = true;
    this.text.text = "Your score: " + score + "\nSnowmen killed: " + enemiesKilled;
    return this.text.visible = true;
  };

  LoseOverlay.prototype.hide = function() {
    this.sprite.visible = false;
    return this.text.visible = false;
  };

  LoseOverlay.prototype.isVisible = function() {
    return this.sprite.visible;
  };

  return LoseOverlay;

})();



},{"./constants":1}],10:[function(require,module,exports){
var G, RockManager,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

G = require('./constants');

module.exports = RockManager = (function() {
  RockManager.properties = {
    maxDamage: 20,
    range: 50,
    framesToRegenerateRock: 60
  };

  function RockManager(game) {
    var i, rock, _i, _ref;
    this.game = game;
    this.makeRandomRock = __bind(this.makeRandomRock, this);
    this.stop = __bind(this.stop, this);
    this.regenerateRock = __bind(this.regenerateRock, this);
    this.update = __bind(this.update, this);
    this.throwRock = __bind(this.throwRock, this);
    this.maxRocks = 3;
    this.stopped = false;
    this.availableRocks = this.maxRocks;
    this.rocks = [];
    for (i = _i = 0, _ref = this.availableRocks; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      rock = this.makeRandomRock(700 + 70 * i, 30);
      this.rocks.push(rock);
    }
  }

  RockManager.prototype.throwRock = function(x, y) {
    var damageEnemies, rock, tweenX, tweenY;
    if (!this.availableRocks || this.stopped) {
      return;
    }
    this.game.sounds.rockWoosh.play();
    this.rocks[this.availableRocks - 1].visible = false;
    damageEnemies = (function(_this) {
      return function() {
        _this.game.snowBurster.x = x;
        _this.game.snowBurster.y = y;
        _this.game.snowBurster.start(true, 1500, null, 10);
        _this.game.sounds['snowHit' + _this.game.rnd.integerInRange(1, 2)].play();
        return _this.game.groups.enemy.forEachAlive(function(enemy) {
          var damage, dist;
          dist = Phaser.Math.distance(enemy.x, enemy.y, x, y);
          if (dist < RockManager.properties.range) {
            damage = Phaser.Math.linear(RockManager.properties.maxDamage, 0, dist / RockManager.properties.range);
            return enemy.damage(damage);
          }
        });
      };
    })(this);
    rock = this.makeRandomRock(-40, -40);
    this.game.groups.foreground.add(rock);
    tweenX = this.game.add.tween(rock);
    tweenX.to({
      x: x
    }, 500, Phaser.Easing.Linear.In);
    tweenX.start();
    tweenY = this.game.add.tween(rock);
    tweenY.to({
      y: y
    }, 500, Phaser.Easing.Cubic.In);
    tweenY.onComplete.add(damageEnemies);
    tweenY.onComplete.add((function(_this) {
      return function() {
        return _this.game.add.tween(rock).to({
          alpha: 0
        }, 1000, Phaser.Easing.Linear.In).start();
      };
    })(this));
    tweenY.start();
    return this.availableRocks--;
  };

  RockManager.prototype.update = function(frame) {
    if (this.availableRocks < this.maxRocks && frame % RockManager.properties.framesToRegenerateRock === 0) {
      return this.regenerateRock();
    }
  };

  RockManager.prototype.regenerateRock = function() {
    if (this.stopped) {
      return;
    }
    this.rocks[this.availableRocks].visible = true;
    return this.availableRocks++;
  };

  RockManager.prototype.stop = function() {
    return this.stopped = true;
  };

  RockManager.prototype.makeRandomRock = function(x, y) {
    var rock;
    rock = this.game.add.sprite(x, y, 'rocks');
    rock.anchor.setTo(0.5, 0.5);
    rock.animations.add('rock', [0, 1, 2], 0);
    rock.animations.play('rock');
    rock.animations.stop('rock');
    rock.animations.frame = this.game.rnd.integerInRange(0, 2);
    return rock;
  };

  return RockManager;

})();



},{"./constants":1}],11:[function(require,module,exports){
var SaltPatch,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = SaltPatch = (function() {
  SaltPatch.spriteKey = 'salt-patch';

  function SaltPatch(game, sprite) {
    var x, y;
    this.game = game;
    this.sprite = sprite;
    this.blast = __bind(this.blast, this);
    x = this.sprite.x;
    y = this.sprite.y;
    this.sprite.animations.add('normal', [0, 1, 2, 3], 60, true);
    this.sprite.animations.play('normal');
  }

  SaltPatch.prototype.blast = function() {};

  return SaltPatch;

})();



},{}],12:[function(require,module,exports){
var G, SaltAnimation, SaltTower, Tower,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Tower = require('./tower');

SaltAnimation = require('./salt-patch');

module.exports = SaltTower = (function(_super) {
  __extends(SaltTower, _super);

  function SaltTower() {
    this.doConstantEffect = __bind(this.doConstantEffect, this);
    this.fire = __bind(this.fire, this);
    return SaltTower.__super__.constructor.apply(this, arguments);
  }

  SaltTower.properties = {
    cooldown: 120,
    range: 50,
    damage: 1,
    animationCls: SaltAnimation,
    framesToDoOccasionalDamage: 60,
    maxEnemySpeed: 20,
    stunDuration: 30,
    drawRangeMarker: true
  };

  SaltTower.prototype.fire = function() {
    if (!SaltTower.__super__.fire.call(this)) {
      return;
    }
    this.animation.blast();
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dist;
        dist = Phaser.Math.distance(enemy.x, enemy.y, _this.x, _this.y);
        if (dist < enemy.radius / 2 + _this.range) {
          enemy.body.setZeroVelocity();
          return enemy.stunDuration = SaltTower.properties.stunDuration;
        }
      };
    })(this));
  };

  SaltTower.prototype.doConstantEffect = function() {
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dist, magnitude, vector;
        dist = Phaser.Math.distance(enemy.x, enemy.y, _this.x, _this.y);
        if (dist < enemy.radius + _this.width / 2) {
          vector = new Phaser.Point(enemy.body.velocity.x, enemy.body.velocity.y);
          magnitude = vector.getMagnitude();
          if (magnitude > SaltTower.properties.maxEnemySpeed) {
            vector.setMagnitude(SaltTower.properties.maxEnemySpeed);
            enemy.body.velocity.x = vector.x;
            enemy.body.velocity.y = vector.y;
          }
          if (_this.game.frame % SaltTower.properties.framesToDoOccasionalDamage === 0) {
            return enemy.damage(_this.damage);
          }
        }
      };
    })(this));
  };

  return SaltTower;

})(Tower);



},{"./constants":1,"./salt-patch":11,"./tower":16}],13:[function(require,module,exports){
var G, Secret,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

module.exports = Secret = (function(_super) {
  __extends(Secret, _super);

  Secret.properties = {
    maxHealth: 100,
    damageDistance: 10
  };

  function Secret(game, x, y) {
    this.game = game;
    this.update = __bind(this.update, this);
    this.damage = __bind(this.damage, this);
    this.restoreMaxHealth = __bind(this.restoreMaxHealth, this);
    this.makeHealthMeter = __bind(this.makeHealthMeter, this);
    Secret.__super__.constructor.call(this, this.game, x, y, 'secret');
    this.game.add.existing(this);
    this.game.groups.secret.add(this);
    this.anchor.setTo(0.5);
    this.game.physics.p2.enable(this, G.DEBUG);
    this.body.kinematic = true;
    this.body.clearShapes();
    this.body.addCircle(this.width / 2);
    this.body.setCollisionGroup(this.game.collisionGroups.secret);
    this.body.collides([this.game.collisionGroups.enemy]);
    this.enemyGroup = this.game.groups.enemy;
    this.health = Secret.properties.maxHealth;
    this.healthMeterData = this.game.add.bitmapData(96, 16);
    this.healthMeter = this.game.add.sprite(this.x, this.y - 40, this.healthMeterData);
    this.healthMeter.anchor.setTo(0.5);
    this.game.groups.secret.add(this.healthMeter);
    this.makeHealthMeter();
  }

  Secret.prototype.makeHealthMeter = function() {
    var amount, color;
    this.healthMeterData.cls();
    amount = (this.health / Secret.properties.maxHealth) * this.healthMeterData.width;
    color = amount > 32 ? '#00ff00' : amount > 16 ? '#ffff00' : '#ff0000';
    this.healthMeterData.rect(0, 0, this.healthMeterData.width, this.healthMeterData.height, 'black');
    this.healthMeterData.rect(2, 2, amount - 4, this.healthMeterData.height - 4, color);
    return this.healthMeterData.render();
  };

  Secret.prototype.restoreMaxHealth = function() {
    this.damage(this.health - Secret.properties.maxHealth);
    return this.makeHealthMeter();
  };

  Secret.prototype.damage = function(damage) {
    Secret.__super__.damage.call(this, damage);
    this.makeHealthMeter();
    if (this.health <= 0) {
      return G.events.onGameOver.dispatch();
    }
  };

  Secret.prototype.update = function() {
    if (!this.alive || this.game.isPaused) {
      return;
    }
    if (this.game.frame % 10 !== 0) {
      return;
    }
    return this.enemyGroup.forEachAlive((function(_this) {
      return function(enemy) {
        var dist;
        dist = Phaser.Math.distance(enemy.x, enemy.y, _this.x, _this.y);
        if (dist < enemy.radius + _this.width / 2 + Secret.properties.damageDistance) {
          enemy.damage(1);
          _this.damage(1);
          return G.events.onSecretDamaged.dispatch(-1);
        }
      };
    })(this));
  };

  return Secret;

})(Phaser.Sprite);



},{"./constants":1}],14:[function(require,module,exports){
var G, Stats,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

G = require('./constants');

module.exports = Stats = (function() {
  function Stats(game) {
    this.game = game;
    this.updateText = __bind(this.updateText, this);
    this.incrementScore = __bind(this.incrementScore, this);
    this.handleEnemyKilled = __bind(this.handleEnemyKilled, this);
    this.score = 0;
    this.gold = 500;
    this.enemiesKilled = 0;
    this.text = this.game.add.text(20, 20, '', {
      font: '20px Droid Sans',
      fill: 'black',
      align: 'left'
    });
    this.updateText();
    G.events.onEnemyKilled.add(this.handleEnemyKilled);
    G.events.onSecretDamaged.add((function(_this) {
      return function() {
        return _this.incrementScore(1);
      };
    })(this));
    G.events.onTowerPlaced.add((function(_this) {
      return function() {
        return _this.incrementScore(20);
      };
    })(this));
  }

  Stats.prototype.addGold = function(amount) {
    this.gold += amount;
    this.updateText();
    return G.events.onGoldAmountChanged.dispatch(this.gold);
  };

  Stats.prototype.subtractGold = function(amount) {
    this.gold -= amount;
    this.updateText();
    return G.events.onGoldAmountChanged.dispatch(this.gold);
  };

  Stats.prototype.handleEnemyKilled = function(enemy) {
    this.enemiesKilled++;
    this.addGold(Math.floor(this.game.rnd.between(10, 40) / this.game.difficulty));
    this.score += 10;
    return this.updateText();
  };

  Stats.prototype.incrementScore = function(score) {
    this.score += Math.abs(score);
    return this.updateText();
  };

  Stats.prototype.updateText = function() {
    return this.text.text = "Gold: " + this.gold + " Score: " + this.score;
  };

  return Stats;

})();



},{"./constants":1}],15:[function(require,module,exports){
var FanTower, FireTower, G, SaltTower, Store, forSaleItems,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

G = require('./constants');

FireTower = require('./fire-tower');

FanTower = require('./fan-tower');

SaltTower = require('./salt-tower');

forSaleItems = {
  towerFire: {
    name: 'Fire',
    description: 'Click/Tap: Melt snowballs around the fire',
    "class": FireTower,
    imageKey: 'fire-store-icon',
    placeable: true,
    cost: 200
  },
  towerFan: {
    name: 'Fan',
    description: 'Click/Tap: Throw snowballs back from whence we came, damaging them in the process',
    "class": FanTower,
    imageKey: 'fan',
    placeable: true,
    cost: 10
  },
  towerSalt: {
    name: 'Salt',
    description: 'Slows and damages snowballs that pass over it. Click/Tap: Stun snowballs.',
    "class": SaltTower,
    imageKey: 'salt-patch',
    placeable: true,
    cost: 50
  },
  towerFireUpgrade: {
    name: 'Fire Upgrade',
    description: 'When purchased, increase the range and damage of all campfires',
    imageKey: 'fire-upgrade',
    placeable: false,
    cost: 500,
    requires: ['game', 'store'],
    createFn: (function(_this) {
      return function(game, store) {
        FireTower.properties.cooldown -= 30;
        FireTower.properties.range += 30;
        FireTower.properties.damage += 5;
        game.groups.tower.forEachAlive(function(tower) {
          if (typeof tower.resetProperties === "function") {
            tower.resetProperties();
          }
          return typeof tower.makeRangeMarker === "function" ? tower.makeRangeMarker() : void 0;
        });
        return store.removeItem('towerFireUpgrade');
      };
    })(this)
  },
  towerFanUpgrade: {
    name: 'Fan Upgrade',
    description: 'When purchased, increase the range and damage of all fans',
    imageKey: 'fan-upgrade',
    placeable: false,
    cost: 500,
    requires: ['game', 'store'],
    createFn: (function(_this) {
      return function(game, store) {
        FanTower.properties.cooldown -= 30;
        FanTower.properties.range += 50;
        FanTower.properties.damage += 10;
        game.groups.tower.forEachAlive(function(tower) {
          if (typeof tower.resetProperties === "function") {
            tower.resetProperties();
          }
          return typeof tower.makeRangeMarker === "function" ? tower.makeRangeMarker() : void 0;
        });
        return store.removeItem('towerFanUpgrade');
      };
    })(this)
  },
  towerSaltUpgrade: {
    name: 'Salt Upgrade',
    description: 'When purchased, increase the stun range and damage of all salt patches',
    imageKey: 'salt-upgrade',
    placeable: false,
    cost: 500,
    requires: ['game', 'store'],
    createFn: (function(_this) {
      return function(game, store) {
        SaltTower.properties.cooldown -= 30;
        SaltTower.properties.range += 30;
        SaltTower.properties.damage += 1;
        SaltTower.properties.stunDuration += 60;
        game.groups.tower.forEachAlive(function(tower) {
          if (typeof tower.resetProperties === "function") {
            tower.resetProperties();
          }
          return typeof tower.makeRangeMarker === "function" ? tower.makeRangeMarker() : void 0;
        });
        return store.removeItem('towerSaltUpgrade');
      };
    })(this)
  },
  secretHealth: {
    name: 'Replenish Health',
    description: 'When purchased, restores the health of your damaged secret. Reusable.',
    imageKey: 'secret-heal',
    placeable: false,
    cost: 100,
    requires: ['secret'],
    createFn: (function(_this) {
      return function(secret) {
        return secret.restoreMaxHealth();
      };
    })(this)
  },
  nuke: {
    name: 'Nuke',
    description: 'Melts all snowmen on screen. Reusable.',
    imageKey: 'mini-nuke',
    placeable: false,
    cost: 5000,
    requires: ['game'],
    createFn: (function(_this) {
      return function(game) {
        var nuke;
        game.groups.enemy.forEachAlive(function(enemy) {
          return enemy.damage(1000000000);
        });
        nuke = game.add.sprite(G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT / 2, 'nuke-blast');
        nuke.anchor.setTo(0.5);
        nuke.scale.setTo(0);
        game.add.tween(nuke).to({
          x: G.SCREEN_WIDTH / 2 - 10,
          y: G.SCREEN_HEIGHT / 2
        }, 10, Phaser.Easing.Linear.None).to({
          x: G.SCREEN_WIDTH / 2 + 10,
          y: G.SCREEN_HEIGHT / 2
        }, 10, Phaser.Easing.Linear.None).loop(true).start();
        game.add.tween(nuke).to({
          alpha: 0
        }, 1200, Phaser.Easing.Circular.Out, true, 800);
        game.add.tween(nuke.scale).to({
          x: 2,
          y: 2
        }, 3000, Phaser.Easing.Circular.Out, true).onComplete.add(function() {
          return nuke.destroy();
        });
        return game.sounds.nukeExplosion.play();
      };
    })(this)
  }
};

module.exports = Store = (function() {
  Store.numItemsPerRow = 6;

  function Store(game, stats) {
    var item, type;
    this.game = game;
    this.stats = stats;
    this.recalculateBuyableItems = __bind(this.recalculateBuyableItems, this);
    this.toggleStore = __bind(this.toggleStore, this);
    this.handleClickOnForSaleItem = __bind(this.handleClickOnForSaleItem, this);
    this.showDescription = __bind(this.showDescription, this);
    this.removeItem = __bind(this.removeItem, this);
    this.addForSaleItem = __bind(this.addForSaleItem, this);
    this.overlay = this.game.add.sprite(0, -474, 'store-overlay');
    this.overlay.inputEnabled = true;
    this.game.groups.overlay.add(this.overlay);
    this.slideDownTween = this.game.add.tween(this.overlay).to({
      y: 0
    }, 500, Phaser.Easing.Bounce.Out);
    this.slideUpTween = this.game.add.tween(this.overlay).to({
      y: -474
    }, 500, Phaser.Easing.Bounce.Out);
    this.storeText = this.game.add.bitmapText(0, 0, 'font', 'STORE', 40);
    this.storeText.x = this.overlay.width / 2 - this.storeText.width / 2;
    this.storeText.y = this.overlay.height - 25 - this.storeText.height;
    this.overlay.addChild(this.storeText);
    this.overlay.events.onInputDown.add(this.toggleStore);
    this.state = 'up';
    this.descriptionText = this.game.add.bitmapText(0, 0, 'font', '', 30);
    this.descriptionText.x = 20;
    this.descriptionText.y = this.overlay.height - 120 - this.descriptionText.height;
    this.overlay.addChild(this.descriptionText);
    this.slotNumber = 0;
    this.slots = [];
    for (type in forSaleItems) {
      item = forSaleItems[type];
      this.addForSaleItem(type, item);
    }
    this.recalculateBuyableItems(this.stats.gold);
    G.events.onGoldAmountChanged.add(this.recalculateBuyableItems);
  }

  Store.prototype.addForSaleItem = function(itemType, itemData) {
    var item, questionText, slot, text, x, y;
    x = (this.slotNumber % Store.numItemsPerRow) * 150 + 100;
    y = Math.floor(this.slotNumber / Store.numItemsPerRow) * 180 + 100;
    slot = this.game.add.sprite(x, y, 'store-slot');
    slot.anchor.setTo(0.5, 0.5);
    slot.inputEnabled = true;
    slot.input.priorityID = 1;
    slot.events.onInputDown.add(this.handleClickOnForSaleItem);
    slot.data = itemData;
    slot.type = itemType;
    this.slots.push(slot);
    item = this.game.add.sprite(x, y, itemData.imageKey);
    item.inputEnabled = true;
    item.input.priorityID = 2;
    item.events.onInputOver.add(this.showDescription);
    item.events.onInputDown.add(this.handleClickOnForSaleItem);
    item.data = itemData;
    item.type = itemType;
    item.anchor.setTo(0.5, 0.5);
    item.slot = slot;
    this.overlay.addChild(slot);
    this.overlay.addChild(item);
    text = this.game.add.text(0, slot.width / 2 + 30, itemData.name + ("\nCost: " + itemData.cost + "g") + '', {
      font: '20px Droid Sans',
      fill: 'black',
      align: 'center'
    });
    text.anchor.setTo(0.5, 0.5);
    slot.text = text;
    slot.addChild(text);
    questionText = this.game.add.text(slot.width / 2 + 15, -1 * slot.height / 2, '?', {
      font: '30px Droid Sans',
      fill: 'black'
    });
    questionText.anchor.setTo(0.5, 0);
    questionText.inputEnabled = true;
    questionText.input.priorityID = 3;
    questionText.events.onInputDown.add(this.showDescription);
    questionText.events.onInputOver.add(this.showDescription);
    questionText.slot = slot;
    slot.addChild(questionText);
    return this.slotNumber++;
  };

  Store.prototype.removeItem = function(key) {
    var child, childrenToDestroy, _i, _j, _len, _len1, _ref, _results;
    childrenToDestroy = [];
    _ref = this.overlay.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      if ((child != null ? child.type : void 0) === key) {
        childrenToDestroy.push(child);
      }
    }
    _results = [];
    for (_j = 0, _len1 = childrenToDestroy.length; _j < _len1; _j++) {
      child = childrenToDestroy[_j];
      _results.push(child.destroy());
    }
    return _results;
  };

  Store.prototype.showDescription = function(object) {
    return this.descriptionText.text = object.slot.data.description;
  };

  Store.prototype.handleClickOnForSaleItem = function(sprite) {
    if (sprite.data.cost > this.stats.gold) {
      return;
    }
    this.stats.subtractGold(sprite.data.cost);
    G.events.onStoreItemPurchased.dispatch(sprite.data);
    return this.toggleStore();
  };

  Store.prototype.toggleStore = function() {
    if (this.state === 'up') {
      this.slideDownTween.start();
      this.state = 'down';
      this.game.sounds.openStore.play();
      return G.events.onStoreOpen.dispatch();
    } else if (this.state === 'down') {
      this.slideUpTween.start();
      this.state = 'up';
      return G.events.onStoreClose.dispatch();
    }
  };

  Store.prototype.recalculateBuyableItems = function(availableGold) {
    var slot, _i, _len, _ref;
    _ref = this.slots;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      slot = _ref[_i];
      if (slot.data.cost <= availableGold) {
        slot.text.addColor('black', 0);
      } else {
        slot.text.addColor('#ff3333', 0);
      }
    }
  };

  return Store;

})();



},{"./constants":1,"./fan-tower":4,"./fire-tower":6,"./salt-tower":12}],16:[function(require,module,exports){
var G, Tower,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

module.exports = Tower = (function(_super) {
  __extends(Tower, _super);

  Tower.properties = [];

  Tower.prototype.resetProperties = function() {
    this.animationCls = this.constructor.properties.animationCls;
    this.cooldown = this.constructor.properties.cooldown;
    this.range = this.constructor.properties.range;
    return this.damage = this.constructor.properties.damage;
  };

  function Tower(game, x, y) {
    this.game = game;
    this.doConstantEffect = __bind(this.doConstantEffect, this);
    this.fire = __bind(this.fire, this);
    this.resetCooldown = __bind(this.resetCooldown, this);
    this.handleClick = __bind(this.handleClick, this);
    this.decreaseCooldownRemaining = __bind(this.decreaseCooldownRemaining, this);
    this.update = __bind(this.update, this);
    this.updateCooldown = __bind(this.updateCooldown, this);
    this.makeRangeMarker = __bind(this.makeRangeMarker, this);
    this.resetProperties();
    Tower.__super__.constructor.call(this, this.game, x, y, this.animationCls.spriteKey);
    this.animation = new this.animationCls(this.game, this);
    this.game.add.existing(this);
    this.inputEnabled = true;
    this.events.onInputDown.add(this.handleClick, this);
    this.anchor.setTo(0.5, 0.5);
    this.game.groups.tower.add(this);
    this.enemyGroup = this.game.groups.enemy;
    this.rangeMarkerData = this.game.add.bitmapData(512, 512);
    this.rangeMarker = this.game.add.sprite(this.x, this.y, this.rangeMarkerData);
    this.rangeMarker.anchor.setTo(0.5, 0.5);
    this.game.groups.tower.add(this.rangeMarker);
    this.cooldownMeter = this.game.add.sprite(this.x, this.y, 'cooldown');
    this.cooldownMeter.anchor.setTo(0.5);
    this.cooldownMeter.animations.add('running', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 0);
    this.game.groups.tower.add(this.cooldownMeter);
    this.cooldownMeter.animations.currentAnim.frame = 12;
    if (!!this.constructor.properties.drawRangeMarker) {
      this.makeRangeMarker();
    }
  }

  Tower.prototype.makeRangeMarker = function() {
    var ctx, height, width, _ref, _ref1;
    this.rangeMarkerData.cls();
    if (((_ref = this.constructor) != null ? (_ref1 = _ref.properties) != null ? _ref1.range : void 0 : void 0) != null) {
      ctx = this.rangeMarkerData.context;
      width = this.rangeMarkerData.width;
      height = this.rangeMarkerData.height;
      ctx.strokeStyle = 'rgba(128, 128, 128, 0.5)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(width / 2, height / 2, this.constructor.properties.range, 0, Math.PI * 2);
      ctx.stroke();
      ctx.closePath();
    }
    return this.rangeMarkerData.render();
  };

  Tower.prototype.updateCooldown = function() {
    var remaining;
    if (this.cooldownRemaining > 0) {
      remaining = this.cooldownRemaining / this.cooldown;
      this.cooldownMeter.animations.currentAnim.frame = (13 - Math.floor(13 * remaining)) - 1;
      return this.inputEnabled = false;
    } else {
      return this.inputEnabled = true;
    }
  };

  Tower.prototype.update = function() {
    if (this.game.isPaused) {
      return;
    }
    this.doConstantEffect();
    this.decreaseCooldownRemaining();
    return this.updateCooldown();
  };

  Tower.prototype.decreaseCooldownRemaining = function() {
    return this.cooldownRemaining -= 1;
  };

  Tower.prototype.handleClick = function() {
    return this.fire();
  };

  Tower.prototype.resetCooldown = function() {
    return this.cooldownRemaining = this.cooldown;
  };

  Tower.prototype.fire = function() {
    if (this.cooldownRemaining > 0) {
      return false;
    }
    this.resetCooldown();
    return true;
  };

  Tower.prototype.doConstantEffect = function() {
    return this.cooldownRemaining < 0;
  };

  return Tower;

})(Phaser.Sprite);



},{"./constants":1}],17:[function(require,module,exports){
var G, WeatherGenerator;

G = require('./constants');

module.exports = WeatherGenerator = (function() {
  WeatherGenerator.spriteKey = 'fan';

  function WeatherGenerator(game) {
    this.game = game;
  }

  return WeatherGenerator;

})();



},{"./constants":1}]},{},[8])