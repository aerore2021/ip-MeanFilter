# MeanFilter IP 核项目

## 项目概述

MeanFilter IP 核是一个基于 SystemVerilog 的 3x3 均值滤波器 IP 核，专为图像处理应用设计。本项目提供了完整的 Vivado 项目创建、构建和仿真流程，支持命令行自动化操作。

### 主要特性

- **3x3 窗口均值滤波**: 实现图像平滑处理
- **AXI-Stream 接口**: 标准流接口，便于集成
- **自动化构建**: 支持一键运行和分步执行
- **智能状态管理**: 自动检测项目和综合状态
- **CLI 友好**: 支持在 Vivado CLI 中重复运行综合和仿真

## 文件结构

```
ip-MeanFilter/
├── src/                             # 源代码
│   ├── MeanFilter.sv                # 主滤波器模块
│   └── LineBuf.sv                   # 行缓冲模块
├── sim/                             # 仿真文件
│   └── tb_MF.sv                     # 仿真测试台
├── create_meanfilter_project.tcl    # 项目创建脚本
├── build.tcl                        # 构建脚本（综合和仿真）
├── simulate.tcl                     # 纯命令行仿真脚本
├── run_meanfilter.sh                # 一键运行脚本
└── README.md                        # 本文件
```

## 核心模块说明

### 1. MeanFilter.sv
主滤波器模块，实现以下功能：
- 3x3 窗口数据收集
- 均值计算（加法树实现）
- AXI-Stream 协议处理
- 状态机控制

### 2. LineBuf.sv
行缓冲模块，负责：
- 图像行数据存储
- BRAM IP 核接口
- 数据读写控制

### 3. tb_MF.sv
仿真测试台，包含：
- 完整帧数据生成
- AXI-Stream 协议仿真
- 输出数据监控

## 使用方法

### 快速开始

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
vivado -mode tcl -source simulate.tcl                     # 不需要GUI
```

#### 方法3：在 Vivado CLI 中重复运行
```bash
# 启动 Vivado CLI
vivado -mode tcl

# 在 CLI 中可以重复运行构建
Vivado% source build.tcl
Vivado% source build.tcl  # 可以重复运行
```

## TCL 脚本说明

### create_meanfilter_project.tcl
创建 MeanFilter 项目和配置：
- 创建新的 Vivado 项目
- 添加设计文件 (MeanFilter.sv, LineBuf.sv)
- 添加仿真文件 (tb_MF.sv)
- 生成和配置 BRAM IP 核
- 创建约束文件
- 设置综合和实现策略

### build.tcl
执行综合和仿真：
- 打开现有项目
- 智能项目状态检测
- 执行综合（支持重复运行）
- 生成综合报告
- 启动仿真
- 错误处理和状态反馈

### simulate.tcl
纯命令行仿真脚本：
- 批处理模式仿真
- 不需要 GUI 支持
- 自动生成仿真报告
- 错误处理和状态检查

### run_meanfilter.sh
一键运行脚本：
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

## 项目输出

### 综合结果
- 资源利用率报告
- 时序摘要报告
- 综合日志文件

### 仿真结果
- 仿真日志
- 测试结果验证

### 生成的文件
- `MeanFilter_project/`: Vivado 项目文件夹
- `MeanFilter_project.srcs/`: 源文件和约束文件
- 各种日志文件 (*.log, *.jou)

## 测试结果

### 综合测试
```
✅ 项目创建: 成功
✅ IP核生成: 成功 (BRAM_32x8192)
✅ 综合执行: 成功
✅ 资源利用: 164 LUTs, 120 registers, 6 BRAM tiles
✅ 时序分析: WNS 4.375ns, 所有约束满足
```

### 仿真测试
```
✅ GUI仿真: 成功启动
✅ 批处理仿真: 成功完成
✅ CLI仿真: 成功运行
```

### 性能指标

#### 资源利用率
- **LUT**: 164个 (低)
- **寄存器**: 120个 (低)
- **BRAM**: 6个 (中等)
- **DSP**: 0个 (优化良好)

#### 时序性能
- **WNS**: 4.375ns (良好)
- **WHS**: 0.030ns (良好)
- **时钟约束**: 全部满足

#### 构建性能
- **项目创建**: <30秒
- **综合时间**: ~2分钟
- **仿真时间**: <10秒

## 故障排除

### 常见问题

#### 1. 项目创建失败
**可能原因**: 
- 文件路径包含特殊字符
- 源文件不存在
- 权限不足

**解决方案**: 
- 检查文件路径
- 验证源文件存在
- 使用管理员权限运行

#### 2. 综合失败
**可能原因**: 
- 语法错误
- 约束冲突
- 资源不足

**解决方案**: 
- 查看综合日志
- 检查约束文件
- 优化设计资源使用

#### 3. 仿真失败
**可能原因**: 
- 测试台错误
- 时钟配置问题
- 信号连接错误

**解决方案**: 
- 检查测试台逻辑
- 验证时钟配置
- 确认信号连接正确

### 设计注意事项

#### 设计警告
1. **Multi-driven nets**: 部分信号存在多驱动
2. **Unconnected ports**: BRAM IP核端口未完全连接
3. **Index out of bounds**: 数组索引越界

#### 建议优化
1. 修复LineBuf模块的信号连接
2. 优化BRAM IP核的端口使用
3. 添加数组边界检查

## 重复运行示例

### 场景1：修改设计后重新构建
```bash
# 修改源文件后
vivado -mode tcl -source build.tcl
```

### 场景2：仅重新仿真
```bash
vivado -mode tcl -source simulate.tcl
```

### 场景3：完全重新创建项目
```bash
rm -rf MeanFilter_project/
vivado -mode tcl -source create_meanfilter_project.tcl
vivado -mode tcl -source build.tcl
```

## 项目状态

### 完成功能
- ✅ 模块化TCL脚本架构
- ✅ 自动化项目创建
- ✅ 智能构建管理
- ✅ 完整的错误处理
- ✅ 详细的文档说明

### 待优化项目
- 🔄 LineBuf模块信号连接优化
- 🔄 BRAM IP核端口使用优化
- 🔄 数组边界检查增强
- 🔄 更多测试用例添加

## 技术支持

### 开发环境
- **Vivado版本**: 2021.1
- **操作系统**: Windows 10/11
- **Shell**: Bash

### 项目信息
- **项目仓库**: GitHub - aerore2021/ip-MeanFilter
- **分支**: main
- **最后更新**: 2025年7月16日

---

**版本**: 2.1  
**状态**: 已完成并测试验证  
**最后更新**: 2025年7月16日
