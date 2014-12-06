G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, @towerGroup, @secret, x, y, key, health) ->
        super(game, x, y, key)

        @health = health # necessary to do after call to super()
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

    update: () =>
        @pointAtSecret(@secret)

    pointAtSecret: (secret) =>
        dx = secret.x - @x
        dy = secret.y - @y
        @body.rotation = Math.atan2(dy, dx) + Math.PI/2

    damage: (damage) =>
        super(damage)

        @healthText.text = @health

        if @health <= 0
            G.events.onEnemyKilled.dispatch(@)


module.exports = class EnemyFactory
    constructor: (@game, @towerGroup, @secret) ->

    getY: =>
        return @game.rnd.integerInRange(0, G.SCREEN_HEIGHT)

    createSmall: =>
        enemy = new Enemy(
            @game
            @towerGroup
            @secret
            0
            @getY()
            'enemy-small'
            10
        )
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy

    createMedium: =>
        enemy = new Enemy(
            @game
            @towerGroup
            @secret
            0
            @getY()
            'enemy-medium'
            20
        )
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy

    createLarge: =>
        enemy = new Enemy(
            @game
            @towerGroup
            @secret
            0
            @getY()
            'enemy-large'
            30
        )
        enemy.body.moveRight(300)
        @game.groups.enemy.add(enemy)
        return enemy
