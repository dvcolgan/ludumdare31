G = require('./constants')


module.exports = class Secret extends Phaser.Sprite
    @properties =
        maxHealth: 100
        damageDistance: 10 # How many pixels away can an enemy start doing damage?

    constructor: (@game, x, y) ->
        super(@game, x, y, 'secret')


        @game.add.existing(@)
        @game.groups.secret.add(@)
        @anchor.setTo 0.5
        @game.physics.p2.enable(@, G.DEBUG)
        @body.kinematic = yes
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(@game.collisionGroups.secret)
        @body.collides([@game.collisionGroups.enemy])

        @enemyGroup = @game.groups.enemy

        @health = Secret.properties.maxHealth

        @healthMeterData = @game.add.bitmapData(96, 16)
        @healthMeter = @game.add.sprite(@x, @y-40, @healthMeterData)
        @healthMeter.anchor.setTo(0.5)
        @game.groups.secret.add(@healthMeter)

        @makeHealthMeter()

    makeHealthMeter: () =>
        @healthMeterData.cls()
        amount = (@health / Secret.properties.maxHealth) * @healthMeterData.width
        color = if amount > 32
            '#00ff00'
        else if amount > 16
            '#ffff00'
        else
            '#ff0000'

        @healthMeterData.rect(
            0, 0,
            @healthMeterData.width,
            @healthMeterData.height,
            'black')
        @healthMeterData.rect(
            2, 2,
            amount-4,
            @healthMeterData.height-4,
            color)
        @healthMeterData.render()

    restoreMaxHealth: () =>
        @damage(@health - Secret.properties.maxHealth)
        @makeHealthMeter()


    damage: (damage) =>
        super damage

        @makeHealthMeter()

        if @health <= 0
            G.events.onGameOver.dispatch()


    update: () =>
        return if not @alive or @game.isPaused
        return if @game.frame % 10 != 0
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < enemy.radius + @width / 2 + Secret.properties.damageDistance
                enemy.damage 1
                @damage 1

                G.events.onSecretDamaged.dispatch(-1)
