# Description:
#   hello

cprocess = require "child_process"
env = require './env.coffee'

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:process.env.HUBOT_SLACK_USERID}, text)
    else
      r.send(text)

  robot.hear /(hello|hi|こんにちは)/i, (r) ->
    send r, "こんにちは！今日の戦車は「" + env.random(env.TANK) + "」"

  robot.hear /uptime/i, (r) ->
    uptime = cprocess.execSync("uptime") + ''
    uptime = uptime.replace /\n/, ""
    send r, uptime
    
  robot.hear /sh (.*)/i, (r) ->
    if !env.ENABLE_SHELL
      send r, "Shell on Slackは現在無効です．有効にするには`env.ENABLE_SHELL=true`にしてください．"
      return
    try
      out = cprocess.execSync(r.match[1], shell="/bin/zsh") + ''
      send r, out
    catch err
      send r, "#{err}"

  send null,  "あ、あの、普通二科、2年3組#{env.NAME}といいます。不束者ですが、よろしくおねがいします！"

