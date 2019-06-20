################################################################################
#
# Make layer
#
################################################################################

CP			= cp -f
RM			= rm -f
ECHO			= echo -e
TAG			= etags
PIP			= pip
PYTHON			= python3
SHELL			= /bin/bash
WATCH			= /usr/bin/watch

AWS			= aws

VENV 			?= .venv
VENV_ACTIVATE		=. $(VENV)/bin/activate

REPODIR 		?= $(shell bash -i -c 'read -e -p "Path to your repo: " path; echo $$path')
PACKAGENAME		?= $(shell bash -c 'read -p "Package name: " package; echo $$package')
LAYERNAME		?= $(shell bash -c 'read -p "Layer name: " layer; echo $$layer')

GITHUB_OWNER		?= $(shell bash -c 'read -p "Owner name: " owner; echo $$owner')
GITHUB_REPO		?= $(shell bash -c 'read -p "Repo name: " repo; echo $$repo')
GITHUB_BRANCH		?= $(shell bash -c 'read -p "Branch name: " branch; echo $$branch')
GITHUB_TOKEN		?= $(shell bash -c 'read -p "Github dev token: " token; echo $$token')

ifndef VERBOSE
.SILENT:
endif

export VIRTUAL_ENV 	:= $(abspath ${VENV})
export PATH 		:= ${VIRTUAL_ENV}/bin:${PATH}

${VENV}			:
			$(PYTHON) -m venv $@

## venv: Creates venv
venv			:
			test -d ${VENV} || $(MAKE) venv-install
			$(VENV_ACTIVATE)
			which python
## venv-install: Force venv install
venv-install		: requirements.txt | ${VENV}
			$(PIP) install -U pip
			$(PIP) install --upgrade -r requirements.txt

## parmeters: Create stack parameters

parameters		:
			test -f layer_params.json || $(MAKE) create-parameters


## create-parameters: Force creation of parameters for CFN

create-parameters	: venv $(VENV_ACTIVATE)
			$(PYTHON) create_params.py --owner $(GITHUB_OWNER) \
			--repo $(GITHUB_REPO) --branch $(GITHUB_BRANCH) \
			--token $(GITHUB_TOKEN) --layer-name $(LAYERNAME) \
			--package-name $(PACKAGENAME)


## clean-parameters: Delete parameters

clean-parameters	:
			$(RM) layer_params.json

## install: Copies files to your repository

install			:
			$(CP) buildspec.yml layer_build.py $(REPODIR)/

## create: create CFN stack

create			: $(VENV_ACTIVATE) validate parameters
			$(AWS) cloudformation create-stack --stack-name lambda-layer-$(LAYERNAME) \
			--template-body file://pipeline_template.yml \
			--capabilities CAPABILITY_IAM --parameters file://layer_params.json

# update: Update the CFN stack

update			: $(VENV_ACTIVATE) validate
			$(AWS) cloudformation update-stack --stack-name lambda-layer-$(LAYERNAME) \
			--template-body file://pipeline_template.yml \
			--capabilities CAPABILITY_IAM --parameters file://layer_params.json

## delete: Delete the CFN stack

delete			: $(VENV_ACTIVATE)
			$(AWS) cloudformation delete-stack --stack-name lambda-layer-$(LAYERNAME)

## validate: Validate the CFN template

validate		: $(VENV_ACTIVATE)
			$(AWS) cloudformation validate-template \
			--template-body file://pipeline_template.yml

## events: describe events for the stack

events			: $(VENV_ACTIVATE)
			$(AWS) cloudformation describe-stack-events \
			--stack-name lambda-layer-$(LAYERNAME) \
			--region $(AWS_REGION)

## watch: watch describe-events

watch			:
			$(WATCH) --interval 1 "bash -c 'make events | head -40'"


all			:

help			: Makefile
			@sed -n 's/^##//p' $<

.PHONY			: all venv venv-install clean validate watch events create update delete parameters create-parameters help
