#!/bin/bash

rclone sync /home/user/work mega:/backup \
  --fast-list \
  --transfers 2 \
  --checkers 4 \
  --exclude '.git/**' \
  --exclude 'node_modules/**' \
  --log-file=/var/log/rclone-mega.log \
  --log-level INFO
