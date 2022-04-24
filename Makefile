AWS_CONFIG_DIR ?= ${HOME}/.aws
PLAN_FILE ?= "terraform-plan"
AWS_REGION ?= ap-southeast-2
TF_VAR_PROJECT_NAME ?= "symbiote-terraform-task"
TF_VAR_ENVIRONMENT ?= "development"

ifndef VERBOSE
.SILENT:
endif

.PHONY: terraform
terraform:
	docker run \
		--rm \
		-v $(AWS_CONFIG_DIR):/root/.aws:ro \
		-v $(shell pwd)/$(TF_DIR):/work \
		-w /work \
		-e AWS_PROFILE \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-e TF_VAR_project_name=$(TF_VAR_PROJECT_NAME) \
		-e TF_VAR_environment=$(TF_VAR_ENVIRONMENT) \
		hashicorp/terraform $(TF_ARGS)

.PHONY: jq
jq:
	docker run \
		--rm -i imega/jq \
		$(JQ_ARGS)

.PHONY: tf-init
tf-init:
	$(eval TF_ARGS := init)

.PHONY: tf-apply
tf-apply:
	$(eval TF_ARGS := apply $(PLAN_FILE))

.PHONY: tf-plan
tf-plan:
	$(eval TF_ARGS := plan -out=$(PLAN_FILE))

.PHONY: tf-output
tf-output:
	$(eval TF_ARGS := output -json)

.PHONY: backend
backend:
	$(eval TF_DIR := terraform/backend)

.PHONY: backend-init
backend-init: backend tf-init terraform

.PHONY: backend-plan
backend-plan: backend tf-plan terraform

.PHONY: backend-apply
backend-apply: backend tf-apply terraform

.PHONY: backend-output
backend-output: backend tf-output terraform

.PHONY: backend-deploy
backend-deploy:
	make backend-init
	make backend-plan
	make backend-apply

.PHONY: solution
solution:
	$(eval TF_DIR := terraform/solution)
	$(eval BUCKET_NAME := $(shell make backend-output | JQ_ARGS="-r .bucket_name.value" make jq))
	$(eval TABLE_NAME := $(shell make backend-output | JQ_ARGS="-r .table_name.value" make jq))
	sed 's/<AWS_REGION>/$(AWS_REGION)/g; s/<BUCKET_NAME>/$(BUCKET_NAME)/g; s/<TABLE_NAME>/$(TABLE_NAME)/g' $(TF_DIR)/main.tf.template > $(TF_DIR)/main.tf
	
.PHONY: solution-init
solution-init: solution tf-init terraform

.PHONY: solution-plan
solution-plan: solution tf-plan terraform

.PHONY: solution-apply
solution-apply: solution tf-apply terraform

.PHONY: solution-deploy
solution-deploy:
	make solution-init
	make solution-plan
	make solution-apply