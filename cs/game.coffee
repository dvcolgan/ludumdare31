G = require('./constants')
RockManager = require('./rock-manager')
EnemySpawner = require('./enemy-spawner')
EnemyFactory = require('./enemy')
FireTower = require('./fire-tower')
FanTower = require('./fan-tower')
SaltTower = require('./salt-tower')
LoseOverlay = require('./lose-overlay')
Store = require('./store')
Secret = require('./secret')
Stats = require('./stats')
Fire = require('./fire')
Fan = require('./fan')
SaltPatch = require('./salt-patch')
WeatherGenerator = require('./weather-generator')


class BootState
    preload: ->
        @load.image('loading-bar', 'assets/loading-bar.png')

    create: ->
        @game.state.start('Preload')


class PreloadState
    preload: ->
        @game.stage.backgroundColor = 'black'
        @loadingBar = @game.add.sprite(G.SCREEN_WIDTH/2, G.SCREEN_HEIGHT/2, 'loading-bar')
        @loadingBar.anchor.setTo(0.5)
        @game.load.setPreloadSprite(@loadingBar)

        @game.load.image('background', 'assets/background.png')
        @game.load.image('secret', 'assets/secret.png')
        @game.load.image('tower', 'assets/tower.png')

        @game.load.image('title-screen', 'assets/title-screen.png')
        @game.load.image('how-to-play', 'assets/how-to-play.png')
        @game.load.image('lose-overlay', 'assets/lose-overlay.png')
        @game.load.image('store-overlay', 'assets/store-overlay.png')
        @game.load.image('store-slot', 'assets/store-slot.png')

        @game.load.image('firewood', 'assets/firewood.png')
        @game.load.image('fire-particle', 'assets/fire-particle.png')
        @game.load.image('fire-store-icon', 'assets/fire-store-icon.png')
        @game.load.spritesheet('flames', 'assets/flames.png', 64, 82, 5)

        @game.load.spritesheet('fan', 'assets/fan.png', 64, 64, 4)
        @game.load.spritesheet('snow-particles', 'assets/snow-particles.png', 4, 4, 4)
        @game.load.spritesheet('snowflake-particles', 'assets/snowflake-particles.png', 16, 16, 5)

        @game.load.spritesheet('cooldown', 'assets/cooldown.png', 96, 96, 13)

        @game.load.image('salt-patch', 'assets/salt-patch.png', 64, 64)
        @game.load.image('salt-particle', 'assets/salt-particle.png')

        @game.load.spritesheet('snowman', 'assets/snowman.png', 94, 101, 8)

        @game.load.audio('play-bgm', 'assets/happybgm.ogg')
        @game.load.audio('gameover-bgm', 'assets/gameoverbgm.ogg')

        @game.load.spritesheet('rocks', 'assets/rocks.png', 48, 32, 3)

        @game.load.audio('snow-hit1', 'assets/snow-hit1.ogg')
        @game.load.audio('snow-hit2', 'assets/snow-hit2.ogg')

        @game.load.audio('click', 'assets/click.ogg')
        @game.load.audio('dying-snowman', 'assets/dying-snowman.ogg')
        @game.load.audio('fan-activate', 'assets/fan-activate.ogg')
        @game.load.audio('fire-activate', 'assets/fire-activate.ogg')
        @game.load.audio('item-buy', 'assets/item-buy.ogg')
        @game.load.audio('nuke-explosion', 'assets/nuke-explosion.ogg')
        @game.load.audio('open-store', 'assets/open-store.ogg')
        @game.load.audio('rock-woosh', 'assets/rock-woosh.ogg')

        @game.load.image('music-on', 'assets/speaker-on.png')
        @game.load.image('music-off', 'assets/speaker-off.png')
        @game.load.bitmapFont('font', 'assets/font.png', 'assets/font.fnt')

        @game.load.image('fire-upgrade', 'assets/fire-upgrade.png')
        @game.load.image('salt-upgrade', 'assets/salt-upgrade.png')
        @game.load.image('fan-upgrade', 'assets/fan-upgrade.png')
        @game.load.image('secret-heal', 'assets/secret-heal.png')

        @game.load.image('mini-nuke', 'assets/mini-nuke.png')
        @game.load.image('nuke-blast', 'assets/nuke-blast.png')

        @game.load.spritesheet('button', 'assets/button.png', 150, 48, 3)
        @initializeMusic()

    create: ->
        @game.state.start('Title')

    initializeMusic: () =>
        @game.music = @game.add.audio('play-bgm', 0.2)
        @game.music.loop = yes
        @game.music.play()


class TitleState
    create: ->

        # Title text
        titleText = @game.add.bitmapText 0, 0, 'font', 'Snowman Attack', 100
        titleText.x = G.SCREEN_WIDTH / 2 - titleText.width / 2
        titleText.y = 20

        # Background image
        titleImage = @game.add.sprite G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT - 60, 'title-screen'
        titleImage.anchor.set 0.5, 1

        # Continue text
        continueText = @game.add.text G.SCREEN_WIDTH / 2, G.SCREEN_HEIGHT - 20, "Tap/Click to Continue",
            font: "Bold 16px Droid Sans"
            fill: "white"
        continueText.anchor.setTo 0.5, 1

        @game.input.onDown.add () =>
            @game.state.start('HowToPlay')


class HowToPlayState
    create: ->
        overlay = @game.add.sprite(0, 0, 'how-to-play')
        @clickSound = @game.add.audio('click')

        buttons = []
        buttons.push @game.add.button 0, 0, 'button', @startEasy, @, 1, 0, 2
        buttons.push @game.add.button 0, 0, 'button', @startMedium, @, 1, 0, 2
        buttons.push @game.add.button 0, 0, 'button', @startHard, @, 1, 0, 2

        for button, i in buttons
            button.text = @game.add.text button.width / 2, button.height / 2, '',
                font: '20px Droid Sans'
                fill: 'white'
            button.text.anchor.setTo 0.5
            button.addChild button.text
            button.x = 20 + (i * 200)
            button.y = overlay.height - 150 + overlay.y + 10
            overlay.addChild button

        buttons[0].text.text = 'Easy'
        buttons[1].text.text = 'Medium'
        buttons[2].text.text = 'Hard'

    startEasy: =>
        @game.difficulty = 1
        @startGame()

    startMedium: =>
        @game.difficulty = 2
        @startGame()

    startHard: =>
        @game.difficulty = 3
        @startGame()

    startGame: =>
        @clickSound.play()
        @game.state.start('Play')



class PlayState extends Phaser.State
    initializeSoundEffects: =>
        @game.sounds =
            snowHit1: @game.add.audio('snow-hit1')
            snowHit2: @game.add.audio('snow-hit2')
            click: @game.add.audio('click')
            dyingSnowman: @game.add.audio('dying-snowman')
            fanActivate: @game.add.audio('fan-activate')
            fireActivate: @game.add.audio('fire-activate')
            itemBuy: @game.add.audio('item-buy')
            nukeExplosion: @game.add.audio('nuke-explosion')
            openStore: @game.add.audio('open-store')
            rockWoosh: @game.add.audio('rock-woosh')


    initializeMusic: =>
        #@game.music.play()

        pauseBtn = @game.add.sprite G.SCREEN_WIDTH, 0, 'music-on'
        pauseBtn.anchor.setTo(1, 0)
        pauseBtn.inputEnabled = true
        pauseBtn.events.onInputDown.add () =>
            @game.music.pause()
            resumeBtn.visible = true
            pauseBtn.visible = false

        resumeBtn = @game.add.sprite G.SCREEN_WIDTH, 0, 'music-off'
        resumeBtn.anchor.setTo(1, 0)
        resumeBtn.visible = false
        resumeBtn.inputEnabled = true
        resumeBtn.events.onInputDown.add () =>
            @game.music.play()
            resumeBtn.visible = false
            pauseBtn.visible = true

    initializeSnowExplosion: =>

    create: =>
        @initializeGame()
        @initializePhysicsEngine()
        @initializeGroups()
        @initializeSoundEffects()
        @initializeMusic()

        @game.physics.p2.updateBoundsCollisionGroup()

        @stats = new Stats(@game)
        @store = new Store(@game, @stats)
        @rockManager = new RockManager(@game)
        @initializeBackground()
        @initializeSecret()
        @loseOverlay = new LoseOverlay(@game)
        @initializeEnemySpawner()
        @weatherGenerator = new WeatherGenerator(@game)

        G.events.onGameOver.add(@handleGameOver)
        G.events.onStoreItemPurchased.add(@handleStoreItemPurchased)
        G.events.onStoreOpen.add(@pauseGame)
        G.events.onStoreClose.add(@resumeGame)

        @game.frame = 0
        @game.isPaused = false

    initializeGame: () =>
        @game.world.setBounds(-200, 0, G.SCREEN_WIDTH + 200, G.SCREEN_HEIGHT)
        @game.camera.x = 0
        @game.time.advancedTiming = G.DEBUG
        window.controller = @
        @boughtItem = null
        @cursorSprite = null

    initializePhysicsEngine: () =>
        @game.physics.startSystem(Phaser.Physics.P2JS)
        @game.physics.p2.setImpactEvents(true)
        @game.physics.p2.setBounds(
            G.PHYSICS_BOUNDS_X_MIN
            G.PHYSICS_BOUNDS_Y_MIN
            G.PHYSICS_BOUNDS_X_MAX
            G.PHYSICS_BOUNDS_Y_MAX
        )

    initializeGroups: () =>
        @game.groups = {}
        @game.groups.background = @game.add.group()
        @game.groups.tower = @game.add.group()
        @game.groups.enemy = @game.add.group()
        @game.groups.secret = @game.add.group()
        @game.groups.overlay = @game.add.group()
        @game.groups.foreground = @game.add.group()

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
        @enemySpawner = new EnemySpawner(enemyFactory, 60, @game.difficulty)

    initializeSecret: () =>
        @secret = new Secret(@game, G.SCREEN_WIDTH - 50, G.SCREEN_HEIGHT/2)


    handlePointerDownOnBackground: (image, pointer) =>
        if @boughtItem
            tower = new @boughtItem.class(@game, pointer.x, pointer.y)
            @boughtItem = null
            @cursorSprite.destroy()
            G.events.onTowerPlaced.dispatch(tower)
        else
            @rockManager.throwRock(pointer.x, pointer.y)


    handleGameOver: () =>
        @enemySpawner.stop()
        @rockManager.stop()
        @loseOverlay.show(@stats.score, @stats.enemiesKilled)


    handleStoreItemPurchased: (itemData) =>
        @boughtItem = itemData

        if @boughtItem.placeable
            @cursorSprite = @game.add.sprite(@game.input.x, @game.input.y, itemData.imageKey)
            @game.groups.overlay.add(@cursorSprite)
            @cursorSprite.anchor.setTo(0.5, 0.5)
            @cursorSprite.alpha = 0.5
            @cursorSprite.update = =>
                @cursorSprite.x = @game.input.x
                @cursorSprite.y = @game.input.y
        else
            args = []
            for arg in @boughtItem.requires
                args.push @[arg]
            @boughtItem.createFn.apply @, args
            @boughtItem = null

    update: () =>
        return if @game.isPaused

        @game.frame++
        @enemySpawner.update(@game.frame)
        @rockManager.update(@game.frame)
        if @game.frame % 10 == 0
            @game.groups.enemy.sort('y', Phaser.Group.SORT_ASCENDING)
            @game.groups.tower.sort('y', Phaser.Group.SORT_ASCENDING)

    render: () =>
        if G.DEBUG
            @game.debug.text(@game.time.fps || '--', 2, 14, "#00ff00")

    pauseGame: () =>
        @game.isPaused = true
        @game.physics.p2.pause()

    resumeGame: () =>
        @game.isPaused = false
        @game.physics.p2.resume()


window.game = new Phaser.Game(G.SCREEN_WIDTH, G.SCREEN_HEIGHT, Phaser.AUTO, 'game-container')
window.game.state.add('Boot', BootState)
window.game.state.add('Preload', PreloadState)
window.game.state.add('Title', TitleState)
window.game.state.add('HowToPlay', HowToPlayState)
window.game.state.add('Play', PlayState)
window.game.state.start('Boot')
