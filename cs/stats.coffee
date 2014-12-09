G = require('./constants')


module.exports = class Stats
    constructor: (@game) ->
        @score = 0
        @gold = 50000
        @enemiesKilled = 0

        # Display text on the screen
        @text = @game.add.text 20, 20, '',
            font: '20px Droid Sans'
            fill: 'black'
            align: 'left'

        @updateText()

        G.events.onEnemyKilled.add @handleEnemyKilled
        G.events.onSecretDamaged.add () =>
            @incrementScore 1
        G.events.onTowerPlaced.add () =>
            @incrementScore 20

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

        @addGold(Math.floor(@game.rnd.between(10, 40) / @game.difficulty))
        @score += 10

        @updateText()

    incrementScore: (score) =>
        @score += Math.abs(score)
        @updateText()

    updateText: () =>
        @text.text = "Gold: #{@gold} Score: #{@score}"
