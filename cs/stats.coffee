G = require('./constants')


module.exports = class Stats
    constructor: (@game) ->
        @score = 0
        @gold = 500

        @game.events.onEnemyKilled.add(@handleEnemyKilled)

    handleEnemyKilled: (enemy) =>

        switch enemy.key
            when 'enemy-small'
                @gold += @game.rnd.between 5, 10
                @score += 5

            when 'enemy-medium'
                @gold += @game.rnd.between 10, 20
                @score += 10

            when 'enemy-large'
                @gold += @game.rnd.between 20, 50
                @score += 20

