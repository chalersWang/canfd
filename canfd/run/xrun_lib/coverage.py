"""coverage: 覆盖率合并与查看"""

import os
import subprocess
from .config import Config
from .utils import Logger, get_dirnames, get_filenames


class CoverageManager:
    """覆盖率管理"""

    def __init__(self, config: Config, logger: Logger):
        self.cfg = config
        self.log = logger

    def merge(self):
        """合并所有 group 的覆盖率"""
        self.log.log("[Coverage] Merging...", True)
        vdb_dirs = get_dirnames(self.cfg.coverage_result_dir, '.vdb')

        if not vdb_dirs:
            raise RuntimeError("No VDB directories found for coverage merge")

        for dirname in vdb_dirs:
            vdb_files = get_filenames(
                os.path.join(self.cfg.coverage_result_dir, dirname), '.vdb')
            if not vdb_files:
                raise RuntimeError(f"No VDB files in {dirname}")

            merge_cmd = ["urg", "-full64"]
            for vdb in vdb_files:
                merge_cmd.append(
                    f"-dir {self.cfg.coverage_result_dir}/{dirname}/{vdb}")
            merge_cmd.append(f"-dbname {self.cfg.coverage_result_dir}/{dirname}.vdb")

            cmd_str = " \\\n".join(merge_cmd)
            self.log.log(cmd_str, True)
            subprocess.run(cmd_str, shell=True, check=True,
                          capture_output=True, text=True)

    def open(self, cov_path=None):
        """用 Verdi 打开覆盖率"""
        if cov_path is None:
            cov_path = self.cfg.coverage_result_dir
        cmd = f"verdi -cov -covdir {cov_path} &"
        self.log.log(f"[Coverage] Opening: {cmd}", True)
        subprocess.Popen(cmd, shell=True)
