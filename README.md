# ws-screenshot
A simple way to take a screenshot of a website by providing its URL. ws-screenshot include a simple web UI but also a REST API and a Websocket API to automate screenshots.

DEMO: https://backup15.terasp.net/

![](https://cf.appdrag.com/support-documentatio-cb1e1b/uploads/files/e76ed2f5-943e-4fac-b454-6ebb9208f7a6.gif)


# DSTG-PRN fork

This is a fork of github.com/elestio/ws-screenshot that has been modified to resolve critical vulnerabilities
suitable for use on Defence networks.

The Dockerfile and related `docker-*.sh` scripts are modified to work within the DSTG PRN.

## Git branches
  * DSTG-PRN - Development and testing 
  * master - Stable releases
  * upstream - This contains a snapshot of master on the forked repo.  The intention is for it to be updated when the upstream project releases a new version.  Changes will then be merged in the DSTG-PRN branch before a bew stable release is made in master.

# Quickstart with Docker (on the DSTG-PRN network)

Run once (scripted):

    ./docker-run.sh

Run once (command-line):

    docker login -u ${USER} artifactory.dsto.defence.gov.au  # login to artifactory
    docker pull ia-test/ws-screenshot.slim:1.2.2  # pull the image from artifactory
    docker run -p 3000:3000 -it ia-test/ws-screenshot.slim:1.2.2

or Run as a docker service:

    docker run --name ws-screenshot -d --restart always -p 3000:3000 -it ia-test/ws-screenshot.slim:1.2.2

Then open http://yourIP:3000/ in your browser

&nbsp;
# Requirements

- Linux, Windows or Mac OS
- Node 22+

## Install Node.js 22 (On Debian Linux)

Note this has already been done in the published Docker image (see above).

    sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates
    curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt -y install nodejs

## Clone this repository
Clone this repo then install NPM dependencies for ws-screenshot:

    git clone git@github.com:defenceau-dstg/ws-screenshot.git
    cd ws-screenshot
    npm install

## Install required dependencies for chrome:

    ./installPuppeteerNativeDeps.sh


&nbsp;

# Run ws-screenshot

## Run directly

Finally we can start WS-SCREENSHOT Server one-time:

    ./run.sh

or run as a service with pm2

    npm install -g pm2
    pm2 start run.sh --name ws-screenshot
    pm2 save

## Run with docker (local version for dev)
Run just once

    docker build -t ws-screenshot .
    docker run --rm -p 3000:3000 -it ws-screenshot

Run as a docker service

    docker run --name ws-screenshot -d --restart always -p 3000:3000 -it ws-screenshot

## Run on Kubernetes
Run with helm

    helm upgrade --install ws-screenshot --namespace ws-screenshot helm/

## Run with proxy
Add `PROXY_SERVER` env variable:

    docker run --rm -p 3000:3000 --env PROXY_SERVER=http://localhost:3128 -it ws-screenshot

> NOTE: Could not seem to get this working on the PRN.  HAIGS need for basic or NTLM auth might be the cause, however I tried to point at a local cntlm proxy and it still did not work.
>
> NOTE: Chromium ignores username and password in `--proxy-server` arg
>
> https://bugs.chromium.org/p/chromium/issues/detail?id=615947


# Usage

## REST API

Make a GET request (or open the url in your browser):

    /api/screenshot?resX=1280&resY=900&outFormat=jpg&isFullPage=false&url=https://vms2.terasp.net&headers={"foo":"bar"}

## Websocket API

```js
var event = {
  cmd: "screenshot",
  url: url,
  originalTS: (+new Date()),
  resX: resX,
  resY: resY,
  outFormat: outFormat,
  isFullPage: isFullPage,
  headers: {
    foo: 'bar'
  }
};
```

You can check /public/js/client.js and /public/index.html for a sample on how to call the Websocket API


# Supported parameters
- url: full url to screenshot, must start with http:// or https://
- resX: integer value for screen width, default: 1280
- resY: integer value for screen height, default: 900
- outFormat: output format, can be jpg, png or pdf, default: jpg
- isFullPage: true or false, indicate if we should scroll the page and make a full page screenshot, default: false
- waitTime: integer value in milliseconds, indicate max time to wait for page resources to load, default: 100
- headers: add extra headers to the request

# Protect with an ApiKey

You can protect the REST & WS APIs with an ApiKey, this is usefull if you want to protect your screenshot server from being used by anyone
To do that, open appconfig.json and set any string like a GUID in ApiKey attribute. This will be your ApiKey to pass to REST & WS APIs

To call the REST API with an ApiKey:

    /api/screenshot?url=https://example.com&apiKey=XXXXXXXXXXXXX

To call the Websocket API with an ApiKey:

```js
var event = {
  cmd: "screenshot",
  url: url,
  originalTS: (+new Date()),
  apiKey: "XXXXXXXXXXXXX"
};
```

You can check /public/js/client.js for a sample on how to call the Websocket API


# TODO list
- Add support for cookies / localstorage auth (to be able to screenshot authenticated pages)
