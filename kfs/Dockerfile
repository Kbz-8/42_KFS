FROM debian:bullseye

RUN apt update -y
RUN apt upgrade -y
RUN apt install wget -y
RUN apt install tar -y

RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
RUN echo 'deb https://dl.bintray.com/dryzig/zig-debian bullseye main' | sudo tee -a /etc/apt/sources.list
RUN apt update
RUN sudo apt install zig

RUN apt install qemu -y
