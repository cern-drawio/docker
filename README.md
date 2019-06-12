# Docker

This is a project inspired in Florian JUDITH's repo [docker-draw.io](https://github.com/cern-drawio/docker-draw.io). It only covers the functionalities that are necessary at CERN.

# Description

This Dockerfile creates the image for [drawi.io](https://github.com/jgraph/drawio) using "Tomcat:9-jre11-slim" as base.

**This image does not leverage embedded database**

## Quick Start

Build the image.

```bash
docker build -t="drawioimg" .
```

Create container with the image

```bash
docker run -d -name="drawio" -p 8080:8080 drawioimg
```

Start a web browser session to http://localhost:8080?offline=1

> `?offline=1` is a security feature that disables support of cloud storage.

## Openshift deployment

> The OpenShift CLI [okd](https://openshift.cern.ch/console/command-line) is needed

Login to your account

```bash
oc login https://openshift.cern.ch --token=<token>
```

Select the project

```bash
oc project <project name>
```

Create the application

```bash
oc new-app . --strategy=docker
```

# Reference

* https://github.com/jgraph/draw.io
* https://www.github.com/fjudith/docker-draw.io
