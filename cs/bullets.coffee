G = require('./constants')


module.exports = class BulletManager
    constructor: (@bullets) ->

    getBullet: ->
        # Get first nonexisting bullet
        return @bullets.getFirstExists(false)

    iterateLive: (callback) ->
        @bullets.forEachAlive(callback)


BulletManager.onCollision = (bulletBody, asteroidBody) ->


BulletManager.create = (game, groups) ->
    bullets = game.add.group()

    for i in [0...40]
        bullet = bullets.create(0, 0, 'bullet')
        game.physics.p2.enable(bullet, G.DEBUG)
        bullet.anchor.setTo(0.5, 0.5)
        bullet.body.setCollisionGroup(groups.bullet)
        bullet.body.damping = 0
        bullet.body.collides(groups.enemy, BulletManager.onCollision)

        bullet.kill()

    return new BulletManager(bullets)
