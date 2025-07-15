# MeanFilter IP 核项目

基于 SystemVerilog 的均值滤波器 IP 核，适用于图像处理应用。本项目提供了完整的 Vivado 项目创建和构建流程。

## 项目简介

MeanFilter IP 核实现了 3x3 窗口的均值滤波功能，包含：
- **MeanFilter.sv**: 主滤波器模块，包含加法树实现
- **LineBuf.sv**: 行缓冲模块，用于存储图像行数据
- **tb_MF.sv**: 仿真测试台

## 主要特性

### 分离式构建架构
- **项目创建与构建分离**: 支持独立的项目创建和重复构建
- **智能状态管理**: 自动检测项目和综合状态
- **CLI 友好**: 支持在 Vivado CLI 中重复运行综合和仿真

### 自动化功能
- **自动 IP 核生成**: 自动创建和配置 BRAM IP 核
- **智能文件管理**: 自动添加设计文件和仿真文件
- **约束文件生成**: 自动生成基本时序约束

### 错误处理
- **鲁棒的错误处理**: 完善的异常处理和错误恢复机制
- **详细的日志信息**: 提供清晰的执行过程和结果反馈
- **状态验证**: 自动检查项目完整性和 IP 核状态

## 文件结构

```
ip-MeanFilter/
├── src/
│   ├── MeanFilter.sv                # 主滤波器模块
│   └── LineBuf.sv                   # 行缓冲模块
├── sim/
│   └── tb_MF.sv                     # 仿真测试台
├── create_meanfilter_project.tcl    # 项目创建脚本
├── build.tcl                        # 构建脚本（综合和仿真）
├── simulate.tcl                     # 纯命令行仿真脚本
├── run_meanfilter.sh                # 一键运行脚本
├── TCL_USAGE_GUIDE.md               # TCL 脚本使用指南
├── REPEAT_RUN_EXAMPLE.md            # 重复运行示例
└── README.md                        # 本文件
```

## 使用方法

### 🚀 快速开始

#### 方法1：一键运行（推荐）
```bash
./run_meanfilter.sh
```

这个脚本会：
1. 清理之前的项目和日志文件
2. 创建新的 Vivado 项目
3. 自动运行综合和仿真

#### 方法2：分步执行
```bash
# 步骤1：创建项目
vivado -mode tcl -source create_meanfilter_project.tcl

# 步骤2：构建项目（综合和仿真）
vivado -mode tcl -source build.tcl                        # 默认批处理模式
vivado -mode tcl -source build.tcl -tclargs -gui          # GUI模式仿真
vivado -mode tcl -source build.tcl -tclargs -nosim        # 跳过仿真

# 步骤3：纯命令行仿真（可选）
vivado -mode tcl -source simulate.tcl                 # 不需要GUI
```

#### 方法3：在 Vivado CLI 中重复运行
```bash
# 启动 Vivado CLI
vivado -mode tcl

# 在 CLI 中可以重复运行构建
Vivado% source build.tcl
Vivado% source build.tcl  # 可以重复运行
```

### 📋 脚本说明

#### `create_meanfilter_project.tcl`
- 创建 Vivado 项目
- 添加设计文件 (MeanFilter.sv, LineBuf.sv)
- 添加仿真文件 (tb_MF.sv)
- 生成 BRAM IP 核 (BRAM_32x8192)
- 创建约束文件
- 配置项目设置

#### `build.tcl`
- 智能项目状态检测
- 执行综合（支持重复运行）
- 生成综合报告
- 启动仿真
- 错误处理和状态反馈

#### `run_meanfilter.sh`
- 环境清理
- 依次执行项目创建和构建
- 错误检查和状态报告

## 技术规格

### MeanFilter 模块参数
- `DATA_WIDTH`: 数据位宽（默认: 8）
- `WINDOW_SIZE`: 滤波窗口大小（默认: 3，即 3x3 窗口）
- `FRAME_WIDTH`: 帧宽度（默认: 640）
- `FRAME_HEIGHT`: 帧高度（默认: 512）

### 生成的 IP 核
- **BRAM_32x8192**: 32位宽，8192深度的双端口 BRAM
- 用于行缓冲存储

### 目标器件
- 默认: `xc7a100tcsg324-1`
- 可在 `create_meanfilter_project.tcl` 中修改

## 详细文档

- **[TCL_USAGE_GUIDE.md](TCL_USAGE_GUIDE.md)**: TCL 脚本详细使用指南

## 项目输出

### 综合结果
- 资源利用率报告
- 时序摘要报告
- 综合日志文件

### 仿真结果
- 波形文件
- 仿真日志
- 测试结果验证

### 生成的文件
- `MeanFilter_project/`: Vivado 项目文件夹
- `MeanFilter_project.srcs/`: 源文件和约束文件
- 各种日志文件 (*.log, *.jou)

## 故障排除

### 常见问题

1. **项目已打开错误**
   ```
   ERROR: [Coretcl 2-101] Project is already open.
   ```
   **解决方案**: `build.tcl` 脚本已经处理了这个问题，支持重复运行

2. **IP 核生成失败**
   - 检查 Vivado 版本兼容性
   - 确认目标器件支持该 IP 核
   - 检查许可证状态

3. **综合失败**
   - 检查设计文件语法
   - 查看综合日志获取详细错误信息
   - 确认所有依赖文件都存在

4. **仿真启动失败**
   - 检查仿真文件路径
   - 确认仿真设置正确
   - 查看仿真日志获取错误信息

### 调试技巧

1. **查看详细日志**
   ```bash
   # 查看 Vivado 日志
   cat vivado.log
   
   # 查看综合日志
   cat MeanFilter_project/MeanFilter_project.runs/synth_1/runme.log
   ```

2. **手动启动仿真**
   ```tcl
   # 在 Vivado GUI 中
   launch_simulation
   ```

3. **检查项目状态**
   ```tcl
   # 检查当前项目
   current_project
   
   # 检查综合状态
   get_property STATUS [get_runs synth_1]
   ```

## 系统要求

- **Vivado**: 2021.1 或更高版本
- **操作系统**: Windows 10/11, Linux (Ubuntu 18.04+)
- **内存**: 最少 8GB，推荐 16GB
- **存储**: 至少 2GB 可用空间

## 版本兼容性

- ✅ Vivado 2021.1
- ✅ Vivado 2021.2
- ✅ Vivado 2022.x
- ✅ Vivado 2023.x

## 贡献指南

如果您想为项目贡献代码：

1. Fork 本仓库
2. 创建特性分支
3. 提交更改
4. 发起 Pull Request

## 许可证

本项目采用 MIT 许可证。详情请参阅 LICENSE 文件。

## 联系信息

- 项目维护者: aerore2021
- 仓库地址: https://github.com/aerore2021/ip-MeanFilter

如有问题，请在 GitHub 上提交 Issue。
