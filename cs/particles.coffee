module.exports = class TrainSmoke
    constructor:  (@game) ->

    preload: ->
        @game.load.image('smoke', 'images/smokeGrey0.png')

    create: ->
        @trail = @game.add.emitter(
            @game.world.centerX + 200,
            @game.world.centerY + 200,
            300
        )
        @trail.makeParticles('smoke')
        @trail.gravity = 10
        @trail.setXSpeed(-10, 10)
        @trail.setYSpeed(-50, -100)
        @trail.setRotation(70, 90)
        @trail.setAlpha(1, 0.0, 8000)
        @trail.setScale(0.5, 1, 0.5, 1, 4000, Phaser.Easing.Quadratic.InOut)
        @trail.start(false, 8000, 70)

        @burst = @game.add.emitter(
            @game.world.centerX + 200,
            @game.world.centerY + 200,
            300
        )
        @burst.makeParticles('smoke')
        @burst.gravity = 30
        @burst.setXSpeed(-20, 20)
        @burst.setYSpeed(-50, -200)
        @burst.setRotation(70, 180)
        @burst.setAlpha(1, 0.0, 4000)
        @burst.setScale(0.5, 1, 0.5, 1, 4000, Phaser.Easing.Quadratic.InOut)

        @game.time.events.loop(Phaser.Timer.QUARTER, @makeSmokeBurst, @)

    makeSmokeBurst: ->
        @burst.start(true, 4000, null, 10)

