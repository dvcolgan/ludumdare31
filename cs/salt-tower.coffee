G = require('./constants')
Tower = require('./tower')
SaltAnimation = require('./salt-patch')


module.exports = class SaltTower extends Tower
    @properties =
        cooldown: 60
        range: 50
        damage: 1
        animationCls: SaltAnimation

    @FRAMES_TO_DO_OCCASIONAL_DAMAGE = 60 * 1
    @MAX_ENEMY_SPEED = 10

    fire: () =>
        return if not super()

        @animation.blast()

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
