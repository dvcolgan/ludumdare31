G = require('./constants')

module.exports = class RockManager
    @properties =
        maxDamage: 20
        range: 50

    constructor: (@game) ->
        @maxRocks = 3
        @stopped = false

        @availableRocks = @maxRocks
        @rocks = []

        for i in [0...@availableRocks]
            rock = new Phaser.Sprite(@game, 700 + 70 * i, 0, 'firewood')
            rock.anchor.setTo(0.5, 0)
            @game.add.existing rock
            @rocks.push rock

    throwRock: (x, y) =>
        return if not @availableRocks or @stopped

        @rocks[@availableRocks - 1].visible = false

        damageEnemies = () =>
            @game.groups.enemy.forEachAlive (enemy) =>
                dist = Phaser.Math.distance(enemy.x, enemy.y, x, y)
                if dist < RockManager.properties.range
                    damage = Phaser.Math.linear(
                        RockManager.properties.maxDamage
                        0
                        dist / RockManager.properties.range
                    )
                    enemy.damage damage
        damageEnemies()

        @availableRocks--

    update: (frame) =>
        if @availableRocks < @maxRocks and frame % 60 == 0
            @regenerateRock()

    regenerateRock: () =>
        return if @stopped
        @rocks[@availableRocks].visible = true
        @availableRocks++

    stop: () =>
        @stopped = true
