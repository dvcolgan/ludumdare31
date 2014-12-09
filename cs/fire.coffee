module.exports = class Fire
    @spriteKey = 'firewood'

    constructor:  (@game, @sprite) ->
        x = @sprite.x
        y = @sprite.y

        @flames = @game.add.sprite(x, y+5, 'flames')
        @flames.animations.add('burn', [0..4], 10, true)
        @flames.animations.play('burn')
        @flames.anchor.setTo(0.5, 0.91)
        @flames.scale.setTo(0.8)
        @game.groups.tower.add @flames
        @game.sounds.fireActivate.play()

    blast: =>
        @game.sounds.fireActivate.play()
        @game.add.tween(@flames.scale)
            .to({x: 1.5, y: 2}, 500, Phaser.Easing.Circular.Out)
            .to({x: 1, y: 1}, 600, Phaser.Easing.Circular.In)
            .start()
