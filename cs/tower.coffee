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
        return false if @cooldownRemaining > 0

        # Reset cooldown
        @cooldownRemaining = @cooldown

        return true

class Fire extends Tower
    fire: () =>
        return if not super()

        # Search for all enemies within @range
        # Kill/delete all enemies found within range
        @game.groups.enemy.forEachAlive (enemy) =>
            dist = Math.sqrt((enemy.x - @x)**2 + (enemy.y - @y)**2)
            if dist < @range
                enemy.damage @damage


class Snowblower extends Tower
    fire: () =>
        return if not super()

        # If there are any enemies directly to the left, damage them and shoot them back
        @game.groups.enemy.forEachAlive (enemy) =>
            dx = @x - enemy.x
            if Phaser.Math.within(enemy.y, @y, 30) and dx >= 0 and dx <= @range # TODO: Change hardcoded value of 30
                enemy.body.moveLeft @range
                enemy.damage @damage


module.exports = class TowerFactory
    constructor: (@game) ->

    createFire: (x, y) =>
        tower = new Fire(
            @game
            x
            y
            'tower-aoe'
            60   # cooldown
            100  # range
            15   # damage
        )
        return tower

    createSnowblower: (x, y) =>
        tower = new Snowblower(
            @game
            x
            y
            'tower-aoe'
            60   # cooldown
            100  # range
            10   # damage
        )
