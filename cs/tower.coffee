G = require('./constants')


module.exports = class Tower extends Phaser.Sprite
    @properties = []

    resetProperties: () ->
        @animationCls = @constructor.properties.animationCls
        @cooldown = @constructor.properties.cooldown
        @range = @constructor.properties.range
        @damage = @constructor.properties.damage

    constructor: (@game, x, y) ->
        @resetProperties()

        super(@game, x, y, @animationCls.spriteKey)

        @animation = new @animationCls @game, @

        @game.add.existing @

        @inputEnabled = true
        @events.onInputDown.add @handleClick, @
        @anchor.setTo(0.5, 0.5)

        @game.groups.tower.add(@)

        @enemyGroup = @game.groups.enemy

        @rangeMarkerData = @game.add.bitmapData(512, 512)
        @rangeMarker = @game.add.sprite(@x, @y, @rangeMarkerData)
        @rangeMarker.anchor.setTo(0.5, 0.5)
        @game.groups.tower.add(@rangeMarker)

        @cooldownMeter = @game.add.sprite(@x, @y, 'cooldown')
        @cooldownMeter.anchor.setTo(0.5)
        @cooldownMeter.animations.add('running', [0..12], 0)
        @game.groups.tower.add(@cooldownMeter)
        @cooldownMeter.animations.currentAnim.frame = 12

        @makeRangeMarker()

    makeRangeMarker: () =>
        @rangeMarkerData.cls()
        if @constructor?.properties?.range?
            ctx = @rangeMarkerData.context
            width = @rangeMarkerData.width
            height = @rangeMarkerData.height
            ctx.strokeStyle = 'rgba(128, 128, 128, 0.5)'
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.arc(width/2, height/2, @constructor.properties.range, 0, Math.PI*2)
            ctx.stroke()
            ctx.closePath()
        @rangeMarkerData.render()

    updateCooldown: =>
        if @cooldownRemaining > 0
            remaining = @cooldownRemaining / @cooldown
            @cooldownMeter.animations.currentAnim.frame = (13 - Math.floor(13 * remaining)) - 1
            @inputEnabled = false
        else
            @inputEnabled = true

    update: () =>
        @doConstantEffect()
        @decreaseCooldownRemaining()
        @updateCooldown()

    decreaseCooldownRemaining: () =>

        # At 60 fps, it would take 4760 millenia to hit min value
        @cooldownRemaining -= 1

    handleClick: () =>
        @fire()

    resetCooldown: () =>
        @cooldownRemaining = @cooldown

    fire: () =>
        return false if @cooldownRemaining > 0

        @resetCooldown()

        return true

    doConstantEffect: () =>
        return @cooldownRemaining < 0
