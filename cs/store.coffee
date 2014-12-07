G = require('./constants')
TowerFactory = require('./tower')


forSaleItems =
    towerFire:
        createFn: 'createFire'
        imageKey: 'tower-aoe'
        cost: 100
    towerSnowblower:
        createFn: 'createSnowblower'
        imageKey: 'tower-aoe'
        cost: 50
    towerSalt:
        createFn: 'createSalt'
        imageKey: 'tower-aoe'
        cost: 20


module.exports = class Store
    constructor: (@game, @towerFactory, @stats) ->
        @overlay = @game.add.sprite(0, -474, 'store-overlay')
        @overlay.inputEnabled = true
        @game.groups.overlay.add(@overlay)
        @slideDownTween = @game.add.tween(@overlay).to({y: 0}, 500, Phaser.Easing.Bounce.Out)
        @slideUpTween = @game.add.tween(@overlay).to({y: -474}, 500, Phaser.Easing.Bounce.Out)

        @overlay.events.onInputDown.add(@toggleStore)
        @state = 'up'

        @slotNumber = 1

        @addForSaleItem(forSaleItems.towerFire)
        @addForSaleItem(forSaleItems.towerSnowblower)
        @addForSaleItem(forSaleItems.towerSalt)

    addForSaleItem: (itemData) ->
        x = @slotNumber * 200
        y = Math.floor(@slotNumber / 5) * 100 + 100

        slot = @game.add.sprite(x, y, 'store-slot')
        slot.anchor.setTo(0.5, 0.5)
        item = @game.add.sprite(x, y, itemData.imageKey)
        item.anchor.setTo(0.5, 0.5)
        @overlay.addChild(slot)
        @overlay.addChild(item)
        slot.inputEnabled = true
        slot.input.priorityID = 1
        slot.events.onInputDown.add(@handleClickOnForSaleItem)
        slot.data = itemData

        @slotNumber++

    handleClickOnForSaleItem: (slot) =>
        @stats.subtractGold(slot.data.cost)
        G.events.onStoreItemPurchased.dispatch(slot.data)

        @toggleStore()

    toggleStore: =>
        if @state == 'up'
            @slideDownTween.start()
            @state = 'down'
        else if @state == 'down'
            @slideUpTween.start()
            @state = 'up'
