#!/bin/bash

# Variables
API_URL="http://192.168.255.5:8085/api/v3/jobs/push"
TAG_UUID="918e0832-dfcf-4fd6-8811-ce8a34d3f302"
CONFIG_FILE="config_file_core_switch"

# Auth token comes from the environment (GitHub Actions secret)
if [ -z "${AUTH_TOKEN}" ]; then
  echo "ERROR: AUTH_TOKEN is not set"
  exit 1
fi
# Normalize: works whether or not the secret already includes the 'Bearer ' prefix
AUTH_TOKEN="Bearer ${AUTH_TOKEN#Bearer }"

# Lookup server's IP address
TFTP_SERVER_HOSTNAME="ubuntu"
TFTP_SERVER_IP=$(getent hosts "${TFTP_SERVER_HOSTNAME}" | awk '{ print $1 }')

if [ -z "$TFTP_SERVER_IP" ]; then
  echo "ERROR: Could not resolve IP address for ${TFTP_SERVER_HOSTNAME}"
  exit 1
fi

COMMAND1="config replace tftp://${TFTP_SERVER_IP}/${CONFIG_FILE} force"
COMMAND2="write memory"
USERNAME="string"
PASSWORD="string"
ENABLE_PASSWORD="string"
CONFIGURE_PASSWORD="string"

# Curl command - capture HTTP status and response so failures fail the workflow
RESPONSE_FILE=$(mktemp)
HTTP_CODE=$(curl -sS -o "${RESPONSE_FILE}" -w '%{http_code}' -X 'POST' "${API_URL}" \
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
}")

echo "HTTP status: ${HTTP_CODE}"
echo "Response: $(cat "${RESPONSE_FILE}")"

if [ "${HTTP_CODE}" -lt 200 ] || [ "${HTTP_CODE}" -ge 300 ]; then
  echo "ERROR: Unimus API call failed (HTTP ${HTTP_CODE})"
  rm -f "${RESPONSE_FILE}"
  exit 1
fi

if ! grep -q '"jobUuid"' "${RESPONSE_FILE}"; then
  echo "ERROR: No jobUuid in response - push job was not created"
  rm -f "${RESPONSE_FILE}"
  exit 1
fi

if grep -q '"acceptedTasks":\[\]' "${RESPONSE_FILE}"; then
  echo "ERROR: Job created but no tasks accepted - check devices/tag ${TAG_UUID}"
  rm -f "${RESPONSE_FILE}"
  exit 1
fi

rm -f "${RESPONSE_FILE}"
echo "Push job submitted successfully"
