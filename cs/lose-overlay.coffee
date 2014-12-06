module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @game.groups.overlay.add(@sprite)
        @text = @game.add.text 200, 200, '',
            font: 'bold 20px Arial'
            fill: 'black'
            align: 'center'

        @hide()

    show: (score) ->
        @sprite.visible = yes
        @text.text = "You are the loseriest of losers.\n\nYour score: #{score}"
        @text.visible = yes

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
