G = require('./constants')
EnemyFactory = require('./enemy')


class PlayState extends Phaser.State
    preload: ->
        @game.load.image('background', 'assets/background.png')
        @game.load.image('secret', 'assets/secret.png')
        @game.load.image('tower', 'assets/tower.png')

        @enemyFactory = new EnemyFactory(@game)
        @enemyFactory.preload()

    create: ->
        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)
        @groups =
            #player: @game.physics.p2.createCollisionGroup()
            #bullet: @game.physics.p2.createCollisionGroup()
            enemy: @game.physics.p2.createCollisionGroup()

        window.controller = @

        @background = @game.add.image(0, 0, 'background')

        @game.time.advancedTiming = G.DEBUG

        @small = @enemyFactory.createSmall(100, 200)

        #@group1 = @game.add.group()
        #@group2 = @game.add.group()

        #@group1.add(sprite)
        #@group2.add(sprite)

        # TODO: Dynamically pass in framerate (should this stay hardcoded to 60?)
        # TODO: Dynamically pass in difficulty.
        @difficultyManager = new DifficultyManager(@enemyFactory, 60, 1)


    #screenWrap: (sprite) =>

    #    if sprite.body.x < -sprite.width/2
    #        sprite.body.x = @game.width + sprite.width/2
    #    else if sprite.body.x > @game.width + sprite.width/2
    #        sprite.body.x = -sprite.width/2

    #    if sprite.body.y < -sprite.height/2
    #        sprite.body.y = @game.height + sprite.height/2
    #    else if sprite.body.y > @game.height + sprite.height/2
    #        sprite.body.y = -sprite.height/2

    update: ->
        #pointerIsDown = @game.input.mousePointer?.isDown or @game.input.pointer1?.isDown
        #pointerX = @game.input.x
        #pointerY = @game.input.y

        #if @cursors.up.isDown then @game.camera.y += 5
        #if @cursors.down.isDown then @game.camera.y -= 5
        #if @cursors.left.isDown then @game.camera.x += 5
        #if @cursors.right.isDown then @game.camera.x -= 5

        @difficultyManager.update()

    render: ->
        @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")
        @game.debug.body(@ship.sprite)


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
