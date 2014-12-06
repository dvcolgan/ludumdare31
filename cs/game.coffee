G = require('./constants')
EnemySpawner = require('./enemy-spawner')
EnemyFactory = require('./enemy')
TowerFactory = require('./tower')
LoseOverlay = require('./lose-overlay')
Secret = require('./secret')


class PlayState extends Phaser.State
    preload: ->
        @game.load.image('background', 'assets/background.png')
        @game.load.image('secret', 'assets/secret.png')
        @game.load.image('tower', 'assets/tower.png')

        @game.groups =
            enemy: @game.add.group()

        @enemyFactory = new EnemyFactory(@game)
        @enemyFactory.preload()
        @towerFactory = new TowerFactory(@game)
        @towerFactory.preload()

        @game.load.image('lose-overlay', 'assets/lose-overlay.png')


    create: ->
        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0

        @game.events =
            onGameOver: new Phaser.Signal()

        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)


        @game.collisionGroups =
            secret: @game.physics.p2.createCollisionGroup()
            tower: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()

        window.controller = @

        @background = @game.add.image(0, 0, 'background')
        @background.inputEnabled = true

        @game.time.advancedTiming = G.DEBUG

        @small = @enemyFactory.createSmall()
        @medium = @enemyFactory.createMedium()
        @large = @enemyFactory.createLarge()

        @secret = new Secret(@game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT/2)

        @loseOverlay = new LoseOverlay(@game)

        #@group1 = @game.add.group()
        #@group2 = @game.add.group()

        #@group1.add(sprite)
        #@group2.add(sprite)

        # TODO: Dynamically pass in framerate (should this stay hardcoded to 60?)
        # TODO: Dynamically pass in difficulty.
        @gameDifficulty = 1
        @enemySpawner = new EnemySpawner(@enemyFactory, 60, @gameDifficulty)

        @background.events.onInputDown.add(@handlePointerDown)
        @game.events.onGameOver.add(@handleGameOver)

    handlePointerDown: (image, pointer) =>
        if @loseOverlay.isVisible() then return
        @towerFactory.createAoe(pointer.x, pointer.y)

    handleGameOver: =>
        @loseOverlay.show()

    update: ->
        #pointerIsDown = @game.input.mousePointer?.isDown or @game.input.pointer1?.isDown
        #pointerX = @game.input.x
        #pointerY = @game.input.y
        
        @enemySpawner.update()

    render: ->
        @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
