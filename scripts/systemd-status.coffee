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
      robot.send({room:env.USER}, text)
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
    for line in (f + '').split("\n")
      a = line.split(" ")
      if line != ""
        if (sv == "" || sv == a[1]) && !line.startsWith("active") && (!flag || !(a[1] in service_flag))
          send(r, "はぁ..大変な事になりました..危機的状況です.." +
            "うちの" + a[1] + "、" + a[0] + "なのです～．")
          errnum += 1
          if flag && !(a[1] in service_flag)
            console.log("push " + a[1])
            service_flag.push(a[1])

        if sv == a[1] && line.startsWith("active")
          send(r, "問題ありません! " + env.random(env.FUN))
          if flag
            service_flag = service_flag.filter((elem, index, array) ->
              return !(a[1] == elem))
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

