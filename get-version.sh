#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)

export DEBIAN_VERSION=$(docker run --rm -t get-version cat /etc/debian_version | tail -n1 | tr -d '\r')
export APACHE_VERSION=$(docker run --rm -t get-version dpkg --list apache2 | grep '^ii' | tr ' ' '\n' | grep '[0-9]\.[0-9]'| sed 's/[+=~:]/_/g' | tr -d '\r')
export PHPMYADMIN_VERSION=$(docker run --rm -t get-version ls /var/www/html/phpmyadmin/RELEASE-DATE* | tr '-' '\n' | grep '[0-9]\.[0-9]')
[ -z "$DEBIAN_VERSION" ] && exit 1

export IMGTAG=$(echo "$1""d$DEBIAN_VERSION-a$APACHE_VERSION-p$PHPMYADMIN_VERSION")
export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi