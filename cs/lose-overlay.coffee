module.exports = class LoseOverlay extends Phaser.Sprite
    preload: ->
        @game.load.image('lose-overlay', 'assets/lose-overlay.png')

    constructor: (game) ->
        super(game, 0, 0, 'lose-overlay')
        game.add.existing(@)
