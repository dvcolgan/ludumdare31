G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (@game, x, y, key, @cooldown, @range, @damage) ->
        super(@game, x, y, key)
        @game.add.existing(@)

        @inputEnabled = true
        @events.onInputDown.add(@handleClick, @)
        @anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.kinematic = yes
        @body.setCollisionGroup(@game.collisionGroups.tower)
        #@body.collides([@game.collisionGroups.enemy])
        @game.groups.tower.add(@)
        #@body.createGroupCallback(@game.collisionGroups.enemy, @onEnemyTouch)

        @enemyGroup = @game.groups.enemy


        # Number of frames before
        @cooldownRemaining = 0

        @cooldownMeterData = @game.add.bitmapData(@width + 16, @height + 16)
        @cooldownMeter = @game.add.sprite(0, 0, @cooldownMeterData)
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
        @doConstantEffect()
        @decreaseCooldownRemaining()
        @makeCooldownMeter()

    decreaseCooldownRemaining: () =>

        # At 60 fps, it would take 4760 millenia to hit min value
        @cooldownRemaining -= 1

    handleClick: () =>
        @fire()

    resetCooldown: () =>
        @cooldownRemaining = @cooldown

    fire: () =>
        return false if @cooldownRemaining > 0

        @resetCooldown()

        return true

    doConstantEffect: () =>
        return @cooldownRemaining < 0


class Fire extends Tower
    @FRAMES_TO_DO_OCCASIONAL_DAMAGE = 60 * 10

    fire: () =>
        return if not super()

        # Search for all enemies within @range
        # Kill/delete all enemies found within range
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2 + @range
                enemy.damage @damage

    doConstantEffect: () =>
        return if not super()
        return if @game.frame % @constructor.FRAMES_TO_DO_OCCASIONAL_DAMAGE != 0

        @resetCooldown()

        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2 + @range
                damage = Math.floor((@range - dist + (@width + enemy.width) / 2) / @range * @damage)
                enemy.damage damage


class Snowblower extends Tower
    fire: () =>
        return if not super()

        # If there are any enemies directly to the left, damage them and shoot them back
        @enemyGroup.forEachAlive (enemy) =>
            dx = @x - enemy.x
            dy = @y - enemy.y
            if Math.abs(dy) < @height / 2 and dx >= 0 and dx <= @range
                enemy.body.moveLeft @range
                enemy.damage @damage


class Salt extends Tower
    @FRAMES_TO_DO_OCCASIONAL_DAMAGE = 60 * 1
    @MAX_ENEMY_SPEED = 10

    fire: () =>
        return if not super()

        # If there are any enemies on top of it, stun them
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2 + @range
                enemy.body.setZeroVelocity()

    doConstantEffect: () =>
        # If there are any enemies on top of it, slow them down
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2

                # Limit the enemy's speed
                vector = new Phaser.Point(enemy.body.velocity.x, enemy.body.velocity.y)
                magnitude = vector.getMagnitude()
                if magnitude > @constructor.MAX_ENEMY_SPEED
                    vector.setMagnitude(@constructor.MAX_ENEMY_SPEED)
                    enemy.body.velocity.x = vector.x
                    enemy.body.velocity.y = vector.y

                # Do damage to the enemy
                if @game.frame % @constructor.FRAMES_TO_DO_OCCASIONAL_DAMAGE == 0
                    enemy.damage @damage


module.exports = class TowerFactory
    constructor: (@game) ->

    createFire: (x, y) =>
        tower = new Fire(
            @game
            x
            y
            'firewood'
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
            'fan'
            60   # cooldown
            100  # range
            10   # damage
        )

    createSalt: (x, y) =>
        tower = new Salt(
            @game
            x
            y
            'tower-aoe'
            60   # cooldown
            50   # range
            1    # damage
        )
