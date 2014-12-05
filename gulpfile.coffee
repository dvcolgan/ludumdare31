gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
browserify = require 'gulp-browserify'
rename = require 'gulp-rename'


gulp.task 'coffee', ->
    gulp.src './cs/game.coffee',
            read: false
        .pipe browserify
            transform: ['coffeeify']
            extensions: ['.coffee', '.js']
        .pipe concat 'app.js'
        .pipe gulp.dest '.'

gulp.task 'watch-coffee', ->
    gulp.watch [
        './cs/*.coffee'
    ], ['coffee']

gulp.task 'watch-all', ['watch-coffee']
gulp.task 'build', ['coffee']
gulp.task 'watch', ['build', 'watch-coffee']
