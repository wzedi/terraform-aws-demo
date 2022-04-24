#! /bin/bash

set -e -u -x -o pipefail

cd "$(dirname "$0")"

./create-s3-backend-test.sh