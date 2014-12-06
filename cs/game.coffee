G = require('./constants')
EnemySpawner = require('./enemy-spawner')
EnemyFactory = require('./enemy')
TowerFactory = require('./tower')
LoseOverlay = require('./lose-overlay')
Store = require('./store')
Secret = require('./secret')
Stats = require('./stats')


class PlayState extends Phaser.State

    preload: =>
        @game.load.image('background', 'assets/background.png')
        @game.load.image('secret', 'assets/secret.png')
        @game.load.image('tower', 'assets/tower.png')

        @enemyFactory = new EnemyFactory(@game)
        @enemyFactory.preload()
        @towerFactory = new TowerFactory(@game)
        @towerFactory.preload()

        @game.load.image('lose-overlay', 'assets/lose-overlay.png')
        @game.load.image('store-overlay', 'assets/store-overlay.png')
        @game.load.image('store-slot', 'assets/store-slot.png')



    create: =>

        @initializeGame()
        @initializePhysicsEngine()
        @initializeGroups()
        @initializeEvents()

        @game.physics.p2.updateBoundsCollisionGroup()

        @store = new Store(@game)
        @initializeBackground()
        @stats = new Stats(@game)
        @secret = new Secret(@game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT/2)
        @loseOverlay = new LoseOverlay(@game)
        @enemySpawner = new EnemySpawner(@enemyFactory, 60, @gameDifficulty)

        G.events.onGameOver.add(@handleGameOver)

    initializeGame: () =>
        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0
        @game.time.advancedTiming = G.DEBUG
        window.controller = @
        @gameDifficulty = 3

    initializePhysicsEngine: () =>
        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)

    initializeGroups: () =>
        @game.groups =
            background: @game.add.group()
            tower: @game.add.group()
            enemy: @game.add.group()
            overlay: @game.add.group()

        @game.collisionGroups =
            secret: @game.physics.p2.createCollisionGroup()
            tower: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()

    initializeEvents: () =>
        G.events =
            onGameOver: new Phaser.Signal()
            onEnemyKilled: new Phaser.Signal()

    initializeBackground: () =>
        @background = @game.add.image(0, 0, 'background')
        @background.inputEnabled = true
        @background.events.onInputDown.add(@handlePointerDownOnBackground)
        @game.groups.background.add(@background)


    handlePointerDownOnBackground: (image, pointer) =>
        if @loseOverlay.isVisible() then return
        @towerFactory.createAoe(pointer.x, pointer.y)

    handleGameOver: =>
        @loseOverlay.show(@stats.score)

    update: =>
        #pointerIsDown = @game.input.mousePointer?.isDown or @game.input.pointer1?.isDown
        #pointerX = @game.input.x
        #pointerY = @game.input.y

        @enemySpawner.update()
        @game.groups.enemy.forEachAlive (enemy) =>

    render: =>
        @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
