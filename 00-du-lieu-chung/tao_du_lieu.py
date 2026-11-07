"""
Tạo bộ dữ liệu mẫu dùng chung cho chuỗi bài "Học SPSS – AMOS – SmartPLS".

Đề tài mẫu: Các yếu tố ảnh hưởng đến ý định mua lại của khách hàng trên sàn X
(vai trò trung gian của sự hài lòng). Dữ liệu là DỮ LIỆU GIẢ LẬP, chỉ dùng để học.

Mô hình tổng thể dùng để sinh dữ liệu (hệ số chuẩn hóa):
    HI = 0,55·XN + e
    HL = 0,45·XN + 0,30·HI + e
    YD = 0,20·HI + 0,40·HL + 0,25·NT + e
    corr(XN, NT) = 0,35

Cách chạy:  python tao_du_lieu.py            (yêu cầu: pip install numpy pandas openpyxl)
Kết quả:    du_lieu_mau_san_x.csv, du_lieu_mau_san_x.xlsx
            (file .sav được tạo bằng PSPP từ nhap_du_lieu.sps)
"""
import numpy as np
import pandas as pd

SEED = 2026
N = 300
rng = np.random.default_rng(SEED)

# ---------- 1. Biến tiềm ẩn ----------
XN = rng.normal(size=N)
NT = 0.35 * XN + np.sqrt(1 - 0.35 ** 2) * rng.normal(size=N)
HI = 0.55 * XN + np.sqrt(1 - 0.55 ** 2) * rng.normal(size=N)
hl_det = 0.45 * XN + 0.30 * HI
HL = hl_det + np.sqrt(max(1 - np.var(hl_det), 0.2)) * rng.normal(size=N)
yd_det = 0.20 * HI + 0.40 * HL + 0.25 * NT
YD = yd_det + np.sqrt(max(1 - np.var(yd_det), 0.2)) * rng.normal(size=N)
latent = {"XN": XN, "HI": HI, "HL": HL, "NT": NT, "YD": YD}

# Hệ số tải của từng biến quan sát
LOADINGS = {
    "XN": [0.78, 0.82, 0.75, 0.70],
    "HI": [0.80, 0.77, 0.83, 0.72],
    "HL": [0.85, 0.80, 0.78, 0.82],
    "NT": [0.76, 0.81, 0.74, 0.68],   # NT4 là câu đảo chiều
    "YD": [0.84, 0.79, 0.81, 0.77],
}
# Ngưỡng cắt sang thang Likert 5 mức (lệch về phía đồng ý, giống dữ liệu khảo sát thật)
CUTS = [-1.9, -1.0, -0.15, 0.95]


def to_likert(z):
    return (np.digitize(z, CUTS) + 1).astype(int)


data = {"ID": np.arange(1, N + 1)}
for c, lams in LOADINGS.items():
    for i, lam in enumerate(lams, start=1):
        z = lam * latent[c] + np.sqrt(1 - lam ** 2) * rng.normal(size=N) + 0.35
        data[f"{c}{i}"] = to_likert(z)
df = pd.DataFrame(data)
df["NT4"] = 6 - df["NT4"]                       # câu đảo chiều: chưa mã hóa lại

# ---------- 2. Thông tin nhân khẩu học ----------
df["GIOITINH"] = rng.choice([1, 2, 3], size=N, p=[0.42, 0.55, 0.03])
df["TUOI"] = np.clip(np.round(rng.gamma(6.0, 4.6, size=N) + 4), 18, 60).astype(int)
df["NGHE"] = rng.choice([1, 2, 3, 4], size=N, p=[0.30, 0.42, 0.18, 0.10])
df["THUNHAP"] = rng.choice([1, 2, 3, 4], size=N, p=[0.28, 0.37, 0.24, 0.11])
df["TANSUAT"] = np.clip(np.round(rng.gamma(2.2, 2.0, size=N)), 1, 30).astype(int)

# ---------- 3. Câu gạn lọc và câu kiểm tra chú ý ----------
df["SL1"] = 1                                   # 1 = đã mua trên sàn X trong 6 tháng qua
df["AC1"] = 2                                   # câu hướng dẫn "Hãy chọn mức 2"

items = [f"{c}{i}" for c in LOADINGS for i in range(1, 5)]
idx = rng.permutation(N)
fail_screen = idx[:14]                          # 14 người chưa mua -> loại
fail_attn = idx[14:25]                          # 11 người trả lời sai câu kiểm tra
straight = idx[25:33]                           # 8 người chọn cùng một mức cho mọi câu
missing_rows = idx[33:45]                       # 12 người bỏ trống 1-2 câu
outlier_rows = idx[45:48]                       # 3 giá trị ngoại lai/nhập sai

df.loc[fail_screen, "SL1"] = 2
df.loc[fail_screen, "TANSUAT"] = 0
df.loc[fail_attn, "AC1"] = rng.choice([1, 3, 4, 5], size=len(fail_attn))
for r in straight:
    df.loc[r, items] = rng.choice([4, 5])
    df.loc[r, "AC1"] = df.loc[r, "YD1"]
df = df.astype({c: "float" for c in items})     # cho phép giá trị thiếu
for r in missing_rows:
    cols = rng.choice(items, size=rng.choice([1, 2]), replace=False)
    df.loc[r, cols] = np.nan
df.loc[outlier_rows[0], "TUOI"] = 230           # lỗi nhập liệu (23 bị gõ thành 230)
df.loc[outlier_rows[1], "TANSUAT"] = 95         # mua rất nhiều lần: ngoại lai thật hoặc lỗi
df.loc[outlier_rows[2], "HL2"] = 55             # lỗi nhập liệu ngoài thang 1–5

df[items] = df[items].astype("Int64")             # số nguyên, vẫn giữ ô trống
order = ["ID", "SL1", "GIOITINH", "TUOI", "NGHE", "THUNHAP", "TANSUAT"] + items[:10] + ["AC1"] + items[10:]
df = df[order]

df.to_csv("du_lieu_mau_san_x.csv", index=False, na_rep="")
df.to_excel("du_lieu_mau_san_x.xlsx", index=False, sheet_name="du_lieu")

print(f"Đã tạo {len(df)} phiếu, {len(df.columns)} biến.")
print(f"Không qua gạn lọc: {len(fail_screen)}, sai câu chú ý: {len(fail_attn)}, "
      f"trả lời một mức: {len(straight)}, có giá trị thiếu: {len(missing_rows)}, ngoại lai/lỗi: {len(outlier_rows)}")
