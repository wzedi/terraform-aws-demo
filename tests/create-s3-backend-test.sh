#! /bin/bash

set -e -u -x -o pipefail

./setup.sh
source ./.env
../scripts/create-s3-backend.sh