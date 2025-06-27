ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG CONDA_PATH=/epyc/projects/dschaub/miniconda/envs

# FROM nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.0.1-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu20.04
# FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu20.04
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu20.04

ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# only necessary if building behind a proxy
ENV http_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"
ENV https_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"


# Create a non-root user
ARG USERNAME=dschaub
ARG USER_UID=2856
## we are using 1735 as our shared group instbonn
ARG USER_GID=1735

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN apt-get update && apt-get install -y sudo \
    && usermod -aG sudo $USERNAME \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# System packages 
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
    build-essential \
    curl \
    wget \
    nano \
    jq \
    zip \
    git \
    screen \
    ffmpeg \
    libsm6 \
    libxext6 \
    gdebi \
    zlib1g-dev \
    graphviz \
    graphviz-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libffi-dev \
    software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update -y
RUN apt-get upgrade -y

# install the latest git version
RUN apt-get remove --purge git -y
RUN apt-get autoremove -y
RUN add-apt-repository ppa:git-core/ppa
RUN apt update -y
RUN apt install -y git

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
RUN conda config --add envs_dirs /epyc/projects/dschaub/miniconda/envs

# install cookiecutter template packages
RUN pip install cruft pre-commit

# install poetry
RUN python3 -m pip install pipx
RUN python3 -m pipx ensurepath
RUN pipx ensurepath --global
RUN pipx install --global poetry
# RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/home/$USERNAME/.local python3 -

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
RUN conda init
RUN conda config --set solver libmamba
RUN conda config --add envs_dirs /epyc/projects/dschaub/miniconda/envs
# ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
# RUN poetry --version

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install arial
RUN sudo apt install -y ttf-mscorefonts-installer
RUN sudo fc-cache -f -v

CMD ["/bin/bash"]