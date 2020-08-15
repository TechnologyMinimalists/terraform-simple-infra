# Operating system: darwin, freebsd, linux, openbsd, solaris, windows
OS = linux

# Architecture: 386, amd64, arm
ARCH = amd64

RELEASES_URL = https://releases.hashicorp.com
TERRAFORM_FILENAME = terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip
PACKER_FILENAME = packer_${PACKER_VERSION}_${OS}_${ARCH}.zip

.PHONY: terraform packer terraform-download packer-download all clean docker-compose

terraform-download:
	wget ${RELEASES_URL}/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILENAME}
	unzip ${TERRAFORM_FILENAME} -d ${BIN_LOCATION}

terraform-clean:
	rm ${TERRAFORM_FILENAME}

packer-download:
	wget ${RELEASES_URL}/packer/${PACKER_VERSION}/${PACKER_FILENAME}
	unzip ${PACKER_FILENAME} -d ${BIN_LOCATION}

packer-clean:
	rm ${PACKER_FILENAME}
