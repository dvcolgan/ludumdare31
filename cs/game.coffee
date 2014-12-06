G = require('./constants')


class PlayState extends Phaser.State
    preload: ->
        #@game.load.image('image', 'assets/image.png')
        #@game.load.spritesheet('spritesheet', 'assets/spritesheet.png', width, height, numframes)
        #@game.load.text('text', 'assets/words.txt')
        #@game.load.physics('image_collision', 'assets/image_collision.json')


    create: ->
        #@game.physics.startSystem(Phaser.Physics.P2JS)
        #@game.physics.p2.setImpactEvents(true)
        #@groups =
        #    player: @game.physics.p2.createCollisionGroup()
        #    bullet: @game.physics.p2.createCollisionGroup()
        #    enemy: @game.physics.p2.createCollisionGroup()

        window.controller = @
        #@cursors = @game.input.keyboard.createCursorKeys()

        #@game.world.setBounds(-10000, -10000, 20000, 20000)
        #@game.camera.x -= Math.floor(@game.stage.width/2)
        #@game.camera.y -= Math.floor(@game.stage.height/2)

        @game.stage.backgroundColor = '#c0ffee'
        @game.time.advancedTiming = G.DEBUG

        #@group1 = @game.add.group()
        #@group2 = @game.add.group()

        #@group1.add(sprite)
        #@group2.add(sprite)

        # TODO: Dynamically pass in framerate (should this stay hardcoded to 60?)
        # TODO: Dynamically pass in difficulty.
        @difficultyManager = new DifficultyManager(@, 60, 1)


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

    #render: ->
    #    @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")

    #    @game.debug.body(@ship.sprite)


window.state = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container', new PlayState())
