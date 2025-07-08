# 42 Kernel From Scratch <a href="https://github.com/Kbz-8/42_KFS/actions/workflows/build.yml"><img src="https://github.com/Kbz-8/42_KFS/actions/workflows/build.yml/badge.svg"></a>

A minimalist kernel from scratch, written in [Zig 0.13](https://ziglang.org/download/0.13.0/).

## Overview

**42_KFS** is a low-level educational operating system project. It is designed to help understand OS fundamentals, boot processes, memory management, and hardware interaction—all implemented in Zig for safety and performance.

## Features

- Written entirely in Zig 0.13 for modern language safety and performance
- Minimalist kernel: simple, clear, and well-documented codebase
- Bootloader setup and kernel entry
- Basic device drivers (VGA text output, keyboard input, etc.)
- **A shell:**  
![image](https://github.com/user-attachments/assets/845f2e94-610f-4003-a39f-58d85044e477)

- **Kernel panics:**  
![image](https://github.com/user-attachments/assets/751ee965-3fa7-4195-b7a9-0c035cc53052)

- **Stack trace:**  
![image](https://github.com/user-attachments/assets/78e78fd2-9a17-45cc-833f-6daf44dbdcb9)

## Requirements

- [Zig 0.13](https://ziglang.org/download/0.13.0/)
- QEMU or another x86 emulator/virtual machine

## Getting Started

1. **Clone the repo:**
    ```sh
    git clone https://github.com/Kbz-8/42_KFS.git
    cd 42_KFS
    ```

2. **Install dependencies:**
    - Download [Zig 0.13](https://ziglang.org/download/0.13.0/)
    - Install QEMU:  
      `sudo apt install qemu` (Debian/Ubuntu)  
      or see [QEMU downloads](https://www.qemu.org/download/)

3. **Build the kernel:**
    ```sh
    zig build
    ```

4. **Run in QEMU:**
    ```sh
    zig run
    ```

## Acknowledgments

- [Zig Programming Language](https://ziglang.org/)
- [OSDev Wiki](https://wiki.osdev.org/)

---

