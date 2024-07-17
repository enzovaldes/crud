GIT_SHA := $(shell git rev-parse --short=7 HEAD)
PROJECT_ID=crud
REGION=us-east-1
AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY=$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(PROJECT_ID)

setup:
	@echo "[setup] Running setup commands..."
	@npm install
	# install aws

clean: 
	@echo "[clean] Cleaning project..."
	@rm -rf dist

build: clean
	@echo "[build] Building setup commands..."
	@npm run build

test:
	@echo "[test] Running tests..."
	@NODE_ENV=test npm test

check: build
	@echo "[check] Checking project..."
	@npm run linter
	@npm run knip

validate-app-name:
	@if [ -z "$(APP_NAME)" ]; then \
		echo "Error: The APP_NAME variable is not set."; \
		exit 1; \
	fi
	@if [ ! -d "src/apps/$(APP_NAME)" ]; then \
		echo "Error: Application '$(APP_NAME)' does not exist in 'src/apps/'"; \
		exit 1; \
	fi

validate-cronjob:
	@if [ -z "$(SCHEDULE)" ]; then \
		echo "Error: The SCHEDULE variable is not set."; \
		exit 1; \
	fi

validate-github-username:
	@if [ -z "$(shell git config user.github)" ]; then \
		echo "Error: The GITHUB_USERNAME variable is not set. Please configure it with 'git config user.github <username>'."; \
		exit 1; \
	fi

ecr-login:
	@echo "[ecr-login] Logging in to Amazon ECR..."
	@aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

dev: validate-app-name build
	@echo "[run-dev $(APP_NAME)] running service in dev mode..."
	@export $$(cat src/apps/$(APP_NAME)/.env) && node_modules/.bin/ts-node -r tsconfig-paths/register src/apps/$(APP_NAME)/index.ts

docker: validate-app-name validate-github-username build
	@echo "[docker $(APP_NAME)] running docker in dev mode..."
	$(eval GITHUB_USERNAME := $(shell git config user.github))
	$(eval DEPLOY_APP_NAME := development-$(APP_NAME)-$(GITHUB_USERNAME))
	@docker build --build-arg APP_NAME=$(APP_NAME) -t $(DEPLOY_APP_NAME):$(GIT_SHA) -f src/apps/$(APP_NAME)/Dockerfile .
	@docker run --env-file src/apps/$(APP_NAME)/.env -p 8080:8080 $(DEPLOY_APP_NAME):$(GIT_SHA)

deploy: validate-app-name validate-github-username build ecr-login
	@echo "[deploy-dev $(APP_NAME)] deploying service in dev mode..."
	$(eval GITHUB_USERNAME := $(shell git config user.github))
	$(eval DEPLOY_APP_NAME := development-$(APP_NAME)-$(GITHUB_USERNAME))
	@docker buildx build --platform linux/amd64,linux/arm64 --build-arg APP_NAME=$(APP_NAME) -t $(ECR_REPOSITORY):$(GIT_SHA) -f src/apps/$(APP_NAME)/Dockerfile . --push
	# create or update secret
	# deploy service

deploy-job: validate-app-name validate-github-username ecr-login
	@echo "[deploy-job $(APP_NAME)] deploying job..."
	$(eval GITHUB_USERNAME := $(shell git config user.github))
	$(eval DEPLOY_APP_NAME := development-$(APP_NAME)-$(GITHUB_USERNAME))
	@docker buildx build --platform linux/amd64,linux/arm64 --build-arg APP_NAME=$(APP_NAME) -t $(ECR_REPOSITORY):$(GIT_SHA) -f src/apps/$(APP_NAME)/Dockerfile . --push
	# create or update secret
	# deploy job

deploy-cronjob: validate-cronjob deploy-job
	@echo "[deploy-cronjob $(APP_NAME)] deploying cronjob..."
	$(eval GITHUB_USERNAME := $(shell git config user.github))
	$(eval DEPLOY_APP_NAME := development-$(APP_NAME)-$(GITHUB_USERNAME))
	# create or update cronjob

destroy: validate-app-name validate-github-username
	@echo "[destroy $(APP_NAME)] destroying cronjob and deployment..."
	$(eval GITHUB_USERNAME := $(shell git config user.github))
	$(eval DEPLOY_APP_NAME := development-$(APP_NAME)-$(GITHUB_USERNAME))
	# delete scheduler
	# delete job
	# delete service

set-envs: validate-app-name
	@if [ -z "$(ENVIRONMENT)" ]; then \
	echo "Error: The ENVIRONMENT variable is not set."; \
	exit 1; \
	fi
	@if [ "$(ENVIRONMENT)" != "production" ] && [ "$(ENVIRONMENT)" != "staging" ]; then \
		echo "Error: The ENVIRONMENT variable must be either 'production' or 'staging'."; \
		exit 1; \
	fi
	# create or update secret
	@gcloud secrets versions add $(ENVIRONMENT)-$(APP_NAME) --data-file=src/apps/$(APP_NAME)/.env || gcloud secrets create $(ENVIRONMENT)-$(APP_NAME) --data-file=src/apps/$(APP_NAME)/.env

.PHONY: setup build clean test check validate-app-name validate-cronjob validate-github-username dev docker deploy deploy-job deploy-cronjob destroy set-envs
