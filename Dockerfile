FROM artifactory.dsto.defence.gov.au/docker-remote/node:23-slim

# set up apt in container
USER root

RUN echo "Copying DSTG local settings"
# COPY ./srce/99artifactory /etc/apt/apt.conf.d/99proxy
# COPY ./srce/sources.list /etc/apt/sources.list

# COPY /etc/apt /etc/
ADD etc/etc_apt.tar /

# this dir should already exist, but just make sure:
RUN mkdir -p -m 0770 /etc/apt/sources.list.d

# Replace DIRECT debian repos with artifactory versions:
COPY etc/apt/sources.list.d/artifactory-debian.list /etc/apt/sources.list.d/
RUN rm -f /etc/apt/sources.list.d/debian.sources

RUN echo "Copying Defence Certificates"
# COPY /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN mkdir -p -m 0770 /etc/ssl/certs
COPY etc/ssl/certs/* /etc/ssl/certs/
COPY update-ca-certificates update-ca-certificates
RUN ./update-ca-certificates

# COPY etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# RUN apt-get install -y ca-certificates && update-ca-certificates


# RUN echo "Installing landscape client"
# RUN apt-get update && apt-get install -o Acquire::https::Verify-Peer=false -y landscape-client

RUN mkdir -p -m 0770 /etc/landscape
COPY etc/landscape/* /etc/landscape/

# no installation candidate for chromium
#    chromium \

# FIXME sort and de-dupe package list
RUN echo "Updating base packages" \
 && apt-get update \
    -o Acquire::https::Verify-Peer=false

RUN echo "Installing new packages 1" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    fonts-ipafont-gothic fonts-liberation fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    libappindicator1 \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    --no-install-recommends --fix-missing

RUN echo "Installing new packages 2" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm-dev \
    --no-install-recommends

RUN echo "Installing new packages 3" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    --no-install-recommends

RUN echo "Installing new packages 4" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    --no-install-recommends

RUN echo "Installing new packages 5" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    libxcb-dri3-0 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    --no-install-recommends

RUN echo "Installing new packages 6" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    --no-install-recommends

RUN echo "Installing new packages 7" \
 && apt-get install \
    -o Acquire::https::Verify-Peer=false \
    -y \
    xdg-utils \
    ca-certificates \
    lsb-release \
    wget \
    --no-install-recommends

# Why is the following required?
# RUN cp /usr/bin/chromium /usr/bin/chromium-browser

# Update CA certificates after installing ca-certificates
RUN echo "Updating CA certificates" \
  && ./update-ca-certificates

# Create app directory
WORKDIR /usr/src/app

# Setup user and group node and home directory
# RUN groupadd --gid 1000 node \
#  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Change the ownership of /usr/src/app to the `node` user
RUN chown -R node:node /usr/src/app

# Switch USER back from root to node
USER node

# Bundle app source
COPY . .

# Configure NPM to pull packages via DSTG PRN artifactory
COPY artifactory.npmrc /home/node/.npmrc

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install nodejs libs
RUN echo "Checking NPM configuration" \
  &&  npm config list

RUN echo "Installing nodejs libs" \
  &&  npm install

EXPOSE 3000
# CMD [ "node",  "./index.js", "-r", ".", "--oc", "1" ]
CMD [ "/bin/bash" ]
