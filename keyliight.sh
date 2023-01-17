#!/bin/bash
NEXT_STATE="0"
CURRENTLY_ON=$(curl -s http://192.168.1.74:9123/elgato/lights | jq .lights[].on)

if [ "$CURRENTLY_ON" == "0" ]; then
  NEXT_STATE="1"
fi
curl -s -X PUT -d '{"lights": [{ "on": '$NEXT_STATE'}]}' http://192.168.1.74:9123/elgato/lights
