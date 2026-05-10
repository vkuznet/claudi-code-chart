#!/usr/bin/env bash
set -euo pipefail

LOGFILE=/tmp/ollama.log

echo "Starting Ollama server..."

nohup ollama serve > "$LOGFILE" 2>&1 < /dev/null &

# Wait for Ollama API
echo "Waiting for Ollama API..."

for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:11434/api/tags >/dev/null; then
        break
    fi
    sleep 1
done

echo "Ensuring model exists..."

if ! ollama list | grep -q "gpt-oss:20b-cloud"; then
    ollama pull gpt-oss:20b-cloud
fi

echo
echo "Ollama is ready."
echo "Logs: $LOGFILE"
echo

exec /bin/bash
