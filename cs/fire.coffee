module.exports = class Fire
    @spriteKey = 'firewood'

    constructor:  (@game, @sprite) ->
        x = @sprite.x
        y = @sprite.y

        #@emitter = @game.add.emitter(x, y+5, 300)
        #@emitter.makeParticles('fire-particle')
        #@emitter.width = @sprite.width / 3
        #@emitter.height = 5
        #@emitter.gravity = 10
        #@emitter.setXSpeed(-2, 2)
        #@emitter.setYSpeed(-40, -60)
        #@emitter.setAlpha(1, 0.0, 3000)
        #@emitter.setScale(1, 0.5, 1, 0.5, 4000, Phaser.Easing.Quadratic.InOut)
        #@emitter.start(false, 3000, 1)

        #@flare = @game.add.emitter(x, y+5, 300)
        #@flare.makeParticles('fire-particle')
        #@flare.width = @sprite.width / 2
        #@flare.height = 20
        #@flare.gravity = 10
        #@flare.setXSpeed(-60, 60)
        #@flare.setYSpeed(40, -200)
        #@flare.setAlpha(1, 0, 1000)
        #@flare.setScale(1, 0.8, 1, 0.8, 3000, Phaser.Easing.Quadratic.InOut)

    blast: =>
        #@flare.start(true, 1000, null, 300)
