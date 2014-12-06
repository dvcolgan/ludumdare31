module.exports = class EnemySpawner
    constructor: (@enemyFactory, @framerate, @difficulty) ->
        @calculateProbability()

        @minDifficultyToSpawnMediumEnemies = 2
        @minDifficultyToSpawnLargeEnemies = 3

        @probabilityOfSpawningMediumEnemy = 0.5
        @probabilityOfSpawningLargeEnemy = 0.2

    calculateProbability: () =>

        # For efficiency, since it'll be used every update
        @frameProbability = 0.1 / @framerate * @difficulty

    update: () =>
        @maybeCreateNewEnemy()

    maybeCreateNewEnemy: () =>
        if Math.random() < @frameProbability

            if @difficulty < @minDifficultyToSpawnMediumEnemies
                @enemyFactory.createSmall()

            else if @difficulty < @minDifficultyToSpawnLargeEnemies
                if Math.random() < @probabilityOfSpawningMediumEnemy
                    @enemyFactory.createMedium()
                else
                    @enemyFactory.createSmall()

            else
                if Math.random() < @probabilityOfSpawningLargeEnemy
                    @enemyFactory.createLarge()
                else if Math.random() < @probabilityOfSpawningMediumEnemy
                    @enemyFactory.createMedium()
                else
                    @enemyFactory.createSmall()
