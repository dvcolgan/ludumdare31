module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @text = @game.add.text 200, 200, '',
            font: 'bold 20px Arial'
            fill: 'black'
            align: 'center'

        @hide()

    show: (score) ->
        @sprite.visible = yes
        @text.text = "You are the loseriest of losers.\n\nYour score: #{score}"
        @text.visible = yes
        @game.world.bringToTop(@text)
        @game.world.bringToTop(@sprite)

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
