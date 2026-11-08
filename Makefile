# ==============================================================================
# Makefile: Automation for Spark on AWS EKS Platform
# ==============================================================================

.PHONY: help check fmt validate init plan apply destroy kubeconfig job-pi job-s3 port-forward-history

SHELL := /bin/bash
CLUSTER_NAME ?= spark-on-eks
AWS_REGION ?= us-west-2
NAMESPACE ?= spark-apps

help:
	@echo "Available commands:"
	@echo "  make check                 - Verify CLI dependencies and AWS auth"
	@echo "  make fmt                   - Format all Terraform files recursively"
	@echo "  make validate              - Validate Terraform syntax across all modules"
	@echo "  make init                  - Initialize root Terraform project"
	@echo "  make plan                  - Generate Terraform execution plan"
	@echo "  make apply                 - Apply Terraform configuration"
	@echo "  make destroy               - Tear down infrastructure"
	@echo "  make kubeconfig            - Update local ~/.kube/config context"
	@echo "  make job-pi                - Submit example PySpark Pi test job"
	@echo "  make job-s3                - Submit example S3 dynamic allocation job"
	@echo "  make port-forward-history  - Port-forward Spark History Server to localhost:18080"

check:
	@./scripts/validate-prerequisites.sh

fmt:
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive

validate:
	@echo "Validating modules and root Terraform..."
	@terraform fmt -check -recursive
	@echo "✓ Terraform format check passed."

init:
	@terraform init

plan:
	@terraform plan -out=tfplan

apply:
	@terraform apply tfplan

destroy:
	@terraform destroy

kubeconfig:
	aws eks --region $(AWS_REGION) update-kubeconfig --name $(CLUSTER_NAME)

job-pi:
	@./scripts/submit-spark-job.sh examples/spark-applications/pyspark-pi.yaml $(NAMESPACE)

job-s3:
	@./scripts/submit-spark-job.sh examples/spark-applications/s3-data-processing.yaml $(NAMESPACE)

port-forward-history:
	@echo "Forwarding Spark History Server to http://localhost:18080 ..."
	kubectl port-forward svc/spark-history-server -n spark-history 18080:18080
