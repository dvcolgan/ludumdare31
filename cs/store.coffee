G = require('./constants')
TowerFactory = require('./tower')


forSaleItems =
    towerFire:
        name: 'Fire'
        description: 'Click/Tap: Melt snowballs around the fire'
        createFn: 'createFire'
        imageKey: 'firewood'
        placeable: true
        cost: 100

    towerSnowblower:
        name: 'Fan'
        description: 'Click/Tap: Throw snowballs back from whence we came, damaging them in the process'
        createFn: 'createSnowblower'
        imageKey: 'fan'
        placeable: true
        cost: 50

    towerSalt:
        name: 'Salt'
        description: 'Slows and damages snowballs that pass over it. Click/Tap: Stun snowballs.'
        createFn: 'createSalt'
        imageKey: 'salt-patch'
        placeable: true
        cost: 20

    secretHealth:
        name: 'Replenish Health'
        description: 'When purchased, restores the health of your damaged secret.'
        requires: ['secret']
        createFn: (secret) =>
            secret.restoreMaxHealth()
        imageKey: 'tower-aoe'
        placeable: false
        cost: 100


module.exports = class Store
    constructor: (@game, @towerFactory, @stats) ->
        @overlay = @game.add.sprite(0, -474, 'store-overlay')
        @overlay.inputEnabled = true
        @game.groups.overlay.add(@overlay)
        @slideDownTween = @game.add.tween(@overlay).to({y: 0}, 500, Phaser.Easing.Bounce.Out)
        @slideUpTween = @game.add.tween(@overlay).to({y: -474}, 500, Phaser.Easing.Bounce.Out)

        @overlay.events.onInputDown.add(@toggleStore)
        @state = 'up'

        # Place to put description text
        @descriptionText = new Phaser.Text(
            @game
            20
            @overlay.height - 100
            ''
                font: '20px Arial'
                fill: 'black'
                align: 'center'
        )
        @descriptionText.anchor.setTo 0, 1
        @overlay.addChild @descriptionText

        @slotNumber = 1

        @addForSaleItem(forSaleItems.towerFire)
        @addForSaleItem(forSaleItems.towerSnowblower)
        @addForSaleItem(forSaleItems.towerSalt)
        @addForSaleItem(forSaleItems.secretHealth)

    addForSaleItem: (itemData) =>

        # Calculate where the item should go
        x = @slotNumber * 200
        y = Math.floor(@slotNumber / 5) * 100 + 100

        # Add the sprite for the slot
        slot = @game.add.sprite(x, y, 'store-slot')
        slot.anchor.setTo(0.5, 0.5)
        slot.inputEnabled = true
        slot.input.priorityID = 1
        slot.events.onInputDown.add @handleClickOnForSaleItem
        slot.data = itemData

        # Add the sprite for the item
        item = @game.add.sprite(x, y, itemData.imageKey)
        item.inputEnabled = true
        item.input.priorityID = 2
        item.events.onInputOver.add @showDescription
        item.events.onInputDown.add @handleClickOnForSaleItem
        item.data = itemData
        item.anchor.setTo(0.5, 0.5)
        item.slot = slot

        # Add to overlay
        @overlay.addChild(slot)
        @overlay.addChild(item)

        # Add the name
        text = new Phaser.Text(
            @game
            0
            slot.width / 2 + 20
            itemData.name + "\nCost: #{itemData.cost}g" + '' # Because coffeescript gets confused and I like weird syntax
                font: '20px Arial'
                fill: 'black'
                align: 'center'
        )
        text.anchor.setTo 0.5, 0.5
        slot.addChild text

        # Add the question mark text
        questionText = new Phaser.Text(
            @game
            slot.width / 2 + 15
            -1 * slot.height / 2
            '?'
                font: '30px Arial'
                fill: 'black'
        )
        questionText.anchor.setTo 0.5, 0
        questionText.inputEnabled = true
        questionText.input.priorityID = 3
        questionText.events.onInputDown.add @showDescription
        questionText.events.onInputOver.add @showDescription
        questionText.slot = slot
        slot.addChild questionText

        @slotNumber++

    showDescription: (object) =>
        @descriptionText.text = object.slot.data.description

    handleClickOnForSaleItem: (sprite) =>
        @stats.subtractGold(sprite.data.cost)
        G.events.onStoreItemPurchased.dispatch(sprite.data)

        @toggleStore()

    toggleStore: =>
        if @state == 'up'
            @slideDownTween.start()
            @state = 'down'
        else if @state == 'down'
            @slideUpTween.start()
            @state = 'up'
