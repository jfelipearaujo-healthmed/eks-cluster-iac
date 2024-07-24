TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
VERSION := $(shell echo $(TAG) | sed 's/v//')

init:
	@echo "Initializing..."
	@cd terraform \
		&& terraform init -reconfigure

check:
	@echo "Checking..."
	make fmt && make validate && make plan

fmt:
	@echo "Formatting..."
	@cd terraform \
		&& terraform fmt -check

validate:
	@echo "Validating..."
	@cd terraform \
		&& terraform validate

plan:
	@echo "Planning..."
	@cd terraform \
		&& terraform plan -var-file="local.tfvars" -out=plan \
		&& terraform show -json plan > plan.tfgraph

apply:
	@echo "Applying..."
	@cd terraform \
		&& terraform apply plan

destroy:
	@echo "Destroying..."
	@cd terraform \
		&& terraform destroy -auto-approve

attach-eks:
	@echo "Attaching to EKS..."
	@aws eks update-kubeconfig --region us-east-1 --name healthmed

gen-tf-docs:
	@echo "Generating Terraform Docs..."
	@terraform-docs markdown table terraform

TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
VERSION := $(shell echo $(TAG) | sed 's/v//')

tag:
	@if [ -z "$(TAG)" ]; then \
        echo "No previous version found. Creating v1.0 tag..."; \
        git tag v1.0; \
    else \
        echo "Previous version found: $(VERSION)"; \
        read -p "Bump major version (M/m) or release version (R/r)? " choice; \
        if [ "$$choice" = "M" ] || [ "$$choice" = "m" ]; then \
            echo "Bumping major version..."; \
			major=$$(echo $(VERSION) | cut -d'.' -f1); \
            major=$$(expr $$major + 1); \
            new_version=$$major.0; \
        elif [ "$$choice" = "R" ] || [ "$$choice" = "r" ]; then \
            echo "Bumping release version..."; \
			release=$$(echo $(VERSION) | cut -d'.' -f2); \
            release=$$(expr $$release + 1); \
            new_version=$$(echo $(VERSION) | cut -d'.' -f1).$$release; \
        else \
            echo "Invalid choice. Aborting."; \
            exit 1; \
        fi; \
        echo "Creating tag for version v$$new_version..."; \
        git tag v$$new_version; \
    fi