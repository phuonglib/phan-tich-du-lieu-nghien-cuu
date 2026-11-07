"""
Tính Cronbach's Alpha (3 chữ số thập phân), tương quan trung bình giữa các câu
và hệ số Omega của McDonald cho 5 thang đo của Bài 11.

PSPP chưa có lệnh tính Omega. Script dùng phân tích nhân tố trục chính (PAF) một nhân tố
trên ma trận tương quan của từng thang đo:  omega = (Σλ)² / ((Σλ)² + Σ(1 − λ²)).

Cách chạy:  python tinh_omega.py
Đầu vào:    ../du-lieu/du_lieu_phan_tich.csv  (xuất từ .sav bằng: pspp-convert du_lieu_phan_tich.sav du_lieu_phan_tich.csv)
Yêu cầu:    pip install pandas numpy
"""
import os

import numpy as np
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
df = pd.read_csv(os.path.join(HERE, "..", "du-lieu", "du_lieu_phan_tich.csv")).apply(pd.to_numeric, errors="coerce")

THANG_DO = {
    "XN": ["XN1", "XN2", "XN3", "XN4"],
    "HI": ["HI1", "HI2", "HI3", "HI4"],
    "HL": ["HL1", "HL2", "HL3", "HL4"],
    "NT": ["NT1", "NT2", "NT3", "NT4R"],
    "YD": ["YD1", "YD2", "YD3", "YD4"],
}


def cronbach_alpha(x):
    k = x.shape[1]
    return k / (k - 1) * (1 - x.var(ddof=1).sum() / x.sum(axis=1).var(ddof=1))


def paf_mot_nhan_to(r, so_vong=500):
    h2 = 1 - 1 / np.diag(np.linalg.inv(r))          # khởi đầu bằng SMC
    for _ in range(so_vong):
        rr = r.copy()
        np.fill_diagonal(rr, h2)
        w, v = np.linalg.eigh(rr)
        lam = v[:, -1] * np.sqrt(w[-1])
        h2 = lam ** 2
    return np.abs(lam)


print(f"{'Thang đo':<9}{'N':>5}{'Alpha':>8}{'Omega':>8}{'r TB':>7}  Hệ số tải")
for ten, cau in THANG_DO.items():
    x = df[cau].dropna()                             # loại theo danh sách, giống PSPP
    r = x.corr().values
    lam = paf_mot_nhan_to(r)
    omega = lam.sum() ** 2 / (lam.sum() ** 2 + (1 - lam ** 2).sum())
    r_tb = r[np.triu_indices(len(cau), 1)].mean()
    print(f"{ten:<9}{len(x):>5}{cronbach_alpha(x):>8.3f}{omega:>8.3f}{r_tb:>7.2f}  {np.round(lam, 2)}")
