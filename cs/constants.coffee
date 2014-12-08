module.exports =
    SCREEN_WIDTH: 960
    SCREEN_HEIGHT: 540

    events:
        onGameOver: new Phaser.Signal()
        onEnemyKilled: new Phaser.Signal()
        onStoreItemPurchased: new Phaser.Signal()
        onGoldAmountChanged: new Phaser.Signal()

    DEBUG: false
