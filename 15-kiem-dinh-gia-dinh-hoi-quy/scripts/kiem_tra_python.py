"""
Đối chiếu kết quả kiểm định giả định của Bài 15 bằng Python, và tính hai thống kê PSPP không có:
khoảng tin cậy bootstrap và sai số chuẩn vững HC3.

Cách chạy:  python kiem_tra_python.py
Đầu vào:    ../du-lieu/du_lieu_phan_tich.csv
Yêu cầu:    pip install pandas numpy scipy statsmodels
"""
import os

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from scipy import stats
from statsmodels.stats.diagnostic import het_breuschpagan, linear_reset
from statsmodels.stats.stattools import durbin_watson

HERE = os.path.dirname(os.path.abspath(__file__))
df = pd.read_csv(os.path.join(HERE, "..", "du-lieu", "du_lieu_phan_tich.csv")).apply(pd.to_numeric, errors="coerce")
d = df[["ID", "XN", "HI", "HL", "NT", "YD"]].dropna().sort_values("ID")
m = smf.ols("YD ~ XN + HI + HL + NT", d).fit()
inf = m.get_influence()

print(f"N = {int(m.nobs)}; R2 = {m.rsquared:.3f}")
print("RESET (bình phương giá trị dự đoán):", linear_reset(m, power=2, use_f=True))
lm, lm_p, f, f_p = het_breuschpagan(m.resid, m.model.exog, robust=True)
print(f"Breusch-Pagan (Koenker): LM = {lm:.2f}, p = {lm_p:.3f}; F = {f:.2f}, p = {f_p:.3f}")
print(f"Durbin-Watson = {durbin_watson(m.resid):.3f}")
w, p = stats.shapiro(m.resid)
print(f"Shapiro-Wilk: W = {w:.3f}, p = {p:.2e}; độ lệch = {stats.skew(m.resid, bias=False):.2f}")
cook, h, sr = inf.cooks_distance[0], inf.hat_matrix_diag, inf.resid_studentized_internal
print(f"Cook lớn nhất = {cook.max():.3f} (phiếu {int(d.ID.values[cook.argmax()])}); số phiếu Cook > 4/N: {(cook > 4 / len(d)).sum()}")
print(f"Đòn bẩy lớn nhất = {h.max():.3f}; số phiếu > 2(k+1)/N: {(h > 10 / len(d)).sum()}")
print(f"Số phiếu |phần dư studentized| > 3: {(np.abs(sr) > 3).sum()}")

hc3 = m.get_robustcov_results("HC3")
print("\nSai số chuẩn OLS và HC3:")
for ten, se, se3, p3 in zip(m.params.index, m.bse, hc3.bse, hc3.pvalues):
    print(f"  {ten:<10} OLS {se:.3f}   HC3 {se3:.3f}   p(HC3) = {p3:.4f}")

rng = np.random.default_rng(15)
x = d[["XN", "HI", "HL", "NT", "YD"]].values
B = []
for _ in range(5000):
    s = x[rng.integers(0, len(x), len(x))]
    B.append(np.linalg.lstsq(np.c_[np.ones(len(s)), s[:, :4]], s[:, 4], rcond=None)[0])
lo, hi = np.percentile(np.array(B), [2.5, 97.5], axis=0)
ci = m.conf_int()
print("\nKhoảng tin cậy 95%: OLS và bootstrap (5.000 mẫu lặp)")
for i, ten in enumerate(m.params.index):
    print(f"  {ten:<10} OLS [{ci.iloc[i, 0]:.3f}; {ci.iloc[i, 1]:.3f}]   bootstrap [{lo[i]:.3f}; {hi[i]:.3f}]")
