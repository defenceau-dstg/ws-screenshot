FROM artifactory.dsto.defence.gov.au/docker-remote/ubuntu:22.04

# set up apt in container
USER root

RUN echo "Copying DSTG local settings"
# COPY ./srce/99artifactory /etc/apt/apt.conf.d/99proxy
# COPY ./srce/sources.list /etc/apt/sources.list

COPY /etc/apt /etc/


RUN echo "Copying Defence Certificates"
# COPY /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN mkdir -p -m 0770 /etc/ssl/certs
COPY etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

RUN echo "Installing landscape client"
RUN apt update && sudo apt install -y landscape-client
RUN ls /etc/landscape
# RUN mkdir -p -m 0770 /etc/landscape
COPY etc/landscape/* /etc/landscape/

RUN echo "Installing packages"
RUN apt-get update \
 && apt-get install -y chromium \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    libxss1 \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
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
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    xdg-utils \
    libgbm-dev \
    libxcb-dri3-0 \
    --no-install-recommends

# RUN dnf upgrade -y && \
#     dnf install -y \
#       ca-certificates \
#       lsb-release \
#       wget \
# Why is the following required?
RUN cp /usr/bin/chromium /usr/bin/chromium-browser

# Create app directory
WORKDIR /usr/src/app

# Change the ownership of /usr/src/app to the `node` user
RUN chown -R node:node /usr/src/app

# Switch USER back from root to node
USER node

# Bundle app source
COPY . .


ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium

#Install deps
RUN npm install && apt-get update && apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget libgbm-dev libxcb-dri3-0

EXPOSE 3000
CMD node ./index.js -r . --oc 1
