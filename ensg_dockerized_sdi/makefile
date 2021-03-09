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
	@echo "  make create-gn-indexes      # Configure geonetwork elasticsearch indexes"
	@echo "  make delete-gn-indexes      # Delete configured geonetwork elasticsearch indexes"
	@echo "  make reset                  # Soft reboot of the whole SDI"
	@echo "  make update                 # Update the whole stack"
	@echo "  make hard-reset             # All configuration except data and databases is deleted, then rebuilt"
	@echo "  make disaster-recovery      # Saves volumes to ../YYYYMMdd_SDI_Voumes then erases all containers and persistent volumes involved in the SDI, ultimately recreating a fresh one"
	@echo "=============================================================================="

.PHONY: proxy-up
proxy-up:
	chmod 755 proxy-toolkit/uploadsize.conf
	docker-compose -f docker-compose.proxy.yml up -d --build --remove-orphans portainer 

.PHONY: up
up:
	docker-compose up -d --remove-orphans geonetwork
	docker-compose up -d --remove-orphans geoserver
	docker-compose up -d --remove-orphans es01

.PHONY: build
build:
	# Geonetwork build
	chmod 755 geonetwork/conf/*
	docker-compose -f docker-compose.yml build geonetwork
	# Geoserver build
	chmod 755 geoserver/conf/*
	docker-compose -f docker-compose.yml build geoserver

.PHONY: pull
pull: 
	docker-compose -f docker-compose.yml pull
	docker-compose -f docker-compose.proxy.yml pull

.PHONY: logs
logs:
	docker-compose logs --follow

.PHONY: down
down:
	docker-compose down --remove-orphans

.PHONY: create-gn-indexes
create-gn-indexes:
	# From https://github.com/geonetwork/core-geonetwork/tree/3.10.x/es
	# And https://geonetwork-opensource.org/manuals/trunk/en/maintainer-guide/statistics/setup-elasticsearch.html
	curl -O https://raw.githubusercontent.com/geonetwork/core-geonetwork/3.10.x/es/config/features.json
	curl -O https://raw.githubusercontent.com/geonetwork/core-geonetwork/3.10.x/es/config/records.json
	curl -O https://raw.githubusercontent.com/geonetwork/core-geonetwork/3.10.x/es/config/searchlogs.json
	#
	# Indexes deployment :
	curl -X PUT http://$(ES_HOST)/gn-features -H 'Content-Type: application/json' -d @features.json && rm features.json
	curl -X PUT http://$(ES_HOST)/gn-records -H 'Content-Type: application/json' -d @records.json && rm records.json
	curl -X PUT http://$(ES_HOST)/gn-searchlogs -H 'Content-Type: application/json' -d @searchlogs.json && rm searchlogs.json

.PHONY: delete-gn-indexes
delete-gn-indexes:
	curl -X DELETE http://$(ES_HOST)/gn-records
	curl -X DELETE http://$(ES_HOST)/gn-features
	curl -X DELETE http://$(ES_HOST)/gn-searchlogs

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
	docker volume rm -f $(DC_PROJECT)_geonetwork-base
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