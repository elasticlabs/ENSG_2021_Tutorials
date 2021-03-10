# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')

# Set elasticsearch host
ES_HOST?=es01:9200

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=============================================================================="
	@echo " Geospatial Metadata Catalogue complete SDI  https://github.com/elasticlabs/geospatial-metadata-catalogue "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make proxy-up               # Initialize front proxy entrypoint"
	@echo "  make up                     # With working proxy, brings up the SDI"
	@echo "  make build                  # Build Geonetwork and Geoserver images"
	@echo "  make logs                   # Follows whole SDI logs (Geoserver, Geonetwork, PostGIS, Client app)"
	@echo "  make down                   # Brings the SDI down. "
	@echo "  make cleanup                # Complete hard cleanup of images, containers, networks, volumes & data of the SDI"
	@echo "  make reset                  # Soft reboot of the whole SDI"
	@echo "  make update                 # Update the whole stack"
	@echo "  make hard-reset             # All configuration except data and databases is deleted, then rebuilt"
	@echo "  make disaster-recovery      # Saves volumes to ../YYYYMMdd_SDI_Voumes then erases all containers and persistent volumes involved in the SDI, ultimately recreating a fresh one"
	@echo "=============================================================================="

.PHONY: proxy-up
proxy-up:
	chmod 755 nginx-proxy/*.conf
	docker-compose -f docker-compose.proxy.yml up -d --build --remove-orphans portainer 

.PHONY: up
up: pull build proxy-up
	docker-compose up -d --remove-orphans geoserver
	docker-compose up -d --remove-orphans mapstore2
	docker system prune -a

.PHONY: build
build: pull
	# Builds the complete stack
	chmod 755 geoserver/conf/*
	docker-compose -f docker-compose.yml build  --no-cache

.PHONY: pull
pull: 
	docker-compose -f docker-compose.yml pull

.PHONY: logs
logs:
	docker-compose logs --follow

.PHONY: down
down:
	docker-compose down --remove-orphans

.PHONY: cleanup
cleanup:
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes (e.g. geoserver catalog)
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune -a

.PHONY: cleanup-volumes
cleanup-volumes:
	# Delete all hosted persistent data available in volumes
	docker volume rm -f $(DC_PROJECT)_geoserver-exts
	docker volume rm -f $(DC_PROJECT)_geoserver-data
	# Remove all dangling docker volumes
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: reset
reset: down up wait

.PHONY: hard-reset
hard-reset: cleanup build up wait

.PHONY: disaster-recovery
disaster-recovery: cleanup cleanup-volumes pull build up wait

.PHONY: wait
wait: 
	sleep 5