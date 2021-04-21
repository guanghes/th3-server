#!/bin/bash
BASE_DIR=/var/lib/jenkins/release/production/
cd $BASE_DIR
current_date=`TZ=America/Los_Angeles date +%Y-%m%d`
docker push th3-server:$current_date-1