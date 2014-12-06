G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)

        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(game.groups.enemy)
        @body.collides([
            game.groups.enemy, game.groups.tower, game.groups.secret,
            game.physics.p2.boundsCollisionGroup
        ])

        game.add.existing(@)


module.exports = class EnemyFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('enemy-small', 'assets/enemy-small.png')
        @game.load.image('enemy-medium', 'assets/enemy-medium.png')
        @game.load.image('enemy-large', 'assets/enemy-large.png')

    getY: =>
        return @game.rnd.integerInRange(0, G.SCREEN_HEIGHT)

    createSmall: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-small')
        return enemy

    createMedium: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-medium')
        enemy.body.moveRight(300)
        return enemy

    createLarge: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-large')
        return enemy
