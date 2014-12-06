G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key, @cooldown, @range, @damage) ->
        super(game, x, y, key)
        game.add.existing(@)

        @inputEnabled = true
        @events.onInputDown.add(@handleClick, @)
        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.kinematic = yes
        @body.setCollisionGroup(@game.collisionGroups.tower)
        @body.collides([@game.collisionGroups.enemy])
        game.groups.tower.add(@)
        #@body.createGroupCallback(@game.collisionGroups.enemy, @onEnemyTouch)


        # Number of frames before
        @cooldownRemaining = 0

        @cooldownMeterData = game.add.bitmapData(@width + 16, @height + 16)
        @cooldownMeter = game.add.sprite(0, 0, @cooldownMeterData)
        @cooldownMeter.anchor.setTo(0.5, 0.5)
        @addChild(@cooldownMeter)

    makeCooldownMeter: ->
        @cooldownMeterData.cls()
        if @cooldownRemaining > 0
            ctx = @cooldownMeterData.context
            width = @cooldownMeterData.width
            height = @cooldownMeterData.height

            ctx.strokeStyle = 'black'
            ctx.lineWidth = 8
            ctx.beginPath()
            remaining = @cooldown - @cooldownRemaining / @cooldown
            ctx.arc(width/2, height/2, @width/2 + 4, remaining * Math.PI * 2 - Math.PI/2, -Math.PI/2)
            console.log(remaining * Math.PI * 2)
            ctx.stroke()
            ctx.closePath()
        @cooldownMeterData.render()

    update: () =>
        @decreaseCooldownRemaining()
        @makeCooldownMeter()

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
