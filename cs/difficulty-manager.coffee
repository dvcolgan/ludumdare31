module.exports = class DifficultyManager
    constructor: (@enemyFactory, @framerate, difficulty) ->
        @changeDifficulty(difficulty)

    changeDifficulty: (difficulty) =>

        # For efficiency, since it'll be used every update
        @frameProbability = 1 / @framerate * difficulty

    update: () =>
        @maybeCreateNewEnemy()

    maybeCreateNewEnemy: () =>
        if Math.random() < @frameProbability

            # Create a new enemy
            @enemyFactory.createMedium()
