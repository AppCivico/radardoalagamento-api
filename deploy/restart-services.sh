#!/bin/bash

[ -z "$TUPA_ENV_FILE" ] && echo "Need to set TUPA_ENV_FILE env before run this." && exit 1;


source $TUPA_ENV_FILE

# setup default, but make possible to overwrite this
TUPA_API_WORKERS=${TUPA_API_WORKERS:=4}
export TUPA_API_WORKERS

mkdir -p $TUPA_LOG_DIR

STARMAN_BIN="$(which starman)"
DAEMON="$(which start_server)"

line (){
    perl -e "print '-' x 40, $/";
}

up_server (){
    TYPE=api
    PSGI_APP_NAME="$1"
    PORT="$2"
    WORKERS=$3

    ERROR_LOG="$TUPA_LOG_DIR/$TYPE.error.log"
    STATUS="$TUPA_LOG_DIR/$TYPE.start_server.status"
    PIDFILE="$TUPA_LOG_DIR/$TYPE.start_server.pid"
    APP_DIR="$TUPA_APP_DIR/"

    touch $ERROR_LOG
    touch $PIDFILE
    touch $STATUS

    STARMAN="$STARMAN_BIN -I$APP_DIR/lib --workers $WORKERS --error-log $ERROR_LOG.starman $APP_DIR/$PSGI_APP_NAME"

    DAEMON_ARGS=" --pid-file=$PIDFILE --signal-on-hup=QUIT --status-file=$STATUS --port 0.0.0.0:$PORT -- $STARMAN"

    echo "Restarting $TYPE...  $DAEMON --restart $DAEMON_ARGS"
    $DAEMON --restart $DAEMON_ARGS

    if [ $? -gt 0 ]; then
        echo "Restart failed, application likely not running. Starting..."

        /sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER --chdir $APP_DIR -u $USER --exec $DAEMON --$DAEMON_ARGS

    fi
}

cd $TUPA_APP_DIR;
cpanm -n --installdeps .;

cd $TUPA_APP_DIR/schema;
sqitch deploy -t $TUPA_SQITCH_DEPLOY_NAME

up_server "script/app.psgi" $TUPA_API_PORT $TUPA_API_WORKERS

cd $TUPA_APP_DIR/script/daemon
./mailer restart
#./saisp restart
sleep 2
line
./mailer status
#./saisp status

line

