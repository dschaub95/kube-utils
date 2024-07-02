ARG CONDA_VER=latest
ARG OS_TYPE=x86_64

# FROM nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.0.1-cudnn8-runtime-ubuntu20.04
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu20.04

ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# only necessary if building behind a proxy
ENV http_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"
ENV https_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"

# System packages 
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y build-essential
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y nano
RUN apt-get install -y jq
RUN apt-get install -y zip
RUN apt-get install -y git
RUN apt-get install -y screen
RUN apt-get install -y ffmpeg
RUN apt-get install -y libsm6
RUN apt-get install -y libxext6
RUN apt-get install -y gdebi
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y graphviz
RUN apt-get install -y graphviz-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libfontconfig1-dev
RUN apt-get install -y libharfbuzz-dev
RUN apt-get install -y libfribidi-dev
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libtiff5-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libffi-dev
RUN apt-get update
RUN apt-get upgrade -y

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

RUN conda install -n base conda-libmamba-solver
RUN conda config --set solver libmamba