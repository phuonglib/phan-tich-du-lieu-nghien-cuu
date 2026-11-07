"""
Bài 18. Đối chiếu kết quả PSPP bằng Python (scipy, statsmodels).
Cách chạy: python kiem_tra_python.py
Yêu cầu:   pip install pandas scipy numpy statsmodels
"""
import os
import numpy as np
import pandas as pd
from scipy import stats
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from statsmodels.stats.oneway import anova_oneway

HERE = os.path.dirname(os.path.abspath(__file__))
df = pd.read_csv(os.path.join(HERE, "..", "du-lieu", "du_lieu_phan_tich.csv")).apply(pd.to_numeric, errors="coerce")


def mot_chieu(y, g):
    d = df[[y, g]].dropna()
    nhom = [x[y] for _, x in d.groupby(g)]
    f = stats.f_oneway(*nhom)
    lev = stats.levene(*nhom, center="mean")
    gm = d[y].mean()
    ssb = sum(len(x) * (x.mean() - gm) ** 2 for x in nhom)
    sst = ((d[y] - gm) ** 2).sum()
    k, n = len(nhom), len(d)
    msw = (sst - ssb) / (n - k)
    print(f"{y} theo {g}: F({k - 1}, {n - k}) = {f.statistic:.2f}, p = {f.pvalue:.4f}; Levene p = {lev.pvalue:.3f}; "
          f"eta2 = {ssb / sst:.3f}; omega2 = {(ssb - (k - 1) * msw) / (sst + msw):.3f}")
    return d


d = mot_chieu("YD", "THUNHAP")
w = anova_oneway(d.YD, d.THUNHAP, use_var="unequal")
print(f"  Welch F(3, {w.df_denom:.2f}) = {w.statistic:.2f}, p = {w.pvalue:.5f}")
kw = stats.kruskal(*[x.YD for _, x in d.groupby("THUNHAP")])
print(f"  Kruskal-Wallis H = {kw.statistic:.2f}, p = {kw.pvalue:.3f}")
print(pairwise_tukeyhsd(d.YD, d.THUNHAP))
tb = d.groupby("THUNHAP").YD.mean().values
c = np.array([-3, -1, 1, 3])
print(f"  Tương phản tuyến tính: giá trị = {(c * tb).sum():.4f}")
mot_chieu("YD", "NGHE")
