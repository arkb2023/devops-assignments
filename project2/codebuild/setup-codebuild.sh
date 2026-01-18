#!/bin/bash
# -----------------------------------------------------------------------------
# Automates the full CodeBuild setup from clean slate, addressing past
# issues like stale credentials, wrong secret formats, and orphans via 
# comprehensive cleanup and idempotent operation
# -----------------------------------------------------------------------------
# Phase I: Cleanup Stale config if any
# -----------------------------------------------------------------------------
# 1. CodeBuild project delete
# 2. GitHub source credentials delete (list-source-credentials)
# 3. terraform destroy
# -----------------------------------------------------------------------------
# Phase II: Fresh Setup
# -----------------------------------------------------------------------------
# 4. GitHub secret upsert
# 5. Docker Hub secret upsert 
# 6. Update tfvars
# 7. Terraform init
# 8. Terraform apply
# 9. Import GitHub source credentials from secrets manager
# 10. Manual build test (Optional)
# 11. Create webhook for push event
# -----------------------------------------------------------------------------

set -e
source ../env.local.sh

CODEBUILD_NAME="website-build"

# 1. Cleanup first: CodeBuild project delete
# -----------------------------------------------------------------------------
echo "1. Delete old Codebuld project..."
aws codebuild delete-project \
  --region $AWS_REGION \
  --name $CODEBUILD_NAME 2>/dev/null \
  || true
echo "--------------------------------------------------------------------------"

# # 2. GitHub source credentials delete (list-source-credentials)
# # -----------------------------------------------------------------------------
# echo "2. Delete stale GitHub source credentials..."
# GITHUB_CRED_ARN=$(aws codebuild list-source-credentials \
#   --region "$AWS_REGION" \
#   --query 'sourceCredentialsInfos[?serverType==`GITHUB`].arn' \
#   --output text 2>/dev/null || echo "")
# if [ -n "$GITHUB_CRED_ARN" ] && [ "$GITHUB_CRED_ARN" != "None" ]; then
#   echo "Deleting GitHub credential: $GITHUB_CRED_ARN"
#   aws codebuild delete-source-credentials \
#     --region "$AWS_REGION" \
#     --arn "$GITHUB_CRED_ARN" || true
# else
#   echo "No GitHub credentials found."
# fi
# echo "--------------------------------------------------------------------------"

# 3. Terraform destroy
# -----------------------------------------------------------------------------
echo "3. Terraform destroy..."
terraform destroy -auto-approve
echo "--------------------------------------------------------------------------"

# 4. GitHub secret upsert (for buildspec)
# -----------------------------------------------------------------------------
echo "4. GitHub Hub secret (for buildspec): $GITHUB_SECRET"
EXISTING_ARN=$(aws secretsmanager describe-secret \
  --secret-id "$GITHUB_SECRET" \
  --region "$AWS_REGION" \
  --query ARN \
  --output text 2>/dev/null || echo "")
  if [ -n "$EXISTING_ARN" ]; then
  echo "Secret exists: $EXISTING_ARN"
  echo "Updating PAT value..."
  aws secretsmanager put-secret-value \
    --secret-id "$GITHUB_SECRET" \
    --secret-string "{
      \"AuthType\": \"PERSONAL_ACCESS_TOKEN\",
      \"ServerType\": \"GITHUB\",
      \"Token\": \"$GITHUB_PAT\"
    }" \
    --region "$AWS_REGION"
  GITHUB_SECRET_ARN="$EXISTING_ARN"
else
  echo "Creating new secret..."
  GITHUB_SECRET_ARN=$(aws secretsmanager create-secret \
    --region "$AWS_REGION" \
    --name "$GITHUB_SECRET" \
      --secret-string "{
        \"AuthType\": \"PERSONAL_ACCESS_TOKEN\",
        \"ServerType\": \"GITHUB\",
        \"Token\": \"$GITHUB_PAT\"
      }" \
    --query ARN \
    --output text)
  echo "Created: $GITHUB_SECRET_ARN"
fi
echo "--------------------------------------------------------------------------"

# 5. Docker Hub secret upsert 
# -----------------------------------------------------------------------------
# Docker Hub secret (for buildspec)
echo "DockerHub Hub secret (for buildspec): $DOCKERHUB_SECRET"
EXISTING_DH_ARN=$(aws secretsmanager describe-secret \
  --secret-id "$DOCKERHUB_SECRET" \
  --region "$AWS_REGION" \
  --query ARN --output text 2>/dev/null || echo "")

if [ -n "$EXISTING_DH_ARN" ]; then
  echo "Updating Docker Hub secret..."
  aws secretsmanager put-secret-value \
    --secret-id "$DOCKERHUB_SECRET" \
    --secret-string "{\"username\":\"$DOCKERHUB_USERNAME\",\"password\":\"$DOCKERHUB_PAT\"}" \
    --region "$AWS_REGION"
  DOCKERHUB_SECRET_ARN="$EXISTING_DH_ARN"
else
  echo "Creating Docker Hub secret..."
  DOCKERHUB_SECRET_ARN=$(aws secretsmanager create-secret \
    --name "$DOCKERHUB_SECRET" \
    --secret-string "{\"username\":\"$DOCKERHUB_USERNAME\",\"password\":\"$DOCKERHUB_PAT\"}" \
    --region "$AWS_REGION" \
    --query ARN --output text)
fi
echo "--------------------------------------------------------------------------"

# 6. Update tfvars
# -----------------------------------------------------------------------------
echo "Update tfvars..."
cat > terraform.tfvars << EOF
aws_region              = "$AWS_REGION"
github_token_secret_arn = "$GITHUB_SECRET_ARN"
dockerhub_token_secret_arn = "$DOCKERHUB_SECRET_ARN"
github_connection_arn      = "$GITHUB_CONNECTION_ARN"
EOF
echo "--------------------------------------------------------------------------"

# 7. Terraform init
# -----------------------------------------------------------------------------
echo "Terraform Init..."
terraform init
echo "--------------------------------------------------------------------------"

# 8. Terraform apply
# -----------------------------------------------------------------------------
echo "Terraform apply"
terraform apply -auto-approve

# 9. Import GitHub source credentials from secrets manager
# -----------------------------------------------------------------------------
echo "Import source credentials from secrets manager into codebuild..."
aws codebuild import-source-credentials \
  --region $AWS_REGION \
  --server-type GITHUB \
  --auth-type SECRETS_MANAGER \
  --token "$GITHUB_SECRET_ARN" \
  --should-overwrite
echo "--------------------------------------------------------------------------"

# 10. Manual build test (Optional)
# Uncomment for manual build Trigger
# -----------------------------------------------------------------------------
echo "Manual Test: Triggering build..."
aws codebuild start-build \
  --region "$AWS_REGION" \
  --project-name "$CODEBUILD_NAME"
BUILD_ID=$(aws codebuild list-builds-for-project \
  --region "$AWS_REGION" \
  --project-name "$CODEBUILD_NAME" \
  --sort-order DESCENDING \
  --max-items 1 \
  --query 'ids[0]' \
  --output text)

echo "Build triggered: $BUILD_ID"

# Poll status only
echo "Polling status (max 10min)..."
MAX_TRIES=60  # ~10min @10s
for i in $(seq 1 $MAX_TRIES); do
  STATUS=$(aws codebuild batch-get-builds \
    --region "$AWS_REGION" \
    --ids "$BUILD_ID" \
    --query 'builds[0].buildStatus' \
    --output text)

  echo "[$i/$MAX_TRIES] $BUILD_ID: $STATUS"

  if [[ "$STATUS" == "SUCCEEDED" ]]; then
    echo "Manual build SUCCEEDED!"
    break
  elif [[ "$STATUS" =~ ^(FAILED|FAULT|STOPPED|TIMED_OUT)$ ]]; then
    echo "Manual build FAILED: $STATUS"
    exit 1
  fi
  sleep 10
done

# 11. Create webhook for push event
# -----------------------------------------------------------------------------
echo "Creating webhook for push event..."
aws codebuild create-webhook \
  --region $AWS_REGION \
  --project-name $CODEBUILD_NAME \
  --filter-groups '[[{"type": "EVENT","pattern": "PUSH"}, 
    {"type": "HEAD_REF", "pattern": "^refs/heads/main$"}]]' \
  || true

echo "Codebuild setup done!"
echo "Test: cd ~/workspace/website && echo test >> README.md && git add README.md && git commit -m test && git push origin main"
