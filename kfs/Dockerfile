FROM debian:bullseye

RUN apt update -y
RUN apt upgrade -y
RUN apt install wget -y
RUN apt install tar -y

RUN wget https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz
RUN tar -xpf zig-linux-x86_64-0.12.0.tar.xz
RUN mv zig-linux-x86_64-0.12.0/zig /bin
RUN wget https://download.qemu.org/qemu-9.0.0.tar.xz
RUN tar -xpf qemu-9.0.0.tar.xz
RUN cd qemu-9.0.0
RUN ./qemu/configure
RUN make -C qemu
