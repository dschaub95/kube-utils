FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

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


# System packages 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    sudo \
    build-essential \
    curl \
    wget \
    nano \
    jq \
    zip \
    git \
    git-lfs \
    ccache \
    python3-dev \
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
    libasound2-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxcursor-dev \
    libxinerama-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libqhull-dev \
    libomp-dev \
    libglpk-dev \
    cmake \
    clang \
    lld \
    clang-format \
    clang-tidy \
    procps \
    time \
    software-properties-common \
    bubblewrap \
    pandoc \
    postgresql \
    openjdk-21-jre-headless \
    && ln -s "$(ls -d /usr/lib/postgresql/*/ | head -n 1)" /usr/lib/postgresql/current \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# PostgreSQL server tools (initdb, pg_ctl, postgres) for a user-owned dev cluster on a persistent volume.
ENV PATH="${PATH}:/usr/lib/postgresql/current/bin"

# Tailscale from its official apt repository; workspace-start runs tailscaled in userspace mode as the user.
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
        -o /usr/share/keyrings/tailscale-archive-keyring.gpg \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
        -o /etc/apt/sources.list.d/tailscale.list \
    && apt-get update \
    && apt-get install -y tailscale \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# R from CRAN's Ubuntu repository; the system libraries above cover common source package builds.
# System directories come first on R's PATH so packages build against them, not conda's libraries.
RUN curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
        | gpg --dearmor -o /usr/share/keyrings/cran-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
        > /etc/apt/sources.list.d/cran.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base r-base-dev \
    && echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> /etc/R/Renviron.site \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build the raylib version used by Magna's C binding.
ARG RAYLIB_VERSION=6.0
RUN git clone --depth 1 --branch "${RAYLIB_VERSION}" \
        https://github.com/raysan5/raylib.git /tmp/raylib \
    && cmake -S /tmp/raylib -B /tmp/raylib/build \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_EXAMPLES=OFF \
    && cmake --build /tmp/raylib/build --parallel "$(nproc)" \
    && cmake --install /tmp/raylib/build \
    && ldconfig \
    && rm -rf /tmp/raylib

# LaTeX (pdflatex, xelatex, lualatex, biber, latexmk), plotting dependencies and Arial fonts
RUN add-apt-repository -y multiverse \
    && apt-get update \
    && apt-get install -y \
    cm-super \
    dvipng \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-science \
    texlive-bibtex-extra \
    biber \
    texlive-xetex \
    texlive-luatex \
    latexmk \
    xvfb \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
    | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ttf-mscorefonts-installer \
    && fc-cache -f -v \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda to /miniconda
ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG CONDA_PATH=/epyc/projects/dschaub/miniconda/envs
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

# Create the user after the shared system and Python installations.
ARG USERNAME=dschaub
ARG USER_UID=2856
# Shared instbonn group
ARG USER_GID=1735
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER $USERNAME
RUN conda tos accept && \
    conda init && \
    conda config --set solver libmamba && \
    conda config --add envs_dirs "${CONDA_PATH}"

# install uv
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"
ENV NVM_DIR="/home/${USERNAME}/.nvm"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# R's default per-user library, so install.packages works without root.
RUN Rscript -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'

RUN bash <<'EOF'
set -euo pipefail
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
. "$HOME/.nvm/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
npm install -g @openai/codex
grep -q nvm.sh "$HOME/.bashrc" || echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> "$HOME/.bashrc"
EOF

# Claude Code, Cursor and Antigravity CLIs; workspace-start updates them, like codex, on each start.
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && curl -fsS https://cursor.com/install | bash \
    && curl -fsSL https://antigravity.google/cli/install.sh | bash

# configure uv to create venvs locally
USER $USERNAME
WORKDIR /home/$USERNAME

ENV UV_BASE="/home/${USERNAME}/.uv-local"
ENV UV_CACHE_DIR="${UV_BASE}/cache" \
    UV_PYTHON_INSTALL_DIR="${UV_BASE}/python" \
    UV_PYTHON_CACHE_DIR="${UV_BASE}/python-cache"

# Create uv directories during build
RUN mkdir -p "$UV_CACHE_DIR" "$UV_PYTHON_INSTALL_DIR" "$UV_PYTHON_CACHE_DIR" "$UV_BASE/venvs"

RUN <<'EOF'
cat <<'BASHRC' >> "/home/$USERNAME/.bashrc"
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

# Configure Git after installations so identity changes preserve their cache.
USER root
ARG GITHUB_NAME=dschaub95
ARG GITHUB_EMAIL=schaub.darius@gmail.com
RUN git config --global user.name "$GITHUB_NAME" \
    && git config --global user.email "$GITHUB_EMAIL"
USER $USERNAME
RUN git config --global user.name "$GITHUB_NAME" \
    && git config --global user.email "$GITHUB_EMAIL"

# Workspace entrypoint: T3 supervisor with PVC snapshots, in-place T3 updates, optional Tailscale.
# A deployment sets T3_STATE_DIR (and TAILSCALE_STATE_DIR for Tailscale) and runs workspace-start.
USER root
COPY workspace/workspace-start workspace/t3-supervisor workspace/t3-update workspace/tailscale /usr/local/bin/
COPY workspace/t3-backup.py /usr/local/lib/t3-workspace/
RUN chmod 755 /usr/local/bin/workspace-start /usr/local/bin/t3-supervisor /usr/local/bin/t3-update /usr/local/bin/tailscale \
    && chmod 644 /usr/local/lib/t3-workspace/t3-backup.py
USER $USERNAME
# Version a workspace starts with until t3-update records another in $T3_STATE_DIR/t3-version.
ENV T3_DEFAULT_VERSION=0.1.11
ENV TAILSCALE_SOCKET="/home/${USERNAME}/.local/state/tailscale/tailscaled.sock"

# these are necessary when deploying to the kubernetes cluster
ENV http_proxy="http://proxy.ims.bio:3128"
ENV https_proxy="http://proxy.ims.bio:3128"

CMD ["/bin/bash"]
