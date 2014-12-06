G = require('./constants')


class Enemy extends Phaser.Sprite
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


module.exports = class EnemyFactory
    constructor: (@game) ->

    preload: ->
        @game.load.image('enemy-small', 'assets/enemy-small.png')
        @game.load.image('enemy-medium', 'assets/enemy-medium.png')
        @game.load.image('enemy-large', 'assets/enemy-large.png')

    createSmall: (x, y) ->
        small = new Enemy(@game, x, y, 'enemy-small')
        small.anchor.setTo(0.5, 0.5)
        small.body.damping = 100
        small.body.clearShapes()
        small.body.addCircle(small.width/2)
        return small

    createMedium: (x, y) ->
        medium = new Enemy(@game, x, y, 'enemy-medium')
        medium.anchor.setTo(0.5, 0.5)
        medium.body.damping = 100
        medium.body.clearShapes()
        medium.body.addCircle(small.width/2)
        return medium

    createLarge: (x, y) ->
        large = new Enemy(@game, x, y, 'enemy-large')
        large.anchor.setTo(0.5, 0.5)
        large.body.damping = 100
        large.body.clearShapes()
        large.body.addCircle(small.width/2)
        return large
