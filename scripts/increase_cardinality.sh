#!/bin/bash

# Default values
DEFAULT_METRIC_COUNT=100
DEFAULT_SERIES_COUNT=10

# Check if metric count is provided
if [ -n "$1" ]; then
    METRIC_COUNT=$1
else
    METRIC_COUNT=$DEFAULT_METRIC_COUNT
fi

# Check if series count is provided
if [ -n "$2" ]; then
    SERIES_COUNT=$2
else
    SERIES_COUNT=$DEFAULT_SERIES_COUNT
fi

kubectl patch deployment \
  metric-source \
  --namespace default \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
  "--metric-count='"$METRIC_COUNT"'",
  "--series-count='"$SERIES_COUNT"'",
  "--port=9001"
]}]'
