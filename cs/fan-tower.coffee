G = require('./constants')
Tower = require('./tower')
FanAnimation = require('./fan')


module.exports = class FanTower extends Tower
    @properties =
        cooldown: 120
        range: 100
        damage: 10
        animationCls: FanAnimation
        drawRangeMarker: false

    fire: () =>
        return if not super()

        @animation.blast()

        # If there are any enemies directly to the left, damage them and shoot them back
        @enemyGroup.forEachAlive (enemy) =>
            dx = @x - enemy.x
            dy = @y - enemy.y
            if Math.abs(dy) < @height / 2 and dx >= 0 and dx <= @range
                enemy.body.moveLeft @range
                enemy.damage @damage
