"""compiler: VCS 编译管理"""

import os
import subprocess
import sys
from .config import Config
from .kfile import KFileExpander
from .utils import Logger, create_dir


class Compiler:
    """VCS 编译管理器"""

    def __init__(self, config: Config, logger: Logger, args):
        self.cfg = config
        self.log = logger
        self.args = args
        self.base_opts = []

    def get_base_opts(self):
        """获取基础编译选项"""
        self.base_opts = []
        comp_base_file = os.path.join(self.cfg.cfg_home, "comp_base.cfg")

        if not os.path.isfile(comp_base_file):
            self.base_opts = [
                '-full64', '-l compile.log', '-sverilog', '+v2k',
                '+evalorder', '+vcs+lic+wait',
                '+libext+.sv+.v+V+.vp+vlib', '+systemverilogext+.svh',
                '-ntb_opts uvm-1.2', '+lint=TFIPC-L +lint=PCWM',
                '-timescale=1ns/1ps', '-reportstats',
                '-j4 -kdb -lca', '-debug_all', '+Marchive=1000',
                '+notimingcheck', '+nospecify', '-top tb_top',
                '+define+SYNOPSYS_SV+NTB', '+define+notiming',
                '-P ${VERIFY_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERIFY_HOME}/share/PLI/VCS/LINUX64/pli.a',
                '+warn=noIAVCVF-W', '+warn=noDRTZ',
                '+incdir+${VCS_HOME}/etc/uvm-1.2',
            ]
        else:
            self._read_cfg_file(comp_base_file)

        # Coverage options
        if self.args.cov:
            cov_file = os.path.join(self.cfg.cfg_home, "coverage.cfg")
            if not os.path.isfile(cov_file):
                self.base_opts.append('-cm line+cond+fsm+tgl+branch+assert')
            else:
                self._read_cfg_file(cov_file)

        # Gate-Level Simulation overrides
        if self.args.gls:
            self.log.log("[Compiler] GLS mode enabled", True)
            self.base_opts = [o for o in self.base_opts
                if '+notimingcheck' not in o
                and '+nospecify' not in o
                and '+define+notiming' not in o]
            self.base_opts.append('+define+GATE_SIM')
            self.netlist_file = os.path.join(self.cfg.filelist_home, "netlist.f")

        # Additional compile cfg
        if self.args.compcfg:
            self._read_cfg_file(os.path.join(self.cfg.tb_home, self.args.compcfg))

    def run(self, compile_dir, define_file, vip_file, rtl_file, tb_file, cmodel_file):
        """执行 VCS 编译"""
        self.get_base_opts()

        # Write compile options
        opt_file = os.path.join(compile_dir, "compile.opt")
        with open(opt_file, "w") as f:
            for opt in self.base_opts:
                f.write(f"{opt}\n")

        # Expand K-files
        kf = KFileExpander(self.cfg.filelist_home, self.log)
        kf.expand_all(compile_dir, opt_file)

        # Build VCS command
        cmd = ['vcs'] + self.base_opts

        if define_file:
            cmd.append(f'-file {define_file}')

        # VIP
        if kf.has_vip:
            cmd.append(f'-file {os.path.join(compile_dir, "vip_new.f")}')
        else:
            cmd.append(f'-file {vip_file}')

        # RTL / Netlist
        if self.args.gls and hasattr(self, 'netlist_file'):
            cmd.append(f'-file {self.netlist_file}')
        elif kf.has_rtl:
            cmd.append(f'-file {os.path.join(compile_dir, "rtl_new.f")}')
        else:
            cmd.append(f'-file {rtl_file}')

        # TB
        if kf.has_tb:
            cmd.append(f'-file {os.path.join(compile_dir, "tb_new.f")}')
        else:
            cmd.append(f'-file {tb_file}')

        # C-Model
        if kf.has_cmodel:
            cmd.append(f'-file {os.path.join(compile_dir, "cmodel_new.f")}')
        else:
            cmd.append(f'-file {cmodel_file}')

        compile_cmd = " \\\n".join(cmd)
        self.log.log(compile_cmd, True)

        os.chdir(compile_dir)
        result = subprocess.run(compile_cmd, shell=True,
                                capture_output=True, text=True)
        if result.returncode != 0:
            self.log.error(f"Compile failed:\n{result.stderr[-500:]}")
            raise RuntimeError("VCS compilation failed")

    def _read_cfg_file(self, filepath):
        """读取 cfg 文件内容到 base_opts"""
        try:
            with open(filepath, 'r') as f:
                for line in f:
                    stripped = line.strip()
                    if stripped and not stripped.startswith("//") and not stripped.startswith("#"):
                        self.base_opts.append(stripped)
        except FileNotFoundError:
            self.log.warn(f"Config file not found: {filepath}")
