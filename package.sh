#!/bin/bash -e

cd $(dirname $0)

rm -rf vendor/conjur-env
# http://blog.wrouesnel.com/articles/Totally%20static%20Go%20builds/
docker-compose -f conjur-env/docker-compose.yml build
docker-compose -f conjur-env/docker-compose.yml run --rm conjur-env-builder

docker-compose -f ci/docker-compose.yml build
docker-compose -f ci/docker-compose.yml run --rm tester ./package_buildpack.sh
