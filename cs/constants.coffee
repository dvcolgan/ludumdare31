module.exports =
    SCREEN_WIDTH: 960
    SCREEN_HEIGHT: 540

    PHYSICS_BOUNDS_X_MIN: -200
    PHYSICS_BOUNDS_X_MAX: 1160 # SCREEN_WIDTH + 200
    PHYSICS_BOUNDS_Y_MIN: 64
    PHYSICS_BOUNDS_Y_MAX: 476 # SCREEN_HEIGHT - 64

    events:
        onGameOver: new Phaser.Signal()
        onEnemyKilled: new Phaser.Signal()
        onStoreItemPurchased: new Phaser.Signal()
        onGoldAmountChanged: new Phaser.Signal()
        onSecretDamaged: new Phaser.Signal()
        onTowerPlaced: new Phaser.Signal()
        onStoreOpen: new Phaser.Signal()
        onStoreClose: new Phaser.Signal()

    DEBUG: false
