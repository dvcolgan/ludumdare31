G = require('./constants')


module.exports = class Secret extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)

Secret.create = (game, size, x, y) ->
    sprite = game.add.sprite(x, y, 'secret')

    sprite.anchor.setTo(0.5, 0.5)
    sprite.body.damping = 100
    sprite.body.clearShapes()
    sprite.body.loadPolygon(
        "secret_collision"
        "secret"
    )

    #sprite.body.setCollisionGroup(groups.enemy)
    #sprite.body.collides([groups.player, groups.bullet, groups.enemy])
    #sprite.body.createGroupCallback(groups.bullet, Asteroid.onCollision)

    return new Secret(game, x, y, "something")
