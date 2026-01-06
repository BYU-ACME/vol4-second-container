########################  BASE PYTHON  ########################
FROM python:3.13.5-slim


########################  SYSTEM PACKAGES  ###################
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential cmake \
        libblas-dev liblapack-dev \
        libgl1 libglib2.0-0 \
        ffmpeg \
        git unzip sudo \
        vim nano \
        wget \
        man-db less groff-base \
        procps \
    && rm -rf /var/lib/apt/lists/*


########################  PYTHON PACKAGES  ###################
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install NumPy first to avoid resolution / ABI weirdness when SciPy is installed.
RUN pip install --no-cache-dir \
    numpy~=2.3.2

# Lab Dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Universal Dependencies
RUN pip install --no-cache-dir \
    cvxopt~=1.3.2 \
    ipykernel~=6.29.5 \
    jupyter~=1.1.1 \
    flake8~=7.3.0 \
    pytest~=7.4.4 \
    pytest-cov~=6.2.1 \
    ipython~=9.4.0 \
    coverage~=7.9.2 \
    matplotlib~=3.10.3 \
    pandas~=2.3.1

# Sanity check: fail build if dependency requirements are inconsistent.
RUN python -m pip check


########################  CONFIGURE GIT ########################
RUN git config --system core.askPass true \
 && git config --system credential.helper cache \
 && git config --system --add safe.directory '*'


########################  NON-ROOT USER  #####################
RUN useradd -m vscode
USER vscode
WORKDIR /workspaces