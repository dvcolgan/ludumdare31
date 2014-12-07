G = require('./constants')
EnemySpawner = require('./enemy-spawner')
EnemyFactory = require('./enemy')
TowerFactory = require('./tower')
LoseOverlay = require('./lose-overlay')
Store = require('./store')
Secret = require('./secret')
Stats = require('./stats')
Fire = require('./fire')
Fan = require('./fan')
SaltPatch = require('./salt-patch')


class PlayState extends Phaser.State

    preload: =>
        @game.load.image('background', 'assets/background.png')
        @game.load.image('secret', 'assets/secret.png')
        @game.load.image('tower', 'assets/tower.png')

        @game.load.image('enemy-medium', 'assets/enemy-medium.png')

        @game.load.image('tower-aoe', 'assets/tower.png')

        @game.load.image('lose-overlay', 'assets/lose-overlay.png')
        @game.load.image('store-overlay', 'assets/store-overlay.png')
        @game.load.image('store-slot', 'assets/store-slot.png')

        @game.load.image('firewood', 'assets/firewood.png')
        @game.load.image('fire-particle', 'assets/fire-particle.png')

        @game.load.spritesheet('fan', 'assets/fan.png', 64, 64, 4)
        @game.load.spritesheet('snow-particles', 'assets/snow-particles.png', 4, 4, 4)
        @game.load.spritesheet('snowflake-particles', 'assets/snowflake-particles.png', 16, 16, 5)
        @game.load.image('salt-patch', 'assets/salt-patch.png', 64, 64)
        @game.load.image('salt-particle', 'assets/salt-particle.png')

    create: =>

        @initializeGame()
        @initializePhysicsEngine()
        @initializeGroups()

        @game.physics.p2.updateBoundsCollisionGroup()

        @towerFactory = new TowerFactory(@game)
        @stats = new Stats(@game)
        @store = new Store(@game, @towerFactory, @stats)
        @initializeBackground()
        @secret = new Secret(@game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT/2)
        @loseOverlay = new LoseOverlay(@game)
        @initializeEnemySpawner()

        G.events.onGameOver.add(@handleGameOver)
        G.events.onStoreItemPurchased.add(@handleStoreItemPurchased)

        @game.frame = 0

        # TODO: Remove this! Iz for cheats
        key = @game.input.keyboard.addKey(Phaser.Keyboard.ONE)
        key.onDown.add () =>
            @towerFactory['createFire'](@game.input.mousePointer.x, @game.input.mousePointer.y)
        key = @game.input.keyboard.addKey(Phaser.Keyboard.TWO)
        key.onDown.add () =>
            @towerFactory['createSnowblower'](@game.input.mousePointer.x, @game.input.mousePointer.y)
        key = @game.input.keyboard.addKey(Phaser.Keyboard.THREE)
        key.onDown.add () =>
            @towerFactory['createSalt'](@game.input.mousePointer.x, @game.input.mousePointer.y)

    initializeGame: () =>
        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0
        @game.time.advancedTiming = G.DEBUG
        window.controller = @
        @gameDifficulty = 3
        @boughtItem = null
        @cursorSprite = null

    initializePhysicsEngine: () =>
        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)
        @game.physics.p2.setBounds(-200, 64, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT - 64)

    initializeGroups: () =>
        @game.groups =
            background: @game.add.group()
            tower: @game.add.group()
            enemy: @game.add.group()
            overlay: @game.add.group()

        # Initialize physics collision groups
        @game.collisionGroups =
            secret: @game.physics.p2.createCollisionGroup()
            tower: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()

    initializeBackground: () =>
        @background = @game.add.image(0, 0, 'background')
        @background.inputEnabled = true
        @background.events.onInputDown.add(@handlePointerDownOnBackground)
        @game.groups.background.add(@background)

    initializeEnemySpawner: () =>
        enemyFactory = new EnemyFactory(@game, @game.groups.tower, @secret)
        @enemySpawner = new EnemySpawner(enemyFactory, 60, @gameDifficulty)


    handlePointerDownOnBackground: (image, pointer) =>
        if @boughtItem
            @towerFactory[@boughtItem.createFn](pointer.x, pointer.y)
            @boughtItem = null
            @cursorSprite.destroy()

    handleGameOver: =>
        @loseOverlay.show(@stats.score)

    handleStoreItemPurchased: (itemData) =>
        @boughtItem = itemData
        @cursorSprite = @game.add.sprite(@game.input.x, @game.input.y, itemData.imageKey)
        @game.groups.overlay.add(@cursorSprite)
        @cursorSprite.anchor.setTo(0.5, 0.5)
        @cursorSprite.alpha = 0.5
        @cursorSprite.update = =>
            @cursorSprite.x = @game.input.x
            @cursorSprite.y = @game.input.y

    update: =>
        @game.frame++
        @enemySpawner.update(@game.frame)

    render: =>
        @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
