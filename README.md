# Vivado Docker for CI and environment sharing

You should download your vivado version here and your board file folders as board_files.tar.gz.

docker build -t bionic-vitis-sdk:2022.2 .

To be able to run the Vivado gui start as:

    docker run --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    -itv $(pwd):/work -v -e TZ=Europe/Copenhagen $HOME/.Xilinx:/home/vivado/.Xilinx \
    focal-vitis:2022.2 /bin/bash

    /usr/bin/docker run --privileged --memory 16g --shm-size 1g --device /dev/snd \
    -itv $(pwd):/work -e DISPLAY=$DISPLAY --net=host  -e TZ=Europe/Copenhagen \
    -v $HOME/.Xauthority:/home/vivado/.Xauthority -v $HOME/.Xresources:/home/vivado/.Xresources \
    -v $HOME/.Xilinx:/home/vivado/.Xilinx -v /tftpboot:/tftpboot focal-vivado:2022.2 /bin/bash
    
    /usr/bin/docker run --privileged --memory 16g --shm-size 1g --device /dev/snd \
    -itv $(pwd):/work -e DISPLAY=$DISPLAY --net=host -e TZ=Europe/Copenhagen \
    -v $HOME/.Xauthority:/home/vivado/.Xauthority -v $HOME/.Xresources:/home/vivado/.Xresources \
    -v $HOME/.Xilinx:/home/vivado/.Xilinx -v /tftpboot:/tftpboot focal-vivado:2022.2 /bin/bash -c \
    'cd /work && /tools/Xilinx/Vivado/2022.2/bin/vivado -stack 2000'
    
    /usr/bin/docker run --rm --privileged --memory 48g --shm-size 1g --device /dev/snd -itv $(pwd):/work -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --net=host -e TZ=Europe/Copenhagen -v $HOME/.Xauthority:/home/vivado/.Xauthority -v $HOME/.Xresources:/home/vivado/.Xresources -v $HOME/.Xilinx:/home/vivado/.Xilinx -v /tftpboot:/tftpboot --name xilinx-sdk bionic-vitis-sdk:2022.2 /bin/bash

    cd /work
    vivado
