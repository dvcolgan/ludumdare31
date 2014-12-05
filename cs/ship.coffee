G = require('./constants')


module.exports = class Ship
    constructor: (@sprite, @physics) ->

    lookAt: (x, y) ->
        dx = x - @sprite.x
        dy = y - @sprite.y
        @sprite.body.rotation = Math.atan2(dy, dx) + Math.PI/2

    setThrust: (thrust) ->
        if thrust
            @sprite.body.thrust(500)
            @sprite.play('thrusting')
        else
            @sprite.play('idle')

    shoot: (bullets) ->
        bullet = bullets.getBullet()
        if bullet?
            bullet.reset(@sprite.body.x, @sprite.body.y)
            bullet.lifespan = 2000
            bullet.body.rotation = @sprite.body.rotation
            bullet.body.velocity.x = @sprite.body.velocity.x
            bullet.body.velocity.y = @sprite.body.velocity.y
            bullet.body.thrust(30000)
            #@physics.velocityFromRotation(@sprite.rotation, 400, bullet.body.velocity)


Ship.create = (game, groups, x, y) ->
    sprite = game.add.sprite(x, y, 'ship')

    sprite.anchor.setTo(0.5, 0.5)
    game.physics.p2.enable(sprite, G.DEBUG)
    sprite.body.damping = 0.2
    sprite.body.clearShapes()
    sprite.body.loadPolygon('ship_collision', 'ship')
    sprite.animations.add('idle', [0], 0)
    sprite.animations.add('thrusting', [1, 0, 0], 10)
    sprite.animations.play('idle')

    sprite.body.setCollisionGroup(groups.player)
    sprite.body.collides(groups.enemy)

    return new Ship(sprite, game.physics.p2)
