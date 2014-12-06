G = require('./constants')


module.exports = class Secret extends Phaser.Sprite
    constructor: (game, x, y) ->
        super(game, x, y, 'secret')
        game.add.existing(@)
        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.kinematic = yes
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(@game.groups.secret)
        @body.collides([@game.groups.enemy])
        @body.createGroupCallback(@game.groups.enemy, @onEnemyTouch)

    onEnemyTouch: =>
        @game.events.onGameOver.dispatch()
