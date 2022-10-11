# SysY in Docker

LLVM 及 MIPS 编译/运行环境，基于 ubuntu 镜像构建，内置有 Clang, LLVM 编译器以及运行 MIPS ELF 的 QEMU 模拟器。

SysY 动态链接库 `sylib` 已经内置在 Docker 镜像中，位于 `/usr/share/sylib`。

## 使用说明

本镜像内置了若干方便使用的脚本:

- `sysy-llvm.sh`: 由 SysY 源代码生成 LLVM IR
- `sysy-asm.sh`: 由 SysY 源代码生成 MIPS 汇编 (交叉 gcc)
- `sysy-asm-clang.sh`: 由 SysY 源代码生成 MIPS 汇编 (clang)
- `sysy-asm-o2.sh`: 由 SysY 源代码生成 MIPS 汇编 (交叉 gcc 开启 O2)
- `sysy-asm-clang-o2.sh`: 由 SysY 源代码生成 MIPS 汇编 (clang 开启 O2)
- `sysy-elf.sh`: 由汇编文件 `.S` 或源代码 (`.sy` 或 `.c`) 生成可执行的 ELF 文件 (交叉 gcc)
- `sysy-elf-clang.sh`: 由汇编文件 `.S` 或源代码 (`.sy` 或 `.c`) 生成可执行的 ELF 文件 (clang)
- `sysy-run-llvm.sh`: 运行 SysY 源代码编译生成的 LLVM IR
- `sysy-run-elf.sh`: 运行 MIPS ELF 可执行文件

以上脚本调用时均需要传入一个文件名参数，例如 `sysy-asm.sh hello.sy`，生成的文件名无需传入，默认的命名规则为去掉传入文件的扩展名，并根据输出文件的格式替换成相应的扩展名。

具体每个脚本的输入/输出文件扩展名如下表:

| 脚本名称 | 输入文件扩展名 | 输出文件扩展名 |
| :---: | :---: | :---: |
| `sysy-llvm.sh` | `.sy` 或 `.c` | `.ll` |
| `sysy-asm.sh` | `.sy` 或 `.c` | `.S` |
| `sysy-asm-clang.sh` | `.sy` 或 `.c` | `.S` |
| `sysy-asm-o2.sh` | `.sy` 或 `.c` | `.S` |
| `sysy-asm-clang-o2.sh` | `.sy` 或 `.c` | `.S` |
| `sysy-elf.sh` | `.sy`, `.c` 或 `.S` | `.elf` |
| `sysy-elf-clang.sh` | `.sy`, `.c` 或 `.S` | `.elf` |
| `sysy-run-llvm.sh` | `.ll` | 无 |
| `sysy-run-elf.sh` | `.elf` 或没有 | 无 |

需要注意的是，这里规定 MIPS ELF 文件的扩展名为 `.elf`，这是为了与普通的 x86 指令集的可执行文件区分开。MIPS 指令集的 ELF 文件在 x86 的 PC 机上无法直接执行，需要使用执行脚本 `sysy-run-elf.sh` 来执行（该脚本自动调用支持 MIPS 指令集的 QEMU 模拟器）。

以上脚本均已置于 `PATH` 下，使用时在 Shell 中键入 `sysy-` 并用 TAB 键自动补全即可。

## Docker 操作

构建镜像（镜像名称及标签为 `sysy:latest`）:

    ./docker-build.sh

由镜像启动容器并进入 Shell（容器名称为 `sysy`，如退出 Shell 则自动删除容器）:

    ./docker-start.sh

（注：如需将主机的代码目录挂载到容器内，可直接传入要挂载的主机目录，例如 `./docker-start.sh /path/to/your/code`，挂载到容器内的 `~/sysy` 目录中）

在容器内可以使用 vim 编辑文件，如使用挂载目录方式则可直接在主机上编辑文件并在容器内编译及运行。

## 使用 qemu 和 gdb 调试

容器内安装了 `gdb-multiarch` 。这里使用 `qemu-user` 启动内置的 gdb server 并通过 `gdb-multiarch` 连接 qemu 进行调试。

设待调试的 MIPS ELF 文件为 `test.elf` ，使用以下命令进入调试：

```shell
# 使用 mips 架构 qemu-user 开启 gdb server 监听本地端口 8888，执行 test.elf
qemu-mips -g 8888 test.elf &     # 该命令后的 & 非常关键，使 qemu 在后台执行，否则将阻塞终端且无法用 Ctrl+C 退出
gdb-multiarch

# 进入 gdb 后
(gdb) file test.elf                   # 加载可执行程序
(gdb) set architecture mips            # 设置体系结构为 mips
(gdb) target remote localhost:8888    # 连接 qemu 监听的端口
```

完成上述命令后即可开始使用 gdb 调试。一些常用的 gdb 命令：

- `b <target>` (`break <target>`) 设置断点，`<target>` 可以是函数或 label 名称，也可以是 `*` + PC 地址（例如 `b *0x00000`)
- `i b` (`info breakpoints`) 查看已有断点
- `disas` (`disassemble`) 反汇编，可用来查看当前执行到的指令及其前后指令
- `i r` (`info registers`) 查看寄存器
- `i vec` (`info vector`) 查看向量寄存器
- `x <addr>` 查看内存地址的值
- `ni` 执行下一条汇编指令 (不进入子函数)
- `si` 执行下一条汇编指令 (进入子函数)
- `c` 执行到下一断点

通常用以下命令作为调试的开始：

```
(gdb) b main
(gdb) c
```