# Description:
#   anime

schedule = require 'node-schedule'
weather_yahoo_jp = require "weather-yahoo-jp"
yolp = new weather_yahoo_jp.Yolp(process.env.YAHOO_APPID)
env = require './env.coffee'
notify_flag = { }

datetostr = (ux) ->
  d = new Date( ux * 1000 )
  month = ("0"+(d.getMonth() + 1)).slice(-2)
  day   = ("0"+d.getDate()).slice(-2)
  return month + "/" + day

timetostr = (ux) ->
  d = new Date( ux * 1000 )
  hour  = ("0"+d.getHours()).slice(-2)
  min   = ("0"+d.getMinutes()).slice(-2)
  return hour + ":" + min

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:env.USER}, text)
    else
      r.send(text)

  getWeather = (r, all) ->
    yolp.getWeather( { coordinates: env.COORDINATES, z:12 }).then (data) ->
      for where of data
        w = data[where]
        if w.observation.rain > 0
          if w.forecast[0].rain > 0
            if all
              send r, where + "は雨が降っていますよ(" + w.observation.rain + ")"
              notify_flag[where] = 3
          else
            if all || !(notify_flag[where] == 4)
              send r, where + "ではもうすぐ雨が止みます!"
              notify_flag[where] = 4
        else
          if w.forecast[0].rain == 0
            if all
              send r, where + "は雨が降っていません"
              notify_flag[where] = 1
          else
            if all || !(notify_flag[where] == 2)
              send r, where + "ではもうすぐ雨が降ってきます(" + w.forecast[0].rain + ").."
              notify_flag[where] = 2

  robot.hear /(weather|forecast|天気)/i, (r) ->
    getWeather r, true

  schedule.scheduleJob("*/#{env.NOTIFY_INTERVAL} * * * *", () =>
    #console.log "weather notify (every #{env.NOTIFY_INTERVAL} minutes)"
    getWeather null, false
  )

  getWeather null, false

