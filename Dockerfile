FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

RUN  apt-get update && \
  apt-get install -y wget && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash neurvps-user

SHELL [ "/bin/bash", "--login", "-c" ]

USER neurvps-user
WORKDIR /home/neurvps-user

ENV CONDA_DIR=/home/neurvps-user/miniconda3

ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
ARG SHA256SUM="6bec65fcb0c66596a5058c6767d25d89a537eb83ee84684ec0fa5a4fbfb32647"
RUN --mount=type=cache,target=/root/.cache \
    wget "${MINICONDA_URL}" --output-document miniconda.sh --quiet --force-directories --directory-prefix ${CONDA_DIR} && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    sha256sum --check --status shasum && \
    /bin/bash miniconda.sh -b -p ${CONDA_DIR} && \
    rm miniconda.sh shasum

ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile && \
    conda init bash && \
    conda update -n base -c defaults conda

RUN conda create -n neurvps python=3.10

RUN --mount=type=cache,target=/root/.cache \
    conda activate neurvps && \
    conda install pytorch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 pytorch-cuda=12.4 -c pytorch -c nvidia && \
    conda install -y tensorboardx -c conda-forge && \
    conda install -y pyyaml docopt matplotlib scikit-image opencv tqdm && \
    conda install mkl=2023.1.0 ninja
