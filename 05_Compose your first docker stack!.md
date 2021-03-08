# The first docker-compose stack
Let's create a simplified version of a useful duo : `nginx-proxy` and `portainer CE`

At the end of this workshop, you'll have a local "bubble apps" entrypoint, up and running.

## Application design
Write down on a paper the logic bihind this : HTTP entrypoint and Management interface

This solution is based on Jason Wilder's Nginx HTTP Proxy (https://github.com/nginx-proxy/nginx-proxy) 
See Automated Nginx Reverse Proxy for Docker (http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/) for why you might want to use this.

For a complete HTTPS setup deployable in production environments, go to (https://github.com/elasticlabs/https-nginx-proxy-docker-compose/)

<p>
  <img src="https://raw.githubusercontent.com/elasticlabs/https-nginx-proxy-docker-compose/main/architecture.png" alt="Automated HTTPS proxy architecture" width="400px">
</p>

**Table Of Contents:**
  - [Docker environment preparation](#docker-environment-preparation)
  - [Stack configuration](#stack-configuration)

----

## Docker environment preparation 
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)

## Nginx HTTPS Proxy preparation
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* Choose & configure a selected DNS name (e.g. `portainer.docker`). Make sure it properly resolves from your server using `nslookup`commands. When working locally you can tweak the `/etc/hosts` file and add appropriate entries, or deploy the `dnsmasq` package to automatically drive to docker containers any request associated with ".docker"
* GIT clone this repository if not done already 

## Stack configuration
### Docker cleanup! 
Clean up all containers & images, without deleting static volumes
```
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune -a

	# Delete all hosted persistent data available in volumes
	docker volume rm -f $(PROJECT_NAME)_certs
	docker volume rm -f $(PROJECT_NAME)_vhost.d
	docker volume rm -f $(PROJECT_NAME)_html
	rm -rf /opt/portainer/data

	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)
```

### Required networks creation
Create the following docker networks : 
- revproxy_admin
- revproxy_apps

```
sudo docker network create revproxy_admin
sudo docker network create revproxy_apps
```

Change every `changeme` keyword with the desired parameters.

More more information on docker-compose YAML configuration, please read this page -> (https://docs.docker.com/compose/compose-file/compose-file-v3/)

### Bring the stack up! 
- Use `docker-compose build` to try to build the stack. Carefully read error messages and retry when ready
- When build is successful, use the `docker-compose up -d` command to bring the stack up!
- The portainer application should be available at the following URL `http://YOUR_PORTAINER_CONTAINER_IP:9000`

## Get this properly configured.
In real deployments, we need to do 2 important steps : 
- Put every parameter in ENV files
- Build a Makefile to automated repeted stuff.


**Configuration**
* **Rename `.env-changeme` file into `.env`** to ensure `docker-compose` gets its environement correctly.
* Modify the following variables in `.env-changeme` file :
  * `PORTAINER_VHOST=` : replace `portainer.your-domain.ltd` with your choosen subdomain for portainer.


```
# 1/ Portainer domain
# Modify the following lines to fit your needs
#     -> replace "your-domain.ltd" with a DNS valid domain name associated with your server
PORTAINER_VHOST=portainer.your-domain.ltd

# 2/ Choose your project name (optional)
COMPOSE_PROJECT_NAME=

# 3/ Name your proxy networks (optional)
#  - APPS_NETWORK will be the name you use in every deployed application
#    Don't touch that except you're as perfectionist as me (catch me for a beer if this happens ^^)
APPS_NETWORK=
ADMIN_NETWORK=
```

Change every `changeme` keyword with the desired parameters.
Move the `docker-compose.envfile.yml` file as `docker-compose.yml`

- Use `docker-compose build` to try to build the stack. Carefully read error messages and retry when ready
- When build is successful, use the `docker-compose up -d` command to bring the stack up!
- The portainer application should be available at the following URL `http://YOUR_PORTAINER_CONTAINER_IP:9000`

The stack behaviour should be the same as previously, but now in a cleaner manner.

### Now, update the portainer version : 
Locate the following lines : 

```
  portainer:
    image: portainer/portainer-ce:2.0.1
```

How should you modify it to :
- **Shrink the image size?**
- **Always stick to the latest version?**

Update the portainer by modifying this file running the following commands : 
- `sudo docker-compose pull portainer`
- `sudo docker-compose up -d --build portainer`

**Useful management commands**
* Go inside a container : `sudo docker-compose exec -it <service-id> bash` or `sh`
* See logs of a container: `sudo docker-compose logs <service-id>`
* Monitor containers : `sudo docker stats` or... use portainer!
* Access Portainer Web GUI : available at the URL defined in `.env` file.