#!/bin/bash
BASE_DIR=/var/lib/jenkins/workspace/th3server/
cd $BASE_DIR
current_date=`TZ=America/Los_Angeles date +%Y-%m%d%H%M`
docker build -t guanghes/th3-server:$current_date -f /var/lib/jenkins/workspace/th3server/Dockerfile .
docker push guanghes/th3-server:$current_date
