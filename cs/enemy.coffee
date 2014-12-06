G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, x, y, key, health) ->
        super(game, x, y, key)

        @health = health
        @anchor.setTo(0.5, 0.5)
        game.physics.p2.enable(@, G.DEBUG)
        @body.clearShapes()
        @body.addCircle(@width/2)
        @body.setCollisionGroup(game.collisionGroups.enemy)
        @body.collides([
            game.collisionGroups.enemy, game.collisionGroups.tower, game.collisionGroups.secret
        ])

        game.add.existing(@)

        # Health text
        @healthText = new Phaser.Text game, 0, 0, @health,
            font: '10px Arial'
            fill: 'black'
            align: 'center'

        @addChild @healthText

    update: (@secret) =>
        @pointAtSecret(@secret)

    pointAtSecret: (@secret) =>
        console.log @secret

    damage: (damage) =>
        super(damage)

        @healthText.text = @health

        if @health <= 0
            G.events.onEnemyKilled.dispatch(@)


module.exports = class EnemyFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('enemy-small', 'assets/enemy-small.png')
        @game.load.image('enemy-medium', 'assets/enemy-medium.png')
        @game.load.image('enemy-large', 'assets/enemy-large.png')

    getY: =>
        return @game.rnd.integerInRange(0, G.SCREEN_HEIGHT)

    createSmall: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-small', 10)
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy

    createMedium: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-medium', 20)
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy

    createLarge: =>
        enemy = new Enemy(@game, 0, @getY(), 'enemy-large', 30)
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy
