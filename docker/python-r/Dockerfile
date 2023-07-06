ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
# FROM jupyter/minimal-notebook:latest
# FROM continuumio/miniconda3:latest
FROM ubuntu:20.04

# Set environment variables
ENV R_VERSION=3.6.3

ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# System packages 
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y build-essential curl wget nano jq zip git screen gdebi libjpeg-dev zlib1g-dev libpng-dev \
    && apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev\
    && apt-get update \
    && apt-get upgrade -y

RUN git config --global user.name "dschaub95"
RUN git config --global user.email "schaub.darius@gmail.com"

# install conda
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

# Install R using gdebi and clean up downloaded package
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb \
    && gdebi --non-interactive r-${R_VERSION}_1_amd64.deb \
    && rm r-${R_VERSION}_1_amd64.deb
# Create symbolic links for R and Rscript executables
RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R \
    && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# Setup R installation
RUN Rscript -e 'install.packages(pkgs = "https://cran.r-project.org/src/contrib/Archive/locfit/locfit_1.5-9.4.tar.gz", repos = NULL, type = "source")'
RUN Rscript -e 'install.packages("languageserver", repos = "https://cloud.r-project.org/")'
RUN Rscript -e 'install.packages("IRkernel", repos = "https://cloud.r-project.org/")'
RUN pip install jupyter

RUN Rscript -e 'IRkernel::installspec(name = "ir35", displayname = "R 3.6.3", user = FALSE)'
RUN Rscript -e 'install.packages("BiocManager", repos = "http://cran.us.r-project.org")'
RUN Rscript -e 'BiocManager::install(version = "3.10")'
# Install tradeseq
RUN Rscript -e 'BiocManager::install("tradeSeq")'