# pi

[Hubot][hubot] フレームワーク上で実現されたチャットボット．
秋山優花里殿がアニメ番組情報やサーバ状況を随時報告してくれます．

[hubot]: http://hubot.github.com

### インストール

    $ sudo mkdir -p /var/slack
	$ sudo chown user.user $_
    $ git clone https://github.com/noyuno/YukariAkiyamaHubotSlack.git $_
	$ cd $_
	$ source install.sh
	$ slack_systemd
	$ systemd_status_cron

### ローカル上で実行

ローカル上で実行するには，次のコマンドを入力します．

    $ bin/hubot

You'll see some start up output and a prompt:
起動時の出力がたくさん出ますが，気にせず挨拶をしましょう．

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    pi> あ、あのぉ、普通二科、2年3組の秋山優花里といいます。えっとぉ、ふつつか者ですが、よろしくおねがいしますっ！
    pi> こんにちは
    pi> こんにちは！今日の戦車は「Ⅳ号戦車D型改(F2型仕様)」

### 設定

#### サービス化

サービス化をするため，今回はSystemdを使います．
なお終了したときは10秒後に再起動させるようにしています．

	$ source install.sh
	$ slack_systemd

#### Slack

Slackと連携するには次の変数を`secret/token`に設定する必要があります．

    HUBOT_SLACK_TERM=xxxx
    HUBOT_SLACK_BOTNAME=xxxx
    HUBOT_SLACK_TOKEN=xoxb-1234....-abcd....

次に，`script/env.coffee`の`USER`を`https://slack.com/api/users.list?token=xxxx`に
アクセスして取得し，変更します．

### サーバの状況

Systemdサービスが正常に動いているかを確認します．
`systemctl`は`root`権限が必要なため，
10分ごとに`cron`で`root`ユーザとして`systemctl`コマンドを実行させています．

次のコマンドで`bin/systemd-status`を登録します．

	$ source install.sh
	$ systemd_status_cron

`bin/systemd-status`の出力先は`out/systemd-status`で，
Hubotサーバはそのファイルの変更を見て，動いていないサービスがあればチャットで知らせます．

サービスの監視は`bin/systemd-status`の`services`の中のサービスのみ行います．
また，サービスをHubotから制御することはできません．

#### アニメ番組表

アニメ番組表を取得するため，[しょぼいカレンダー](cal.syoboi.jp)に登録します．
JSONファイルのURL`src`は

    src='http://cal.syoboi.jp/rss2.php?usr='$USER'&filter=0&count=1000&days=14&titlefmt=%24(StTime)%01%24(Mark)%24(MarkW)%01%24(ShortTitle)%01%24(SubTitleB)%01%24(ChName)&alt=json'

ですが，そのままでは大量の見ない番組が含まれています．
そのため，自分の場合は，あるキーワードが含まれている番組を抜き出してJSONを作りなおしています．

[anime-json](https://github.com/noyuno/pisite/blob/master/bin/anime-json)
と
[anime-json-extract](https://github.com/noyuno/pisite/blob/master/bin/anime-json-extract)
のスクリプトとキーワードファイルを使用して，JSONファイルを再作成しました．

最後にJSONファイルの場所を `script/env.coffee`の`ANIMEFILE`に設定します．

### Slackでチャット

次のコマンドが使えます．

- `status`: 監視しているサービスすべての状況を取得する
- `status SERVICE`: SERVICEの状況を取得する（ただし，`services`に限る）
- `番組表|anime list`: アニメ番組の一覧を表示する．
- `今日の番組|anime today`: 今日のアニメ番組表の一覧を表示する
- `こんにちは|hello|hi`: 挨拶をする

また，自動的にダイレクトメッセージが届きます

- アニメ番組が始まる10分前から直前までに通知
- 10分ごとにサービス状態を確認して，`active`でなければ通知

![slack](https://raw.githubusercontent.com/noyuno/YukariAkiyamaHubotSlack/master/slack.png)

