ARG CONDA_VER=latest
ARG OS_TYPE=x86_64

# FROM nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04
FROM nvidia/cuda:12.0.1-cudnn8-runtime-ubuntu20.04

ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV http_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"
ENV https_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"

# System packages 
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y build-essential curl wget nano jq zip git screen\
        ffmpeg libsm6 libxext6 gdebi zlib1g-dev graphviz graphviz-dev \
        libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev \
        libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libffi-dev \
    && apt-get update \
    && apt-get upgrade -y

RUN git config --global user.name "dschaub95"
RUN git config --global user.email "schaub.darius@gmail.com"

# Use the above args 
ARG CONDA_VER
ARG OS_TYPE
# Install miniconda to /miniconda
RUN curl -LO "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh"
RUN bash Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh -p /miniconda -b
RUN rm Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda
RUN conda init
