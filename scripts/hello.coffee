# Description:
#   hello

env = require './env.coffee'

module.exports=(robot)->
  robot.hear /(hello|hi|こんにちは)/i, (r) ->
    r.send "こんにちは！今日の戦車は「" + env.random(env.TANK) + "」"

