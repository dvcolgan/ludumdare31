G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key, @cooldown, @range) ->
        super(game, x, y, key)

        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.kinematic = yes
        @body.setCollisionGroup(@game.groups.tower)
        @body.collides([@game.groups.enemy])
        #@body.createGroupCallback(@game.groups.enemy, @onEnemyTouch)

        game.add.existing(@)

        # Number of frames before
        @cooldownRemaining = 0

    update: () =>
        @decreaseCooldownRemaining()

    decreaseCooldownRemaining: () =>

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
        @game.load.image('tower-aoe', 'assets/tower.png')

    createAoe: (x, y) =>
        tower = new Tower(@game, x, y, 'tower-aoe', 60, 100)
        return tower
