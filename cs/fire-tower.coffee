G = require('./constants')
Tower = require('./tower')
FireAnimation = require('./fire')


module.exports = class FireTower extends Tower
    @properties =
        cooldown: 120
        range: 100
        damage: 15
        animationCls: FireAnimation
        framesToDoOccasionalDamage: 600

    fire: () =>
        return if not super()

        @animation.blast()

        # Search for all enemies within @range
        # Kill/delete all enemies found within range
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2 + @range
                enemy.damage @damage

    doConstantEffect: () =>
        return if not super()
        return if @game.frame % FireTower.properties.framesToDoOccasionalDamage != 0

        @animation.blast()

        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < (@width + enemy.width) / 2 + @range
                damage = Math.floor((@range - dist + (@width + enemy.width) / 2) / @range * @damage)
                enemy.damage damage
