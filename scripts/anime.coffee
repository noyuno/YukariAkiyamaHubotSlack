# Description:
#   anime

fs = require 'fs'
schedule = require 'node-schedule'
env = require './env.coffee'

unless process.env.ANIMEJSON?
  module.exports=(robot)->
    send = (r) ->
      text = "この機能は現在無効中です．`secret/token`に`ANIMEJSON=<file>`を記述してください．"
      unless r?
        robot.send({room:process.env.HUBOT_SLACK_USERID}, text)
      else
        r.send(text)

    robot.hear /anime$/i, (r) ->
      send r
    robot.hear /anime today|今日の番組/i, (r) ->
      send r
    robot.hear /anime list|番組表/i, (r) ->
      send r
  return

notify_flag = []

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

todaysanime = () ->
  data = JSON.parse(fs.readFileSync process.env.ANIMEJSON)
  ret = ""
  d = new Date()
  y = new Date()
  y.setDate(y.getDate()+1)
  for p in data["items"]
    e = new Date(p["StTime"] * 1000)
    if (d.getMonth() == e.getMonth() && d.getDate() == e.getDate()) ||
        (y.getMonth() == e.getMonth() && y.getDate() == e.getDate() && e.getHours() < 6)
      ret += datetostr(p["StTime"]) + " " + timetostr(p["StTime"]) + " " +
        p["ChName"] + " " + p["Title"] + "\n"
  if ret == ""
    ret = "今日はありません．" + env.random(env.SAD) + ":fearful:"
  else
    ret += env.random(env.FUN)
  return ret

show_on_air = (robot) ->
  data = JSON.parse(fs.readFileSync process.env.ANIMEJSON)
  d = Math.floor((new Date()).getTime() / 1000)
  for p in data["items"]
    e = p["StTime"]
    f = p["EdTime"]
    if f - d >= 0 && d - e >= 0
      ret=""
      unless p["Count"]?
        ret = "ただいま " + p["ChName"] + "で「" + p["Title"] +
          '」が放送中であります!' + env.random(env.FUN)
      else
        ret = "ただいま"  + p["ChName"] + "で「" + p["Title"] + '」#' + p["Count"] +
          "が放送中であります!" + env.random(env.FUN)
      robot.send {room: process.env.HUBOT_SLACK_USERID}, ret

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:process.env.HUBOT_SLACK_USERID}, text)
    else
      r.send(text)

  robot.hear /anime$/i, (r) ->
    show_on_air(robot)
    notify(true)
    send r, "今日の番組を知りたいときは `anime today|今日の番組` を，" +
      "番組表一覧がほしいときは `anime list|番組表` って言ってくださいねー．"
  robot.hear /anime today|今日の番組/i, (r) ->
    show_on_air(robot)
    notify(true)
    send r, todaysanime()

  robot.hear /anime list|番組表/i, (r) ->
    show_on_air(robot)
    notify(true)
    data = JSON.parse(fs.readFileSync process.env.ANIMEJSON)
    ret = ""
    n = 0
    for p in data["items"]
      if n > 20
        break
      if p["Count"]?
        ret += datetostr(p["StTime"]) + " " + timetostr(p["StTime"]) + " " +
          p["ChName"] + " " + p["Title"] + "#" + p["Count"] + "\n"
      else
        ret += datetostr(p["StTime"]) + " " + timetostr(p["StTime"]) + " " +
          p["ChName"] + " " + p["Title"] + "\n"
      n++

    ret += env.random(env.FUN)
    send r, ret

  notify = (all) ->
    data = JSON.parse(fs.readFileSync process.env.ANIMEJSON)
    d = Math.floor((new Date()).getTime() / 1000)
    for p in data["items"]
      e = p["StTime"]
      if e - d > 0 && e - (d + (env.ANIME_NOTIFY_TIMING * 60)) <= 0
        #console.log "soon start"
        if !(p["PID"] in notify_flag) || all
          ret=""
          unless p["Count"]?
            ret = timetostr(p["StTime"]) + "から" + p["ChName"] + "で「" + 
              p["Title"] + '」#' + p["Count"] "が始まります!" + env.random(env.FUN)
          else
            ret = timetostr(p["StTime"]) + "から" + p["ChName"] + "で「" + 
              p["Title"] + '」が始まります!' + env.random(env.FUN)
          console.log ret
          send null, ret
          notify_flag.push(p["PID"])
        else
          #console.log "already sent: " + ret
  
  schedule.scheduleJob("*/#{env.ANIME_NOTIFY_INTERVAL} * * * *", () =>
    #console.log "anime notify (every #{env.ANIME_NOTIFY_INTERVAL} minutes)"
    notify(false)
  )
  show_on_air robot
  notify(false)
  
  schedule.scheduleJob('00 22 * * *', () =>
    #console.log "todays-anime (at 22:00)"
    send null, todaysanime()
  )

