# Description:
#   systemd-status

fs = require 'fs'
chokidar = require 'chokidar'
env = require './env.coffee'

systemd_out = 'out/systemd-status'
all_ok="すべて問題ありません! "

service_flag = []

module.exports=(robot)->
  send = (r, text) ->
    unless r?
      robot.send({room:process.env.HUBOT_SLACK_USERID}, text)
    else
      r.send(text)

  robot.hear /status$/i, (r) ->
    ret = check_output(r, "", false)
    if ret == 0
      r.send(all_ok + env.random(env.FUN))

  robot.hear /status (.*)/i, (r) ->
    sv = r.match[1]
    if sv == "all"
      check_outall(r)
    else
      check_output(r, sv, false)

  chokidar.watch(systemd_out, { persistent: true }).on(
    'all', (event, path) =>
      check_output(null, "", true)
    )

  check_output = (r, sv, flag) ->
    f = fs.readFileSync(systemd_out)
    errnum=0
    out = ""
    for line in (f + '').split("\n")
      a = line.split(" ")
      if line != ""
        if (sv == "" || sv == a[1]) && !line.startsWith("active") && (!flag || !(a[1] in service_flag))
          if out isnt ""
            out += "で，"
          out += a[1]+"が"+a[0]
          errnum += 1
          if flag && !(a[1] in service_flag)
            service_flag.push(a[1])

        if sv == a[1] && line.startsWith("active")
          send(r, "問題ありません! " + env.random(env.FUN))
          if flag
            service_flag = service_flag.filter((elem, index, array) ->
              return !(a[1] == elem))
    if out isnt ""
      send(r, "はぁ..大変な事になりました..危機的状況です.." +
      "うちの" + out + "なのです～．")
    return errnum
  
  check_outall = (r) ->
    f = fs.readFileSync(systemd_out)
    errnum=0
    text = ""
    for line in (f + '').split("\n")
      a = line.split(" ")
      if line != ""
        if line.startsWith("active")
          text += a[1] + ": 問題ありません！\n"
        else
          text += a[1] + ": _" + a[0] + "_です..\n"
    send r, text
    return errnum

