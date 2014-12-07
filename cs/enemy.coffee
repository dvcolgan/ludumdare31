G = require('./constants')


class Enemy extends Phaser.Sprite
    @properties =
        maxSpeed: 30
        rotationSpeed: 0.3

    constructor: (game, @towerGroup, @secret, x, y, key, health) ->
        super(game, x, y, key)

        @health = health # necessary to do after call to super()
        @stunDuration = 0
        @anchor.setTo(0.5, 0.69)

        @moveRotation = 0
        @moveSpeed = 0

        game.add.existing(@)

        @animations.add('walk', [0...8], 10, true)
        @play('walk')


    update: () =>
        @updateHealth()
        @moveTowardSecret(@secret)
        @updateAnimationDelay()
        @setScaleForHealth()

    updateHealth: () =>
        return
        speed = Phaser.Point.parse(@body.velocity).getMagnitude()
        @health += speed / 3000

    moveTowardSecret: (secret) =>
        return if @stunDuration-- > 0
        return if not secret.alive

        # Point directly at the secret
        vectorToSecret = Phaser.Point.subtract(@, secret)

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

        # Turn toward the desired vector
        @moveRotation = Phaser.Math.linear(
            @moveRotation
            vectorToSecret.angle(new Phaser.Point())
            Enemy.properties.rotationSpeed
        )

        # Increase speed by a bit
        @moveSpeed = Math.min(@moveSpeed + 1, Enemy.properties.maxSpeed)

        # Calculate new position

        # Start with 0-rad angle
        vectorToNewPosition = new Phaser.Point(1, 0)

        # Rotate it
        vectorToNewPosition.rotate 0, 0, @moveRotation

        # Set the speed
        vectorToNewPosition.setMagnitude @moveSpeed / 60

        # Compute new position
        @position = Phaser.Point.add(@, vectorToNewPosition)


    updateAnimationDelay: =>
        return
        magnitude = Phaser.Point.parse(@body.velocity).getMagnitude()
        delay = 100 - (magnitude/2)
        if delay < 10
            delay = 10
        @animations.currentAnim.delay = delay


    setScaleForHealth: =>
        return
        @scale.x = @health / 50
        @scale.y = @health / 50
        @body.clearShapes()
        @body.addCircle(32 * @scale.x)

    damage: (damage) =>
        super damage

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
