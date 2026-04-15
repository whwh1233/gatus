#!/bin/bash
set -a
source "$(dirname "$0")/.env"
set +a
export GATUS_CONFIG_PATH="$(dirname "$0")/config.yaml"
exec "$(dirname "$0")/gatus"
