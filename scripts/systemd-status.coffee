# Description:
#   systemd-status

fs = require 'fs'
chokidar = require 'chokidar'
env = require './env.coffee'

systemd_out = 'out/systemd-status'
all_ok="すべて問題ありません! "

module.exports=(robot)->
  robot.hear /status$/i, (r) ->
    ret = check_output("")
    if ret == 0
      r.send(all_ok + env.random(env.FUN))

  robot.hear /status (.*)/i, (r) ->
    sv = r.match[1]
    check_output(sv)

  chokidar.watch(systemd_out).on('all', (event, path) => { check_output })

  check_output = (sv) ->
    f = fs.readFileSync(systemd_out)
    errnum=0
    for line in (f + '').split("\n")
      a = line.split(" ")
      if line != "" && (sv == "" || sv == a[1]) && (!line.startsWith("active"))
        robot.send({room:env.USER}, "はぁ...大変な事になりました...危機的状況です...！" +
          "うちの" + a[1] + "、" + a[0] + "なのです～。")
        errnum += 1
      if sv == a[1]
        robot.send({room:env.USER}, "問題ありません! " + env.random(env.FUN))
    return errnum
  check_output("")

