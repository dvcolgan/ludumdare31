module.exports = class Fan
    @spriteKey = 'fan'

    constructor:  (@game, @sprite) ->
        x = @sprite.x
        y = @sprite.y

        @sprite.animations.add('normal', [0,1,2,3], 60, true)
        @sprite.animations.add('blast', [0,1,2,3,0,1,2,3,0,1,2,3], 120)
        @sprite.animations.play('normal')

        for i in [-1..1]
            @emitter = @game.add.emitter(x+i*10-4, y-5, 300)
            @emitter.makeParticles('snow-particles', [0,1,2,3])
            @emitter.width = 6
            @emitter.height = @sprite.height/2
            @emitter.gravity = 10
            @emitter.setXSpeed(-200, -100)
            @emitter.setYSpeed(-10, 10)
            @emitter.setAlpha(1, 0.0, 1500)
            @emitter.start(false, 1500, 1)

        @blastEmitter = @game.add.emitter(x, y+5, 300)
        @blastEmitter.makeParticles('snow-particles', [0,1,2,3])
        @blastEmitter.width = @sprite.width / 2
        @blastEmitter.height = 20
        @blastEmitter.gravity = 10
        @blastEmitter.setXSpeed(-60, 60)
        @blastEmitter.setYSpeed(40, -200)
        @blastEmitter.setAlpha(1, 0, 1000)
        @blastEmitter.setScale(1, 0.8, 1, 0.8, 3000, Phaser.Easing.Quadratic.InOut)

        #@game.time.events.loop(3000, @blast)

    blast: =>
        @sprite.animations.play('blast')
        @blastEmitter.start(true, 1000, null, 300)
