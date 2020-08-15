TERRAFORM_VERSION := 0.12.21
PACKER_VERSION := 1.2.5
BIN_LOCATION := "./bin"

include makefiles/terraform.mk

.PHONY: clean
clean: terraform-clean packer-clean

