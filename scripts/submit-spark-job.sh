#!/usr/bin/env bash
# ==============================================================================
# Script: submit-spark-job.sh
# Injects Terraform outputs into SparkApplication manifest and submits it to EKS
# ==============================================================================

set -euo pipefail

JOB_TEMPLATE=${1:-"examples/spark-applications/pyspark-pi.yaml"}
NAMESPACE=${2:-"spark-apps"}

if [ ! -f "$JOB_TEMPLATE" ]; then
  echo "Error: Job template file '$JOB_TEMPLATE' does not exist."
  echo "Usage: $0 [path/to/manifest.yaml] [namespace]"
  exit 1
fi

echo "Resolving S3 Event Log Bucket from Terraform output..."
EVENT_LOG_BUCKET=$(terraform output -raw s3_event_log_bucket 2>/dev/null || echo "")

if [ -z "$EVENT_LOG_BUCKET" ]; then
  echo "Warning: Could not read 's3_event_log_bucket' from Terraform output."
  read -r -p "Enter S3 Event Log Bucket Name manually: " EVENT_LOG_BUCKET
fi

TMP_JOB=$(mktemp)
sed "s/<EVENT_LOG_BUCKET>/$EVENT_LOG_BUCKET/g" "$JOB_TEMPLATE" > "$TMP_JOB"

JOB_NAME=$(grep "name:" "$TMP_JOB" | head -n 1 | awk '{print $2}')

echo "Applying SparkApplication '$JOB_NAME' in namespace '$NAMESPACE'..."
kubectl apply -f "$TMP_JOB"
rm -f "$TMP_JOB"

echo ""
echo "SparkApplication submitted successfully."
echo "Monitoring application status (Press Ctrl+C to stop watching):"
echo "------------------------------------------------------------"
kubectl get sparkapplications -n "$NAMESPACE" -w
