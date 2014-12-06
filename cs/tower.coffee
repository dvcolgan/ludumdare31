G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key, @cooldown, @range, @damage) ->
        super(game, x, y, key)

        @inputEnabled = true
        @events.onInputDown.add(@handleClick, @)
        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.kinematic = yes
        @body.setCollisionGroup(@game.collisionGroups.tower)
        @body.collides([@game.collisionGroups.enemy])
        #@body.createGroupCallback(@game.collisionGroups.enemy, @onEnemyTouch)

        game.add.existing(@)

        # Number of frames before
        @cooldownRemaining = 0

    update: () =>
        @decreaseCooldownRemaining()

    decreaseCooldownRemaining: () =>

        # At 60 fps, it would take 4760 millenia to hit min value
        @cooldownRemaining -= 1

    handleClick: () =>
        @fire()

    fire: () =>
        return if @cooldownRemaining > 0

        # Search for all enemies within @range
        # Kill/delete all enemies found within range
        @game.groups.enemy.forEachAlive (enemy) =>
            dist = Math.sqrt((enemy.x - @x)**2 + (enemy.y - @y)**2)
            if dist < @range
                enemy.damage(@damage)

        # Reset cooldown
        @cooldownRemaining = @cooldown


module.exports = class TowerFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('tower-aoe', 'assets/tower.png')

    createAoe: (x, y) =>
        tower = new Tower(
            @game
            x
            y
            'tower-aoe'
            60   # cooldown
            100  # range
            10   # damage
        )
        return tower
