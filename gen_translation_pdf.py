#!/usr/bin/env python3
"""
CAN FD v3.0 LogiCORE IP 产品指南——中文翻译 PDF 生成器
使用 fpdf2 + 中文字体生成专业中文技术 PDF
"""

import os
import re
import sys

from fpdf import FPDF

# ── 路径配置 ──────────────────────────────────────────
MARKDOWN_PATH = "/Users/ai-work/ai-dv/agents/claw-pdf/workspace/canfd/pg223_canfd_中文翻译.md"
OUTPUT_PDF    = "/Users/ai-work/ai-dv/agents/claw-pdf/workspace/canfd/pg223_canfd_中文翻译.pdf"

FONT_SONGTI  = "/System/Library/Fonts/Supplemental/Songti.ttc"
FONT_HEITI   = "/System/Library/Fonts/STHeiti Light.ttc"

# ── PDF 类 ────────────────────────────────────────────
class ChinesePDF(FPDF):
    def __init__(self):
        super().__init__("P", "mm", "A4")
        # 注册中文字体
        self.add_font("Songti", "",  FONT_SONGTI)
        self.add_font("Heiti",  "",  FONT_HEITI)
        self.add_font("HeitiB", "",  "/System/Library/Fonts/STHeiti Medium.ttc")

        self.font_body      = "Songti"
        self.font_title     = "Heiti"
        self.font_title_b   = "HeitiB"
        self.font_code      = "Songti"

        self.font_body_size   = 10
        self.font_h1_size     = 16
        self.font_h2_size     = 13
        self.font_h3_size     = 11
        self.font_small       = 8
        self.font_title_page  = 22

        self.l_margin = 20
        self.r_margin = 15
        self.t_margin = 15
        self.set_auto_page_break(True, 18)

        self.in_code_block = False
        self.in_table = False
        self.table_col_widths = []
        self.page_count = 0

    # ── 辅助 ──────────────────────────────────────────
    def reset_x(self):
        self.set_x(self.l_margin)

    def safe_multi_cell(self, w, h, txt, **kwargs):
        self.reset_x()
        self.multi_cell(w, h, txt, **kwargs)

    def stripper(self, text):
        """安全剥除 Markdown 格式"""
        t = text
        t = re.sub(r'\*\*(.+?)\*\*', r'\1', t)
        t = re.sub(r'\*(.+?)\*', r'\1', t)
        t = re.sub(r'`(.+?)`', r'\1', t)
        return t

    # ── 封面 ──────────────────────────────────────────
    def title_page(self):
        self.add_page()
        self.ln(40)
        self.set_font(self.font_title_b, "", self.font_title_page + 4)
        self.reset_x()
        self.multi_cell(0, 14, "CAN FD v3.0\nLogiCORE IP 产品指南", align="C")
        self.ln(6)
        self.set_font(self.font_title, "", 14)
        self.reset_x()
        self.cell(0, 10, "中文翻译版", align="C")
        self.ln(18)
        self.set_font(self.font_body, "", 11)
        self.reset_x()
        self.cell(0, 8, "PG223 (v3.0)  2025年8月28日", align="C")
        self.ln(10)
        self.reset_x()
        self.cell(0, 8, "AMD Vivado Design Suite", align="C")
        self.ln(24)
        self.set_font(self.font_body, "", 9)
        self.reset_x()
        self.cell(0, 7, "原文：CAN FD v3.0 LogiCORE IP Product Guide", align="C")
        self.ln(7)
        self.reset_x()
        self.cell(0, 7, "专业术语参照 ISO 11898-1:2015 中文标准", align="C")
        self.ln(7)
        self.reset_x()
        self.cell(0, 7, "翻译生成日期：2026年6月14日", align="C")

    # ── 页眉页脚 ──────────────────────────────────────
    def header(self):
        if self.page_no() == 1:
            return
        self.set_font(self.font_body, "", self.font_small)
        self.set_text_color(100, 100, 100)
        self.reset_x()
        self.cell(0, 6, "CAN FD v3.0 LogiCORE IP 产品指南（中文翻译）", align="C")
        self.ln(6)
        self.set_draw_color(180, 180, 180)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(4)
        self.set_text_color(0, 0, 0)

    def footer(self):
        if self.page_no() == 1:
            return
        self.set_y(-15)
        self.set_font(self.font_body, "", self.font_small)
        self.set_text_color(100, 100, 100)
        self.reset_x()
        self.cell(0, 8, f"PG223 (v3.0) — 第 {self.page_no()} 页", align="C")

    # ── 渲染器 ────────────────────────────────────────
    def render_md(self, md_path):
        with open(md_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        in_code  = False
        in_table = False
        table_rows = []

        # 跳过目录行，在内容中不重复渲染封面信息
        started = False

        for raw in lines:
            line = raw.rstrip()

            # 跳过封面区域在正文中的重复
            if not started:
                if line.startswith("# 第1章") or line.startswith("## 目录"):
                    started = True
                    # 目录跳过不渲染
                    if line.startswith("## 目录"):
                        continue

            if not started and line.strip():
                continue

            # ── 代码块 ──
            if line.startswith("```"):
                if in_code:
                    in_code = False
                    self.set_font(self.font_body, "", self.font_body_size)
                    continue
                else:
                    in_code = True
                    self.set_font(self.font_code, "", self.font_small)
                    continue

            if in_code:
                self.reset_x()
                self.cell(0, 4.5, line)
                self.ln()
                continue

            # ── 空行 ──
            if not line.strip():
                if in_table:
                    continue
                self.ln(3)
                continue

            # ── 标题 ──
            if line.startswith("# ") and not line.startswith("## "):
                self.set_font(self.font_title_b, "", self.font_h1_size)
                txt = self.stripper(line[2:])
                self.ln(4)
                self.safe_multi_cell(0, 7, txt)
                self.ln(2)
                continue

            if line.startswith("## "):
                self.set_font(self.font_title, "", self.font_h2_size)
                txt = self.stripper(line[3:])
                self.ln(3)
                self.safe_multi_cell(0, 7, txt)
                self.ln(2)
                continue

            if line.startswith("### "):
                self.set_font(self.font_title, "", self.font_h3_size)
                txt = self.stripper(line[4:])
                self.ln(2)
                self.safe_multi_cell(0, 6.5, txt)
                self.ln(1)
                continue

            # ── 水平线 ──
            if line.strip() == "---":
                self.set_draw_color(180, 180, 180)
                self.reset_x()
                y = self.get_y()
                self.line(self.l_margin, y, self.w - self.r_margin, y)
                self.ln(4)
                continue

            # ── 表格 ──
            if "|" in line and line.strip().startswith("|"):
                cells = [c.strip() for c in line.split("|")[1:-1]]
                # 跳过分隔行
                if all(re.match(r'^[-: ]+$', c) for c in cells if c):
                    continue
                if not in_table:
                    in_table = True
                    table_rows = []
                table_rows.append(cells)
                continue
            else:
                if in_table:
                    # 刷新表格
                    self._render_table(table_rows)
                    table_rows = []
                    in_table = False

            # ── 引用块 ──
            if line.startswith("> "):
                self.set_font(self.font_body, "", self.font_body_size)
                self.set_text_color(80, 80, 80)
                txt = self.stripper(line[2:])
                self.reset_x()
                self.set_x(self.l_margin + 4)
                self.multi_cell(self.w - self.l_margin - self.r_margin - 4, 5.5, txt)
                self.set_text_color(0, 0, 0)
                continue

            # ── 一般段落 ──
            self.set_font(self.font_body, "", self.font_body_size)
            txt = self.stripper(line)
            # 检查是否有序列表
            if re.match(r'^\d+[\.\)]\s', txt):
                self.reset_x()
                self.set_x(self.l_margin + 5)
                self.multi_cell(self.w - self.l_margin - self.r_margin - 5, 5.5, txt)
            elif txt.startswith("- ") or txt.startswith("• ") or txt.startswith("* "):
                self.reset_x()
                self.set_x(self.l_margin + 5)
                self.multi_cell(self.w - self.l_margin - self.r_margin - 5, 5.5, txt)
            elif txt.startswith("**") or txt.startswith("|"):
                # 粗体行
                self.set_font(self.font_title, "", self.font_body_size)
                self.safe_multi_cell(0, 5.5, txt)
            else:
                self.safe_multi_cell(0, 5.5, txt)

        # 刷新最后的表格
        if in_table and table_rows:
            self._render_table(table_rows)

    def _render_table(self, rows):
        if not rows:
            return
        ncols = len(rows[0])

        # 固定宽度计算
        usable = self.w - self.l_margin - self.r_margin
        col_w = [usable / ncols] * ncols

        self.set_font(self.font_body, "", self.font_small)

        for ri, row in enumerate(rows):
            # 检查是否适合放在当前页
            if self.get_y() + 7 > self.h - self.b_margin:
                self.add_page()

            self.reset_x()

            # 计算每行最大高度
            max_h = 6
            cell_texts = []
            for ci, cell in enumerate(row):
                cw = col_w[ci] - 1
                # 估算行数
                txt = self.stripper(cell)
                cell_texts.append(txt)
                # 估算行高
                lines_needed = self.multi_cell(cw, 5, txt, dry_run=True, output="LINES")
                h = len(lines_needed) * 5 + 1
                if h > max_h:
                    max_h = h

            # 避免跨页断裂
            if self.get_y() + max_h > self.h - self.b_margin:
                self.add_page()
                self.reset_x()

            x_start = self.get_x()
            y_start = self.get_y()

            # 画格子
            for ci in range(ncols):
                x_pos = x_start + sum(col_w[:ci])
                col_w_ci = col_w[ci]

                if ri == 0:
                    # 表头
                    self.set_fill_color(40, 80, 140)
                    self.set_text_color(255, 255, 255)
                    self.set_font(self.font_title, "", self.font_small)
                else:
                    if ri % 2 == 0:
                        self.set_fill_color(245, 245, 250)
                    else:
                        self.set_fill_color(255, 255, 255)
                    self.set_text_color(0, 0, 0)
                    self.set_font(self.font_body, "", self.font_small)

                # 画矩形背景
                self.rect(x_pos, y_start, col_w_ci, max_h, "FD")

                self.set_xy(x_pos + 0.5, y_start + 0.5)
                self.multi_cell(col_w_ci - 1, 5, cell_texts[ci])

            self.set_y(y_start + max_h)

        self.set_text_color(0, 0, 0)
        self.ln(4)


# ── 主流程 ────────────────────────────────────────────
def main():
    if not os.path.exists(MARKDOWN_PATH):
        print(f"错误：找不到翻译文件 {MARKDOWN_PATH}")
        sys.exit(1)

    pdf = ChinesePDF()
    pdf.set_title("CAN FD v3.0 LogiCORE IP 产品指南（中文翻译）")
    pdf.set_author("AMD / 中文翻译")

    # 封面
    pdf.title_page()

    # 正文
    pdf.add_page()
    pdf.render_md(MARKDOWN_PATH)

    # 输出
    pdf.output(OUTPUT_PDF)
    file_size_kb = os.path.getsize(OUTPUT_PDF) / 1024
    print(f"PDF 已生成：{OUTPUT_PDF}")
    print(f"文件大小：{file_size_kb:.1f} KB")
    print(f"总页数：{pdf.page_no()} 页")


if __name__ == "__main__":
    main()
