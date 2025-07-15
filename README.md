# MeanFilter Vivado项目使用说明

## 主要特性

### 🚀 高度自动化
- **自动文件扫描**：自动识别和添加所有HDL文件（.sv, .v, .vhd等）
- **智能语言检测**：根据文件扩展名自动识别文件类型和语言
- **自动顶层模块检测**：智能分析模块名称，自动设置设计和仿真顶层模块
- **依赖关系分析**：自动检测项目中的IP核依赖关系
- **智能IP生成**：根据检测到的依赖自动生成优化的IP核配置

### 🛠️ 智能IP核生成
- **BRAM优化配置**：根据数据位宽和深度自动选择最优的BRAM配置
- **参数化设计**：支持不同数据位宽和深度的BRAM配置
- **避免重复生成**：自动检查已存在的IP核，避免重复生成

### 📊 项目验证和统计
- **完整性验证**：自动检查项目的完整性和潜在问题
- **详细统计**：提供项目文件、类型、IP核等详细统计信息
- **状态检查**：验证IP核状态和项目配置

### 🎯 用户友好
- **详细日志**：提供清晰的执行过程和结果反馈
- **错误处理**：优雅处理文件不存在等异常情况
- **下一步指导**：提供明确的后续操作建议

## 文件结构
```
MF_project/
├── src/
│   ├── MeanFilter.sv         # 主滤波器模块
│   └── LineBuf.sv            # 行缓冲模块
├── sim/
│   └── tb_MF.sv              # 测试台
├── create_meanfilter_project.tcl   # 🆕 项目创建脚本（分离式）
├── run_meanfilter_build.tcl        # 🆕 构建脚本（分离式）
├── create_meanfilter_auto.tcl      # 完整自动化脚本（包含综合和仿真）
├── create_project.tcl        # 完整项目创建脚本（包含BRAM IP生成）
├── generate_multiple_bram_ip.tcl  # 多种BRAM IP生成脚本
├── run_setup.bat             # Windows运行脚本
├── run_setup.sh              # Linux运行脚本
├── cleanup.bat               # Windows清理脚本
├── cleanup.sh                # Linux清理脚本
├── TCL_USAGE_GUIDE.md        # 🆕 TCL脚本使用指南
└── README.md                 # 本说明文件
```

## 自动化功能详解

### 1. 自动文件扫描
脚本会自动扫描以下目录和文件类型：
- `src/` - 设计源文件
- `sim/` - 仿真文件  
- `constraints/` - 约束文件
- `rtl/`, `hdl/`, `design/` - 额外的设计文件目录
- `testbench/`, `tb/` - 额外的测试文件目录

支持的文件类型：
- `.sv` - SystemVerilog
- `.v` - Verilog
- `.vhd`, `.vhdl` - VHDL
- `.vh`, `.svh` - 头文件
- `.xci` - IP核文件
- `.bd` - 块设计文件

### 2. 智能顶层模块检测
脚本会自动分析源文件中的模块定义，并根据以下规则选择顶层模块：

**设计源文件顶层模块选择规则：**
1. 优先选择包含关键词的模块：`top`, `main`, `filter`, `processor`
2. 避免选择测试相关的模块：`tb`, `test`, `bench`
3. 如果没有明确的候选，选择第一个非测试模块

**仿真源文件顶层模块选择规则：**
1. 优先选择包含测试关键词的模块：`tb`, `test`, `bench`
2. 如果没有找到测试模块，选择第一个可用模块

### 3. 智能IP核生成
脚本会：
1. 分析源文件中的IP核实例化
2. 检测BRAM相关的模块名称
3. 自动解析位宽和深度配置
4. 根据参数选择最优的BRAM配置：
   - 深度≤512：使用单端口RAM
   - 深度>512：使用双端口RAM
   - 位宽≥32：启用字节写使能

### 4. 项目验证
脚本会自动检查：
- ✅ 设计源文件是否存在
- ✅ 顶层模块是否正确设置
- ✅ IP核状态是否正常
- ⚠️ 仿真文件和约束文件（非必需）

## 使用方法

### 推荐使用方法：分离式TCL脚本

我们提供了分离式TCL脚本，将工程创建和构建过程分离，提供更好的模块化和灵活性：

#### 方法1：使用shell脚本（推荐）
```bash
./run_meanfilter.sh
```

#### 方法2：手动执行两个步骤
```bash
# 步骤1：创建项目
vivado -mode tcl -source create_meanfilter_project.tcl

# 步骤2：构建项目 (综合和仿真)
vivado -mode tcl -source run_meanfilter_build.tcl
```

#### 优势：
- **模块化**: 项目创建和构建分离，便于维护
- **重用性**: 可以重复运行构建脚本而无需重新创建项目
- **灵活性**: 可以只运行项目创建部分，然后在GUI中手动构建
- **调试友好**: 构建失败时只需重新运行构建脚本

详细说明请参考：[`TCL_USAGE_GUIDE.md`](TCL_USAGE_GUIDE.md)

### 其他可用脚本（高级用户）

如果您需要使用其他版本的脚本，以下选项仍然可用：

#### 完整自动化脚本（包含综合和仿真）
```bash
vivado -mode tcl -source create_meanfilter_auto.tcl
```

#### 根据Vivado版本选择的脚本

##### Vivado 2021.1
```bash
vivado -mode tcl -source create_project_v2021.tcl
```

##### Vivado 2019.2-2022.x
```bash
vivado -mode tcl -source create_project.tcl
```

##### 简单测试版本
```bash
vivado -mode tcl -source create_project_simple.tcl
```

### 使用便捷运行脚本

**Windows用户：**
```cmd
run_setup.bat
```

**Linux用户：**
```bash
./run_setup.sh
```

### 在Vivado GUI中运行
1. 启动Vivado
2. 在TCL Console中运行：
   ```tcl
   # 对于Vivado 2021.1
   source create_project_v2021.tcl
   
   # 对于其他版本
   source create_project.tcl
   ```

## 版本兼容性说明

### Vivado 2021.1特殊问题
- **`try` 命令不支持**: 使用 `catch` 命令替代
- **某些属性配置限制**: 简化了配置选项
- **文件类型设置**: 使用更保守的设置方法

### 不同版本的脚本
- **`create_project_v2021.tcl`**: 专门为Vivado 2021.1优化
- **`create_project.tcl`**: 适用于较新版本的Vivado
- **`create_project_simple.tcl`**: 简化版本，适用于所有版本

## BRAM IP配置说明
生成的BRAM IP核 `BRAM_32x8192` 具有以下特性：
- 类型：True Dual Port RAM
- 端口A/B位宽：32位
- 深度：8192
- 无输出寄存器
- 支持同时读写

## 参数说明
在使用前，请根据你的开发板修改以下参数：

### 器件型号
在TCL脚本中修改 `part_name` 变量：
```tcl
set part_name "xc7z020clg400-2"  # 根据你的开发板修改
```

常见器件型号：
- Zynq-7000: `xc7z020clg400-2`
- Kintex-7: `xc7k325tffg676-2`
- Virtex-7: `xc7v585tffg1761-2`

### 滤波器参数
在 `MeanFilter.sv` 中可以修改：
- `DATA_WIDTH`: 数据位宽（默认8位）
- `WINDOW_SIZE`: 滤波窗口大小（默认3x3）
- `FRAME_WIDTH`: 帧宽度（默认640）
- `FRAME_HEIGHT`: 帧高度（默认512）

## 仿真运行
项目创建完成后，可以在Vivado中：
1. 点击"Run Simulation" -> "Run Behavioral Simulation"
2. 或在TCL Console中运行：
   ```tcl
   launch_simulation
   ```

## 综合与实现
```tcl
# 运行综合
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# 运行实现
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# 生成比特流
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
```

## 约束文件
脚本会自动生成基本的时序约束文件 `constraints/timing.xdc`，包含：
- 时钟约束
- 输入延迟约束
- 输出延迟约束

请根据实际需求修改约束文件。

## 注意事项
1. 确保Vivado版本支持所选器件
2. 根据实际使用的开发板修改器件型号
3. 如果需要修改BRAM配置，请相应修改TCL脚本中的参数
4. 在实际使用中，可能需要添加额外的约束文件

## 项目清理

当你需要清理项目生成的文件时，可以使用清理脚本：

**Windows用户：**
```cmd
cleanup.bat
```

**Linux用户：**
```bash
./cleanup.sh
```

这些脚本会删除：
- 生成的项目文件夹
- IP核文件
- 约束文件
- 临时文件和日志
- Vivado缓存文件

## 故障排除

### 常见问题及解决方案

#### 1. target_language配置错误
```
ERROR: [Common 17-162] Invalid option value specified for 'value'.
```
**解决方案**: 脚本已经包含了兼容性处理，会自动尝试不同的语言设置。

#### 2. IP核创建失败
如果遇到IP核创建问题，请检查：
- Vivado版本是否支持所需的IP核
- 器件是否支持该IP核
- 是否有足够的许可证

#### 3. 文件添加失败
确保：
- 文件路径正确
- 文件确实存在
- 没有权限问题

#### 4. 脚本测试
使用简化版本测试基本功能：
```bash
vivado -mode tcl -source create_project_simple.tcl
```

#### 5. 详细故障排除指南
查看 `TROUBLESHOOTING.md` 文件获取完整的故障排除指南。

### 支持的Vivado版本
- 2019.1及以上版本
- 2020.x系列
- 2021.x系列
- 2022.x系列

### 兼容性检查
运行兼容性检查脚本：
```bash
vivado -mode tcl -source vivado_compatibility_check.tcl
```

## 故障排除
如果遇到问题，请检查：
1. Vivado版本是否支持目标器件
2. 文件路径是否正确
3. 是否有足够的磁盘空间
4. 器件型号是否正确

## 联系信息
如有问题，请查看Vivado用户手册或联系技术支持。
