#!/bin/bash
BASE_DIR=/var/lib/jenkins/release/production/
cd $BASE_DIR
current_date=`TZ=America/Los_Angeles date +%Y-%m%d%H%M`
docker build -t th3-server:$current_date -f /var/lib/jenkins/release/production/Dockerfile .
docker push guanghes/th3-server:$current_date
