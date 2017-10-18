fs = require 'fs'
schedule = require 'node-schedule'

animefile = "/var/www/html/data/anime.json"
notify_span = 60 * 10

# https://slack.com/api/users.list?token=xxxx
user = "U7LMRS8QP"

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
  data = JSON.parse(fs.readFileSync animefile)
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
    ret = "今日はありません:fearful:"
  return ret

module.exports=(robot)->
  sendDM = (message) ->
    robot.send {room: user}, message
    return 0

  robot.hear /today anime|今日の番組/i, (r) ->
    r.send todaysanime()

  robot.hear /anime list|番組表/i, (r) ->
    data = JSON.parse(fs.readFileSync animefile)
    ret = ""
    n = 0
    for p in data["items"]
      if n > 20
        break
      if p["Count"]?
        ret += datetostr(p["StTime"]) + " " + timetostr(p["StTime"]) + " " +
          p["ChName"] + " " + p["Title"] + "\n"
      else
        ret += datetostr(p["StTime"]) + " " + timetostr(p["StTime"]) + " " +
          p["ChName"] + " " + p["Title"] + "#" + p["Count"] + "\n"
      n++
    r.send ret

  notify = () ->
    data = JSON.parse(fs.readFileSync animefile)
    d = Math.floor((new Date()).getTime() / 1000)
    for p in data["items"]
      e = p["StTime"]
      if e - d > 0 && e - (d + notify_span) <= 0
        ret=""
        if p["Count"]?
          ret = timetostr(p["StTime"]) + "から" + p["ChName"] + "で「" + p["Title"] + '」が始まります'
        else
          ret = timetostr(p["StTime"]) + "から" + p["ChName"] + "で「" + p["Title"] + '」#' + p["Count"] "が始まります"
        robot.send {room: user}, ret
  
  schedule.scheduleJob(String(notify_span) + ' * * * * *', "anime-notify", () =>
    console.log "notify (every " + String(notify_span) " minutes)"
    notify()
  )
  notify()
  
  schedule.scheduleJob('30 21 * * * *', 'todays-anime', () =>
    console.log "todays-anime (at 21:30)"
    sendDM(todaysanime())
  )
  schedule.scheduleJob('0 8 * * * *', 'forecast', () =>
    console.log "forecast (at 08:00)"
    sendDM(get_forecast())
  )

  sendDM("起動しました")

