module.exports = class LoseOverlay
    constructor: (@game) ->
        @sprite = @game.add.sprite(0, 0, 'lose-overlay')
        @game.groups.overlay.add(@sprite)
        @text = @game.add.text 200, 200, '',
            font: 'bold 20px Arial'
            fill: 'black'
            align: 'left'

        @hide()

    show: (score) ->
        @sprite.visible = yes
        @text.text = switch @game.rnd.between(0, 1)
            when 0 then "You are the loseriest of losers."
            when 1 then "Apparently, you suck."
        @text.text += "\n\nYour score: #{score}"
        @text.visible = yes

    hide: ->
        @sprite.visible = no
        @text.visible = no

    isVisible: ->
        return @sprite.visible
