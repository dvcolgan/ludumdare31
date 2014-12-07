G = require('./constants')
FireTower = require('./fire-tower')
FanTower = require('./fan-tower')
SaltTower = require('./salt-tower')


forSaleItems =
    towerFire:
        name: 'Fire'
        description: 'Click/Tap: Melt snowballs around the fire'
        class: FireTower
        imageKey: 'firewood'
        placeable: true
        cost: 100

    towerFan:
        name: 'Fan'
        description: 'Click/Tap: Throw snowballs back from whence we came, damaging them in the process'
        class: FanTower
        imageKey: 'fan'
        placeable: true
        cost: 50

    towerSalt:
        name: 'Salt'
        description: 'Slows and damages snowballs that pass over it. Click/Tap: Stun snowballs.'
        class: SaltTower
        imageKey: 'salt-patch'
        placeable: true
        cost: 20

    secretHealth:
        name: 'Replenish Health'
        description: 'When purchased, restores the health of your damaged secret.'
        imageKey: 'tower-aoe'
        placeable: false
        cost: 100
        requires: ['secret']
        createFn: (secret) =>
            secret.restoreMaxHealth()

    towerFireUpgrade:
        name: 'Fire Upgrade'
        description: 'When purchased, increase the range and damage of all campfires'
        imageKey: 'tower-aoe'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            FireTower.properties.cooldown -= 60
            FireTower.properties.range += 50
            FireTower.properties.damage += 10

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties()

            store.removeItem 'towerFireUpgrade'

    towerFanUpgrade:
        name: 'Fan Upgrade'
        description: 'When purchased, increase the range and damage of all fans'
        imageKey: 'tower-aoe'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            FanTower.properties.cooldown -= 60
            FanTower.properties.range += 50
            FanTower.properties.damage += 10

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties()

            store.removeItem 'towerFanUpgrade'

    towerSaltUpgrade:
        name: 'Salt Upgrade'
        description: 'When purchased, increase the stun range and damage of all salt patches'
        imageKey: 'tower-aoe'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            SaltTower.properties.cooldown -= 60
            SaltTower.properties.range += 50
            SaltTower.properties.damage += 2
            SaltTower.properties.stunDuration += 60 * 2

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties()

            store.removeItem 'towerSaltUpgrade'


module.exports = class Store
    @NUM_ITEMS_PER_ROW = 4

    constructor: (@game, @stats) ->
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

        @slotNumber = 0

        for type, item of forSaleItems
            @addForSaleItem type, item

    addForSaleItem: (itemType, itemData) =>

        # Calculate where the item should go
        x = (@slotNumber % Store.NUM_ITEMS_PER_ROW + 1) * 200
        y = Math.floor(@slotNumber / Store.NUM_ITEMS_PER_ROW) * 150 + 100

        # Add the sprite for the slot
        slot = @game.add.sprite(x, y, 'store-slot')
        slot.anchor.setTo(0.5, 0.5)
        slot.inputEnabled = true
        slot.input.priorityID = 1
        slot.events.onInputDown.add @handleClickOnForSaleItem
        slot.data = itemData
        slot.type = itemType

        # Add the sprite for the item
        item = @game.add.sprite(x, y, itemData.imageKey)
        item.inputEnabled = true
        item.input.priorityID = 2
        item.events.onInputOver.add @showDescription
        item.events.onInputDown.add @handleClickOnForSaleItem
        item.data = itemData
        item.type = itemType
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

    removeItem: (key) =>
        childrenToDestroy = []
        for child in @overlay.children
            if child?.type is key
                childrenToDestroy.push child

        for child in childrenToDestroy
            child.destroy()

    showDescription: (object) =>
        @descriptionText.text = object.slot.data.description

    handleClickOnForSaleItem: (sprite) =>
        if sprite.data.cost > @stats.gold
            return

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
