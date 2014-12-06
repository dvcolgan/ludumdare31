G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key, @cooldown, @range) ->
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

        # Search for all enemies within @range
        # Kill/delete all enemies found within range

        # Reset cooldown
        @cooldown = @cooldownRemaining


module.exports = class TowerFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('tower-aoe', 'assets/tower-aoe.png')

    createAoe: (x, y) =>
        tower = new Tower(@game, x, y, 'tower-aoe', 60, 100)

        tower.anchor.setTo(0.5, 0.5)
        tower.body.clearShapes()
        tower.body.addCircle(tower.width/2)
        return tower
