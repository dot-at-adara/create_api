FROM ubuntu:18.04

EXPOSE 8080 8081 443

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.6 \
    nginx \
    python3.6-dev \
    git \
    python-virtualenv \
    python-pip \
    libjemalloc1 \
    libjemalloc-dev \
    gcc \
    curl \
    make \
    libssl-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    libpq-dev \
    wget \
    mysql-client \
    python-mysqldb \
    sudo && \
    apt-get -o Dpkg::Options::="--force-confmiss" install -y --reinstall netbase && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir /apps && mkdir /apps/deployment

RUN curl -L https://github.com/firebase/firebase-tools/releases/download/v7.8.1/firebase-tools-linux > /apps/deployment/firebase-tools-linux

COPY requirements.txt /apps/requirements.txt

RUN python -m virtualenv env -p python3.6 && \
    . env/bin/activate && \
    pip install -U pip && \
    pip install --upgrade pip && \
    pip install -r /apps/requirements.txt

RUN mkdir /apps/app
COPY app/ /apps/app/
COPY deployment/ /apps/deployment/

RUN mkdir /apps/files && \
    mkdir /apps/settings && \
    mkdir /apps/settings/env && \
    mkdir /apps/settings/secrets && \
    mkdir /apps/settings/test



RUN chmod +x /apps/deployment/startup/app.sh && \
    chmod +x /apps/deployment/startup/test.sh && \
    chmod +x /apps/deployment/startup/worker.sh && \
    chmod +x /apps/deployment/startup/setup.sh && \
    chmod +x /apps/deployment/startup/beat.sh && \
    chmod +x /apps/deployment/startup/qa.sh && \
    chmod +x /apps/deployment/startup/ci.sh && \
    chmod +x /apps/deployment/firebase-tools-linux

RUN chmod +x /apps/deployment/healthchecks/worker.sh

WORKDIR /apps/app/
