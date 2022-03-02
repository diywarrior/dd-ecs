#bash

countContainer=$1

if [ -z "$countContainer" ]; then
    countContainer=1
fi

docker-compose up --build -d

docker-compose up -d --scale app=$countContainer