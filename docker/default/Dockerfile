# FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG CONDA_PATH=/epyc/projects/dschaub/miniconda/envs
# Create a non-root user
ARG USERNAME=dschaub
ARG USER_UID=2856
## we are using 1735 as our shared group instbonn
ARG USER_GID=1735
ARG GITHUB_NAME=dschaub95
ARG GITHUB_EMAIL=schaub.darius@gmail.com

# Set environment variables
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
# Allow overriding proxy at build time but default to none to avoid
# inheriting host proxies that break apt inside the image.
ARG http_proxy
ARG https_proxy
ENV http_proxy="${http_proxy:-}" \
    https_proxy="${https_proxy:-}" \
    no_proxy="localhost,127.0.0.1"
ENV TZ=Europe/Berlin


# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# If no proxy is supplied, ensure no stale proxy config remains.
RUN if [ -z "$http_proxy$https_proxy" ]; then \
    rm -f /etc/apt/apt.conf.d/*proxy /etc/apt/apt.conf; \
    fi


# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN apt-get update && apt-get install -y sudo \
    && usermod -aG sudo $USERNAME \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# System packages 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
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
    libopenblas-dev \
    cmake \
    software-properties-common

# install arial
RUN sudo add-apt-repository multiverse \
    && sudo apt-get update \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
    | sudo debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
    ttf-mscorefonts-installer \
    && sudo fc-cache -f -v

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# set git config
RUN git config --global user.name $GITHUB_NAME
RUN git config --global user.email $GITHUB_EMAIL

# Install miniconda to /miniconda
ENV PATH=/miniconda/bin:${PATH}
RUN curl -LO "https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh" && \
    bash Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh -p /miniconda -b && \
    rm Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh && \
    conda tos accept && \
    conda update -y conda && \
    conda init && \
    conda install -n base conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda config --add envs_dirs "${CONDA_PATH}"

# install cookiecutter template packages
RUN pip install cruft pre-commit

# install poetry
RUN python3 -m pip install pipx && \
    python3 -m pipx ensurepath && \
    pipx ensurepath --global && \
    pipx install --global poetry

RUN echo 'Defaults  env_keep += "http_proxy https_proxy"' \
    > /etc/sudoers.d/proxy && chmod 0440 /etc/sudoers.d/proxy

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
RUN git config --global user.name $GITHUB_NAME && \
    git config --global user.email $GITHUB_EMAIL
RUN conda tos accept && \
    conda init && \
    conda config --set solver libmamba && \
    conda config --add envs_dirs "${CONDA_PATH}"

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# configure uv to create venvs locally
USER $USERNAME
WORKDIR /home/$USERNAME

# Create uv directories during build
RUN mkdir -p "$HOME/.uv-local/cache" "$HOME/.uv-local/python" "$HOME/.uv-local/python-cache" "$HOME/.uv-local/venvs"

RUN <<'EOF'
cat <<'BASHRC' >> "/home/$USERNAME/.bashrc"
# ---- uv base dirs on local FS (inside container) ----
export UV_BASE="$HOME/.uv-local"

export UV_CACHE_DIR="$UV_BASE/cache"
export UV_PYTHON_INSTALL_DIR="$UV_BASE/python"
export UV_PYTHON_CACHE_DIR="$UV_BASE/python-cache"

# Find project root by walking up until we see a marker file
_uv_find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/uv.lock" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Automatically set UV_PROJECT_ENVIRONMENT per project
_uv_auto_env() {
    local root
    root="$(_uv_find_project_root)" || { unset UV_PROJECT_ENVIRONMENT; return; }

    # Use project directory name for env name
    local project_name
    project_name="$(basename "$root")"

    export UV_PROJECT_ENVIRONMENT="$UV_BASE/venvs/$project_name"
}

# Hook into the prompt so it updates after every cd
case "$PROMPT_COMMAND" in
    *"_uv_auto_env"*) : ;;  # already hooked
    *)
    PROMPT_COMMAND="_uv_auto_env${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    ;;
esac
BASHRC
EOF

# these are necessary when deploying to the kubernetes cluster
ENV http_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"
ENV https_proxy="http://proxy1.zmnh.uni-hamburg.de:8888"

CMD ["/bin/bash"]