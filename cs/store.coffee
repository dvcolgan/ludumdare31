G = require('./constants')
FireTower = require('./fire-tower')
FanTower = require('./fan-tower')
SaltTower = require('./salt-tower')


forSaleItems =
    towerFire:
        name: 'Fire'
        description: 'Click/Tap: Melt snowballs around the fire'
        class: FireTower
        imageKey: 'fire-store-icon'
        placeable: true
        cost: 200

    towerFan:
        name: 'Fan'
        description: 'Click/Tap: Throw snowballs back from whence we came, damaging them in the process'
        class: FanTower
        imageKey: 'fan'
        placeable: true
        cost: 10

    towerSalt:
        name: 'Salt'
        description: 'Slows and damages snowballs that pass over it. Click/Tap: Stun snowballs.'
        class: SaltTower
        imageKey: 'salt-patch'
        placeable: true
        cost: 50

    towerFireUpgrade:
        name: 'Fire Upgrade'
        description: 'When purchased, increase the range and damage of all campfires'
        imageKey: 'fire-upgrade'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            FireTower.properties.cooldown -= 30
            FireTower.properties.range += 30
            FireTower.properties.damage += 5

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties?()
                tower.makeRangeMarker?()

            store.removeItem 'towerFireUpgrade'

    towerFanUpgrade:
        name: 'Fan Upgrade'
        description: 'When purchased, increase the range and damage of all fans'
        imageKey: 'fan-upgrade'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            FanTower.properties.cooldown -= 30
            FanTower.properties.range += 50
            FanTower.properties.damage += 10

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties?()
                tower.makeRangeMarker?()

            store.removeItem 'towerFanUpgrade'

    towerSaltUpgrade:
        name: 'Salt Upgrade'
        description: 'When purchased, increase the stun range and damage of all salt patches'
        imageKey: 'salt-upgrade'
        placeable: false
        cost: 500
        requires: ['game', 'store']
        createFn: (game, store) =>
            SaltTower.properties.cooldown -= 30
            SaltTower.properties.range += 30
            SaltTower.properties.damage += 1
            SaltTower.properties.stunDuration += 60

            game.groups.tower.forEachAlive (tower) =>
                tower.resetProperties?()
                tower.makeRangeMarker?()

            store.removeItem 'towerSaltUpgrade'

    secretHealth:
        name: 'Replenish Health'
        description: 'When purchased, restores the health of your damaged secret. Reusable.'
        imageKey: 'secret-heal'
        placeable: false
        cost: 100
        requires: ['secret']
        createFn: (secret) =>
            secret.restoreMaxHealth()

    nuke:
        name: 'Nuke'
        description: 'Melts all snowmen on screen. Reusable.'
        imageKey: 'mini-nuke'
        placeable: false
        cost: 5000
        requires: ['game']
        createFn: (game) =>
            game.groups.enemy.forEachAlive (enemy) =>
                enemy.damage 1000000000

            nuke = game.add.sprite(G.SCREEN_WIDTH/2, G.SCREEN_HEIGHT/2, 'nuke-blast')
            nuke.anchor.setTo(0.5)
            nuke.scale.setTo(0)
            game.add.tween(nuke)
                .to({x: G.SCREEN_WIDTH/2 - 10, y: G.SCREEN_HEIGHT/2}, 10, Phaser.Easing.Linear.None)
                .to({x: G.SCREEN_WIDTH/2 + 10, y: G.SCREEN_HEIGHT/2}, 10, Phaser.Easing.Linear.None)
                .loop(true)
                .start()
            game.add.tween(nuke).to({alpha: 0}, 1200, Phaser.Easing.Circular.Out, true, 800)
            game.add.tween(nuke.scale)
                .to({x: 2, y: 2}, 3000, Phaser.Easing.Circular.Out, true)
                .onComplete.add ->
                    nuke.destroy()



module.exports = class Store
    @numItemsPerRow = 6

    constructor: (@game, @stats) ->
        @overlay = @game.add.sprite(0, -474, 'store-overlay')
        @overlay.inputEnabled = true
        @game.groups.overlay.add(@overlay)
        @slideDownTween = @game.add.tween(@overlay).to({y: 0}, 500, Phaser.Easing.Bounce.Out)
        @slideUpTween = @game.add.tween(@overlay).to({y: -474}, 500, Phaser.Easing.Bounce.Out)

        @storeText = @game.add.bitmapText 0, 0, 'font', 'STORE', 40
        @storeText.x = @overlay.width / 2 - @storeText.width / 2
        @storeText.y = @overlay.height - 25 - @storeText.height
        @overlay.addChild @storeText

        @overlay.events.onInputDown.add(@toggleStore)
        @state = 'up'

        # Place to put description text
        @descriptionText = @game.add.bitmapText 0, 0, 'font', '', 30
        @descriptionText.x = 20
        @descriptionText.y = @overlay.height - 120 - @descriptionText.height
        @overlay.addChild @descriptionText

        @slotNumber = 0
        @slots = []

        for type, item of forSaleItems
            @addForSaleItem type, item

        @recalculateBuyableItems(@stats.gold)
        G.events.onGoldAmountChanged.add(@recalculateBuyableItems)

    addForSaleItem: (itemType, itemData) =>

        # Calculate where the item should go
        x = (@slotNumber % Store.numItemsPerRow) * 150 + 100
        y = Math.floor(@slotNumber / Store.numItemsPerRow) * 180 + 100

        # Add the sprite for the slot
        slot = @game.add.sprite(x, y, 'store-slot')
        slot.anchor.setTo(0.5, 0.5)
        slot.inputEnabled = true
        slot.input.priorityID = 1
        slot.events.onInputDown.add @handleClickOnForSaleItem
        slot.data = itemData
        slot.type = itemType
        @slots.push slot

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
        text = @game.add.text(
            0
            slot.width / 2 + 30
            itemData.name + "\nCost: #{itemData.cost}g" + '' # Because coffeescript gets confused and I like weird syntax
                font: '20px Droid Sans'
                fill: 'black'
                align: 'center'
        )
        text.anchor.setTo 0.5, 0.5
        slot.text = text
        slot.addChild text

        # Add the question mark text
        questionText = @game.add.text(
            slot.width / 2 + 15
            -1 * slot.height / 2
            '?'
                font: '30px Droid Sans'
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
            G.events.onStoreOpen.dispatch()
        else if @state == 'down'
            @slideUpTween.start()
            @state = 'up'
            G.events.onStoreClose.dispatch()

    recalculateBuyableItems: (availableGold) =>
        for slot in @slots
            if slot.data.cost <= availableGold
                slot.text.addColor 'black', 0
            else
                slot.text.addColor '#ff3333', 0
        return
