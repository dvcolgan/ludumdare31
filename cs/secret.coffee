G = require('./constants')


module.exports = class Secret extends Phaser.Sprite
    @MAX_HEALTH = 100

    constructor: (@game, x, y) ->
        super(@game, x, y, 'secret')
        @game.add.existing(@)
        @anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(@, G.DEBUG)
        @body.kinematic = yes
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(@game.collisionGroups.secret)
        @body.collides([@game.collisionGroups.enemy])

        @enemyGroup = @game.groups.enemy

        # Health text
        @health = Secret.MAX_HEALTH
        @healthText = new Phaser.Text @game, 0, 0, @health,
            font: '10px Arial'
            fill: 'black'
            align: 'center'
        @addChild @healthText


    restoreMaxHealth: () =>
        @damage(@health - Secret.MAX_HEALTH)


    damage: (damage) =>
        super damage

        @healthText.text = @health

        if @health <= 0
            G.events.onGameOver.dispatch()


    update: () =>
        return if not @alive
        return if @game.frame % 10 != 0
        @enemyGroup.forEachAlive (enemy) =>
            if Phaser.Math.within(
                Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
                (@width + enemy.width) / 2
                3 # How close does the enemy have to be to do damage?
            )
                enemy.damage 1
                @damage 1
