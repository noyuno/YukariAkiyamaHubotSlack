# Description:
#   hello

env = require './env.coffee'

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:env.USER}, text)
    else
      r.send(text)

  robot.hear /(hello|hi|こんにちは)/i, (r) ->
    send r, "こんにちは！今日の戦車は「" + env.random(env.TANK) + "」"

  send null,  "あ、あの、普通二科、2年3組の秋山優花里といいます。えっと、不束者ですが、よろしくおねがいします！"

