#!/bin/bash

# Variables
API_URL="http://192.168.255.5:8085/api/v3/jobs/push"
AUTH_TOKEN="${AUTH_TOKEN}"
TAG_UUID="b29da665-3147-4790-a775-ac8ed583231b"

# Lookup server's IP address
TFTP_SERVER_HOSTNAME="ubuntu"
TFTP_SERVER_IP=$(getent hosts "${TFTP_SERVER_HOSTNAME}" | awk '{ print $1 }')

if [ -z "$TFTP_SERVER_IP" ]; then
  echo "Could not resolve IP address for ${TFTP_SERVER_HOSTNAME}"
  exit 1
fi

COMMAND1="config replace tftp://${TFTP_SERVER_IP}/config_file_access_switch force"
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
