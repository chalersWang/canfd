"""utils: 通用工具函数"""

import os
import random


class Logger:
    """统一日志输出"""
    def __init__(self, debug=False):
        self.debug = debug

    def info(self, msg):
        if self.debug:
            print(f"[INFO] {msg}")

    def warn(self, msg):
        print(f"\033[33;1m[WARN]\033[0m {msg}")

    def error(self, msg):
        print(f"\033[31;1m[ERROR]\033[0m {msg}")

    def log(self, msg, force=False):
        if force or self.debug:
            print(msg)

    def array(self, items, enable=True):
        if enable:
            for item in items:
                print(item)


def create_dir(path):
    """创建目录 (幂等)"""
    if not os.path.isdir(path):
        os.makedirs(path, exist_ok=True)


def seed_gen(fixed=None):
    """生成随机 seed"""
    if fixed is not None:
        return fixed
    return random.randint(0, 2**16)


def get_dirnames(path, suffix):
    """获取指定后缀的文件/目录名列表"""
    result = []
    if not os.path.isdir(path):
        return result
    for name in os.listdir(path):
        if not os.path.splitext(name)[1] == suffix:
            result.append(name)
    return result


def get_filenames(path, suffix):
    """获取指定后缀的文件名列表"""
    result = []
    if not os.path.isdir(path):
        return result
    for name in os.listdir(path):
        if os.path.splitext(name)[1] == suffix:
            result.append(name)
    return result
