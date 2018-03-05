#!/bin/bash -e

slack_systemd() {
    cat << EOF | sudo tee /etc/systemd/system/slack.service
[Unit]
Description=Hubot Slack robot

[Service]
User=$USER
WorkingDirectory=/var/slack
ExecStart=/var/slack/bin/run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    sudo service slack restart
    sudo systemctl enable slack
}

slack_cron() {
    cat << EOF | sudo tee /etc/cron.d/slack
*/10 * * * * root /var/slack/bin/systemd-status
48 19 * * * root /var/slack/bin/apt-upgrade
EOF
}

help()
{
cat << EOF
Install 秋山優花里 bot
Arguments:

bash install.sh COMMAND

COMMAND:
    systemd : Add 秋山優花里 bot to Systemd.
    cron : Add 'bin/systemd-status' and 'bin/apt-upgrade' script to cron
EOF

    exit 1
}

if [ $# -eq 0 ]; then
    help
fi

case "$1" in
    cron) slack_cron ;;
    systemd) slack_systemd ;;
    *) help
esac

