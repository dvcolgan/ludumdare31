G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)


module.exports = class EnemyFactory
    constructor: (@game) ->

    preload: ->
        @game.load.image('enemy-small', 'assets/enemy-small.png')
        @game.load.image('enemy-medium', 'assets/enemy-medium.png')
        @game.load.image('enemy-large', 'assets/enemy-large.png')

    getY: ->
        return @game.rnd.getRandomInteger(0, G.SCREEN_HEIGHT)

    createSmall: ->
        small = @game.add.sprite(0, @getY(), 'enemy-small')
        small.anchor.setTo(0.5, 0.5)
        small.body.damping = 100
        small.body.clearShapes()
        small.body.addCircle(small.width/2)
        return small

    createMedium: ->
        medium = @game.add.sprite(0, y, 'enemy-medium')
        medium.anchor.setTo(0.5, 0.5)
        medium.body.damping = 100
        medium.body.clearShapes()
        medium.body.addCircle(small.width/2)
        return medium

    createLarge: ->
        large = new Enemy(@game, 0, y, 'enemy-large')
        large.anchor.setTo(0.5, 0.5)
        large.body.damping = 100
        large.body.clearShapes()
        large.body.addCircle(small.width/2)
        return large
