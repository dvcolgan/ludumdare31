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

        # Point directly at the secret
        vector = Phaser.Point.subtract(@, secret)

        # TODO: Come back to this later.
        ## Invert the magnitude of the vector
        #magnitude = vector.getMagnitude()
        #vector.setMagnitude(10000 / magnitude)

        ## Iterate over all the towers and point away from them,
        ## inversely proportional to the distance from them
        #@towerGroup.forEachAlive (tower) =>

        #    # Point AWAY from the towers
        #    vectorToTower = Phaser.Point.subtract(tower, @)

        #    # Invert the magnitude of the vector
        #    magnitude = vectorToTower.getMagnitude()
        #    vectorToTower.setMagnitude(1000 / magnitude)

        #    # Add this vector to the angle
        #    Phaser.Point.add(vector, vectorToTower, vector)

        @body.rotation = vector.angle(new Phaser.Point()) + Math.PI/2
        @body.thrust 10

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
        @game.groups.enemy.add(enemy)
        return enemy
