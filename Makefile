SHELL := /bin/bash
REPO_URL ?= https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git
ENV ?= prod

.PHONY: init fmt validate-terraform validate-manifests validate-python render-bootstrap bootstrap-argocd build-inference-image build-training-image

init:
	terraform -chdir=infra/terraform/live/prod init

fmt:
	terraform fmt -recursive infra/terraform
	python3 -m compileall apps scripts

validate-terraform:
	bash ./scripts/validate_terraform.sh

validate-manifests:
	bash ./scripts/validate_manifests.sh

validate-python:
	python3 -m compileall apps scripts

render-bootstrap:
	REPO_URL=$(REPO_URL) bash ./scripts/render_bootstrap.sh

bootstrap-argocd: render-bootstrap
	bash ./scripts/bootstrap_argocd.sh

build-inference-image:
	docker build -t inference-gateway:local apps/inference-gateway/image

build-training-image:
	docker build -t training-runner:local apps/training-jobs/image
