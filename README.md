![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/hornwind/bird-antifilter)
![Docker Pulls](https://img.shields.io/docker/pulls/hornwind/bird-antifilter)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/hornwind/bird-antifilter/latest)
# [bird-antifilter](https://hub.docker.com/r/hornwind/bird-antifilter)
This container for the receiving of blocking lists from [antifilter.download](https://antifilter.download/) and the distribution this subnets over BGP with bird daemon. To start, you need to have a raised interface corresponding to the $SOURCE_ADDRESS.

Description of setup with a Mikrotik router can be found in the next article on habr:

https://habr.com/ru/post/359268/

## Run in shell:
```
docker run -d --name bird \
--network=host \
--env ROUTER_ID="10.100.0.1" \
--env NEIGHBOR_IP="10.100.0.2" \
--env NEIGHBOR_AS="64998" \
--env LOCAL_AS="64999" \
--env SOURCE_ADDRESS="10.100.0.1" \
--env SCAN_TIME="60" \
--env CRON_MIN="30" \
--restart=always \
hornwind/bird-antifilter:latest
```

## Example docker-compose:
```
version: '3.7'

services:

  bird:
    image: hornwind/bird-antifilter:latest
    container_name: bird
    restart: always
    network_mode: host
    environment:
      ROUTER_ID: 10.100.0.1
      NEIGHBOR_IP: 10.100.0.2
      NEIGHBOR_AS: 64998
      LOCAL_AS: 64999
      SOURCE_ADDRESS: 10.100.0.1
      SCAN_TIME: 60
      CRON_MIN: 30
    logging:
      driver: json-file
      options:
        max-size: "2m"
        max-file: "10"
```
