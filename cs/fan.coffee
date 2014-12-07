module.exports = class Fan
    @spriteKey = 'fan'

    constructor:  (@game, @sprite) ->
        x = @sprite.x
        y = @sprite.y

        @sprite.animations.add('normal', [0,1,2,3], 60, true)
        @sprite.animations.play('normal')

        for i in [-1..1]
            @emitter = @game.add.emitter(x+i*10-4, y-5, 300)
            @emitter.makeParticles('snowflake-particles', [0,1,2,3,4])
            @emitter.width = 6
            @emitter.height = @sprite.height/2
            @emitter.gravity = 10
            @emitter.setXSpeed(-200, -100)
            @emitter.setYSpeed(-10, 10)
            @emitter.setAlpha(1, 0.0, 1500)
            @emitter.start(false, 1500, 5)

        @blastEmitter = @game.add.emitter(x, y-5, 300)
        @blastEmitter.makeParticles('snowflake-particles', [0,1,2,3,4])
        @blastEmitter.width = @sprite.width / 2
        @blastEmitter.height = @sprite.height / 1.5
        @blastEmitter.gravity = 10
        @blastEmitter.setXSpeed(-300, -100)
        @blastEmitter.setYSpeed(-50, 50)
        @blastEmitter.setAlpha(1, 0, 1500)
        @blastEmitter.setScale(1, 1.8, 1, 1.8, 1000, Phaser.Easing.Quadratic.InOut)


    blast: =>
        @blastEmitter.start(true, 1500, null, 300)
