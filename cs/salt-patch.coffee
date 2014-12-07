module.exports = class SaltPatch
    @spriteKey = 'salt-patch'

    constructor:  (@game, @sprite) ->
        x = @sprite.x
        y = @sprite.y

        @sprite.animations.add('normal', [0,1,2,3], 60, true)
        @sprite.animations.play('normal')

        @blastEmitter = @game.add.emitter(x, y-5, 300)
        @blastEmitter.makeParticles('salt-particle')
        @blastEmitter.width = @sprite.width
        @blastEmitter.height = @sprite.height
        @blastEmitter.gravity = 500
        @blastEmitter.setXSpeed(0, 0)
        @blastEmitter.setYSpeed(-200, -210)
        @blastEmitter.setAlpha(1, 0, 2500)
        #@blastEmitter.setScale(1, 1.8, 1, 1.8, 1000, Phaser.Easing.Quadratic.InOut)

    blast: =>
        @blastEmitter.start(true, 1000, null, 300)

