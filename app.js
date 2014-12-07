(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = {
  SCREEN_WIDTH: 960,
  SCREEN_HEIGHT: 540,
  events: {
    onGameOver: new Phaser.Signal(),
    onEnemyKilled: new Phaser.Signal(),
    onStoreItemPurchased: new Phaser.Signal()
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
    this.maybeCreateNewEnemy = __bind(this.maybeCreateNewEnemy, this);
    this.update = __bind(this.update, this);
    this.calculateProbability = __bind(this.calculateProbability, this);
    this.calculateProbability();
    this.minDifficultyToSpawnMediumEnemies = 2;
    this.minDifficultyToSpawnLargeEnemies = 3;
    this.probabilityOfSpawningMediumEnemy = 0.5;
    this.probabilityOfSpawningLargeEnemy = 0.2;
    this.secondsUntilSpawnRateDoubled = 60;
    this.framesUntilSpawnRateDoubled = this.framerate * this.secondsUntilSpawnRateDoubled;
  }

  EnemySpawner.prototype.calculateProbability = function() {
    return this.frameProbability = 0.1 / this.framerate * this.difficulty;
  };

  EnemySpawner.prototype.update = function(frame) {
    return this.maybeCreateNewEnemy(frame);
  };

  EnemySpawner.prototype.maybeCreateNewEnemy = function(frame) {
    if (Math.random() < this.frameProbability * (frame / this.framesUntilSpawnRateDoubled + 1)) {
      if (this.difficulty < this.minDifficultyToSpawnMediumEnemies) {
        return this.enemyFactory.createSmall();
      } else if (this.difficulty < this.minDifficultyToSpawnLargeEnemies) {
        if (Math.random() < this.probabilityOfSpawningMediumEnemy) {
          return this.enemyFactory.createMedium();
        } else {
          return this.enemyFactory.createSmall();
        }
      } else {
        if (Math.random() < this.probabilityOfSpawningLargeEnemy) {
          return this.enemyFactory.createLarge();
        } else if (Math.random() < this.probabilityOfSpawningMediumEnemy) {
          return this.enemyFactory.createMedium();
        } else {
          return this.enemyFactory.createSmall();
        }
      }
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

  function Enemy(game, towerGroup, secret, x, y, key, health) {
    this.towerGroup = towerGroup;
    this.secret = secret;
    this.damage = __bind(this.damage, this);
    this.pointAtSecret = __bind(this.pointAtSecret, this);
    this.update = __bind(this.update, this);
    Enemy.__super__.constructor.call(this, game, x, y, key);
    this.health = health;
    this.anchor.setTo(0.5, 0.5);
    game.physics.p2.enable(this, G.DEBUG);
    this.body.clearShapes();
    this.body.addCircle(this.width / 2);
    this.body.setCollisionGroup(game.collisionGroups.enemy);
    this.body.collides([game.collisionGroups.enemy, game.collisionGroups.tower, game.collisionGroups.secret]);
    game.add.existing(this);
    this.healthText = new Phaser.Text(game, 0, 0, this.health, {
      font: '10px Arial',
      fill: 'black',
      align: 'center'
    });
    this.addChild(this.healthText);
  }

  Enemy.prototype.update = function() {
    return this.pointAtSecret(this.secret);
  };

  Enemy.prototype.pointAtSecret = function(secret) {
    var vector;
    vector = Phaser.Point.subtract(this, secret);
    this.body.rotation = vector.angle(new Phaser.Point()) + Math.PI / 2;
    return this.body.thrust(10);
  };

  Enemy.prototype.damage = function(damage) {
    Enemy.__super__.damage.call(this, damage);
    this.healthText.text = this.health;
    if (this.health <= 0) {
      return G.events.onEnemyKilled.dispatch(this);
    }
  };

  return Enemy;

})(Phaser.Sprite);

module.exports = EnemyFactory = (function() {
  function EnemyFactory(game, towerGroup, secret) {
    this.game = game;
    this.towerGroup = towerGroup;
    this.secret = secret;
    this.createLarge = __bind(this.createLarge, this);
    this.createMedium = __bind(this.createMedium, this);
    this.createSmall = __bind(this.createSmall, this);
    this.getY = __bind(this.getY, this);
  }

  EnemyFactory.prototype.getY = function() {
    return this.game.rnd.integerInRange(0, G.SCREEN_HEIGHT);
  };

  EnemyFactory.prototype.createSmall = function() {
    var enemy;
    enemy = new Enemy(this.game, this.towerGroup, this.secret, 0, this.getY(), 'enemy-small', 10);
    this.game.groups.enemy.add(enemy);
    return enemy;
  };

  EnemyFactory.prototype.createMedium = function() {
    var enemy;
    enemy = new Enemy(this.game, this.towerGroup, this.secret, 0, this.getY(), 'enemy-medium', 20);
    this.game.groups.enemy.add(enemy);
    return enemy;
  };

  EnemyFactory.prototype.createLarge = function() {
    var enemy;
    enemy = new Enemy(this.game, this.towerGroup, this.secret, 0, this.getY(), 'enemy-large', 30);
    this.game.groups.enemy.add(enemy);
    return enemy;
  };

  return EnemyFactory;

})();



},{"./constants":1}],4:[function(require,module,exports){
var Fire;

module.exports = Fire = (function() {
  function Fire(game, x, y) {
    this.game = game;
    this.wood = this.game.add.sprite(x, y, 'firewood');
    this.wood.anchor.setTo(0.5, 0.5);
    this.emitter = this.game.add.emitter(x, y + 5, 300);
    this.emitter.makeParticles('fire-particle');
    this.emitter.width = this.wood.width / 3;
    this.emitter.height = 5;
    this.emitter.gravity = 10;
    this.emitter.setXSpeed(-2, 2);
    this.emitter.setYSpeed(-40, -60);
    this.emitter.setAlpha(1, 0.0, 3000);
    this.emitter.setScale(1, 0.5, 1, 0.5, 4000, Phaser.Easing.Quadratic.InOut);
    this.emitter.start(false, 3000, 1);
  }

  return Fire;

})();



},{}],5:[function(require,module,exports){
var EnemyFactory, EnemySpawner, Fire, G, LoseOverlay, PlayState, Secret, Stats, Store, TowerFactory,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

EnemySpawner = require('./enemy-spawner');

EnemyFactory = require('./enemy');

TowerFactory = require('./tower');

LoseOverlay = require('./lose-overlay');

Store = require('./store');

Secret = require('./secret');

Stats = require('./stats');

Fire = require('./fire');

PlayState = (function(_super) {
  __extends(PlayState, _super);

  function PlayState() {
    this.render = __bind(this.render, this);
    this.update = __bind(this.update, this);
    this.handleStoreItemPurchased = __bind(this.handleStoreItemPurchased, this);
    this.handleGameOver = __bind(this.handleGameOver, this);
    this.handlePointerDownOnBackground = __bind(this.handlePointerDownOnBackground, this);
    this.initializeEnemySpawner = __bind(this.initializeEnemySpawner, this);
    this.initializeBackground = __bind(this.initializeBackground, this);
    this.initializeGroups = __bind(this.initializeGroups, this);
    this.initializePhysicsEngine = __bind(this.initializePhysicsEngine, this);
    this.initializeGame = __bind(this.initializeGame, this);
    this.create = __bind(this.create, this);
    this.preload = __bind(this.preload, this);
    return PlayState.__super__.constructor.apply(this, arguments);
  }

  PlayState.prototype.preload = function() {
    this.game.load.image('background', 'assets/background.png');
    this.game.load.image('secret', 'assets/secret.png');
    this.game.load.image('tower', 'assets/tower.png');
    this.game.load.image('enemy-small', 'assets/enemy-small.png');
    this.game.load.image('enemy-medium', 'assets/enemy-medium.png');
    this.game.load.image('enemy-large', 'assets/enemy-large.png');
    this.game.load.image('tower-aoe', 'assets/tower.png');
    this.game.load.image('lose-overlay', 'assets/lose-overlay.png');
    this.game.load.image('store-overlay', 'assets/store-overlay.png');
    this.game.load.image('store-slot', 'assets/store-slot.png');
    this.game.load.image('firewood', 'assets/firewood.png');
    return this.game.load.image('fire-particle', 'assets/fire-particle.png');
  };

  PlayState.prototype.create = function() {
    var key;
    this.initializeGame();
    this.initializePhysicsEngine();
    this.initializeGroups();
    this.game.physics.p2.updateBoundsCollisionGroup();
    this.towerFactory = new TowerFactory(this.game);
    this.stats = new Stats(this.game);
    this.store = new Store(this.game, this.towerFactory, this.stats);
    this.initializeBackground();
    this.secret = new Secret(this.game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT / 2);
    this.loseOverlay = new LoseOverlay(this.game);
    this.initializeEnemySpawner();
    G.events.onGameOver.add(this.handleGameOver);
    G.events.onStoreItemPurchased.add(this.handleStoreItemPurchased);
    this.frame = 0;
    key = this.game.input.keyboard.addKey(Phaser.Keyboard.ONE);
    key.onDown.add((function(_this) {
      return function() {
        return _this.towerFactory['createAoe'](_this.game.input.mousePointer.x, _this.game.input.mousePointer.y);
      };
    })(this), this);
    return this.fire = new Fire(this.game, 400, 300);
  };

  PlayState.prototype.initializeGame = function() {
    this.game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT);
    this.game.camera.x = 0;
    this.game.time.advancedTiming = G.DEBUG;
    window.controller = this;
    this.gameDifficulty = 3;
    this.boughtItem = null;
    return this.cursorSprite = null;
  };

  PlayState.prototype.initializePhysicsEngine = function() {
    this.game.physics.startSystem(Phaser.Physics.P2JS);
    this.game.physics.p2.setImpactEvents(true);
    return this.game.physics.p2.setBounds(-200, 64, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT - 64);
  };

  PlayState.prototype.initializeGroups = function() {
    this.game.groups = {
      background: this.game.add.group(),
      tower: this.game.add.group(),
      enemy: this.game.add.group(),
      overlay: this.game.add.group()
    };
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
    return this.enemySpawner = new EnemySpawner(enemyFactory, 60, this.gameDifficulty);
  };

  PlayState.prototype.handlePointerDownOnBackground = function(image, pointer) {
    if (this.boughtItem) {
      this.towerFactory[this.boughtItem.createFn](pointer.x, pointer.y);
      this.boughtItem = null;
      return this.cursorSprite.destroy();
    }
  };

  PlayState.prototype.handleGameOver = function() {
    return this.loseOverlay.show(this.stats.score);
  };

  PlayState.prototype.handleStoreItemPurchased = function(itemData) {
    this.boughtItem = itemData;
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
  };

  PlayState.prototype.update = function() {
    this.frame++;
    return this.enemySpawner.update(this.frame);
  };

  PlayState.prototype.render = function() {
    return this.game.debug.text(this.game.time.fps || '--', 2, 14, "#00ff00");
  };

  return PlayState;

})(Phaser.State);

window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState());



},{"./constants":1,"./enemy":3,"./enemy-spawner":2,"./fire":4,"./lose-overlay":6,"./secret":7,"./stats":8,"./store":9,"./tower":10}],6:[function(require,module,exports){
var LoseOverlay;

module.exports = LoseOverlay = (function() {
  function LoseOverlay(game) {
    this.game = game;
    this.sprite = this.game.add.sprite(0, 0, 'lose-overlay');
    this.game.groups.overlay.add(this.sprite);
    this.text = this.game.add.text(200, 200, '', {
      font: 'bold 20px Arial',
      fill: 'black',
      align: 'center'
    });
    this.hide();
  }

  LoseOverlay.prototype.show = function(score) {
    this.sprite.visible = true;
    this.text.text = "You are the loseriest of losers.\n\nYour score: " + score;
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



},{}],7:[function(require,module,exports){
var G, Secret,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

module.exports = Secret = (function(_super) {
  __extends(Secret, _super);

  function Secret(game, x, y) {
    this.onEnemyTouch = __bind(this.onEnemyTouch, this);
    Secret.__super__.constructor.call(this, game, x, y, 'secret');
    game.add.existing(this);
    this.anchor.setTo(0.5, 0.5);
    game.physics.p2.enable(this, G.DEBUG);
    this.body.kinematic = true;
    this.body.clearShapes();
    this.body.addCircle(this.width / 2);
    this.body.setCollisionGroup(this.game.collisionGroups.secret);
    this.body.collides([this.game.collisionGroups.enemy]);
    this.body.createGroupCallback(this.game.collisionGroups.enemy, this.onEnemyTouch);
  }

  Secret.prototype.onEnemyTouch = function() {
    return G.events.onGameOver.dispatch();
  };

  return Secret;

})(Phaser.Sprite);



},{"./constants":1}],8:[function(require,module,exports){
var G, Stats,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

G = require('./constants');

module.exports = Stats = (function() {
  function Stats(game) {
    this.game = game;
    this.updateText = __bind(this.updateText, this);
    this.handleEnemyKilled = __bind(this.handleEnemyKilled, this);
    this.score = 0;
    this.gold = 500;
    this.text = this.game.add.text(20, 20, '', {
      font: '20px Arial',
      fill: 'black',
      align: 'left'
    });
    this.updateText();
    G.events.onEnemyKilled.add(this.handleEnemyKilled);
  }

  Stats.prototype.addGold = function(amount) {
    this.gold += amount;
    return this.updateText();
  };

  Stats.prototype.subtractGold = function(amount) {
    this.gold -= amount;
    return this.updateText();
  };

  Stats.prototype.handleEnemyKilled = function(enemy) {
    switch (enemy.key) {
      case 'enemy-small':
        this.gold += this.game.rnd.between(5, 10);
        this.score += 5;
        break;
      case 'enemy-medium':
        this.gold += this.game.rnd.between(10, 20);
        this.score += 10;
        break;
      case 'enemy-large':
        this.gold += this.game.rnd.between(20, 50);
        this.score += 20;
    }
    return this.updateText();
  };

  Stats.prototype.updateText = function() {
    return this.text.text = "Gold: " + this.gold + " Score: " + this.score;
  };

  return Stats;

})();



},{"./constants":1}],9:[function(require,module,exports){
var G, Store, TowerFactory, forSaleItems,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

G = require('./constants');

TowerFactory = require('./tower');

forSaleItems = {
  towerAoe: {
    createFn: 'createAoe',
    imageKey: 'tower-aoe',
    cost: 10
  }
};

module.exports = Store = (function() {
  function Store(game, towerFactory, stats) {
    this.game = game;
    this.towerFactory = towerFactory;
    this.stats = stats;
    this.toggleStore = __bind(this.toggleStore, this);
    this.handleClickOnForSaleItem = __bind(this.handleClickOnForSaleItem, this);
    this.overlay = this.game.add.sprite(0, -474, 'store-overlay');
    this.overlay.inputEnabled = true;
    this.game.groups.overlay.add(this.overlay);
    this.slideDownTween = this.game.add.tween(this.overlay).to({
      y: 0
    }, 500, Phaser.Easing.Bounce.Out);
    this.slideUpTween = this.game.add.tween(this.overlay).to({
      y: -474
    }, 500, Phaser.Easing.Bounce.Out);
    this.overlay.events.onInputDown.add(this.toggleStore);
    this.state = 'up';
    this.addForSaleItem(forSaleItems.towerAoe);
  }

  Store.prototype.addForSaleItem = function(itemData) {
    var item, slot;
    slot = this.game.add.sprite(200, 100, 'store-slot');
    slot.anchor.setTo(0.5, 0.5);
    item = this.game.add.sprite(200, 100, itemData.imageKey);
    item.anchor.setTo(0.5, 0.5);
    this.overlay.addChild(slot);
    this.overlay.addChild(item);
    slot.inputEnabled = true;
    slot.input.priorityID = 1;
    slot.events.onInputDown.add(this.handleClickOnForSaleItem);
    return slot.data = itemData;
  };

  Store.prototype.handleClickOnForSaleItem = function(slot) {
    this.stats.subtractGold(slot.data.cost);
    G.events.onStoreItemPurchased.dispatch(slot.data);
    return this.toggleStore();
  };

  Store.prototype.toggleStore = function() {
    if (this.state === 'up') {
      this.slideDownTween.start();
      return this.state = 'down';
    } else if (this.state === 'down') {
      this.slideUpTween.start();
      return this.state = 'up';
    }
  };

  return Store;

})();



},{"./constants":1,"./tower":10}],10:[function(require,module,exports){
var G, Tower, TowerFactory,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

G = require('./constants');

Tower = (function(_super) {
  __extends(Tower, _super);

  function Tower(game, x, y, key, cooldown, range, damage) {
    this.cooldown = cooldown;
    this.range = range;
    this.damage = damage;
    this.fire = __bind(this.fire, this);
    this.handleClick = __bind(this.handleClick, this);
    this.decreaseCooldownRemaining = __bind(this.decreaseCooldownRemaining, this);
    this.update = __bind(this.update, this);
    Tower.__super__.constructor.call(this, game, x, y, key);
    game.add.existing(this);
    this.inputEnabled = true;
    this.events.onInputDown.add(this.handleClick, this);
    this.anchor.setTo(0.5, 0.5);
    game.physics.p2.enable(this, G.DEBUG);
    this.body.clearShapes();
    this.body.addCircle(this.width / 2);
    this.body.kinematic = true;
    this.body.setCollisionGroup(this.game.collisionGroups.tower);
    this.body.collides([this.game.collisionGroups.enemy]);
    game.groups.tower.add(this);
    this.cooldownRemaining = 0;
    this.cooldownMeterData = game.add.bitmapData(this.width + 16, this.height + 16);
    this.cooldownMeter = game.add.sprite(0, 0, this.cooldownMeterData);
    this.cooldownMeter.anchor.setTo(0.5, 0.5);
    this.addChild(this.cooldownMeter);
  }

  Tower.prototype.makeCooldownMeter = function() {
    var ctx, height, remaining, width;
    this.cooldownMeterData.cls();
    if (this.cooldownRemaining > 0) {
      ctx = this.cooldownMeterData.context;
      width = this.cooldownMeterData.width;
      height = this.cooldownMeterData.height;
      ctx.strokeStyle = 'black';
      ctx.lineWidth = 8;
      ctx.beginPath();
      remaining = this.cooldown - this.cooldownRemaining / this.cooldown;
      ctx.arc(width / 2, height / 2, this.width / 2 + 4, remaining * Math.PI * 2 - Math.PI / 2, -Math.PI / 2);
      console.log(remaining * Math.PI * 2);
      ctx.stroke();
      ctx.closePath();
    }
    return this.cooldownMeterData.render();
  };

  Tower.prototype.update = function() {
    this.decreaseCooldownRemaining();
    return this.makeCooldownMeter();
  };

  Tower.prototype.decreaseCooldownRemaining = function() {
    return this.cooldownRemaining -= 1;
  };

  Tower.prototype.handleClick = function() {
    return this.fire();
  };

  Tower.prototype.fire = function() {
    if (this.cooldownRemaining > 0) {
      return;
    }
    this.game.groups.enemy.forEachAlive((function(_this) {
      return function(enemy) {
        var dist;
        dist = Math.sqrt(Math.pow(enemy.x - _this.x, 2) + Math.pow(enemy.y - _this.y, 2));
        if (dist < _this.range) {
          return enemy.damage(_this.damage);
        }
      };
    })(this));
    return this.cooldownRemaining = this.cooldown;
  };

  return Tower;

})(Phaser.Sprite);

module.exports = TowerFactory = (function() {
  function TowerFactory(game) {
    this.game = game;
    this.createAoe = __bind(this.createAoe, this);
  }

  TowerFactory.prototype.createAoe = function(x, y) {
    var tower;
    tower = new Tower(this.game, x, y, 'tower-aoe', 60, 100, 10);
    return tower;
  };

  return TowerFactory;

})();



},{"./constants":1}]},{},[5])