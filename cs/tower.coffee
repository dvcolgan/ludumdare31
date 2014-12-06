G = require('./constants')


class Tower extends Phaser.Sprite
    constructor: (game, x, y, key) ->
        super(game, x, y, key)


module.exports = class TowerFactory
    constructor: (@game) ->

    preload: =>
        @game.load.image('tower-aoe', 'assets/tower-aoe.png')

    createAoe: (x, y) =>
        # TODO: Instantiate Tower class and add to game instead of this:
        tower = @game.add.sprite(x, y, 'tower-aoe')

        tower.anchor.setTo(0.5, 0.5)
        tower.body.damping = 100
        tower.body.clearShapes()
        tower.body.addCircle(tower.width/2)
        return tower
