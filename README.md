# phpmyadmin - (ghcr.io/servercontainers/phpmyadmin) (+ optional tls) on debian, apache2 [x86 + arm]

_maintained by ServerContainers_

## What is it

This Dockerfile (available as ___ghcr.io/servercontainers/phpmyadmin___) gives you a ready to use phpmyadmin installation with optional tls.

Note: This container only supports `mysql` / `mariadb` database servers.
There is no internal mysql-server available - so you need to setup a seconds container for that (take a look at `docker-compose.yml`)

View in Docker Registry [ghcr.io/servercontainers/phpmyadmin](https://hub.docker.com/r/ghcr.io/servercontainers/phpmyadmin)

View in GitHub [ServerContainers/docker-phpmyadmin](https://github.com/ServerContainers/docker-phpmyadmin)

This Dockerfile is based on the [ghcr.io/servercontainers/apache2-ssl-secure](https://ghcr.io/servercontainers/apache2-ssl-secure/) `debian:bullseye` based image.

## Build & Versioning

You can specify `DOCKER_REGISTRY` environment variable (for example `my.registry.tld`)
and use the build script to build the main container and it's variants for _x86_64, arm64 and arm_

You'll find all images tagged like `d11.2-a1.18.0-6.1-p5.2.1` which means `d<debian version>-a<apache version (with some esacped chars)>-p<phpmyadmin version (with some esacped chars)>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

To build a `latest` tag run `./build.sh release`

## Changelogs

* 2023-03-20
    * github action to build container
    * implemented ghcr.io as new registry
    * moved from `MarvAmBass` to `ServerContainers`
* 2021-08-27
    * complete rework
    * new inital commit
    * multiarch build

## How to use

This container needs to connect to a database, so take a look at the `docker-compose.yml`

## Environment variables and defaults

* __DB\_HOST__
 * host of mysql db
 * default: `db`

* __SECRET__
 * phpmyadmin `blowfish_secret` - should be a 32 character string
 * default: _auto generated string using: `pwgen 32 1`_

### BASEIMAGE: Environment variables and defaults

* __DISABLE\_TLS__
 * default: not set - if set yo any value `https` and the `HSTS_HEADERS_*` will be disabled

* __HSTS\_HEADERS\_ENABLE__
 * default: not set - if set to any value the HTTP Strict Transport Security will be activated on SSL Channel

* __HSTS\_HEADERS\_ENABLE\_NO\_SUBDOMAINS__
 * default: not set - if set together with __HSTS\_HEADERS\_ENABLE__ and set to any value the HTTP Strict Transport Security will be deactivated on subdomains

