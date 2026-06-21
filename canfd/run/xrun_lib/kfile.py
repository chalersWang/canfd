"""kfile: K-file (`ifdef/`else/`endif) 展开器

展开 .k 文件中的条件编译指令，输出到 _new.f 文件。
使用栈式 ifdef 展开算法。
"""

import os
import re
from .utils import Logger


class KFileExpander:
    """K-file 条件编译展开器"""

    def __init__(self, filelist_home, logger: Logger):
        self.home = filelist_home
        self.log = logger
        self.has_rtl    = False
        self.has_tb     = False
        self.has_vip    = False
        self.has_cmodel = False

    def expand_all(self, compile_dir, cfg_file):
        """展开所有 K-file"""
        mappings = [
            ("rtl.k",    "rtl_new.f",    "rtl"),
            ("tb.k",     "tb_new.f",     "tb"),
            ("vip.k",    "vip_new.f",    "vip"),
            ("cmodel.k", "cmodel_new.f", "cmodel"),
        ]

        for kfile, newfile, attr in mappings:
            src = os.path.join(self.home, kfile)
            dst = os.path.join(compile_dir, newfile)
            if os.path.isfile(src):
                setattr(self, f"has_{attr}", True)
                self._expand(src, dst, cfg_file)
            else:
                setattr(self, f"has_{attr}", False)

    def _expand(self, src_path, dst_path, cfg_file):
        """展开单个 K-file"""
        with open(src_path, 'r') as f:
            lines = f.readlines()

        # 提取编译选项中的 define
        define_set = self._extract_defines(cfg_file)

        # 栈式 ifdef 展开
        stack = [{"active": True, "had_true": False}]
        result = []

        for line in lines:
            s = line.strip()

            # `ifdef MACRO
            m = re.match(r'`ifdef\s+(\S+)', s)
            if m:
                macro = m.group(1)
                is_defined = macro in define_set
                frame = stack[-1]
                new_active = frame["active"] and is_defined
                stack.append({"active": new_active, "had_true": new_active})
                result.append("")
                continue

            # `else
            if s.startswith('`else'):
                frame = stack[-1]
                if frame["had_true"]:
                    frame["active"] = False
                else:
                    parent_active = stack[-2]["active"] if len(stack) >= 2 else True
                    frame["active"] = parent_active and not frame["had_true"]
                result.append("")
                continue

            # `endif
            if s.startswith('`endif'):
                if len(stack) > 1:
                    stack.pop()
                result.append("")
                continue

            # 普通行
            if stack[-1]["active"]:
                result.append(line)
            else:
                result.append("")

        # 写入展开结果
        with open(dst_path, 'w') as f:
            for line in result:
                if line.strip():
                    f.write(line.lstrip())

        kept = sum(1 for r in result if r.strip())
        self.log.info(f"[KFile] {os.path.basename(src_path)}: {kept}/{len(lines)} lines kept")

    def _extract_defines(self, cfg_file):
        """从编译选项文件中提取 define 宏"""
        defines = set()
        if not os.path.isfile(cfg_file):
            return defines

        with open(cfg_file, 'r') as f:
            content = f.read()
            for m in re.finditer(r'[+]define[+]\s*(\S+)', content):
                defines.add(m.group(1))
        return defines
