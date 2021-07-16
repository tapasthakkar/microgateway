#!/bin/bash

EDGEMICRO_ORG="tapas-0a5674a7-eval"
EDGEMICRO_ENV="test"
EDGEMICRO_KEY="c8cc184ba56ae9512e9252e58f7c81f6d15aca3dabf5b272654e253c8b1339f7"
EDGEMICRO_SECRET="80c0301e8ef43d01c08489927b0cda2d31427dd9135dea7e0cc5b09beed8f6f8"
EDGEMICRO_CONFIG="$(cat ~/.edgemicro/tapas-0a5674a7-eval-test-config.yaml | base64)"

docker run -P -p 8000:8000 -d --name edgemicro_local \
-v /var/tmp:/opt/apigee/logs \
-e EDGEMICRO_PROCESSES=1 \
-e EDGEMICRO_ORG=$EDGEMICRO_ORG \
-e EDGEMICRO_ENV=$EDGEMICRO_ENV \
-e EDGEMICRO_KEY=$EDGEMICRO_KEY \
-e EDGEMICRO_SECRET=$EDGEMICRO_SECRET \
-e "EDGEMICRO_CONFIG=$EDGEMICRO_CONFIG" \
-e SERVICE_NAME=edgemicro \
--user apigee:apigee \
--security-opt=no-new-privileges \
--cap-drop=ALL \
edgemicro_local

echo "Testing the api"
sleep 5
curl http://localhost:8000;echo;