G = require('./constants')


module.exports = class Stats
    constructor: (@game) ->
        @score = 0
        @gold = 500
        @enemiesKilled = 0

        # Display text on the screen
        @text = @game.add.text 20, 20, '',
            font: '20px Arial'
            fill: 'black'
            align: 'left'

        @updateText()

        G.events.onEnemyKilled.add(@handleEnemyKilled)

    addGold: (amount) ->
        @gold += amount
        @updateText()
        G.events.onGoldAmountChanged.dispatch(@gold)

    subtractGold: (amount) ->
        @gold -= amount
        @updateText()
        G.events.onGoldAmountChanged.dispatch(@gold)

    handleEnemyKilled: (enemy) =>
        @enemiesKilled++

        @addGold @game.rnd.between 20, 50
        @score += 20

        @updateText()

    updateText: () =>
        @text.text = "Gold: #{@gold} Score: #{@score}"
