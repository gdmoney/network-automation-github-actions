#!/bin/sh

curl -X 'POST' \
  'http://192.168.255.5:8085/api/v3/jobs/push' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhdXRoMCJ9.SENSdIUM5ZI7BwHH7mVw2cHyZwMzSQCngz0CNBcyAuU' \
  -H 'Content-Type: application/json' \
  -d '{
  "commands": [
    "config replace tftp://172.18.0.2/config_file_router_2 force",
    "write memory"
  ],
  "requireEnableMode": true,
  "requireConfigureMode": false,
  "tagUuids": [
    "27ac3847-ddcf-4109-9984-544fbb52a80f"
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
