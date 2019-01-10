# YukariAkiyamaHubotSlack

[Hubot][hubot] フレームワーク上で実現されたSlackチャットボット．
秋山優花里殿がアニメ番組情報やサーバ状況，降雨状況を随時報告してくれます．

[hubot]: http://hubot.github.com

![slack](https://raw.githubusercontent.com/noyuno/YukariAkiyamaHubotSlack/master/slack.png)

## 1. コマンド

次のコマンドが使えます．コマンド出力の後の言葉はランダムです．

- `status`: 監視しているサービスすべての状況を取得する
- `status all`: 監視しているサービスすべての状況を取得して，一覧表示する
- `status SERVICE`: SERVICEの状況を取得する（ただし，`services`に限る）
- `番組表|anime list`: アニメ番組の一覧を表示する．
- `今日の番組|anime today`: 今日のアニメ番組表の一覧を表示する
- `天気|weather|forecast`: 現在及び今後の降雨状況を表示する
- `こんにちは|hello|hi`: 挨拶をする
- `更新|upgradable` : 更新可能なパッケージを表示する

また，自動的に以下のダイレクトメッセージが届きます

- アニメ番組が始まる10分前から5分前までに通知
- 10分ごとにサービス状態を確認して，`active`でなければ通知
- 10分ごとに今後の降雨状況を確認して，変化（雨が降ってきたり，雨が止んだり）があった時に通知

また，起動時に必要に応じて以下の情報を通知します．

- サービス状態を確認して，`active`でなければ通知
- 更新可能なパッケージがあれば通知
- 今後の降雨状況を確認して，変化（雨が降ってきたり，雨が止んだり）があった時に通知

これらは後述します．

## 2. インストール

Raspbian on Raspberry Pi 3でのみ動作確認

    $ sudo mkdir -p /var/slack
	$ sudo chown user.user $_
    $ git clone https://github.com/noyuno/YukariAkiyamaHubotSlack.git $_
	$ cd $_
	$ bash install.sh systemd
	$ bash install.sh status

## 3. ローカル上で実行

ローカル上で実行するには，次のコマンドを入力します．

    $ bin/hubot

起動時の出力がたくさん出ますが，気にせず挨拶をしましょう．

    yukari> あ、あの、普通二科、2年3組の秋山優花里といいます。えっと、不束者ですが、よろしくおねがいします！
    [Thu Oct 19 2017 19:52:22 GMT+0900 (JST)] WARNING A script has tried registering a HTTP route while the HTTP server is disabled with --disabled-httpd.
    [Thu Oct 19 2017 19:52:23 GMT+0900 (JST)] INFO hubot-redis-brain: Using default redis on localhost:6379
    愛知ではもうすぐ雨が降ってきます(0)..
    yukari> こんにちは
    こんにちは！今日の戦車は「Ⅳ号戦車D型改(F2型仕様)」
    yukari> 天気を教えて
    yukari> 愛知ではもうすぐ雨が降ってきます(0)..


## 4. 設定

### 4.1. サービス化

サービス化をするため，今回はSystemdを使います．
`slack`として登録します．
なお異常終了したときは10秒後に再起動させるようにしています．

    $ ./install.sh systemd

### 4.2. Slack

Slackと連携するには次の変数を`secret/token`に設定する必要があります．

    HUBOT_SLACK_TERM=xxxx
    HUBOT_SLACK_BOTNAME=xxxx
    HUBOT_SLACK_TOKEN=xoxb-1234....-abcd....

次に，`secret/token`で設定する，ボットが送信する既定の宛先`HUBOT_SLACK_USERID`を`https://slack.com/api/users.list?token=xoxb-000000...`に
アクセスして`UDXXXXXXX`形式で設定します．

### 4.3. サーバの状況

Systemdサービスが正常に動いているかを確認します．
`systemctl`は`root`権限が必要なため，
10分ごとに`cron`で`root`ユーザとして`systemctl`コマンドを実行させています．

次のコマンドで`bin/systemd-status`を登録します．

    $ ./install.sh cron

`bin/systemd-status`の出力先は`out/systemd-status`で，
Hubotサーバはそのファイルの変更を見て，動いていないサービスがあればチャットで知らせます．

サービスの監視は`bin/systemd-status`の`services`の中のサービスのみ行います．
また，サービスをHubotから制御することはできません．
また，サービスの確認には5分間隔で実行しているため，例えば`sudo systemctl start slack`
をしたのに起動直後Slackがinactiveとして通知されます．

### 4.4. アップグレード通知

一日一回，APTを使ってシステムのパッケージに更新できるものがあるか調べます．
次のコマンドで`cron`に登録します．

    $ ./install.sh cron

更新できるものがあれば「n個のパッケージが更新できます」と通知されます．
「upgradable」または「更新」コマンドで更新可能なパッケージを列挙します．

### 4.5. アニメ番組表

アニメ番組表を取得するため，[しょぼいカレンダー](http://cal.syoboi.jp)に登録します．
JSONファイルのURL`src`は

    src='http://cal.syoboi.jp/rss2.php?usr='$USER'&filter=0&count=1000&days=14&titlefmt=%24(StTime)%01%24(Mark)%24(MarkW)%01%24(ShortTitle)%01%24(SubTitleB)%01%24(ChName)&alt=json'

ですが，そのままでは大量の見ない番組が含まれています．
そのため，自分の場合は，あるキーワードが含まれている番組を抜き出してJSONを作りなおしています．

[anime-json](https://github.com/noyuno/pisite/blob/master/bin/anime-json)
と
[anime-json-extract](https://github.com/noyuno/pisite/blob/master/bin/anime-json-extract)
のスクリプトとキーワードファイルを使用して，JSONファイルを再作成しました．

つぎにJSONファイルの場所を `secret/token`の`ANIMEJSON`に設定します．

### 4.6. 降雨状況

降雨状況を問い合わせたり，ある場所の降雨の変化
（もうすぐ雨が降ってきたり，雨が止んだり）があった時に通知することができます．

YOLPを使ってますので，[新しいアプリケーションを開発](https://e.developer.yahoo.co.jp/register)
で「クライアントサイド（Yahoo! ID連携v1）」を選び登録します．
発行されたアプリケーションIDを`secret/token`に`YAHOO_APPID=abc..`の形式で設定します．

次に，`script/env.coffee`の`COORDINATES`に次の形式で座標を設定します．

    @COORDINATES: {\
        "愛知": "137.123456,34.123456"
    }

### 4.7. Shell on Slack

`sh COMMAND [ARGS...]`でSlackからサーバシェルにコマンドを送信できます．
デフォルトで無効なので，有効にするには`scripts/env.coffee`の`ENABLE_SHELL`を`true`にします．
セキュリティに充分注意する必要があります．
`ENABLE_SHELL`が`false`でも`uptime`コマンドは使えます．


