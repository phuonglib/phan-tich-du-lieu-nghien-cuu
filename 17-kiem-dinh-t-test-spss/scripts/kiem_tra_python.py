"""
Bài 17. Đối chiếu kết quả PSPP bằng Python (scipy).
Cách chạy: python kiem_tra_python.py
Yêu cầu:   pip install pandas scipy numpy
"""
import os
import numpy as np
import pandas as pd
from scipy import stats

HERE = os.path.dirname(os.path.abspath(__file__))
df = pd.read_csv(os.path.join(HERE, "..", "du-lieu", "du_lieu_phan_tich.csv")).apply(pd.to_numeric, errors="coerce")


def cohen_d(a, b):
    sp = np.sqrt(((len(a) - 1) * a.var() + (len(b) - 1) * b.var()) / (len(a) + len(b) - 2))
    return (a.mean() - b.mean()) / sp


print("1. Hai mẫu độc lập (Nam = 1, Nữ = 2)")
for v in ["YD", "HL", "TANSUAT"]:
    a = df.loc[df.GIOITINH == 1, v].dropna(); b = df.loc[df.GIOITINH == 2, v].dropna()
    lev = stats.levene(a, b, center="mean")
    st = stats.ttest_ind(a, b); we = stats.ttest_ind(a, b, equal_var=False)
    mw = stats.mannwhitneyu(a, b)
    print(f"  {v}: n = {len(a)}/{len(b)}, TB = {a.mean():.3f}/{b.mean():.3f}, Levene F = {lev.statistic:.2f} "
          f"p = {lev.pvalue:.3f}; Student t = {st.statistic:.2f} p = {st.pvalue:.3f}; "
          f"Welch t = {we.statistic:.2f} df = {we.df:.2f} p = {we.pvalue:.3f}; d = {cohen_d(a, b):.3f}; "
          f"Mann-Whitney U = {mw.statistic:.1f} p = {mw.pvalue:.3f}")
t99 = df[df.ID != 99]
a = t99.loc[t99.GIOITINH == 1, "TANSUAT"].dropna(); b = t99.loc[t99.GIOITINH == 2, "TANSUAT"].dropna()
print(f"  TANSUAT bỏ ID 99: SD = {a.std():.2f}/{b.std():.2f}, Welch p = {stats.ttest_ind(a, b, equal_var=False).pvalue:.3f}")

print("2. Mẫu cặp HI2 - HI3")
p = df[["HI2", "HI3"]].dropna(); d = p.HI2 - p.HI3
r = stats.ttest_rel(p.HI2, p.HI3); ci = r.confidence_interval()
w = stats.wilcoxon(p.HI2, p.HI3, zero_method="wilcox", correction=False, method="approx")
print(f"  N = {len(p)}, chênh lệch TB = {d.mean():.3f}, SD = {d.std():.3f}, t = {r.statistic:.2f}, p = {r.pvalue:.3f}, "
      f"CI [{ci.low:.3f}; {ci.high:.3f}], r = {p.HI2.corr(p.HI3):.3f}, d_z = {d.mean() / d.std():.3f}")
print(f"  Wilcoxon: âm = {(d < 0).sum()}, dương = {(d > 0).sum()}, bằng nhau = {(d == 0).sum()}, p = {w.pvalue:.3f}")

print("3. Một mẫu")
for g in [3, 4]:
    for v in ["HL", "YD"]:
        x = df[v].dropna(); r = stats.ttest_1samp(x, g); ci = r.confidence_interval()
        print(f"  {v} so với {g}: TB = {x.mean():.3f}, t({len(x) - 1}) = {r.statistic:.2f}, p = {r.pvalue:.4f}, "
              f"chênh lệch = {x.mean() - g:.3f} [{ci.low - g:.3f}; {ci.high - g:.3f}], d = {(x.mean() - g) / x.std():.3f}")
