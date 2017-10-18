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
*/10 * * * * root /var/slack/bin/systemd-status
EOF
}

