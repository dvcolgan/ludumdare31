G = require('./constants')


module.exports = class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)

Enemy.create = (game, size, x, y) ->
    sprite = game.add.sprite(x, y, "enemy_#{size}")

    sprite.anchor.setTo(0.5, 0.5)
    sprite.body.damping = 100
    sprite.body.clearShapes()
    sprite.body.loadPolygon(
        "enemy_#{size}_collision"
        "enemy_#{size}"
    )

    #sprite.body.setCollisionGroup(groups.enemy)
    #sprite.body.collides([groups.player, groups.bullet, groups.enemy])
    #sprite.body.createGroupCallback(groups.bullet, Asteroid.onCollision)

    return new Enemy(game, x, y, "something")
