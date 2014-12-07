G = require('./constants')

module.exports = class RockManager
    @properties =
        maxDamage: 20
        range: 50
        framesToRegenerateRock: 60

    constructor: (@game) ->
        @maxRocks = 3
        @stopped = false

        @availableRocks = @maxRocks
        @rocks = []

        for i in [0...@availableRocks]
            rock = @makeRandomRock(700 + 70 * i, 15)
            @rocks.push rock

    throwRock: (x, y) =>
        return if not @availableRocks or @stopped

        @rocks[@availableRocks - 1].visible = false

        damageEnemies = () =>
            @game.sounds['snowHit' + @game.rnd.integerInRange(1, 2)].play()
            @game.groups.enemy.forEachAlive (enemy) =>
                dist = Phaser.Math.distance(enemy.x, enemy.y, x, y)
                if dist < RockManager.properties.range
                    damage = Phaser.Math.linear(
                        RockManager.properties.maxDamage
                        0
                        dist / RockManager.properties.range
                    )
                    enemy.damage damage

        rock = @makeRandomRock(-40, -40)
        @game.groups.foreground.add(rock)
        tweenX = @game.add.tween(rock)
        tweenX.to({x: x}, 500, Phaser.Easing.Linear.In)
        tweenX.start()
        tweenY = @game.add.tween(rock)
        tweenY.to({y: y}, 500, Phaser.Easing.Cubic.In)
        tweenY.onComplete.add(damageEnemies)
        tweenY.onComplete.add =>
            @game.add.tween(rock).to({alpha: 0}, 1000, Phaser.Easing.Linear.In).start()
            
        tweenY.start()

        rock.update = ->
            console.log(rock.x, rock.y)

        @availableRocks--

    update: (frame) =>
        if @availableRocks < @maxRocks and frame % RockManager.properties.framesToRegenerateRock == 0
            @regenerateRock()

    regenerateRock: () =>
        return if @stopped
        @rocks[@availableRocks].visible = true
        @availableRocks++

    stop: () =>
        @stopped = true

    makeRandomRock: (x, y) =>
        rock = @game.add.sprite(x, y, 'rocks')
        rock.anchor.setTo(0.5, 0)

        # Pick a random rock
        rock.animations.add 'rock', [0, 1, 2], 0
        rock.animations.play 'rock'
        rock.animations.stop 'rock'
        rock.animations.frame = @game.rnd.integerInRange(0, 2)
        return rock
