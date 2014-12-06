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
        @body.setCollisionGroup(@game.collisionGroups.secret)
        @body.collides([@game.collisionGroups.enemy])
        @body.createGroupCallback(@game.collisionGroups.enemy, @onEnemyTouch)

    onEnemyTouch: =>
        @game.events.onGameOver.dispatch()
