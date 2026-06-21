# CAN FD IP 验证环境架构文档

> CAN FD Controller UVM Verification Environment
>
> 基于 AMD/Xilinx PG223 v3.0 规范 | UVM 1.2 | SystemVerilog | VCS/Verdi
>
> 日期: 2026-06-21

---

## 1. 概述

本验证环境用于验证 **CAN FD Controller IP**（CAN Flexible Data-Rate），基于 UVM 1.2 标准构建。环境采用分层架构，包含 3 个 UVC 组件（CANPHY、AXI4-Lite、UCSPI），7 大测试组共 80+ 个定向和随机测试用例，支持覆盖率驱动验证（CDV）和持续集成（Jenkins Pipeline）。

### 验证目标

- CAN 2.0 / CAN FD 协议帧收发正确性
- AXI4-Lite 寄存器接口功能
- 错误检测与处理（错误帧、错误计数器、Bus-Off 等）
- 工作模式切换（Normal / Loopback / Sleep / Snoop）
- 接收滤波器（标准/扩展 ID、掩码、独立滤波器）
- TX Buffer / RX FIFO 管理
- 时序参数（TDC、BRS、ESI 等）
- 跨时钟域（CDC）与复位

---

## 2. 目录结构

```
canfd/
├── ARCHITECTURE.md          ← 本架构文档
├── readme                   ← 使用说明（运行命令）
├── SourceMe                 ← 环境变量设置脚本
├── Jenkinsfile              ← CI/CD Pipeline
├── promt.md                 ← 项目/提示文档
│
├── tb/                      ← 测试平台顶层
│   ├── tb_top.sv            ← UVM 测试平台顶层模块
│   ├── crg_gen.sv           ← 时钟/复位生成
│   ├── dutinst.sv           ← DUT 实例化
│   ├── uvmconfigdb.sv       ← UVM Config DB 接口设置
│   └── dumpctrl.sv          ← 波形 dump 控制
│
├── testcase/                ← 测试用例层
│   ├── canfd_TestTop.svh    ← TestTop Package
│   ├── canfd_base_test.sv   ← 基础测试类
│   └── sequence_lib/        ← 序列库
│       ├── canfd_sequence_lib.sv
│       ├── canfd_common_task_function.sv
│       └── gen_testcases.py
│
├── env/                     ← 环境层 (Environment Layer)
│   ├── canfd_EnvTop.svh     ← EnvTop Package
│   ├── canfd_env.sv         ← UVM env 组件
│   ├── canfd_config.sv      ← 全局配置对象
│   ├── canfd_event.sv       ← 全局事件同步
│   ├── canfd_ref_model.sv   ← 参考模型 (C 模型)
│   ├── canfd_scoreboard.sv  ← 计分板 (比对 + 统计)
│   ├── canfd_virtual_sequencer.sv ← 虚拟 Sequencer
│   └── canfd_function_coverage.sv  ← 功能覆盖率封装
│
├── uvc/                     ← UVC 组件层 (Universal Verification Components)
│   ├── canphy/              ← CAN PHY UVC (总线物理层)
│   │   ├── canphy_UvcTop.svh
│   │   ├── canphy_agent.sv / driver.sv / monitor.sv
│   │   ├── canphy_sequencer.sv / sequence_lib.sv
│   │   ├── canphy_trans.sv / config.sv / vif.sv
│   ├── axi4lite/            ← AXI4-Lite UVC (主机寄存器接口)
│   │   ├── axi4lite_UvcTop.svh
│   │   ├── axi4lite_agent.sv / driver.sv / monitor.sv
│   │   ├── axi4lite_sequencer.sv / sequence_lib.sv
│   │   ├── axi4lite_trans.sv / config.sv / vif.sv
│   └── ucspi/               ← UCSPI UVC (串行外设接口)
│       ├── ucspi_UvcTop.svh
│       ├── ucspi_agent.sv / driver.sv / monitor.sv
│       ├── ucspi_sequencer.sv / sequence_lib.sv
│       ├── ucspi_trans.sv / config.sv / vif.sv
│
├── regmodel/                ← 寄存器模型层
│   ├── canfd_reg_block.sv   ← 寄存器 Block (27 寄存器, PG223 v3.0)
│   ├── canfd_reg_adapter.sv ← 寄存器 Adapter (AXI4-Lite ↔ reg 转换)
│   ├── canfd_reg_sequence.sv← 寄存器访问 Sequence
│   └── canphy_reg_adapter.sv← CANPHY 寄存器 Adapter
│
├── sva/                     ← SVA 断言层
│   ├── canfd_vif.sv         ← 顶层 Virtual Interface
│   ├── define_lib.v         ← 宏定义库
│   ├── VifMacroDefine.v     ← Interface 宏定义
│   └── code/                ← 断言代码
│       ├── sva_tb_top.sv    ← TB 顶层断言
│       ├── sva_vif_top.sv   ← 顶层接口断言
│       ├── sva_vif_canphy.sv← CANPHY 接口断言
│       └── sva_vif_ucspi.sv ← UCSPI 接口断言
│
├── coverage/                ← 覆盖率层
│   └── code/
│       ├── canfd_function_coverage.sv   ← CANFD 功能覆盖率
│       ├── canphy_function_coverage.sv  ← CANPHY 功能覆盖率
│       ├── axi4lite_function_coverage.sv← AXI4-Lite 功能覆盖率
│       ├── ucspi_function_coverage.sv   ← UCSPI 功能覆盖率
│       ├── Guide.Coverage_coding.sv     ← 覆盖率编码规范
│       └── CoverageHierarchy.lst        ← 覆盖率层次结构
│
├── testplan/                ← 测试计划层（7 组）
│   ├── T1_group/            ← T1: 基础功能 (CEN/定时/非法访问)
│   ├── T2_group/            ← T2: 基本通信 (TX/RX/仲裁)
│   ├── T3_group/            ← T3: FD 帧 (BRS/ESI/FDF)
│   ├── T4_group/            ← T4: TX Buffer 管理
│   ├── T5_group/            ← T5: 接收 FIFO/滤波器
│   ├── T6_group/            ← T6: 错误处理/错误计数器
│   └── T7_group/            ← T7: 特殊功能 (TDC/TSR/模式/中断)
│  每组包含: cmodel.f, rtl.f, tb.f, vip.f, test.json
│
├── filelist/                ← 文件列表
│   ├── rtl.f / tb.f / vip.f / cmodel.f / netlist.f
│
├── cfg/                     ← 仿真配置文件
│   ├── comp_base.cfg        ← 编译基础配置
│   ├── sim_base.cfg         ← 仿真基础配置
│   ├── assertion.cfg        ← 断言配置
│   ├── coverage.cfg         ← 覆盖率配置
│   ├── debug.cfg            ← 调试配置
│   ├── xprop.cfg            ← X-propagation 配置
│   └── partitioncompile_cfg.v ← 分块编译配置
│
├── run/                     ← 运行基础设施 (Python)
│   ├── xrun                 ← 主入口脚本
│   ├── run                  ← 运行引导脚本
│   ├── regression.py        ← 回归测试脚本
│   ├── gen_dashboard.py     ← Dashboard 生成
│   ├── verify_report_template.md ← 报告模板
│   └── xrun_lib/            ← 运行库
│       ├── compiler.py      ← 编译模块
│       ├── simulator.py     ← 仿真模块
│       ├── config.py        ← 配置模块
│       ├── coverage.py      ← 覆盖率模块
│       ├── kfile.py         ← 文件列表解析
│       └── utils.py         ← 工具函数
│
├── tcl/                     ← TCL 脚本
│   └── wave.tcl             ← 波形配置
│
├── json/                    ← JSON 配置
│   ├── canfd_VerifyPlan.xlsx← 验证计划
│   └── excel_to_json.py     ← Excel → JSON 转换
│
└── reference/               ← 参考数据
```

---

## 3. 架构层次图

```
┌─────────────────────────────────────────────────────────────┐
│                      CI/CD Layer                             │
│  Jenkinsfile (Pipeline: compile → simulate → merge cov)    │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Run Infrastructure                      │
│  xrun (Python): compile/sim/regression/coverage/dashboard  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Test Layer                              │
│  canfd_TestTop Package                                       │
│  ├── canfd_base_test (基础测试)                               │
│  ├── canfd_sequence_lib (序列库)                              │
│  ├── canfd_reg_sequence (寄存器序列)                           │
│  └── 80+ testcases (B/C/E/I/M/R/S/T 系列)                 │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    Environment Layer                          │
│  canfd_EnvTop Package                                        │
│  ├── canfd_env          ← UVM env (顶层容器)                  │
│  ├── canfd_config       ← 全局配置 (config_db 传递)           │
│  ├── canfd_event        ← 全局事件同步                         │
│  ├── canfd_virtual_sequencer ← 虚拟 Sequencer                 │
│  ├── canfd_scoreboard   ← 计分板 (比对 + 覆盖率采样)          │
│  └── canfd_ref_model    ← 参考模型 (寄存器状态 + TX 期望帧)    │
└─────────────────────────────────────────────────────────────┘
                            │
     ┌──────────────────────┼──────────────────────┐
     ▼                      ▼                      ▼
┌──────────┐    ┌──────────────┐    ┌──────────┐
│ CANPHY   │    │ AXI4-Lite    │    │ UCSPI    │
│ UVC      │    │ UVC          │    │ UVC      │
│ (总线侧)  │    │ (主机寄存器侧)│    │ (SPI侧)  │
│          │    │              │    │          │
│ Agent    │    │ Agent        │    │ Agent    │
│ ├─Driver │    │ ├─Driver     │    │ ├─Driver │
│ ├─Monitor│    │ ├─Monitor    │    │ ├─Monitor│
│ └─Seqr   │    │ └─Seqr       │    │ └─Seqr   │
└──────────┘    └──────────────┘    └──────────┘
     │                      │              │
     ▼                      ▼              ▼
┌─────────────────────────────────────────────────┐
│              Virtual Interface Layer              │
│  canfd_vif ← { axi4lite_vif, canphy_vif }      │
└─────────────────────────────────────────────────┘
     │                      │              │
     ▼                      ▼              ▼
┌─────────────────────────────────────────────────┐
│                 DUT (CAN FD IP)                   │
└─────────────────────────────────────────────────┘
```

---

## 4. 核心组件详解

### 4.1 测试平台顶层 (`tb/tb_top.sv`)

```systemverilog
module tb_top;
    import uvm_pkg::*;
    import canfd_TestTop::*;
    `include "crg_gen.sv"       // 时钟复位生成
    `include "uvmconfigdb.sv"   // config_db 接口设置
    `include "dutinst.sv"       // DUT 例化 + 连接
    `include "dumpctrl.sv"      // 波形 dump 控制
endmodule
```

- `crg_gen.sv` — 通过 Clock_Reset_Generater 组件生成时钟和复位
- `uvmconfigdb.sv` — 将 virtual interface 注册到 uvm_config_db
- `dutinst.sv` — 绑定 DUT 信号到 canfd_vif，实例化 SVA
- `dumpctrl.sv` — 控制 VPD/FSDB dump

### 4.2 测试用例层 (`testcase/`)

#### canfd_base_test — 所有测试的基类

| Phase | 职责 |
|-------|------|
| `build_phase` | 创建 env，获取 vif，构建 RegModel |
| `connect_phase` | 连接 RegModel default_map → AXI4 sequencer |
| `end_of_elaboration_phase` | 打印 UVM 拓扑 |
| `run_phase` | 等待复位释放 → 等待稳定 → 子类 override |
| `report_phase` | 打印测试结果摘要 |

#### 测试用例分类 (80+ tests)

| 系列 | 测试内容 | 数量 |
|------|----------|:----:|
| **B** (Basic) | 基础功能: CEN、非法访问、定时、标准/扩展帧、RTR、FD帧、TX Buffer | 19 |
| **C** (Corner) | 边界测试: DLC=0/64、ID=0/11/29、1Mbps/8Mbps、Stress | 11 |
| **E** (Error) | 错误处理: Bit Error、Stuff Error、CRC Error、ACK Error、Form Error、Error Counters | 10 |
| **I** (Interface) | 接口测试: AXI R/W/Handshake/Error、CDC、复位延迟 | 9 |
| **M** (Mode) | 模式测试: Normal/Loopback/Sleep/Snoop/MUX、Bus-Off | 9 |
| **R** (RX) | 接收测试: FIFO深度/溢出/水位线/释放、滤波器 标准/扩展/掩码/独立 | 9 |
| **S** (Special) | 特殊功能: TSR、TDC | 4 |
| **T** (Register) | 寄存器测试: RW/SRST/Addr/Write Protect、Interrupt Trigger/Mask/Clear/Level | 9 |

### 4.3 环境层 (`env/`)

#### canfd_env — 顶层容器

```
canfd_env (uvm_env)
├── canfd_config               ← 全局配置 (config_db)
├── canfd_event                ← 事件池同步
├── canfd_virtual_sequencer    ← 虚拟 Sequencer
│   ├── canphy_seqr (handle)
│   └── axi4lite_seqr (handle)
├── canfd_scoreboard           ← 计分板
│   ├── canfd_ref_model        ← 参考模型
│   ├── canphy_analysis_fifo   ← CAN PHY 双向 FIFO
│   ├── canphy_tx_analysis_fifo← TX 方向 FIFO
│   ├── canphy_rx_analysis_fifo← RX 方向 FIFO
│   ├── axi4lite_analysis_fifo ← AXI4-Lite FIFO
│   └── [canphy_cov / axi4lite_cov]  ← 功能覆盖率
├── canphy_agent               ← CAN PHY Agent (总线侧)
├── axi4lite_agent             ← AXI4-Lite Agent (主机侧)
└── [RegModel]                 ← 寄存器模型 (可选, REG_MODEL)
```

#### canfd_scoreboard — 计分板（核心比对引擎）

**架构**：双 FIFO 并行处理 + Reference Model

```
                    ┌─────────────────────┐
  canphy_monitor ──▶│ canphy_tx_analysis  │──▶ process_tx_frame()
                    │       _fifo         │      ├─ canphy_cov.sample()
                    ├─────────────────────┤      ├─ 获取期望帧 (ref_model)
                    │ canphy_rx_analysis  │──▶ process_rx_frame()
                    │       _fifo         │      ├─ canphy_cov.sample()
                    ├─────────────────────┤      └─ ref_model.on_can_frame_received()
  axi4lite_monitor─▶│ axi4lite_analysis   │──▶ process_axi4lite_tr()
                    │       _fifo         │      ├─ axi4lite_cov.sample()
                    └─────────────────────┘      ├─ write: ref_model.write_reg()
                                                 └─ read: 比对 vs ref_model.read_reg()
```

**比对策略**：
- **TX 帧比对**：参考模型生成期望帧 → 与 DUT 实际发送帧逐字段比对（frame_type、can_id、dlc、fdf、brs、data[]）
- **AXI 读比对**：所有寄存器值由 ref_model 建模（v2.0 不再跳过任何寄存器），任何差异都是真实的 mismatch
- **AXI 响应检查**：非法地址 → 期望 DECERR，合法地址 → 期望 OKAY

#### canfd_ref_model — 参考模型

- 维护 CAN FD 控制器的所有寄存器状态
- `write_reg(addr, data)` — 写寄存器更新内部状态
- `read_reg(addr)` — 返回期望的读回值
- `write_tx_buf(idx, offset, data)` — 写入 TX Buffer
- `get_expected_tx_frame()` — 返回期望 DUT 发送的 CAN 帧
- `process_tx_arbitration()` — 处理 TX 仲裁
- `on_can_frame_received(tr)` — 更新接收侧状态
- `tick()` — 时间戳更新（每个 clk posedge）

### 4.4 UVC 层 (`uvc/`)

每个 UVC 遵循标准的 UVM Agent 架构：

```
<name>_UvcTop (Package)
├── <name>_config        ← 配置对象
├── <name>_trans         ← Transaction 对象
├── <name>_driver        ← Driver (seq_item_port → vif 驱动)
├── <name>_monitor       ← Monitor (vif 采样 → analysis_port)
├── <name>_sequencer     ← Sequencer
├── <name>_agent         ← Agent (封装 driver + monitor + sequencer)
├── <name>_sequence_lib  ← 基础 Sequence 库
└── <name>_vif           ← SystemVerilog Interface
```

| UVC | 方向 | 协议 |
|-----|------|------|
| **canphy** | 总线侧 | CAN 2.0 / CAN FD 物理层 |
| **axi4lite** | 主机侧 | AXI4-Lite 32-bit |
| **ucspi** | SPI 侧 | UCSPI 串行外设接口 |

---

## 5. 数据流

```
                    ┌──────────────────────────────┐
                    │        Virtual Sequencer      │
                    │  canphy_seqr  axi4lite_seqr  │
                    └──────────┬───────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │ canphy_seqr  │   │axi4lite_seqr │   │  ucspi_seqr  │
   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
          ▼                    ▼                    ▼
   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │canphy_driver │   │axi4lite_drv  │   │ ucspi_driver │
   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
          ▼                    ▼                    ▼
   ┌─────────────────────────────────────────────────────────┐
   │                      canfd_vif                          │
   │  axi4lite_vif(clk, rstn)    canphy_vif(clk, rstn)      │
   └──────────────────────────┬──────────────────────────────┘
                              ▼
   ┌─────────────────────────────────────────────────────────┐
   │                   DUT (CAN FD IP)                       │
   └─────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │canphy_monitor│   │axi4lite_mon  │   │ ucspi_monitor│
   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
          │                   │                   │
          │  canphy_trans     │  axi4lite_trans   │
          ▼                   ▼                   ▼
   ┌─────────────────────────────────────────────────────────┐
   │              canfd_scoreboard (TLM Analysis FIFOs)       │
   │                                                         │
   │  TX帧 → compare_tx_frame(exp, act)  ← ref_model.get_expected_tx_frame()
   │  RX帧 → ref_model.on_can_frame_received(tr)             │
   │  AXI  → ref_model.write_reg() / read_reg() + compare    │
   └─────────────────────────────────────────────────────────┘
```

---

## 6. 运行流程

### 6.1 命令使用

```bash
# 环境初始化
source SourceMe

# 列出所有用例
run/xrun -l

# 单用例编译
run/xrun -g T1_group -t canfd_B_01_01_cen_test -c

# 单用例仿真
run/xrun -g T1_group -t canfd_B_01_01_cen_test -s

# 带 FSDB 波形 + 指定 Seed
run/xrun -g T1_group -t canfd_B_01_01_cen_test -s --fsdb --seed=1

# 全组编译 + 仿真 + 重复 10 次
run/xrun -g T1_group -c
run/xrun -g T1_group -s -n 10

# 覆盖率
run/xrun -g T1_group -c --cov
run/xrun -g T1_group -s --cov -n 10
xrun --covmerge      # 合并覆盖率
xrun --opencov       # 打开覆盖率

# 回归 + 邮件通知
run/xrun -g T1_group -s -m
```

### 6.2 xrun 内部流程

```
xrun (Python)
├── GetArgs()        ← 解析命令行参数
├── GetEnv()         ← 读取环境变量 (VERIFY_HOME, VCS_HOME, etc.)
├── GetTestcaseList()← 读取 test.json 生成用例列表
├── Compile:         ← vcs -f rtl.f -f vip.f -f tb.f ...
├── Simulate:        ← ./simv +UVM_TESTNAME=xxx +seed=xxx ...
├── Coverage:
│   ├── --covmerge   ← urg -dir cov_work/xxx -dbname cov_merge
│   └── --opencov    ← dve -full64 -cov -dir cov_merge.vdb
└── Report:
    ├── 生成 verify_report.md
    └── 邮件通知 (--mail)
```

---

## 7. SVA 断言体系

```
sva/
├── define_lib.v         ← `define REG_ADDR_xxx 等宏定义
├── VifMacroDefine.v     ← Interface 实例化宏
├── canfd_vif.sv         ← 顶层 virtual interface (含 axi4lite_vif + canphy_vif)
└── code/
    ├── sva_tb_top.sv    ← TB 顶层: 跨模块协议断言
    ├── sva_vif_top.sv   ← 顶层接口: 时钟/复位 / X/Z 检测
    ├── sva_vif_canphy.sv← CAN PHY 接口: 总线时序、协议合规
    └── sva_vif_ucspi.sv ← UCSPI 接口: SPI 时序、片选/数据
```

---

## 8. 功能覆盖率体系

| 覆盖率模块 | 覆盖目标 |
|-----------|----------|
| **canfd_function_coverage** | CAN FD 帧格式、DLC、BRS、ESI、FDF 交叉 |
| **canphy_function_coverage** | CAN 总线: 帧类型、ID、数据长度、错误类型 |
| **axi4lite_function_coverage** | AXI 读写、地址空间、响应码、HS 握手 |
| **ucspi_function_coverage** | SPI 模式、CPOL/CPHA、波特率、数据位宽 |

覆盖率通过 `ifdef COVERAGE_xxx` 条件编译控制。

---

## 9. 寄存器模型

基于 **PG223 v3.0** 规范，共 **27 个寄存器**：

| 地址 | 寄存器 | 说明 |
|:----:|--------|------|
| 0x0000 | SRR | Software Reset / CEN |
| 0x0004 | MSR | Mode Status (LBACK/SLEEP/SNOOP/CEN/SRST) |
| 0x0008 | BRPR | Baud Rate Prescaler |
| 0x000C | BTR | Bit Timing (TS1/TS2/SJW) |
| 0x0010 | ECR | Error Counter (REC/TEC) |
| 0x0014 | ESR | Error Status |
| 0x0018 | SR | Status Register |
| 0x001C | ISR | Interrupt Status |
| 0x0020 | IER | Interrupt Enable |
| 0x0024 | ICR | Interrupt Clear |
| 0x0028~0x003C | — | TX/RX 相关寄存器 |
| 0x0040~0x004C | — | FIFO / Watermark 寄存器 |
| 0x0050~0x009C | — | AF (Acceptance Filter) 寄存器 |
| 0x00A0~0x00AC | — | TDC 寄存器 |
| 0x0100~0x1FFF | — | TX Buffer (512 字节) |

通过 `REG_MODEL` 宏控制是否启用寄存器模型。

---

## 10. testplan 测试组结构

每组包含 5 个文件列表：

| 文件 | 内容 |
|------|------|
| `cmodel.f` | C 参考模型文件列表 |
| `rtl.f` | DUT RTL 文件列表 |
| `tb.f` | 测试平台文件列表 (env + uvc + sva + coverage) |
| `vip.f` | VIP 文件列表 |
| `test.json` | 本组测试用例定义 (名称、描述、seed、约束) |

### 7 大测试组 — 用例分布

| 组 | 名称 | 系列 | 数量 |
|:--:|------|------|:----:|
| T1 | 基础功能 | B (CEN/定时/非法访问) | 3 |
| T2 | 基本通信 | B (TX/RX/仲裁) | 7 |
| T3 | FD 帧 | B (BRS/ESI/FDF) | 7 |
| T4 | TX Buffer | B (Full/Cancel/ARET/SSHOT/EVT/WM) | 6 |
| T5 | 接收/滤波器 | R (FIFO/滤波器) + R_03 | 10 |
| T6 | 错误处理 | E (错误帧/错误计数器) + C (Stress/Corner) | 17 |
| T7 | 特殊功能 | S + I + T + M | 38 |

---

## 11. CI/CD (Jenkins Pipeline)

```groovy
pipeline {
    agent { label 'vcs' }
    environment {
        VCS_HOME   = "/tools/synopsys/vcs/vcs-mx-2023.12"
        VERDI_HOME = "/tools/synopsys/verdi/verdi-2023.12"
    }
    parameters {
        choice(name: 'REGRESSION_GROUP', choices: ['all','T1'..'T7'])
        booleanParam(name: 'ENABLE_COVERAGE', defaultValue: true)
        booleanParam(name: 'ENABLE_GLS', defaultValue: false)
    }
    stages {
        stage('Checkout')   { ... }
        stage('Compile')    { ... }  // vcs -f rtl.f -f vip.f -f tb.f
        stage('Simulate')   { ... }  // parallel 每组并行
        stage('Merge Cov')  { ... }  // urg merge
        stage('Report')     { ... }  // gen_dashboard + email
    }
}
```

---

## 12. 依赖关系

```
外部依赖:
├── VCS 2017.12+ / 2023.12    (仿真器)
├── Verdi 2017.12+ / 2023.12  (波形/覆盖率查看)
├── UVM 1.2                   (Methodology)
├── Synopsys VIP              (可选, 用于 UCSPI/APB)
├── Python 3.x                (运行脚本)
│   ├── argparse, json, threading, multiprocessing, smtplib
└── C Model                   (参考模型, filelist/cmodel.f)

内部依赖链:
  uvc/* → env/canfd_EnvTop → testcase/canfd_TestTop → tb/tb_top
  sva/code/* ← sva/VifMacroDefine.v ← sva/define_lib.v
  regmodel/* → env/canfd_EnvTop (ifdef REG_MODEL)
```

---

## 13. 设计特点

1. **方向感知 Scoreboard**：TX/RX 分离，TX 比对期望帧，RX 更新参考模型状态
2. **双模式配置读取**：reg_field 模式（UVM 寄存器模型）vs hdl_path 模式（直接 DUT 信号读取）
3. **可配置覆盖率**：通过宏 COVERAGE_CANPHY / COVERAGE_AXI4LITE 单独控制
4. **可配置寄存器模型**：通过宏 REG_MODEL 控制，支持前门/后门访问
5. **并行回归**：Python multiprocessing 支持 TEST_PARALLEL_NUM=8 并行仿真
6. **分块编译**：partitioncompile_cfg.v 支持增量编译
7. **邮件通知**：回归完成后自动发送结果摘要到配置的邮箱
