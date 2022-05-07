# SysY in Docker

编译竞赛 LLVM 及 ARM 编译/运行环境，基于 ubuntu 镜像构建，内置有 Clang, LLVM 编译器以及运行 ARM ELF 的 QEMU 模拟器。

SysY 动态链接库 `sylib` 已经内置在 Docker 镜像中，位于 `/usr/share/sylib`。

## 使用说明

本镜像内置了若干方便使用的脚本:

- `sysy-llvm.sh`: 由 SysY 源代码生成 LLVM IR
- `sysy-asm.sh`: 由 SysY 源代码生成 aarch64 汇编
- `sysy-elf.sh`: 由汇编文件 `.S` 或源代码 (`.sy` 或 `.c`) 生成可执行的 ELF 文件
- `sysy-run-llvm.sh`: 运行 SysY 源代码编译生成的 LLVM IR
- `sysy-run-elf.sh`: 运行 ARM ELF 可执行文件

以上脚本调用时均需要传入一个文件名参数，例如 `sysy-asm.sh hello.sy`，生成的文件名无需传入，默认的命名规则为去掉传入文件的扩展名，并根据输出文件的格式替换成相应的扩展名。

具体每个脚本的输入/输出文件扩展名如下表:

| 脚本名称 | 输入文件扩展名 | 输出文件扩展名 |
| :---: | :---: | :---: |
| `sysy-llvm.sh` | `.sy` 或 `.c` | `.ll` |
| `sysy-asm.sh` | `.sy` 或 `.c` | `.S` |
| `sysy-elf.sh` | `.sy`, `.c` 或 `.S` | `.elf` |
| `sysy-run-llvm.sh` | `.ll` | 无 |
| `sysy-run-elf.sh` | `.elf` 或没有 | 无 |

需要注意的是，这里规定 ARM ELF 文件的扩展名为 `.elf`，这是为了与普通的 x86 指令集的可执行文件区分开。ARM 指令集的 ELF 文件在 x86 的 PC 机上无法直接执行，需要使用执行脚本 `sysy-run-elf.sh` 来执行（该脚本自动调用支持 ARM 指令集的 QEMU 模拟器）。

以上脚本均已置于 `PATH` 下，使用时在 Shell 中键入 `sysy-` 并用 TAB 键自动补全即可。

## Docker 操作

构建镜像（镜像名称及标签为 `sysy:latest`）:

    ./docker-build.sh

由镜像启动容器（容器名称为 `sysy`）:

    ./docker-start.sh

（注：可在该脚本中加入 `-v` 选项以将主机的代码目录挂载进 docker 容器中，例如 `-v /path/to/your/code:/root/sysy`）

进入 docker 容器的 Shell:

    ./docker-enter.sh
