#!/bin/bash
. ./.env
set -e

cd /code



if [ $# -eq 0 ]; then
    echo "Usage: command.sh [PROCESS_TYPE](app/beat/worker/flower/test)"
    exit 1
fi

PROCESS_TYPE=$1

case $PROCESS_TYPE in
    app)
        . ./.env
        python manage.py collectstatic --noinput
        python manage.py migrate
        gunicorn \
            --bind 0:8000 \
            --workers 4 \
            --max-requests 500 \
            --log-level info \
            --access-logfile "-" \
            --error-logfile "-" \
            config.wsgi:application \

        exit 1
        ;;

    worker)
        . ./.
        celery \
            -A config worker --loglevel INFO --events -c 1000 -P gevent
        exit 1
        ;;

    beat)
        . ./.
        celery \
            -A config beat --loglevel INFO
        exit 1
        ;;

    flower)
        celery \
            -A config \
            --broker="redis://$REDIS_HOST:$REDIS_PORT/0" \
            flower \
            --address=0.0.0.0 \
            --port=5555 \
            --url_prefix=flower \
            --loglevel INFO \
            --basic-auth=$FLOWER_LOGIN:$FLOWER_PASSWORD \
            --persisten=True \
            --db="flower_db" \

        exit 1
        ;;

    test)
        python manage.py migrate
        python manage.py test
        exit 1
        ;;
esac

exec "$@"