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

systemd_status_cron() {
    cat << EOF | sudo tee /etc/cron.d/systemd-status
*/5 * * * * root /var/slack/bin/systemd-status
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
    status : Add 'bin/systemd-status' script to cron
EOF

    exit 1
}

if [ $# -eq 0 ]; then
    help
fi

case "$1" in
    status) systemd_status_cron ;;
    systemd) slack_systemd ;;
    *) help
esac

