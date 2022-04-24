#! /bin/bash

set -e -u -x -o pipefail

AWS_REGION=${AWS_REGION:-ap-southeast-2}
NAME=symbiote-tf-backend-${RANDOM}
AWS_ENDPOINT_URL=${AWS_ENDPOINT_URL:-}

[[ -n ${AWS_ENDPOINT_URL} ]] && ENDPOINT_URL_PARAM="--endpoint-url=${AWS_ENDPOINT_URL}" || ENDPOINT_URL_PARAM=

aws ${ENDPOINT_URL_PARAM} \
    s3api create-bucket \
    --bucket ${NAME} \
    --region ${AWS_REGION} \
    --create-bucket-configuration LocationConstraint=${AWS_REGION}

aws ${ENDPOINT_URL_PARAM} \
    put-bucket-versioning \
    --bucket ${NAME} \
    --versioning-configuration MFADelete=Disabled,Status=Enabled

aws ${ENDPOINT_URL_PARAM} \
    dynamodb create-table \
    --table-name ${NAME} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH