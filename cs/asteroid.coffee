G = require('./constants')


module.exports = class Asteroid
    constructor: (@sprite, @physics) ->


Asteroid.onHit = new Phaser.Signal()


Asteroid.onCollision = (asteroidBody, bulletBody) ->
    Asteroid.onHit.dispatch(asteroidBody)
    asteroidBody.sprite.kill()


Asteroid.create = (game, groups, size, x, y) ->
    sprite = game.add.sprite(x, y, "asteroid_#{size}")

    sprite.anchor.setTo(0.5, 0.5)
    game.physics.p2.enable(sprite, G.DEBUG)
    sprite.body.damping = 0
    sprite.body.clearShapes()
    sprite.body.loadPolygon(
        "asteroid_#{size}_collision",
        "asteroid_#{size}")

    sprite.size = size

    sprite.body.setCollisionGroup(groups.enemy)
    sprite.body.collides([groups.player, groups.bullet, groups.enemy])
    sprite.body.createGroupCallback(groups.bullet, Asteroid.onCollision)

    return new Asteroid(sprite, game.physics.p2)

