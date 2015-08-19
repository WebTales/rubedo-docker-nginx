#!/bin/bash
# set -e

if [ -d /var/www/html/rubedo ]; then
    rm -rf /var/www/html/rubedo
fi

if [ "${URL}" = "**None**" ] && [ "${GITHUB_APIKEY}" = "**None**" ]; then
    mkdir -p /var/www/html/rubedo
    wget -O /var/www/html/rubedo.tar.gz https://github.com/WebTales/rubedo/releases/download/3.1.0/rubedo-3.1.tar.gz
    tar -zxvf /var/www/html/rubedo.tar.gz -C /var/www/html/
    rm -f /var/www/html/rubedo.tar.gz
else
    if [ "${EXTENSIONS_REQUIRES}" = "**None**" ]; then
        unset EXTENSIONS_REQUIRES
    fi

    if [ "${EXTENSIONS_REPOSITORIES}" = "**None**" ]; then
        unset EXTENSIONS_REPOSITORIES
    fi

    if [ "${URL}" != "**None**" ]; then
        mkdir -p /var/www/html/rubedo
        wget -O /var/www/html/rubedo.tar.gz "$URL"
        tar -zxvf /var/www/html/rubedo.tar.gz -C /var/www/html/rubedo --strip-components=1 && rm -f /var/www/html/rubedo.tar.gz
    else
        if [ "${VERSION}" != "**None**" ]; then
            git clone -b "$VERSION" https://github.com/WebTales/rubedo.git /var/www/html/rubedo
        else
            git clone -b 3.1.x https://github.com/WebTales/rubedo.git /var/www/html/rubedo
        fi
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/var/www/html/rubedo
        if [ "${EXTENSIONS_REQUIRES}" ] && [ "${EXTENSIONS_REPOSITORIES}" ]; then
            python generate-composer-extension.py >> /var/www/html/rubedo/composer.extensions.json
        fi
        cd /var/www/html/rubedo/
        php composer.phar config -g github-oauth.github.com 30def8c238c6b161663e2794682d40f722303210
        ./rubedo.sh
    fi
fi


exec "$@"