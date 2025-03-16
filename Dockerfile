# FROM artifactory.dsto.defence.gov.au/docker-remote/node:23-slim
# Note maxiumu verison of node supported by elestio/cloudgate is node:22
FROM artifactory.dsto.defence.gov.au/docker-remote/node:22-slim

# set up apt in container
USER root

RUN echo "Checking NPM configuration" \
  && npm config ls

RUN echo "Copying DSTG local settings"
# COPY ./srce/99artifactory /etc/apt/apt.conf.d/99proxy
# COPY ./srce/sources.list /etc/apt/sources.list

# COPY /etc/apt /etc/
ADD etc/etc_apt.tar /

# this dir should already exist, but just make sure:
RUN mkdir -p -m 0755 /etc/apt/sources.list.d

# Replace DIRECT debian repos with artifactory versions:
COPY etc/apt/sources.list.d/artifactory-debian.list /etc/apt/sources.list.d/
RUN rm -f /etc/apt/sources.list.d/debian.sources

RUN echo "Copying Defence Certificates"
# COPY /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN mkdir -p -m 0755 /etc/ssl/certs
COPY etc/ssl/certs/* /etc/ssl/certs/

# RUN echo "Installing landscape client"
# RUN apt-get update && apt-get install -o Acquire::https::Verify-Peer=false -y landscape-client

RUN mkdir -p -m 0755 /etc/landscape
COPY etc/landscape/* /etc/landscape/

# FIXME sort and de-dupe package list
RUN echo "Updating base packages" \
 && apt-get update \
    -o Acquire::https::Verify-Peer=false

RUN echo "Installing new packages" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    chromium \
    fonts-ipafont-gothic fonts-liberation fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    libappindicator1 \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm-dev \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    ca-certificates \
    lsb-release \
    wget \
    --no-install-recommends

# Why is the following required?
# RUN cp /usr/bin/chromium /usr/bin/chromium-browser

# Update CA certificates after installing ca-certificates
RUN echo "Updating CA certificates" \
  && /usr/sbin/update-ca-certificates

# Create app directory
WORKDIR /usr/src/app

# Setup user and group node and home directory
# RUN groupadd --gid 1000 node \
#  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node




# Bundle app source
COPY . .

# Operation not permitted
RUN chmod a+rw package-lock.json

# Change the ownership of /usr/src/app to the `node` user
RUN chown -R node:node /usr/src/app

# Switch USER back from root to node
USER node

# Operation not permitted
# RUN chmod u+rw package-lock.json

# Configure NPM to pull packages via DSTG PRN artifactory
COPY artifactory.npmrc /home/node/.npmrc

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install nodejs libs
RUN echo "Checking NPM configuration" \
  && npm config ls

RUN echo "Installing nodejs libs" \
  && npm install

EXPOSE 3000
CMD [ "node",  "./index.js", "-r", ".", "--oc", "1" ]
# USER root
# CMD [ "/bin/bash" ]
