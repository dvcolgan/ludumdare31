module.exports = class Store
    constructor: (@game) ->
        @overlay = @game.add.sprite(0, -474, 'store-overlay')
        @overlay.inputEnabled = true
        @game.groups.overlay.add(@overlay)
        @slideDownTween = @game.add.tween(@overlay).to({y: 0}, 1000, Phaser.Easing.Bounce.Out)
        @slideUpTween = @game.add.tween(@overlay).to({y: -474}, 1000, Phaser.Easing.Bounce.Out)

        @overlay.events.onInputDown.add(@toggleStore)
        @state = 'up'

    toggleStore: =>
        if @state == 'up'
            @slideDownTween.start()
            @state = 'down'
        else if @state == 'down'
            @slideUpTween.start()
            @state = 'up'
