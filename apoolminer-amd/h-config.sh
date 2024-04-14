#!/usr/bin/env bash

cd `dirname $0`

[[ "$CUSTOM_URL" = "" ]] && echo "Using default address" && CUSTOM_URL="qubic1.hk.apool.io:3334"

conf=""
conf+="ADDRESS=\"$CUSTOM_TEMPLATE\""$'\n'
conf+="PROXY=\"$CUSTOM_URL\""$'\n'
conf+="PASS=\"$CUSTOM_PASS\""$'\n'
conf+="EXTRA=\"$CUSTOM_USER_CONFIG\""$'\n'

echo "$conf" > $CUSTOM_CONFIG_FILENAME
