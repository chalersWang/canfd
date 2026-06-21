"""
xrun_lib — CAN FD 验证环境模块化工具包

模块:
    config    — 环境变量、路径配置
    compiler  — VCS 编译管理
    simulator — 仿真执行管理
    coverage  — 覆盖率合并与查看
    kfile     — K-file (`ifdef/`else/`endif) 展开器
    utils     — 通用工具 (日志、目录、seed生成)
"""
from .config import Config
from .compiler import Compiler
from .simulator import Simulator
from .coverage import CoverageManager
from .kfile import KFileExpander
from .utils import Logger, create_dir, seed_gen
