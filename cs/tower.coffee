G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key, @cooldown) ->
        super(game, x, y, key)
        game.add.existing(@)

        # Number of frames before
        @cooldownRemaining = 0

    update: () =>
        @decreaseCooldownRemaining()

    decreaseCooldown: () =>

        # At 60 fps, it would take 4760 millenia to hit min value
        @cooldownRemaining -= 1

    fire: () =>
        return if @cooldownRemaining > 0

        # TODO: Make things happen

        # Reset cooldown
        @cooldown = @cooldownRemaining


module.exports = class TowerFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('tower-aoe', 'assets/tower-aoe.png')

    createAoe: (x, y) =>
        tower = new Tower(@game, x, y, 'tower-aoe', 60)

        tower.anchor.setTo(0.5, 0.5)
        tower.body.clearShapes()
        tower.body.addCircle(tower.width/2)
        return tower
