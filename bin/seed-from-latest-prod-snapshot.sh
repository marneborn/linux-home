#!/usr/bin/env bash
set -e

SCRIPT_DIR="$HOME/noodle/noodle-api/scripts/postgres"

DOTENV_FILE=/tmp/.env.prod.$$
yarn run:ts --project tsconfig.just-configuration.json "$SCRIPT_DIR/../createDotEnv.ts" --tier production --out $DOTENV_FILE

POSTGRES_SNAPSHOT_BUCKET=$(DOTENV_CONFIG_PATH=$DOTENV_FILE "$SCRIPT_DIR/../printAKey.sh" POSTGRES_SNAPSHOT_BUCKET)
POSTGRES_SNAPSHOT_NAME=$(DOTENV_CONFIG_PATH=$DOTENV_FILE "$SCRIPT_DIR/../printAKey.sh" POSTGRES_SNAPSHOT_NAME)

rm $DOTENV_FILE

LATEST_SNAPSHOT=$(aws s3api list-objects-v2 \
  --bucket "$POSTGRES_SNAPSHOT_BUCKET" \
  --prefix "postgres_snapshot_${POSTGRES_SNAPSHOT_NAME}" \
  --query 'reverse(sort_by(Contents,&LastModified))[:1].Key' \
  --output=text
)

if [ -z "$LATEST_SNAPSHOT" ]; then
  >&2 echo "Could not find LATEST_SNAPSHOT from $POSTGRES_SNAPSHOT_BUCKET"
  exit 1
fi 

aws s3 cp "s3://$POSTGRES_SNAPSHOT_BUCKET/$LATEST_SNAPSHOT" "$LATEST_SNAPSHOT"

echo "Seeding from $LATEST_SNAPSHOT"

"$SCRIPT_DIR/restore-from-file.sh" "$LATEST_SNAPSHOT"
