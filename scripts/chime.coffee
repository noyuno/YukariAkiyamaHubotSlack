# Description:
#    chime
gohan = require "hubot-gohan"
schedule = require 'node-schedule'
env = require './env.coffee'

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:process.env.HUBOT_SLACK_USERID}, text)
    else
      r.send(text)
  
  eatit = () ->
    gohan.getGohan()
    .then (res) ->
      text = """
      「#{res.title}」を食べましょう
      #{res.url}
      """
      if res.description
        desc = res.description.match(/^([^。]+。)/)[0]
        text += "\n\n#{desc}"
      if res.image
        text += "\n#{res.image}"
      send null, text

  schedule.scheduleJob('0 7 * * *', () =>
    getWeather(null, false).then (ret)=>
      r = "おはようございます！今日の戦車は「"+env.random(env.TANK)+"」"
      if ret?
        r += ret
      robot.send null, r
  )
  schedule.scheduleJob('0 12 * * *', () =>
    getWeather(null, false).then (ret)=>
      r = "お昼です！"
      if ret?
        r += ret
      robot.send null, r
  )
  schedule.scheduleJob('20 18 * * *', () =>
    send null, "夕ごはんの時間です!"
    eatit
  )
  schedule.scheduleJob('20 18 * * 5', () =>
    send null, "今日は金曜日，カレーの日です！"
    eatit
  )
