module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @game.groups.overlay.add(@sprite)
        @text = @game.add.text 200, 200, '',
            font: 'bold 20px Droid Sans'
            fill: 'black'
            align: 'left'

        button = @game.add.button @sprite.width / 2, @sprite.height - 110, 'tower-aoe', () =>
            @game.state.start('HowToPlay')
        button.anchor.set 0.5
        @sprite.addChild button

        restartText = @game.add.text 0, 0, 'Restart',
            font: 'bold 20px Droid Sans'
            fill: 'black'
        restartText.anchor.set 0.5
        button.addChild restartText

        @hide()

    show: (score, enemiesKilled) ->
        @sprite.visible = yes
        @text.text = "Game Over.\n\nYour score: #{score}\nSnowmen killed: #{enemiesKilled}"
        @text.visible = yes

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
