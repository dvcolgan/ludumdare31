G = require('./constants')
EnemySpawner = require('./enemy-spawner')
EnemyFactory = require('./enemy')
TowerFactory = require('./tower')
LoseOverlay = require('./lose-overlay')
Store = require('./store')
Secret = require('./secret')
Stats = require('./stats')


class PlayState extends Phaser.State

    preload: ->
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



    create: ->
        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0

        @game.events =
            onGameOver: new Phaser.Signal()
            onEnemyKilled: new Phaser.Signal()

        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)

        @game.groups = {}
        @game.groups.background = @game.add.group()
        @game.groups.tower = @game.add.group()
        @game.groups.enemy = @game.add.group()
        @game.groups.overlay = @game.add.group()
        @store = new Store(@game)

        @game.collisionGroups =
            secret: @game.physics.p2.createCollisionGroup()
            tower: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()
        @game.physics.p2.updateBoundsCollisionGroup()

        window.controller = @

        @background = @game.add.image(0, 0, 'background')
        @background.inputEnabled = true

        @game.groups.background.add(@background)
        @stats = new Stats(@game)

        @game.time.advancedTiming = G.DEBUG

        @secret = new Secret(@game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT/2)

        @loseOverlay = new LoseOverlay(@game)


        # TODO: Dynamically pass in framerate (should this stay hardcoded to 60?)
        @gameDifficulty = 3
        @enemySpawner = new EnemySpawner(@enemyFactory, 60, @gameDifficulty)

        @background.events.onInputDown.add(@handlePointerDown)
        @game.events.onGameOver.add(@handleGameOver)

    handlePointerDown: (image, pointer) =>
        if @loseOverlay.isVisible() then return
        @towerFactory.createAoe(pointer.x, pointer.y)

    handleGameOver: =>
        @loseOverlay.show(@stats.score)

    update: ->
        #pointerIsDown = @game.input.mousePointer?.isDown or @game.input.pointer1?.isDown
        #pointerX = @game.input.x
        #pointerY = @game.input.y

        @enemySpawner.update()

    render: ->
        @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
