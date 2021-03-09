#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then

	mkdir -p "$DATA_DIR"

	#Set geonetwork data dir
	export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"
fi

#
# Setup Elasticsearch & Kibana from docker-compose file environment
if [ "$ES_URL" != "" ]; then
	
	sed -i "s#es.url=*#es.url=${ES_HOST}#" ${INSTALL_DIR}/WEB-INF/config.properties
	# Elasticsearch indexes setup 
	# TODO : full index creation automation when building geonetwork or elasticsearch directly
	sed -i "/es.index.features=/c\es.index.features=gn-features" ${INSTALL_DIR}/WEB-INF/config.properties
	sed -i "/es.index.records=/c\es.index.records=gn-records" ${INSTALL_DIR}/WEB-INF/config.properties
	sed -i "/es.index.searchlogs=/c\es.index.searchlogs=gn-searchlogs" ${INSTALL_DIR}/WEB-INF/config.properties
	
	# User and password, if set in elasticsearch & compose file
	[ "$ES_USERNAME" != "" ] && sed -i "/es.username=/c\es.username=${ES_USERNAME}" ${INSTALL_DIR}/WEB-INF/config.properties
	[ "$ES_PASSWORD" != "" ] && sed -i "/es.password=/c\es.password=${ES_PASSWORD}" ${INSTALL_DIR}/WEB-INF/config.properties
fi

# Kibana
[ "$KB_URL" != "" ] && sed -i "/kb.url=*/c\kb.url=${KB_URL}" ${INSTALL_DIR}/WEB-INF/config.properties

exec "$@"