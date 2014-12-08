G = require('./constants')


class Enemy extends Phaser.Sprite
    @framesUntilGrowthRateDoubled = 60 * 120
    @baseRadius = 32
    @healthScale = 60

    constructor: (game, @towerGroup, @secret, x, y, key, health) ->
        super(game, x, y, key)

        @health = health # necessary to do after call to super()
        @stunDuration = 0
        game.physics.p2.enable(@, G.DEBUG)
        @anchor.setTo(0.5, 0.69)

        @setScaleForHealth()
        @body.clearShapes()
        @body.addCircle(@radius)
        @body.setCollisionGroup(game.collisionGroups.enemy)
        @body.collides([
            game.collisionGroups.enemy, game.collisionGroups.tower, game.collisionGroups.secret
        ])

        game.add.existing(@)

        @animations.add('walk', [0...8], 10, true)
        @play('walk')


    update: () =>
        return if not @alive
        @updateHealth()
        @moveTowardSecret(@secret)
        @updateAnimationDelay()
        @setScaleForHealth()

    updateHealth: () =>
        speed = Phaser.Point.parse(@body.velocity).getMagnitude()
        @health += speed / 9000 * @game.difficulty * (@game.frame / Enemy.framesUntilGrowthRateDoubled + 1)

    moveTowardSecret: (secret) =>
        return if @stunDuration-- > 0
        return if not secret.alive

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

    updateAnimationDelay: =>
        magnitude = Phaser.Point.parse(@body.velocity).getMagnitude()
        delay = 100 - (magnitude/2)
        if delay < 10
            delay = 10
        @animations.currentAnim.delay = delay


    setScaleForHealth: =>
        @scale.x = @health / Enemy.healthScale + 0.2
        @scale.y = @health / Enemy.healthScale + 0.2
        @body.clearShapes()
        @radius = Enemy.baseRadius * @scale.x
        @body.addCircle(@radius)

        @body.setCollisionGroup(@game.collisionGroups.enemy)
        @body.collides([
            @game.collisionGroups.enemy, @game.collisionGroups.tower, @game.collisionGroups.secret
        ])

    damage: (damage) =>
        super damage

        @setScaleForHealth()

        if @health <= 0
            G.events.onEnemyKilled.dispatch(@)


module.exports = class EnemyFactory

    @defaultHealth = 10
    @defaultRadius = Enemy.baseRadius * (EnemyFactory.defaultHealth / Enemy.healthScale + 0.2)

    constructor: (@game, @towerGroup, @secret) ->

    getX: =>
        return @game.rnd.integerInRange(-75, 0)

    getY: =>
        minY = G.PHYSICS_BOUNDS_Y_MIN + EnemyFactory.defaultRadius + 1
        maxY = G.PHYSICS_BOUNDS_Y_MAX - EnemyFactory.defaultRadius - 1

        return @game.rnd.integerInRange(minY, maxY)

    intersectsWithExistingEnemy: (x, y, enemyGroup) =>
        intersects = false

        enemyGroup.forEachAlive (enemy) =>
            if Phaser.Math.distance(enemy.x, enemy.y, x, y) <= enemy.radius + EnemyFactory.defaultRadius + 2
                intersects = true
                return

        return intersects

    createEnemy: =>
        i = 0
        loop
            x = @getX()
            y = @getY()
            break if not @intersectsWithExistingEnemy(x, y, @game.groups.enemy) or i++ > 10

        enemy = new Enemy(
            @game
            @towerGroup
            @secret
            x
            y
            'snowman'
            EnemyFactory.defaultHealth
        )
        @game.groups.enemy.add(enemy)
        return enemy
