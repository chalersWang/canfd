#!/usr/bin/env python3
"""
CAN FD 回归仪表板生成器
=======================
从 regression_report.json 生成 HTML 可视化仪表板
"""

import json
import os
from datetime import datetime

VERIFY_HOME = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(VERIFY_HOME, "results")
REPORT_FILE = os.path.join(RESULTS_DIR, "regression_report.json")


def generate_dashboard(report_path=None, output_path=None):
    if report_path is None:
        report_path = REPORT_FILE
    if output_path is None:
        output_path = os.path.join(RESULTS_DIR, "dashboard.html")

    if not os.path.isfile(report_path):
        print(f"[ERROR] Report not found: {report_path}")
        # Generate empty report
        report = {"meta": {"total": 0, "passed": 0, "failed": 0,
                  "pass_rate": 0, "timestamp": datetime.now().isoformat()},
                  "by_group": {}, "details": []}
    else:
        with open(report_path) as f:
            report = json.load(f)

    meta = report["meta"]
    by_group = report.get("by_group", {})
    details = report.get("details", [])

    # Calculate pass rate color
    pass_rate = meta.get("pass_rate", 0)
    if pass_rate >= 95:
        rate_color = "#4CAF50"
    elif pass_rate >= 80:
        rate_color = "#FF9800"
    else:
        rate_color = "#F44336"

    # Build group rows
    group_rows = ""
    for g, stats in sorted(by_group.items()):
        g_pass_rate = round(stats["passed"] / stats["total"] * 100, 1) if stats["total"] > 0 else 0
        g_color = "#4CAF50" if g_pass_rate >= 95 else ("#FF9800" if g_pass_rate >= 80 else "#F44336")
        group_rows += f"""
        <tr>
            <td>{g}</td>
            <td>{stats['total']}</td>
            <td>{stats['passed']}</td>
            <td>{stats['failed']}</td>
            <td style="color:{g_color};font-weight:bold">{g_pass_rate}%</td>
        </tr>"""

    # Build detail rows (failed first)
    failed_tests = [d for d in details if d.get("status") != "PASS"]
    detail_rows = ""
    for d in failed_tests[:50]:  # Limit to 50
        status_color = {"PASS": "#4CAF50", "FAIL": "#F44336", "TIMEOUT": "#9C27B0",
                        "EXCEPTION": "#FF9800"}.get(d.get("status", ""), "#757575")
        detail_rows += f"""
        <tr>
            <td style="color:{status_color};font-weight:bold">{d.get('status', '?')}</td>
            <td>{d.get('group', '')}</td>
            <td>{d.get('test', '')}</td>
            <td>{d.get('seed', '')}</td>
            <td>{d.get('elapsed_s', '')}s</td>
        </tr>"""

    html = f"""<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>CAN FD Verification Dashboard</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 2em; background: #f5f5f5; }}
        .card {{ background: white; border-radius: 8px; padding: 1.5em;
                 margin: 1em 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
        .metric {{ display: inline-block; text-align: center; min-width: 120px; margin: 0 1em; }}
        .metric .value {{ font-size: 2em; font-weight: bold; }}
        .metric .label {{ color: #666; font-size: 0.9em; margin-top: 0.25em; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 1em; }}
        th {{ background: #263238; color: white; padding: 10px; text-align: left; }}
        td {{ padding: 8px 10px; border-bottom: 1px solid #e0e0e0; }}
        tr:hover {{ background: #f5f5f5; }}
        .pass-bar {{ background: #e0e0e0; border-radius: 4px; height: 20px; margin-top: 0.5em; }}
        .pass-bar-fill {{ background: {rate_color}; border-radius: 4px; height: 100%;
                          width: {pass_rate}%; transition: width 1s; }}
        h1 {{ color: #263238; }}
        h2 {{ color: #455A64; }}
    </style>
</head>
<body>
    <h1>CAN FD IP Verification Dashboard</h1>
    <p>Generated: {meta.get('timestamp', 'N/A')}</p>

    <div class="card">
        <h2>Overall Summary</h2>
        <div class="metric">
            <div class="value">{meta.get('total', 0)}</div>
            <div class="label">Total Tests</div>
        </div>
        <div class="metric">
            <div class="value" style="color:#4CAF50">{meta.get('passed', 0)}</div>
            <div class="label">Passed</div>
        </div>
        <div class="metric">
            <div class="value" style="color:#F44336">{meta.get('failed', 0)}</div>
            <div class="label">Failed</div>
        </div>
        <div class="metric" style="margin-left:2em">
            <div class="value" style="color:{rate_color}">{pass_rate}%</div>
            <div class="label">Pass Rate</div>
        </div>
        <div class="pass-bar"><div class="pass-bar-fill"></div></div>
    </div>

    <div class="card">
        <h2>By Test Group</h2>
        <table>
            <tr><th>Group</th><th>Total</th><th>Passed</th><th>Failed</th><th>Pass Rate</th></tr>
            {group_rows}
        </table>
    </div>

    <div class="card">
        <h2>Failed / Exception Tests</h2>
        <p>{len(failed_tests)} failed out of {meta.get('total', 0)} total</p>
        <table>
            <tr><th>Status</th><th>Group</th><th>Test</th><th>Seed</th><th>Elapsed</th></tr>
            {detail_rows}
        </table>
    </div>
</body>
</html>"""

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        f.write(html)
    print(f"Dashboard saved to: {output_path}")
    return output_path


if __name__ == "__main__":
    generate_dashboard()
