FROM ubuntu:xenial

WORKDIR /src

COPY . /src

RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    build-essential \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip 

RUN pip3 install --upgrade pip

RUN pip3 install Flask==0.12

RUN pip3 install prometheus_client

EXPOSE 8080
EXPOSE 8081
