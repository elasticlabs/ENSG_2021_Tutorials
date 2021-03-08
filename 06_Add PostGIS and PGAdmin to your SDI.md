Now that your have an entrypoint and useful containers management interface, let's spice up the stack and add PostGIS + its management interface too.

First, add the `sdi-entrypoint.conf` file to your Nginx proxy configuration
- **How will you do it?**
- **Where will be available the PGAdmin interface?**
- **How is it automated?**

## docker-compose.yml file customization
Add and adapt the following line **after the portainer application block** inside your `docker-compose.yml` file.

```
# pgAdmin & PostGIS
  pgadmin:
    image: ${COMPOSE_PROJECT_NAME}_pgadmin4:latest
    container_name: pgadmin4${COMPOSE_PROJECT_NAME}
    restart: unless-stopped
    expose:
      - "80" 
    build:
      context: ./pgadmin
    env_file:
      - ./pgadmin/.env
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    networks:
      - changeme

  postgis:
    image: ${COMPOSE_PROJECT_NAME}_postgis:latest
    container_name: PostGIS4${COMPOSE_PROJECT_NAME}
    restart: unless-stopped
    expose:
      - "5432" 
    build:
      context: ./postgis
    stdin_open: true
    env_file: 
      - ./postgis/.env
    volumes:
      - dbdata:/var/lib/postgresql/data
      - dbbackups:/pg_backups
    networks:
      - changeme
```

- Use `docker-compose -f docker-compose.yml build` to try to build the stack. Carefully read error messages and retry when ready
- When build is successful, use the `docker-compose up -d` command to bring the stack up!
- Access PGAdmin4 through the proper URL. All should be pre configured as a useful GeoServer backeng!