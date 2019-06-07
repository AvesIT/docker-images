#!/bin/bash

if [ ! -d "/srv/config" ]; then
    echo "/srv/config is not mounted"
    exit 1
fi

function var_not_set {
    echo "Environment variable $1 is not set"
    exit 1
}

########
##
## Variables
##

if [ -z $HOSTNAME ]; then
    HOSTNAME="$(hostname -f)"
fi

if [ -z $DB_HOST ]; then
    var_not_set "DB_HOST"
fi

if [ -z $DB_USER ]; then
    DB_USER="mum_postfix"
fi

if [ -z $DB_PASSWORD ]; then
    var_not_set "DB_PASSWORD"
fi

if [ -z $DB_NAME ]; then
    var_not_set "DB_NAME"
fi

########
##
## Preparation
##

cp /srv/config/{main,master}.cf /etc/postfix/
find /srv/sql/ -type f -name '*.cf' -exec sed -i "s/mum_postfix_user/${DB_USER}/g" {} \;
find /srv/sql/ -type f -name '*.cf' -exec sed -i "s/mum_postfix_password/${DB_PASSWORD}/g" {} \;
find /srv/sql/ -type f -name '*.cf' -exec sed -i "s/mum_postfix_password/${DB_PASSWORD}/g" {} \;
find /srv/sql/ -type f -name '*.cf' -exec sed -i "s/mum_database/${DB_NAME}/g" {} \;
find /srv/sql/ -type f -name '*.cf' -exec sed -i "s/127.0.0.1/${DB_HOST}/g" {} \;

########
##
## Postfix Configuration
##

postconf -e "myhostname = $HOSTNAME"

########
##
## Start
##

postfix start &
touch /var/log/mail.log
tail -f /var/log/mail.log