"""
Các phép tính bổ sung cho Bài 12 mà PSPP chưa có sẵn:
  1. Chỉ số MSA của từng câu (KMO riêng từng biến) và định thức ma trận tương quan
  2. Phân tích song song (parallel analysis, Horn 1965) để xác định số nhân tố
  3. Vẽ biểu đồ scree kèm đường phân tích song song (hinh-scree-song-song.png)

Cách chạy:  python efa_bo_sung.py --fonts ../fonts --out ../images
Đầu vào:    ../du-lieu/du_lieu_phan_tich.csv
Yêu cầu:    pip install pandas numpy matplotlib
"""
import argparse
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib import font_manager

HERE = os.path.dirname(os.path.abspath(__file__))
CAU = ["XN1", "XN2", "XN3", "XN4", "HI1", "HI2", "HI3", "HI4", "HL1", "HL2", "HL3", "HL4",
       "NT1", "NT2", "NT3", "NT4R", "YD1", "YD2", "YD3", "YD4"]
NAVY, TEAL, ORANGE, MUTED = "#1F3A5F", "#2A8C7E", "#C2562E", "#5B6472"


def kmo(r):
    ri = np.linalg.inv(r)
    d = np.sqrt(np.outer(np.diag(ri), np.diag(ri)))
    p = -ri / d                                   # tương quan riêng phần
    np.fill_diagonal(p, 0)
    r0 = r.copy(); np.fill_diagonal(r0, 0)
    msa = (r0 ** 2).sum(0) / ((r0 ** 2).sum(0) + (p ** 2).sum(0))
    tong = (r0 ** 2).sum() / ((r0 ** 2).sum() + (p ** 2).sum())
    return tong, msa


def eig_day_du(r):
    return np.sort(np.linalg.eigvalsh(r))[::-1]


def eig_rut_gon(r):
    """Eigenvalue của ma trận tương quan rút gọn (đường chéo thay bằng SMC), dùng cho PAF."""
    rr = r.copy()
    np.fill_diagonal(rr, 1 - 1 / np.diag(np.linalg.inv(r)))
    return np.sort(np.linalg.eigvalsh(rr))[::-1]


def song_song(n, k, ham, lan=1000, seed=2026):
    rng = np.random.default_rng(seed)
    ev = np.array([ham(np.corrcoef(rng.standard_normal((n, k)), rowvar=False)) for _ in range(lan)])
    return np.percentile(ev, 95, axis=0)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--fonts", default=os.path.join(HERE, "..", "fonts"))
    ap.add_argument("--out", default=os.path.join(HERE, "..", "images"))
    a = ap.parse_args()
    df = pd.read_csv(os.path.join(HERE, "..", "du-lieu", "du_lieu_phan_tich.csv")).apply(pd.to_numeric, errors="coerce")
    x = df[CAU].dropna()
    n, k = x.shape
    r = np.corrcoef(x.values, rowvar=False)
    tong, msa = kmo(r)
    print(f"N = {n}; định thức = {np.linalg.det(r):.2e}; KMO = {tong:.3f}")
    print("MSA từng câu:", ", ".join(f"{c} {m:.2f}" for c, m in zip(CAU, msa)))
    print(f"MSA nhỏ nhất: {msa.min():.3f} ({CAU[msa.argmin()]}); lớn nhất: {msa.max():.3f} ({CAU[msa.argmax()]})")
    ket_qua = {}
    for ten, ham in [("PCA", eig_day_du), ("PAF", eig_rut_gon)]:
        ev, p95 = ham(r), song_song(n, k, ham)
        so = int((ev > p95).cumprod().sum())
        ket_qua[ten] = (ev, p95, so)
        print(f"\nPhân tích song song dựa trên {ten}: giữ {so} nhân tố")
        print("Thứ tự  Eigenvalue  Ngẫu nhiên (95%)")
        for i in range(8):
            print(f"{i + 1:>6} {ev[i]:>11.3f} {p95[i]:>17.3f}")

    for f in os.listdir(a.fonts):
        if f.endswith(".ttf"):
            font_manager.fontManager.addfont(os.path.join(a.fonts, f))
    plt.rcParams["font.family"] = "Be Vietnam Pro"
    fig, axes = plt.subplots(1, 2, figsize=(10, 4.8), dpi=200)
    fig.subplots_adjust(left=0.07, right=0.98, top=0.76, bottom=0.13, wspace=0.22)
    t = np.arange(1, 11)
    tieu_de = {"PCA": "Ma trận tương quan đầy đủ (theo PCA)", "PAF": "Ma trận tương quan rút gọn (theo PAF)"}
    for ax, ten in zip(axes, ["PCA", "PAF"]):
        ev, p95, so = ket_qua[ten]
        ax.plot(t, ev[:10], "-o", color=NAVY, lw=2, ms=5, label="Dữ liệu thật")
        ax.plot(t, p95[:10], "--", color=ORANGE, lw=1.8, label="Dữ liệu ngẫu nhiên (95%)")
        ax.scatter(t[:so], ev[:so], s=70, facecolor="none", edgecolor=TEAL, lw=1.8, zorder=5)
        ax.set_title(f"{tieu_de[ten]}: giữ {so} nhân tố", fontsize=10, color=NAVY, loc="left", fontweight="bold")
        ax.set_xticks(t); ax.tick_params(labelsize=8.5, colors=MUTED)
        ax.set_xlabel("Thứ tự nhân tố", fontsize=9, color=MUTED)
        for sp in ("top", "right"):
            ax.spines[sp].set_visible(False)
        ax.grid(axis="y", color="#E5E7EB", lw=0.8)
        ax.legend(frameon=False, fontsize=8.5, loc="upper right")
    axes[0].axhline(1, color=MUTED, lw=0.9, ls=":")
    axes[0].text(10, 1.12, "Eigenvalue = 1", ha="right", fontsize=8, color=MUTED)
    axes[0].set_ylabel("Eigenvalue", fontsize=9, color=MUTED)
    fig.text(0.04, 0.94, "Phân tích song song: hai cách tính cho hai kết luận", fontsize=14, fontweight="bold", color=NAVY)
    fig.text(0.04, 0.895, f"N = {n}, 20 câu; vòng xanh là các nhân tố có eigenvalue lớn hơn dữ liệu ngẫu nhiên (1.000 lần mô phỏng)",
             fontsize=9, color=MUTED)
    os.makedirs(a.out, exist_ok=True)
    fig.savefig(os.path.join(a.out, "hinh-9-phan-tich-song-song.png"), facecolor="white")
