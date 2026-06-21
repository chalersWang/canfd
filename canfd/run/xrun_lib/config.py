"""config: 环境变量与路径配置"""

import os


class Config:
    """CAN FD 验证环境配置"""

    def __init__(self, debug=False):
        self.debug = debug
        self._setup_env()
        self._setup_paths()

    def _setup_env(self):
        """设置环境变量，缺失时使用 fallback 默认值"""
        env_defaults = {
            "VERIFY_HOME":   os.getcwd(),
            "TESTPLAN_HOME": os.path.join(os.getcwd(), "testplan"),
            "TOOLS_HOME":    os.path.join(os.getcwd(), "tools"),
            "VCS_HOME":      os.path.join(os.getcwd(), "vcs"),
            "VERDI_HOME":    os.path.join(os.getcwd(), "verdi"),
        }
        for var, default in env_defaults.items():
            if var not in os.environ:
                if self.debug:
                    print(f"[WARN] {var} not set, using: {default}")
                os.environ[var] = default

        self.tb_home       = os.environ["VERIFY_HOME"]
        self.testplan_home = os.environ["TESTPLAN_HOME"]

    def _setup_paths(self):
        """派生路径"""
        self.build_home          = os.path.join(self.tb_home, "build")
        self.cfg_home            = os.path.join(self.tb_home, "cfg")
        self.filelist_home       = os.path.join(self.tb_home, "filelist")
        self.coverage_home       = os.path.join(self.tb_home, "coverage")
        self.coverage_result_dir = os.path.join(self.coverage_home, "coverage_result")
