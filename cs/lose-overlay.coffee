G = require('./constants')

module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @game.groups.overlay.add(@sprite)

        # Game Over text
        gameOverText = @game.add.bitmapText 0, 0, 'font', 'Game Over', 80
        gameOverText.x = G.SCREEN_WIDTH / 2 - gameOverText.width / 2
        gameOverText.y = 100
        @sprite.addChild gameOverText

        # Score text
        @text = @game.add.text 200, 250, '',
            font: 'bold 40px Droid Sans'
            fill: 'white'
            align: 'left'

        # Restart button
        button = @game.add.button @sprite.width / 2, @sprite.height - 140, 'button', (() =>
            @game.state.start('HowToPlay')
            @game.sounds.click.play()
        ), @, 1, 0, 2
        button.anchor.set 0.5
        @sprite.addChild button

        restartText = @game.add.text 0, 0, 'Restart',
            font: 'bold 20px Droid Sans'
            fill: 'white'
        restartText.anchor.set 0.5
        button.addChild restartText

        @hide()

    show: (score, enemiesKilled) ->
        @sprite.visible = yes
        @text.text = "Your score: #{score}\nSnowmen killed: #{enemiesKilled}"
        @text.visible = yes

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
