FROM ubuntu:20.04 as stage1
MAINTAINER Michael Brown <producer@holotronic.dk>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Europe/Copenhagen apt-get -y install tzdata

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git \
    net-tools \
    unzip \
    gcc \
    g++ \
    python2 \
    python3 \
    xz-utils \
    libtinfo5 \
    libgtk-3-0 \
    dbus-x11 \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libfreetype6 \
    libfontconfig \
    lsb-release \
    software-properties-common \
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
    ruby \
    ruby-dev \
    pkg-config \
    libprotobuf-dev \
    protobuf-compiler \
    x11-utils \
    device-tree-compiler \
    parted \
    udev \
    xxd \
    lbzip2 \
    bc \
    tofrodos \
    libsdl1.2-dev \
    liberror-perl \
    mtd-utils \
    xtrans-dev \
    libxcb-randr0-dev \
    libxcb-xtest0-dev \
    libxcb-xinerama0-dev \
    libxcb-shape0-dev \
    libxcb-xkb-dev \
    openssh-server \
    util-linux \
    sysvinit-utils \
    google-perftools \
    libncurses5 \
    libncursesw5-dev \
    libncurses5:i386 \
    libstdc++6:i386 \
    libgtk2.0-0:i386 \
    dpkg-dev:i386 \
    ocl-icd-libopencl1 \
    opencl-headers \
    ocl-icd-opencl-dev \
    xz-utils \
    libgtk-3-0 \
    dbus-x11 \
    locales

# COPY xrt_202110.2.9.0_20.04-amd64-xrt.deb /tmp/
# RUN apt-get install -y /tmp/xrt_202110.2.9.0_20.04-amd64-xrt.deb && rm -rf /tmp/*

# copy in config file
COPY install_config-vivado.txt /tmp/
#COPY install_config-vitis.txt /tmp/
COPY install_config-petalinux.txt /tmp/

ADD Xilinx_Unified_2022.2_1014_8888.tar.gz /tmp/

RUN mkdir -p /home/vivado

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

RUN /tmp/Xilinx_Unified_2022.2_1014_8888/xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /tmp/install_config-vivado.txt

RUN useradd -m vivado && echo "vivado:vivado" | chpasswd && adduser vivado sudo \
    && adduser vivado audio && adduser vivado video && \
    chown -R vivado:vivado /home/vivado
USER vivado

RUN /tmp/Xilinx_Unified_2022.2_1014_8888/xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /tmp/install_config-petalinux.txt

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

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  net-tools \
  unzip \
  gcc \
  g++ \
  python2 \
  python3 \
  libtinfo5
  
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Copenhagen apt-get -y install tzdata

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
        ruby \
        ruby-dev \
        pkg-config \
        libprotobuf-dev \
        protobuf-compiler \
        x11-utils \
        device-tree-compiler \
        parted \
        udev \
        xxd \
        lbzip2 \
        bc \
        tofrodos \
        libsdl1.2-dev \
        liberror-perl \
        mtd-utils \
        xtrans-dev \
        libxcb-randr0-dev \
        libxcb-xtest0-dev \
        libxcb-xinerama0-dev \
        libxcb-shape0-dev \
        libxcb-xkb-dev \
        openssh-server \
        util-linux \
        sysvinit-utils \
        google-perftools \
        libncurses5 \
        libncursesw5-dev \
        libncurses5:i386 \
        libstdc++6:i386 \
        libgtk2.0-0:i386 \
        dpkg-dev:i386 \
        ocl-icd-libopencl1 \
        opencl-headers \
        ocl-icd-opencl-dev \
        xz-utils \
        libgtk-3-0 \
        dbus-x11 \
        python3-pip && \
        pip3 install intelhex && \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen && \
        gem install fpm && \
        apt-get clean

COPY --from=stage1 /tools/Xilinx /tools/Xilinx
COPY --from=stage1 /root /root

#RUN /tools/Xilinx/Vitis/2022.2/scripts/installLibs.sh

RUN useradd -m vivado && echo "vivado:vivado" | chpasswd && adduser vivado sudo && adduser vivado audio && \
    chown -R vivado:vivado /home/vivado

COPY --from=stage1 /home /home

COPY keyboard /etc/default/keyboard

#RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y xserver-xorg-video-all
RUN apt-get update && apt-get install -y \
    expect \
    libgnutls28-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    lib32stdc++6 \
    libfontconfig1:i386 \
    libx11-6:i386 \
    libxext6:i386 \
    libxrender1:i386 \
    libsm6:i386 \
    libqt5gui5:i386 \
    gnome-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y

RUN usermod -a -G video vivado

COPY accept-eula.sh /
RUN chmod a+rx /accept-eula.sh

RUN sudo -u vivado -i /accept-eula.sh /home/vivado/PetaLinux/2022.2/bin/petalinux-v2022.2-final-installer.run /home/vivado/petalinux "arm aarch64" && \
    rm -f /home/vivado/PetaLinux/2022.2/bin/petalinux-v2022.2-final-installer.run /accept-eula.sh


# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
RUN chsh -s /bin/bash

USER vivado
WORKDIR /home/vivado
  
#add vivado tools to path
#    echo "source /opt/xilinx/xrt/setup.sh" >> /home/vivado/.bashrc && \

#RUN echo "source /tools/Xilinx/Vitis/2022.2/settings64.sh" >> /home/vivado/.bashrc && \

RUN echo "source /tools/Xilinx/Vivado/2022.2/settings64.sh" >> /home/vivado/.bashrc && \
    echo "source /home/vivado/petalinux/settings.sh" >> /home/vivado/.bashrc

COPY ding.wav /home/vivado/

# customize gui (font scaling 125%)
#COPY --chown=vivado:vivado vivado.xml /home/vivado/.Xilinx/Vivado/2022.2/vivado.xml

# add U96 board files
ADD /board_files.tar.gz /tools/Xilinx/Vivado/2022.2/data/boards/
