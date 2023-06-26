ARG CONDA_VER=latest
ARG OS_TYPE=x86_64

# FROM nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04
FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.0.1-cudnn8-runtime-ubuntu20.04

# System packages 
RUN apt-get update && apt-get install -y build-essential curl wget nano
# RUN apt-get install -y r-base
RUN apt upgrade -y
RUN apt install -y build-essential

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
