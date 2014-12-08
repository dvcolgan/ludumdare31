G = require('./constants')
Tower = require('./tower')
FireAnimation = require('./fire')


module.exports = class FireTower extends Tower
    @properties =
        cooldown: 120
        range: 70
        damage: 15
        animationCls: FireAnimation
        framesToDoOccasionalDamage: 120
        drawRangeMarker: true

    fire: () =>
        return if not super()

        @animation.blast()

        # Search for all enemies within @range
        # Kill/delete all enemies found within range
        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < enemy.radius / 2 + @range
                enemy.damage @damage

    doConstantEffect: () =>
        return if not super()
        return if @game.frame % FireTower.properties.framesToDoOccasionalDamage != 0

        @enemyGroup.forEachAlive (enemy) =>
            dist = Phaser.Math.distance(enemy.x, enemy.y, @x, @y)
            if dist < enemy.radius / 2 + @range
                enemy.damage 1
