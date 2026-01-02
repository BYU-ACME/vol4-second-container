########################  BASE PYTHON  ########################
# Leave this unpinned for now, JAX will only work with the OS that pinned it
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
    && rm -rf /var/lib/apt/lists/*


########################  PYTHON PACKAGES  ###################
# Lab Dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Universal Dependencies
# cvxopt prevents warnings for various optimization routines in packages
# ipykernel is needed for the Jupyter kernel
# flake8 is needed for linting
# pytest, pytest-cov, coverage, ipython are helpful for testing and debugging
# matplotlib, numpy, pandas are required for grading (and in nearly all labs)
RUN pip install --no-cache-dir \
    cvxopt~=1.3.2 \
    ipykernel~=6.29.5 \
    flake8~=7.3.0 \
    pytest~=7.4.4 \
    pytest-cov~=6.2.1 \
    ipython~=9.4.0 \
    coverage~=7.9.2 \
    matplotlib~=3.10.3 \
    numpy~=2.3.2 \
    pandas~=2.3.1
    

########################  CONFIGURE GIT ########################
# Removes dubious ownership error and terminal prompts not working warning
RUN git config --system core.askPass true \
 && git config --system credential.helper cache \
 && git config --system --add safe.directory '*'


########################  REMOVE VSCODE SIGNING TOOL ########################
# Some installations activate a signing tool that uses a massive portion of the cpu for no reason
# I have found that these commands seem to do the trick
RUN rm -f /usr/bin/vsce-sign
RUN printf '#!/bin/sh\n# Disable rogue CPU-hungry VSCE signing processes\nfind /vscode/vscode-server -name vsce-sign -exec chmod -x {} + || true\n' > /usr/local/bin/disable-vsce-sign \
  && chmod +x /usr/local/bin/disable-vsce-sign
RUN mkdir -p /etc/sudoers.d && \
    echo "vscode ALL=(ALL) NOPASSWD: /usr/local/bin/disable-vsce-sign" | tee /etc/sudoers.d/disable-vsce-sign > /dev/null && \
    chmod 0440 /etc/sudoers.d/disable-vsce-sign


########################  NON‑ROOT USER  #####################
# This is the user that will be used to run the container
# Do not change this, vscode dev containers expects it and it's more secure
RUN useradd -m vscode
USER vscode
WORKDIR /workspaces