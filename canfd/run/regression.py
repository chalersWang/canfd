#!/usr/bin/env python3
"""
CANFD Unified Regression Manager
=================================
统一回归管理器 — CAN FD 验证环境唯一入口。

用法:
  python3 regression.py --list              # 列出所有 testcase
  python3 regression.py --run T1            # 运行 T1 group
  python3 regression.py --run all           # 运行全部
  python3 regression.py --run all --cov     # 运行全部 + 覆盖率
  python3 regression.py --run all --gls     # 门级仿真回归
  python3 regression.py --run T1 -n 10      # 运行 T1，重复 10 次 (随机 seed)
  python3 regression.py --run T1 --parallel 8  # 并行 8 任务
  python3 regression.py --covmerge          # 合并覆盖率
  python3 regression.py --report            # 生成 JSON 报告
  python3 regression.py --clean             # 清理 build 目录

环境变量 (fallback defaults):
  VERIFY_HOME    — 验证环境根目录 (默认: 当前目录)
  VCS_HOME       — Synopsys VCS 安装路径
  VERDI_HOME     — Verdi 安装路径
"""

import argparse
import json
import os
import random
import subprocess
import sys
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

# ---------------------------------------------------------------------------
# 常量和配置
# ---------------------------------------------------------------------------
VERIFY_HOME = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TESTPLAN_DIR = os.path.join(VERIFY_HOME, "testplan")
RUN_DIR = os.path.join(VERIFY_HOME, "run")
BUILD_DIR = os.path.join(VERIFY_HOME, "build")
RESULTS_DIR = os.path.join(VERIFY_HOME, "results")

GROUPS = ["T1", "T2", "T3", "T4", "T5", "T6", "T7"]
GROUP_NAMES = {
    "T1": "寄存器访问",
    "T2": "CAN通信功能",
    "T3": "接收功能",
    "T4": "工作模式",
    "T5": "错误处理",
    "T6": "接口时序",
    "T7": "特殊功能+压力边界",
}


# ---------------------------------------------------------------------------
# 核心功能
# ---------------------------------------------------------------------------

def load_test_db():
    """加载所有 testplan group 的 test.json 到统一字典"""
    db = {}
    for g in GROUPS:
        jf = os.path.join(TESTPLAN_DIR, f"{g}_group", "test.json")
        if os.path.isfile(jf):
            with open(jf) as f:
                db[g] = json.load(f)
        else:
            print(f"[WARN] test.json not found for {g}")
            db[g] = {}
    return db


def list_tests(db):
    """列出所有测试用例"""
    total = 0
    for g in GROUPS:
        tests = db.get(g, {})
        print(f"\n{g} ({GROUP_NAMES.get(g, '?')}): {len(tests)} tests")
        for t in sorted(tests.keys()):
            print(f"  - {t}")
        total += len(tests)
    print(f"\nTotal: {total} tests across {len(GROUPS)} groups")


def xrun_cmd(*args):
    """调用 xrun 脚本"""
    cmd = [os.path.join(RUN_DIR, "xrun")] + list(args)
    return subprocess.run(cmd, cwd=RUN_DIR)


def run_group(group: str, opts: dict, db: dict):
    """运行单个 group 的全部测试"""
    tests = db.get(group, {})
    if not tests:
        print(f"[WARN] No tests found for group {group}")
        return []

    results = []
    print(f"\n{'='*60}")
    print(f"  Running {group} ({GROUP_NAMES.get(group, '')}): {len(tests)} tests")
    print(f"{'='*60}")

    xrun_args = ["-g", group, "-s"]
    if opts.get("cov"):
        xrun_args.append("--cov")
    if opts.get("gls"):
        xrun_args.append("--gls")
    if opts.get("fsdb"):
        xrun_args.append("-fsdb")

    n_repeat = opts.get("n", 1)
    if n_repeat > 1:
        xrun_args.extend(["-n", str(n_repeat)])

    for tname in sorted(tests.keys()):
        seed = opts.get("seed") or random.randint(0, 2**16)
        print(f"\n>>> {tname}  seed={seed}")
        start = time.time()
        result = subprocess.run(
            [os.path.join(RUN_DIR, "xrun"), "-g", group, "-t", tname, "-s",
             "--seed", str(seed)] +
            ([x for x in xrun_args if x not in ("-g", group, "-t", tname, "-s")]),
            cwd=RUN_DIR, capture_output=True, text=True, timeout=7200
        )
        elapsed = time.time() - start

        status = "PASS"
        if result.returncode != 0:
            status = "FAIL"
        elif "UVM_FATAL" in (result.stdout + result.stderr):
            status = "FAIL"
        elif "UVM_ERROR" in (result.stdout + result.stderr):
            status = "FAIL"

        results.append({
            "test": tname,
            "group": group,
            "seed": seed,
            "status": status,
            "elapsed_s": round(elapsed, 1),
            "timestamp": datetime.now().isoformat(),
        })
        print(f"  [{status}] {tname}  ({elapsed:.1f}s)")

    return results


def run_parallel(group: str, tests: list, opts: dict, max_workers: int):
    """并行运行指定 group 的测试列表"""
    results = []

    def run_one(tname):
        seed = opts.get("seed") or random.randint(0, 2**16)
        start = time.time()
        cmd = [os.path.join(RUN_DIR, "xrun"), "-g", group, "-t", tname, "-s",
               "--seed", str(seed)]
        if opts.get("cov"):
            cmd.append("--cov")
        if opts.get("gls"):
            cmd.append("--gls")
        if opts.get("fsdb"):
            cmd.append("-fsdb")

        try:
            result = subprocess.run(cmd, cwd=RUN_DIR,
                                    capture_output=True, text=True, timeout=7200)
            elapsed = time.time() - start
            status = "PASS"
            if result.returncode != 0:
                status = "FAIL"
            elif "UVM_FATAL" in (result.stdout + result.stderr):
                status = "FAIL"
            elif "UVM_ERROR" in (result.stdout + result.stderr):
                status = "FAIL"
        except subprocess.TimeoutExpired:
            elapsed = time.time() - start
            status = "TIMEOUT"

        return {
            "test": tname, "group": group, "seed": seed,
            "status": status, "elapsed_s": round(elapsed, 1),
            "timestamp": datetime.now().isoformat(),
        }

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(run_one, t): t for t in tests}
        for future in as_completed(futures):
            r = future.result()
            results.append(r)
            print(f"  [{r['status']}] {r['test']}  seed={r['seed']}  ({r['elapsed_s']:.1f}s)")

    return results


def merge_coverage():
    """合并覆盖率数据库"""
    print("Merging coverage databases...")
    subprocess.run([os.path.join(RUN_DIR, "xrun"), "--covmerge"], cwd=RUN_DIR)


def generate_report(results: list, output_dir: str = None):
    """生成结构化 JSON 回归报告"""
    if output_dir is None:
        output_dir = RESULTS_DIR
    os.makedirs(output_dir, exist_ok=True)

    total = len(results)
    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = sum(1 for r in results if r["status"] == "FAIL")
    timeout = sum(1 for r in results if r["status"] == "TIMEOUT")
    exceptions = total - passed - failed - timeout

    report = {
        "meta": {
            "timestamp": datetime.now().isoformat(),
            "total": total,
            "passed": passed,
            "failed": failed,
            "timeout": timeout,
            "exception": exceptions,
            "pass_rate": round(passed / total * 100, 1) if total > 0 else 0,
        },
        "by_group": {},
        "details": results,
    }

    for r in results:
        g = r["group"]
        if g not in report["by_group"]:
            report["by_group"][g] = {"total": 0, "passed": 0, "failed": 0}
        report["by_group"][g]["total"] += 1
        if r["status"] == "PASS":
            report["by_group"][g]["passed"] += 1
        else:
            report["by_group"][g]["failed"] += 1

    # 写 JSON 报告
    json_path = os.path.join(output_dir, "regression_report.json")
    with open(json_path, "w") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    # 打印摘要
    print(f"\n{'='*60}")
    print(f"  REGRESSION REPORT")
    print(f"{'='*60}")
    print(f"  Total:   {total}")
    print(f"  Passed:  {passed}  ({report['meta']['pass_rate']}%)")
    print(f"  Failed:  {failed}")
    if timeout:
        print(f"  Timeout: {timeout}")
    if exceptions:
        print(f"  Exception: {exceptions}")
    print(f"{'='*60}")
    print(f"  Report saved to: {json_path}")

    return report


# ---------------------------------------------------------------------------
# CLI 入口
# ---------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(
        description="CANFD Unified Regression Manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --list                 List all tests
  %(prog)s --run T1               Run T1 group once
  %(prog)s --run all --cov        Run all with coverage
  %(prog)s --run all --gls        Run all gate-level
  %(prog)s --run all --parallel 8 Run all, 8 parallel jobs
  %(prog)s --run T1 -n 10        Repeat T1 10x with random seeds
  %(prog)s --covmerge             Merge coverage databases
  %(prog)s --report               Generate JSON report
  %(prog)s --clean                Clean build directory
        """,
    )
    p.add_argument("--list", action="store_true", help="List all testcases")
    p.add_argument("--run", type=str, metavar="GROUP",
                   help="Run test group (T1-T7 or 'all')")
    p.add_argument("--cov", action="store_true", help="Enable coverage collection")
    p.add_argument("--gls", action="store_true", help="Enable gate-level simulation")
    p.add_argument("--fsdb", action="store_true", help="Enable FSDB waveform dump")
    p.add_argument("--seed", type=int, default=None, help="Fixed random seed")
    p.add_argument("-n", type=int, default=1, help="Repeat count per test")
    p.add_argument("--parallel", type=int, default=0, metavar="N",
                   help="Parallel simulation jobs (0=serial)")
    p.add_argument("--covmerge", action="store_true", help="Merge coverage databases")
    p.add_argument("--report", action="store_true", help="Generate JSON regression report")
    p.add_argument("--clean", action="store_true", help="Clean build directory")
    args = p.parse_args()

    # 加载测试数据库
    db = load_test_db()

    if args.list:
        list_tests(db)

    elif args.clean:
        import shutil
        if os.path.isdir(BUILD_DIR):
            shutil.rmtree(BUILD_DIR)
            print(f"Cleaned: {BUILD_DIR}")
        else:
            print("Build directory already clean.")

    elif args.covmerge:
        merge_coverage()

    elif args.run:
        opts = {
            "cov": args.cov,
            "gls": args.gls,
            "fsdb": args.fsdb,
            "seed": args.seed,
            "n": args.n,
        }

        groups_to_run = GROUPS if args.run == "all" else [args.run]
        all_results = []

        for g in groups_to_run:
            tests = db.get(g, {})
            if not tests:
                print(f"[WARN] No tests found for {g}")
                continue

            if args.parallel > 0:
                res = run_parallel(g, sorted(tests.keys()), opts, args.parallel)
            else:
                res = run_group(g, opts, db)
            all_results.extend(res)

        # 自动生成报告
        if all_results:
            generate_report(all_results)

    elif args.report:
        # 从已有 regression.log 生成报告
        reg_log = os.path.join(BUILD_DIR, "regression")
        results = []
        if os.path.isfile(reg_log):
            with open(reg_log) as f:
                for line in f:
                    line = line.strip()
                    if line:
                        parts = line.split()
                        if len(parts) >= 3:
                            results.append({
                                "test": parts[0],
                                "seed": parts[1],
                                "status": parts[2],
                                "elapsed_s": 0,
                                "timestamp": "",
                                "group": "",
                            })
        generate_report(results)

    else:
        p.print_help()


if __name__ == "__main__":
    main()
