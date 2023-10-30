#!/bin/sh
curl -X 'POST' \
  'http://172.18.50.1:8085/api/v3/jobs/push' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhdXRoMCJ9.SENSdIUM5ZI7BwHH7mVw2cHyZwMzSQCngz0CNBcyAuU' \
  -H 'Content-Type: application/json' \
  -d '{
  "commands": [
    "config replace tftp://172.17.0.2/config_file_access_switch force"
  ],
  "requireEnableMode": true,
  "requireConfigureMode": false,
  "tagUuids": [
    "b29da665-3147-4790-a775-ac8ed583231b"
  ],
  "advancedSettings": {
    "promptMatchingMode": "LEARNING",
    "overrideTimeouts": false,
    "timeout": 0,
    "overrideCredentials": false,
    "username": "string",
    "password": "string",
    "enablePassword": "string",
    "configurePassword": "string"
  }
}'
