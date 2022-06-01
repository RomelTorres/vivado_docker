FROM ubuntu:20.04 as stage1
MAINTAINER Michael Brown <producer@holotronic.dk>

#install dependences for:
# * downloading Vivado (wget)
# * xsim (gcc build-essential to also get make)
# * MIG tool (libglib2.0-0 libsm6 libxi6 libxrender1 libxrandr2 libfreetype6 libfontconfig)
# * CI (git)
# RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
#   build-essential \
#   git \
#   libglib2.0-0 \
#   libsm6 \
#   libxi6 \
#   libxrender1 \
#   libxrandr2 \
#   libfreetype6 \
#   libfontconfig \
#   lsb-release \
#   software-properties-common
# 
RUN apt-get update && apt-get install -y \
   git \
   net-tools \
   unzip \
   gcc \
   g++ \
   python \
   libtinfo5 \
   locales

# COPY xrt_202110.2.9.0_20.04-amd64-xrt.deb /tmp/
# RUN apt-get install -y /tmp/xrt_202110.2.9.0_20.04-amd64-xrt.deb && rm -rf /tmp/*

# copy in config file
#COPY install_config-vitis.txt /tmp/
COPY install_config-vivado.txt /tmp/
COPY install_config-petalinux.txt /tmp/

ADD Xilinx_Unified_2021.2_1021_0703.tar.gz /tmp/

RUN mkdir -p /home/vivado

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

RUN /tmp/Xilinx_Unified_2021.2_1021_0703/xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /tmp/install_config-vivado.txt

RUN useradd -m vivado && echo "vivado:vivado" | chpasswd && adduser vivado sudo \
    && adduser vivado audio && adduser vivado video && \
    chown -R vivado:vivado /home/vivado
USER vivado

RUN /tmp/Xilinx_Unified_2021.2_1021_0703/xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /tmp/install_config-petalinux.txt

USER root
run rm -rf /tmp/*

FROM ubuntu:20.04

#install dependences for:
# * downloading Vivado (wget)
# * xsim (gcc build-essential to also get make)
# * MIG tool (libglib2.0-0 libsm6 libxi6 libxrender1 libxrandr2 libfreetype6 libfontconfig)
# * CI (git)
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  build-essential \
  git \
  libglib2.0-0 \
  libsm6 \
  libxi6 \
  libxrender1 \
  libxrandr2 \
  libfreetype6 \
  libfontconfig \
  lsb-release \
  software-properties-common

RUN dpkg --add-architecture i386 

RUN apt-get update && apt-get -y upgrade && apt-get install -y \
  net-tools \
  unzip \
  gcc \
  g++ \
  python \
  libtinfo5
  
  
# turn off recommends on container OS
# install required dependencies
RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
    /etc/apt/apt.conf.d/01norecommend && \
    apt-get update && \
    apt-get -y install \
        iproute2 \
        gawk \
        python3 \
        make \
        libncurses5-dev \
        zlib1g-dev \
        libssl-dev  \
        flex \
        bison \
        libselinux1 \
        gnupg \
        wget \
        git-core \
        diffstat \
        chrpath \
        socat \
        xterm \
        autoconf \
        libtool \
        tar \
        texinfo \
        gcc-multilib \
        automake \
        zlib1g:i386 \
        screen \
        pax \
        gzip \
        cpio \
        python3-pexpect \
        xz-utils \
        debianutils \
        iputils-ping \
        python3-git \
        python3-jinja2 \
        libegl1-mesa \
        ibsdl1.2-dev \
        pylint3 \
        alsa-utils \
        libc6-i386 \
        git \
        rsync \
        libfontconfig1 \
        libglib2.0-0 \
        sudo \
        nano \
        locales \
        libxext6 \
        libxrender1 \
        libxtst6 \
        libgtk2.0-0 \
        build-essential \
        ruby \
        ruby-dev \
        pkg-config \
        libprotobuf-dev \
        protobuf-compiler \
        python-protobuf \
        x11-utils \
        device-tree-compiler \
        parted \
        udev \
        xxd \
        lbzip2 \
        bc \
        python3-pip && \
        pip3 install intelhex && \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen && \
        gem install fpm && \
        apt-get clean

COPY --from=stage1 /tools/Xilinx /tools/Xilinx
COPY --from=stage1 /root /root

#COPY xrt_202110.2.11.634_20.04-amd64-xrt.deb /tmp/
#RUN apt-get install -y /tmp/xrt_202110.2.11.634_20.04-amd64-xrt.deb && rm -rf /tmp/*

#RUN /tools/Xilinx/Vivado/2021.2/scripts/installLibs.sh

RUN useradd -m vivado && echo "vivado:vivado" | chpasswd && adduser vivado sudo && adduser vivado audio && \
    chown -R vivado:vivado /home/vivado

COPY --from=stage1 /home /home

COPY keyboard /etc/default/keyboard

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y xserver-xorg-video-all
RUN apt-get update && apt-get install -y \
    expect \
    libgnutls28-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -a -G video vivado

COPY accept-eula.sh /
RUN chmod a+rx /accept-eula.sh

RUN sudo -u vivado -i /accept-eula.sh /home/vivado/PetaLinux/2021.2/bin/petalinux-v2021.2-final-installer.run /home/vivado/petalinux "arm aarch64" && \
    rm -f /home/vivado/PetaLinux/2021.2/bin/petalinux-v2021.2-final-installer.run /accept-eula.sh

#   sudo -u vivado -i /accept-eula.sh /${PETA_RUN_FILE} /opt/Xilinx/petalinux && \

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER vivado
WORKDIR /home/vivado
  
#add vivado tools to path
#    echo "source /opt/xilinx/xrt/setup.sh" >> /home/vivado/.bashrc && \

RUN echo "source /tools/Xilinx/Vivado/2021.2/settings64.sh" >> /home/vivado/.bashrc && \
    echo "source /home/vivado/petalinux/settings.sh" >> /home/vivado/.bashrc

COPY ding.wav /home/vivado/

# customize gui (font scaling 125%)
#COPY --chown=vivado:vivado vivado.xml /home/vivado/.Xilinx/Vivado/2021.2/vivado.xml

# add U96 board files
ADD /board_files.tar.gz /tools/Xilinx/Vivado/2021.2/data/boards/
