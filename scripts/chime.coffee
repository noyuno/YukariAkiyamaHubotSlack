# Description:
#    chime
gohan = require "hubot-gohan"
schedule = require 'node-schedule'

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:env.USER}, text)
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

  schedule.scheduleJob('0 12 * * *', () =>
    send null, "お昼です!"
    eatit
  )
  schedule.scheduleJob('20 18 * * *', () =>
    send null, "夕ごはんの時間です!"
    eatit
  )
  schedule.scheduleJob('20 18 * * 5', () =>
    send null, "今日は金曜日，カレーの日です！"
    eatit
  )
