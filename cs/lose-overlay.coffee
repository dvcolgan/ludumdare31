module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @game.groups.overlay.add(@sprite)
        @text = @game.add.text 200, 200, 'You are the loseriest of losers.',
            font: 'bold 20px Arial'
            fill: 'black'
            align: 'center'

        @hide()

    show: ->
        @sprite.visible = yes
        @text.visible = yes
        @game.world.bringToTop(@text)
        @game.world.bringToTop(@sprite)

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
