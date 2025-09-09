#!/bin/bash
# NGINX 설치
apt-get update
apt-get -y install nginx

# index.html 파일 만들기
fileName=/var/www/html/index.html
echo "Running Azure Arc enabled Ubuntu Server from host $(hostname)">${fileName}
