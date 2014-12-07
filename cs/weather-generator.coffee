G = require('./constants')


module.exports = class WeatherGenerator
    @spriteKey = 'fan'

    constructor:  (@game) ->
        @emitter = @game.add.emitter(G.SCREEN_WIDTH - 200, 0, 500)
        @emitter.width = G.SCREEN_WIDTH * 1.5
        @game.groups.foreground.add(@emitter)
        @emitter.makeParticles('snowflake-particles', [0,1,2,3,4])
        @emitter.gravity = 20
        @emitter.setXSpeed(-20, -40)
        @emitter.setYSpeed(150, 250)
        @emitter.start(false, 7000, 3)
