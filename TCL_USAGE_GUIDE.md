# MeanFilter Project TCL Scripts Usage Guide

本项目使用分离式 TCL 脚本架构，将工程创建和构建过程分离，提供更好的模块化和灵活性。

## 文件说明

### 1. `create_meanfilter_project.tcl`
- **功能**: 创建 MeanFilter 项目和配置
- **包含内容**:
  - 创建新的 Vivado 项目
  - 添加设计文件 (MeanFilter.sv, LineBuf.sv)
  - 添加仿真文件 (tb_MF.sv)
  - 生成和配置 BRAM IP 核
  - 创建约束文件
  - 设置综合和实现策略
  - 更新编译顺序

### 2. `build.tcl`
- **功能**: 执行综合和仿真
- **包含内容**:
  - 打开现有项目
  - 执行综合
  - 生成综合报告
  - 启动仿真
  - 显示构建结果

## 使用方法

### 推荐方法：使用 Shell 脚本
```bash
./run_meanfilter.sh
```

这个脚本会自动执行以下步骤：
1. 清理现有项目和日志文件
2. 创建新项目
3. 构建项目（综合和仿真）

### 手动执行方法

#### 步骤 1: 创建项目
```bash
vivado -mode tcl -source create_meanfilter_project.tcl
```

#### 步骤 2: 构建项目 (综合和仿真)
```bash
vivado -mode tcl -source build.tcl
```

在 Vivado CLI 中重复运行构建：
```tcl
Vivado% source build.tcl
# 第一次运行 - 执行综合和仿真

Vivado% source build.tcl
# 第二次运行 - 重新运行综合和仿真
# 脚本会自动检测项目状态并智能处理

Vivado% source build.tcl
# 第三次运行 - 继续重复运行
```
### 在 Vivado GUI 中使用
1. 打开 Vivado
2. 在 Tcl Console 中运行：
   ```tcl
   source create_meanfilter_project.tcl
   source build.tcl
   ```

## 优势

1. **模块化**: 项目创建和构建过程分离，便于维护
2. **重用性**: 可以重复运行构建脚本而无需重新创建项目
3. **灵活性**: 可以只运行项目创建部分，然后在 GUI 中手动构建
4. **调试友好**: 如果构建失败，可以只重新运行构建脚本
5. **清晰的错误处理**: 每个步骤都有详细的状态检查和错误报告

## 注意事项

- 确保在运行构建脚本之前已经创建了项目
- 构建脚本会自动检查项目是否存在
- 如果需要重新创建项目，请先删除现有项目文件夹
- 构建过程中会生成详细的综合和仿真报告

## 故障排除

如果遇到问题：
1. 检查 Vivado 版本是否支持目标器件
2. 确认所有源文件都存在
3. 检查项目路径是否正确
4. 查看生成的日志文件获取详细错误信息
