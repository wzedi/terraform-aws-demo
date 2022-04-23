AWS_CONFIG_DIR ?= ${HOME}/.aws
PLAN_FILE ?= "terraform-plan"

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
		hashicorp/terraform $(TF_ARGS)

.PHONY: tf-init
tf-init:
	$(eval TF_ARGS := init)

.PHONY: tf-apply
tf-apply:
	$(eval TF_ARGS := apply $(PLAN_FILE))

.PHONY: tf-plan
tf-plan:
	$(eval TF_ARGS := plan -out=$(PLAN_FILE))

.PHONY: backend
backend:
	$(eval TF_DIR := terraform/backend)

.PHONY: backend-init
backend-init: backend tf-init terraform

.PHONY: backend-plan
backend-plan: backend tf-plan terraform

.PHONY: backend-apply
backend-apply: backend tf-apply terraform

.PHONY: backend-deploy
backend-deploy: backend-init backend-plan backend-apply

.PHONY: solution
solution:
	$(eval TF_DIR := terraform/solution)
