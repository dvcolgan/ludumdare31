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
        @game.time.advancedTiming = G.DEBUG

        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0

        @boughtItem = null

        # Initialize rendering groups, order initialized is the order they are drawn
        @game.groups = {}
        @game.groups.background = @game.add.group()
        @game.groups.tower = @game.add.group()
        @game.groups.enemy = @game.add.group()
        @game.groups.overlay = @game.add.group()
        #
        # Initialize physics
        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)
        @game.physics.p2.setBounds(-200, 64, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT - 64)

        # Initialize physics collision groups
        @game.collisionGroups =
            secret: @game.physics.p2.createCollisionGroup()
            tower: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()
        @game.physics.p2.updateBoundsCollisionGroup()

        @stats = new Stats(@game)
        @store = new Store(@game, @towerFactory, @stats)


        window.controller = @

        @background = @game.add.image(0, 0, 'background')
        @background.inputEnabled = true
        @game.groups.background.add(@background)

        @secret = new Secret(@game, G.SCREEN_WIDTH - 100, G.SCREEN_HEIGHT/2)
        @loseOverlay = new LoseOverlay(@game)

        # TODO: Dynamically pass in framerate (should this stay hardcoded to 60?)
        @gameDifficulty = 3
        @enemySpawner = new EnemySpawner(@enemyFactory, 60, @gameDifficulty)

        @background.events.onInputDown.add(@handlePointerDown)
        G.events.onGameOver.add(@handleGameOver)
        G.events.onStoreItemPurchased.add(@handleStoreItemPurchased)

    handleStoreItemPurchased: (itemData) ->
        @boughtItem = itemData

    handlePointerDown: (image, pointer) =>
        if @loseOverlay.isVisible() then return
        if @store.state == 'down' then return

        if @boughtItem
            @towerFactory[@boughtItem.data.createFn](400, 400)
            @boughtItem = null

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
