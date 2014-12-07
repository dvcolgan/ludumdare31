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

        @cooldownRemaining = 0
        @cooldownMeterData = @game.add.bitmapData(@width + 16, @height + 16)
        @cooldownMeter = @game.add.sprite(0, 0, @cooldownMeterData)
        @cooldownMeter.anchor.setTo(0.5, 0.5)
        @addChild(@cooldownMeter)

    makeCooldownMeter: ->
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
