"""simulator: 仿真执行管理"""

import os
import subprocess
from .config import Config
from .utils import Logger, create_dir, seed_gen


class Simulator:
    """VCS 仿真管理器"""

    def __init__(self, config: Config, logger: Logger, args):
        self.cfg = config
        self.log = logger
        self.args = args
        self.base_opts = []
        self.results = []

    def get_base_opts(self):
        """获取基础仿真选项"""
        self.base_opts = []
        sim_base_file = os.path.join(self.cfg.cfg_home, "sim_base.cfg")

        if not os.path.isfile(sim_base_file):
            self.base_opts = [
                '-l sim.log',
                '+UVM_VERBOSITY=UVM_MEDIUM',
                '+UVM_TIMEOUT="100000000ps,YES"',
                '+fsdb+all',
                '+vcs+ignorestop', '+vcs+loopreport+2', '+vcs+loopdetect',
                '-reportstats',
                '+RANDOM_SEED=1 +ntb_random_seed=1',
            ]
        else:
            self._read_cfg_file(sim_base_file)

        if self.args.cov:
            cov_file = os.path.join(self.cfg.cfg_home, "coverage.cfg")
            if not os.path.isfile(cov_file):
                self.base_opts.append('-cm line+cond+fsm+tgl+branch+assert')
            else:
                self._read_cfg_file(cov_file)

        if self.args.simcfg:
            self._read_cfg_file(os.path.join(self.cfg.tb_home, self.args.simcfg))

    def run(self, simv_dir, sim_dir, group_name, test_name, test_info):
        """执行单个仿真"""
        self.get_base_opts()

        uvm_test = test_info.get('uvm_testname', test_name)
        sim_cmd = [f'{simv_dir}/simv']
        sim_cmd.append(f'+UVM_TESTNAME={uvm_test}')

        # Coverage directory
        if self.args.cov:
            cov_dir = os.path.join(self.cfg.coverage_result_dir, group_name, f"{test_name}.vdb")
            sim_cmd.append(f'-cm dir {cov_dir}')

        for opt in self.base_opts:
            sim_cmd.append(opt)

        sim_cmd.append(test_info.get('sim_args', ''))

        # FSDB dump
        os.environ['MY_FSDB_DUMP'] = 'on' if self.args.fsdb else 'off'

        # Waveform TCL
        tcl_file = test_info.get('tcl', '${VERIFY_HOME}/tcl/wave.tcl')
        if self.args.wavetcl:
            tcl_file = '${VERIFY_HOME}/' + self.args.wavetcl
        sim_cmd.append(f'-ucli -do {tcl_file}')

        sim_cmd_str = " \\\n".join(sim_cmd)
        self.log.log(sim_cmd_str, True)

        os.chdir(sim_dir)
        try:
            result = subprocess.run(sim_cmd_str, shell=True,
                                    capture_output=True, text=True, timeout=7200)
            if result.returncode != 0:
                self.log.warn(f"Simulation exited with code {result.returncode}")
        except subprocess.TimeoutExpired:
            self.log.error(f"Simulation timed out: {test_name}")

        # Write simulation options for reference
        opt_file = os.path.join(sim_dir, "simulation.opt")
        with open(opt_file, "w") as f:
            for opt in self.base_opts:
                f.write(f"{opt}\n")

        return self._check_result(sim_dir, test_name)

    def _check_result(self, sim_dir, test_name):
        """检查仿真日志结果"""
        logfile = os.path.join(sim_dir, "sim.log")
        seed = self.args.seed or "random"

        if not os.path.isfile(logfile):
            return {"test": test_name, "seed": seed, "status": "EXCEPTION", "reason": "no log"}

        with open(logfile, "r") as f:
            content = f.read()

        has_fatal   = "UVM_FATAL" in content
        has_error   = "UVM_ERROR" in content
        has_passed  = "UVM TEST PASSED" in content
        has_failed  = "UVM TEST FAILED" in content
        has_timeout = "UVM TIMEOUT" in content

        if has_timeout:
            return {"test": test_name, "seed": seed, "status": "FAIL", "reason": "TIMEOUT"}
        elif has_fatal:
            return {"test": test_name, "seed": seed, "status": "FAIL", "reason": "FATAL"}
        elif has_error:
            return {"test": test_name, "seed": seed, "status": "FAIL", "reason": "ERROR"}
        elif has_failed and not has_passed:
            return {"test": test_name, "seed": seed, "status": "FAIL", "reason": "FAILED"}
        elif has_passed:
            return {"test": test_name, "seed": seed, "status": "PASS", "reason": ""}
        else:
            return {"test": test_name, "seed": seed, "status": "EXCEPTION", "reason": "incomplete"}

    def _read_cfg_file(self, filepath):
        try:
            with open(filepath, 'r') as f:
                for line in f:
                    s = line.strip()
                    if s and not s.startswith("//") and not s.startswith("#"):
                        self.base_opts.append(s)
        except FileNotFoundError:
            self.log.warn(f"Config file not found: {filepath}")
