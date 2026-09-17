#!/bin/sh
set -e


if [ -f /run/secrets/spring_datasource_password ]; then
  export SPRING_DATASOURCE_PASSWORD=$(cat /run/secrets/spring_datasource_password)
fi


exec java -jar app.jar
