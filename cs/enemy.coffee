G = require('./constants')


class Enemy extends Phaser.Sprite
    constructor: (game, @towerGroup, @secret, x, y, key, health) ->
        super(game, x, y, key)

        @health = health # necessary to do after call to super()
        game.physics.p2.enable(@, G.DEBUG)
        @anchor.setTo(0.5, 0.69)

        @body.clearShapes()
        @body.addCircle(32)
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

        @animations.add('walk', [0...8], 10, true)
        @play('walk')


    update: () =>
        if Math.random() < 1 / 60
            @health++
            @healthText.text = @health

        @pointAtSecret(@secret)

        # Make the snowman sized according to health
        magnitude = Phaser.Point.parse(@body.velocity).getMagnitude()
        delay = 100 - (magnitude/2)
        if delay < 10
            delay = 10
        @animations.currentAnim.delay = delay

        @setScaleForHealth()

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
        @body.rotation = 0

    setScaleForHealth: =>
        @scale.x = @health / 50
        @scale.y = @health / 50
        @body.clearShapes()
        @body.addCircle(32 * @scale.x)

        @body.setCollisionGroup(@game.collisionGroups.enemy)
        @body.collides([
            @game.collisionGroups.enemy, @game.collisionGroups.tower, @game.collisionGroups.secret
        ])

    damage: (damage) =>
        super damage

        @healthText.text = @health
        @setScaleForHealth()

        if @health <= 0
            G.events.onEnemyKilled.dispatch(@)


module.exports = class EnemyFactory
    constructor: (@game, @towerGroup, @secret) ->

    getY: =>
        return @game.rnd.integerInRange(0, G.SCREEN_HEIGHT)

    createEnemy: =>
        enemy = new Enemy(
            @game
            @towerGroup
            @secret
            0
            @getY()
            'snowman'
            10
        )
        @game.groups.enemy.add(enemy)
        return enemy
