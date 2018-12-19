FROM jenkins/jenkins:lts

USER root

RUN apt-get update && apt-get install -y \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI binary
WORKDIR /
RUN mkdir /sfdx \
    && wget -qO- https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz | tar xJ -C sfdx --strip-components 1 \
    && /sfdx/install \
    && rm -rf /sfdx

# Setup CLI exports
ENV SFDX_AUTOUPDATE_DISABLE=false \
    SFDX_DOMAIN_RETRY=300 \
    SFDX_DISABLE_APP_HUB=true \
    SFDX_LOG_LEVEL=DEBUG \
    TERM=xterm-256color \
    DEV_HUB_USERNAME=daniel.gonzalez-jeq4@force.com \
    DEV_HUB_CONSUMER_KEY=3MVG9KsVczVNcM8yI8P.sy64kdj15XYMfhujCw9uBTnvdjkMB0Kiw6GA2Yk14EeVSQZpTSrnTXMrq9g81yd.m \
    STAGE_USERNAME=daniel.gonzalez-jeq4@force.com \
    STAGE_CONSUMER_KEY=3MVG90D5vR7UtjboLvIcVTyDai_8.uzajrFUAWc0VtRRCFm_gEwYDGMGugESLXzYfJDn4g0XPug==

RUN sfdx update

USER jenkins