FROM dpage/pgadmin4:latest
LABEL maintainer="Elasticlabs <contact@elasticlabs.co>"

# >> Configuration file creation
# Create 'servers.json' configuration file
USER root
RUN echo -e $'{ \n\
    "Servers": { \n\
        "1": { \n\
            "Name": "Elasticlabs SDI", \n\
            "Group": "Servers", \n\
            "Host": "postgis", \n\
            "Port": 5432, \n\
            "MaintenanceDB": "geoserver", \n\
            "Username": "geoserver", \n\
            "SSLMode": "prefer", \n\
            "PassFile": "/pgpassfile" \n\
        } \n\
    } \n\
}' > /pgadmin4/servers.json
