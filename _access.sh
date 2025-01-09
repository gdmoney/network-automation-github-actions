#!/bin/bash

# Variables
API_URL="http://192.168.255.5:8085/api/v3/jobs/push"
AUTH_TOKEN=$AUTH_TOKEN
TAG_UUID="b29da665-3147-4790-a775-ac8ed583231b"
COMMAND1="config replace tftp://172.18.0.2/config_file_access_switch force"
COMMAND2="write memory"
USERNAME="string"
PASSWORD="string"
ENABLE_PASSWORD="string"
CONFIGURE_PASSWORD="string"

# Curl command
curl -X 'POST' ${API_URL} \
  -H 'accept: application/json' \
  -H "Authorization: ${AUTH_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d "{
  \"commands\": [
    \"${COMMAND1}\",
    \"${COMMAND2}\"
  ],
  \"requireEnableMode\": true,
  \"requireConfigureMode\": false,
  \"tagUuids\": [
    \"${TAG_UUID}\"
  ],
  \"advancedSettings\": {
    \"promptMatchingModeEnum\": \"LEARNING\",
    \"overrideTimeouts\": false,
    \"timeout\": 0,
    \"overrideCredentials\": false,
    \"username\": \"${USERNAME}\",
    \"password\": \"${PASSWORD}\",
    \"enablePassword\": \"${ENABLE_PASSWORD}\",
    \"configurePassword\": \"${CONFIGURE_PASSWORD}\"
  }
}"
