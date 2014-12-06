G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)
        game.add.existing(@)

    update: =>
        console.log(@x, @y)


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
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        return enemy

    createMedium: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-medium')
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        return enemy

    createLarge: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-large')
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        return enemy
