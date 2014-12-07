module.exports = class Fire
    constructor:  (@game, x, y) ->
        @wood = @game.add.sprite(x, y, 'firewood')
        @wood.anchor.setTo(0.5, 0.5)
        @emitter = @game.add.emitter(x, y+5, 300)
        @emitter.makeParticles('fire-particle')
        @emitter.width = @wood.width / 3
        @emitter.height = 5
        @emitter.gravity = 10
        @emitter.setXSpeed(-2, 2)
        @emitter.setYSpeed(-40, -60)
        @emitter.setAlpha(1, 0.0, 3000)
        @emitter.setScale(1, 0.5, 1, 0.5, 4000, Phaser.Easing.Quadratic.InOut)
        @emitter.start(false, 3000, 1)
