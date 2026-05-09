#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-1"
PROJECT="sqily"
ENV_FILE=".env"
USER_NAME=""
BUCKET_NAME=""
PROFILE=""

usage() {
  cat <<'USAGE'
Usage:
  scripts/setup-aws-s3-dev.sh [options]

Options:
  --project <name>      Project slug used for default names (default: sqily)
  --bucket <name>       Explicit bucket name (default: auto-generated)
  --user <name>         Explicit IAM user name (default: <project>-dev-s3-app)
  --env-file <path>     Env file to update (default: .env)
  --profile <profile>   AWS CLI profile to use
  -h, --help            Show this help

This script:
1) creates an S3 bucket in eu-west-1 (if missing),
2) configures bucket settings to allow object ACLs and public object reads,
3) configures permissive CORS for browser-based uploads from local dev,
4) creates an IAM user with least-privilege S3 access to that bucket,
5) creates an access key,
6) writes AWS_BUCKET_URL to the env file.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --bucket) BUCKET_NAME="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

aws_cmd=(aws)
if [[ -n "$PROFILE" ]]; then
  aws_cmd+=(--profile "$PROFILE")
fi

echo "Checking AWS CLI authentication..."
ACCOUNT_ID="$("${aws_cmd[@]}" sts get-caller-identity --query Account --output text)"
if [[ -z "$ACCOUNT_ID" || "$ACCOUNT_ID" == "None" ]]; then
  echo "Unable to resolve AWS account id from current credentials." >&2
  exit 1
fi

if [[ -z "$BUCKET_NAME" ]]; then
  BUCKET_NAME="${PROJECT}-dev-${ACCOUNT_ID}-${REGION}"
fi

if [[ -z "$USER_NAME" ]]; then
  USER_NAME="${PROJECT}-dev-s3-app"
fi

POLICY_NAME="${PROJECT}-dev-s3-bucket-policy"

echo "Using account: $ACCOUNT_ID"
echo "Using region: $REGION"
echo "Using bucket: $BUCKET_NAME"
echo "Using IAM user: $USER_NAME"

echo "Ensuring S3 bucket exists..."
if "${aws_cmd[@]}" s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
  echo "Bucket already exists: $BUCKET_NAME"
else
  "${aws_cmd[@]}" s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration "LocationConstraint=$REGION" >/dev/null
  echo "Created bucket: $BUCKET_NAME"
fi

echo "Configuring bucket ownership and public access settings (ACL-compatible)..."
"${aws_cmd[@]}" s3api put-bucket-ownership-controls \
  --bucket "$BUCKET_NAME" \
  --ownership-controls 'Rules=[{ObjectOwnership=BucketOwnerPreferred}]' >/dev/null

"${aws_cmd[@]}" s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  'BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false' >/dev/null

TMP_BUCKET_POLICY="$(mktemp)"
cat > "$TMP_BUCKET_POLICY" <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
POLICY

echo "Applying public-read bucket policy..."
"${aws_cmd[@]}" s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "file://$TMP_BUCKET_POLICY" >/dev/null
rm -f "$TMP_BUCKET_POLICY"

TMP_CORS="$(mktemp)"
cat > "$TMP_CORS" <<CORS
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "HEAD", "POST"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag", "Location"],
      "MaxAgeSeconds": 3000
    }
  ]
}
CORS

echo "Applying bucket CORS configuration..."
"${aws_cmd[@]}" s3api put-bucket-cors \
  --bucket "$BUCKET_NAME" \
  --cors-configuration "file://$TMP_CORS" >/dev/null
rm -f "$TMP_CORS"

echo "Ensuring IAM user exists..."
if "${aws_cmd[@]}" iam get-user --user-name "$USER_NAME" >/dev/null 2>&1; then
  echo "IAM user already exists: $USER_NAME"
else
  "${aws_cmd[@]}" iam create-user --user-name "$USER_NAME" >/dev/null
  echo "Created IAM user: $USER_NAME"
fi

TMP_POLICY="$(mktemp)"
cat > "$TMP_POLICY" <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BucketMeta",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::$BUCKET_NAME"
    },
    {
      "Sid": "ObjectRWAcl",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
POLICY

echo "Applying inline least-privilege policy to IAM user..."
"${aws_cmd[@]}" iam put-user-policy \
  --user-name "$USER_NAME" \
  --policy-name "$POLICY_NAME" \
  --policy-document "file://$TMP_POLICY" >/dev/null
rm -f "$TMP_POLICY"

echo "Cleaning up inactive IAM access keys..."
"${aws_cmd[@]}" iam list-access-keys \
  --user-name "$USER_NAME" \
  --query 'AccessKeyMetadata[?Status==`Inactive`].AccessKeyId' \
  --output text | tr '\t' '\n' | while IFS= read -r ACCESS_KEY_ID_TO_DELETE; do
    [[ -z "$ACCESS_KEY_ID_TO_DELETE" ]] && continue
    echo "Deleting inactive access key: $ACCESS_KEY_ID_TO_DELETE"
    "${aws_cmd[@]}" iam delete-access-key \
      --user-name "$USER_NAME" \
      --access-key-id "$ACCESS_KEY_ID_TO_DELETE" >/dev/null
  done

echo "Creating access key for IAM user..."
ACCESS_KEY_COUNT="$("${aws_cmd[@]}" iam list-access-keys --user-name "$USER_NAME" --query 'length(AccessKeyMetadata)' --output text)"
if [[ "$ACCESS_KEY_COUNT" -ge 2 ]]; then
  echo "IAM user still has 2 active access keys. Delete one key before re-running:" >&2
  echo "  aws iam list-access-keys --user-name $USER_NAME" >&2
  exit 1
fi

ACCESS_KEY_ID=""
SECRET_ACCESS_KEY=""
MAX_ATTEMPTS=6

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
  read -r TRY_ACCESS_KEY_ID TRY_SECRET_ACCESS_KEY < <(
    "${aws_cmd[@]}" iam create-access-key \
      --user-name "$USER_NAME" \
      --query 'AccessKey.[AccessKeyId,SecretAccessKey]' \
      --output text
  )

  if [[ -z "$TRY_ACCESS_KEY_ID" || -z "$TRY_SECRET_ACCESS_KEY" ]]; then
    echo "Failed to parse access key output." >&2
    exit 1
  fi

  TRY_URL="https://${TRY_ACCESS_KEY_ID}:${TRY_SECRET_ACCESS_KEY}@s3-${REGION}.amazonaws.com/${BUCKET_NAME}"
  if ruby -ruri -e 'u=URI.parse(ARGV[0]); exit(u.password == ARGV[1] ? 0 : 1)' "$TRY_URL" "$TRY_SECRET_ACCESS_KEY"; then
    ACCESS_KEY_ID="$TRY_ACCESS_KEY_ID"
    SECRET_ACCESS_KEY="$TRY_SECRET_ACCESS_KEY"
    break
  fi

  echo "Generated key $i/$MAX_ATTEMPTS is not URI-compatible with current app parsing, rotating..."
  "${aws_cmd[@]}" iam delete-access-key \
    --user-name "$USER_NAME" \
    --access-key-id "$TRY_ACCESS_KEY_ID" >/dev/null
done

if [[ -z "$ACCESS_KEY_ID" || -z "$SECRET_ACCESS_KEY" ]]; then
  echo "Unable to generate a URI-compatible AWS secret key after $MAX_ATTEMPTS attempts." >&2
  echo "Delete one access key and re-run the script:" >&2
  echo "  aws iam list-access-keys --user-name $USER_NAME" >&2
  exit 1
fi

AWS_BUCKET_URL="https://${ACCESS_KEY_ID}:${SECRET_ACCESS_KEY}@s3-${REGION}.amazonaws.com/${BUCKET_NAME}"

echo "Updating $ENV_FILE ..."
touch "$ENV_FILE"
TMP_ENV="$(mktemp)"
grep -vE '^(AWS_BUCKET_URL|AWS_BUCKET_PREFIX)=' "$ENV_FILE" > "$TMP_ENV" || true
{
  cat "$TMP_ENV"
  echo "AWS_BUCKET_URL=$AWS_BUCKET_URL"
  echo "AWS_BUCKET_PREFIX=development"
} > "$ENV_FILE"
rm -f "$TMP_ENV"

echo
echo "Done."
echo "Bucket: $BUCKET_NAME"
echo "IAM user: $USER_NAME"
echo "Bucket policy: public-read objects enabled"
echo "Bucket CORS: enabled for browser uploads"
echo "AWS_BUCKET_URL written to: $ENV_FILE"
echo
echo "Next:"
echo "  docker compose down"
echo "  docker compose up -d db web"
