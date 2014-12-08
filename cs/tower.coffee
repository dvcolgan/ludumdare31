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

        @cooldownRemaining = 0
        @cooldownMeterData = @game.add.bitmapData(@width + 16, @height + 16)
        @cooldownMeter = @game.add.sprite(@x, @y, @cooldownMeterData)
        @cooldownMeter.anchor.setTo(0.5, 0.5)
        @game.groups.tower.add(@cooldownMeter)

    makeRangeMarker: =>
        @rangeMarkerData.cls()
        if @constructor?.properties?.range?
            ctx = @rangeMarkerData.context
            width = @rangeMarkerData.width
            height = @rangeMarkerData.height
            ctx.strokeStyle = 'black'
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.arc(width/2, height/2, @constructor.properties.range, 0, Math.PI*2)
            ctx.stroke()
            ctx.closePath()
        @rangeMarkerData.render()

    makeCooldownMeter: =>
        @cooldownMeterData.cls()
        if @cooldownRemaining > 0
            ctx = @cooldownMeterData.context
            width = @cooldownMeterData.width
            height = @cooldownMeterData.height

            ctx.strokeStyle = 'black'
            ctx.lineWidth = 8
            ctx.beginPath()
            remaining = @cooldown - @cooldownRemaining / @cooldown
            ctx.arc(width/2, height/2, @width/2 + 4, remaining * Math.PI * 2 - Math.PI/2, -Math.PI/2)
            ctx.stroke()
            ctx.closePath()
        @cooldownMeterData.render()

    update: () =>
        @doConstantEffect()
        @decreaseCooldownRemaining()
        @makeCooldownMeter()
        @makeRangeMarker()

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
