G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key) =>
        super(game, x, y, key)

    update: =>
        console.log(x, y)


module.exports = class EnemyFactory
    constructor: (@game) =>

    preload: =>
        @game.load.image('enemy-small', 'assets/enemy-small.png')
        @game.load.image('enemy-medium', 'assets/enemy-medium.png')
        @game.load.image('enemy-large', 'assets/enemy-large.png')

    getY: =>
        return @game.rnd.integerInRange(0, G.SCREEN_HEIGHT)

    createSmall: =>
        enemy = @game.add.sprite(0, @getY(), 'enemy-small')
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.damping = 100
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        return enemy

    createMedium: =>
        enemy = @game.add.sprite(100, @getY(), 'enemy-medium')
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.damping = 100
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        enemy.body.moveRight(300)
        return enemy

    createLarge: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-large')
        enemy.anchor.setTo(0.5, 0.5)
        @game.physics.p2.enable(enemy, G.DEBUG)
        enemy.body.damping = 100
        enemy.body.clearShapes()
        enemy.body.addCircle(enemy.width/2)
        return enemy
