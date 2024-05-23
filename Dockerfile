FROM debian:bullseye

RUN apt update -y
RUN apt install wget -y
RUN apt install tar -y
RUN apt install xz-utils -y
RUN apt install make -y

RUN wget https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz
RUN tar xf ./zig-linux-x86_64-0.12.0.tar.xz
RUN mv zig-linux-x86_64-0.12.0/* /bin

RUN apt install qemu -y
RUN apt install qemu-system-x86 -y

RUN apt install grub -y
RUN apt install xorriso -y
RUN apt install mtools -y

RUN apt install xauth -y
COPY kfs ./kfs
WORKDIR "kfs"

ENTRYPOINT ["make", "run"]
