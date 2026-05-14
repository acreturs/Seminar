SHELL := /usr/bin/env bash

.PHONY: help bootstrap-env clone clone-submodules flowr-install assets check dl3dv-12 dl3dv-24 scannet-val custom-splatfacto

help:
	@sed -n '1,120p' README.md

bootstrap-env:
	bash scripts/bootstrap_conda.sh

clone:
	bash scripts/clone_repos.sh --all

clone-submodules:
	bash scripts/clone_repos.sh --all --with-submodules

flowr-install:
	bash scripts/install_flowr.sh

assets:
	bash scripts/download_flowr_assets.sh

download-dl3dv-scene:
	bash scripts/download_dl3dv.sh benchmark-scene

check:
	python3 scripts/check_setup.py

dl3dv-12:
	VIEWS=12 bash scripts/prepare_flowr_dl3dv.sh

dl3dv-24:
	VIEWS=24 bash scripts/prepare_flowr_dl3dv.sh

scannet-val:
	bash scripts/prepare_flowr_scannetpp.sh

custom-splatfacto:
	bash scripts/process_custom_images.sh examples/custom_scene/images custom_scene
