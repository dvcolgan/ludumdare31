G = require('./constants')


module.exports = class Secret extends Phaser.Sprite
    @properties =
        maxHealth: 100
        damageDistance: 10 # How many pixels away can an enemy start doing damage?

    constructor: (@game, x, y) ->
        super(@game, x, y, 'secret')

        @game.add.existing(@)
        @anchor.setTo 0.5
        @game.physics.p2.enable(@, G.DEBUG)
        @body.kinematic = yes
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(@game.collisionGroups.secret)
        @body.collides([@game.collisionGroups.enemy])

        @enemyGroup = @game.groups.enemy

        # Health text
        @health = Secret.properties.maxHealth
        @healthText = @game.add.text 0, 0, @health,
            font: '10px Droid Sans'
            fill: 'black'
            align: 'center'
        @addChild @healthText


    restoreMaxHealth: () =>
        @damage(@health - Secret.properties.maxHealth)


    damage: (damage) =>
        super damage

        @healthText.text = @health

        if @health <= 0
            G.events.onGameOver.dispatch()


    update: () =>
        return if not @alive
        return if @game.frame % 10 != 0
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < enemy.radius + @width / 2 + Secret.properties.damageDistance
                enemy.damage 1
                @damage 1
