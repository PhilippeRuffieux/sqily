#!/bin/sh
set -eu

MINIO_ALIAS="${MINIO_ALIAS:-local}"
MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://minio:9000}"
MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"
MINIO_BUCKET="${MINIO_BUCKET:-sqily-development}"

attempts="${MINIO_SETUP_ATTEMPTS:-30}"
sleep_seconds="${MINIO_SETUP_SLEEP_SECONDS:-1}"

i=0
while ! /usr/bin/mc alias set "$MINIO_ALIAS" "$MINIO_ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
  i=$((i + 1))
  if [ "$i" -ge "$attempts" ]; then
    echo "MinIO did not become ready after ${attempts} attempts." >&2
    exit 1
  fi
  sleep "$sleep_seconds"
done

/usr/bin/mc mb --ignore-existing "${MINIO_ALIAS}/${MINIO_BUCKET}"
/usr/bin/mc anonymous set download "${MINIO_ALIAS}/${MINIO_BUCKET}"
