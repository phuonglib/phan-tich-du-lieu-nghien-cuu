"""
Tính cỡ mẫu cho mô hình mẫu của chuỗi bài (ý định mua lại trên sàn X).

Mô hình: 5 khái niệm (XN, HI, HL, NT, YD), mỗi khái niệm 4 biến quan sát = 20 biến.
Cách chạy:  python tinh_co_mau.py      (yêu cầu: pip install scipy)

Các kết quả in ra được dùng trực tiếp trong Bài 4.
"""
import math
from scipy import stats

ALPHA, POWER = 0.05, 0.80
N_CONSTRUCTS, ITEMS_PER = 5, 4
P = N_CONSTRUCTS * ITEMS_PER          # số biến quan sát


def regression_power_n(m, f2, alpha=ALPHA, power=POWER):
    """Cỡ mẫu tối thiểu cho kiểm định F của R² trong hồi quy bội
    (tương đương G*Power: Linear multiple regression, fixed model, R² deviation from zero).
    Tham số phi trung tâm lambda = f² * N."""
    n = m + 2
    while True:
        df1, df2 = m, n - m - 1
        crit = stats.f.ppf(1 - alpha, df1, df2)
        if 1 - stats.ncf.cdf(crit, df1, df2, f2 * n) >= power:
            return n
        n += 1


def rmsea_power_n(df, rmsea0=0.05, rmsea_a=0.08, alpha=ALPHA, power=POWER):
    """Cỡ mẫu tối thiểu cho kiểm định 'close fit' của MacCallum, Browne và Sugawara (1996)."""
    n = 10
    while True:
        lam0 = (n - 1) * df * rmsea0 ** 2
        lam_a = (n - 1) * df * rmsea_a ** 2
        crit = stats.ncx2.ppf(1 - alpha, df, lam0)
        if 1 - stats.ncx2.cdf(crit, df, lam_a) >= power:
            return n
        n += 1


def inverse_square_root_n(p_min):
    """Phương pháp căn bậc hai nghịch đảo (Kock & Hadaya, 2018), mức ý nghĩa 5%, công suất 80%."""
    return math.ceil((2.486 / abs(p_min)) ** 2)


def cochran_n(p=0.5, e=0.05, z=1.96):
    return math.ceil(z ** 2 * p * (1 - p) / e ** 2)


def yamane_n(N, e=0.05):
    return math.ceil(N / (1 + N * e ** 2))


def cfa_free_params(k, p):
    loadings = p - k                  # mỗi khái niệm cố định 1 hệ số tải
    errors = p
    factor_var = k
    factor_cov = k * (k - 1) // 2
    return loadings + errors + factor_var + factor_cov


if __name__ == "__main__":
    print(f"Số biến quan sát p = {P}")
    print("\n1) EFA (Hair et al., 2019)")
    print(f"   Tỷ lệ 5:1  -> {5 * P}")
    print(f"   Tỷ lệ 10:1 -> {10 * P}")

    m = 3  # hồi quy YD ~ HI + HL + NT
    print(f"\n2) Hồi quy bội với m = {m} biến độc lập")
    print(f"   Green (1991): 50 + 8m = {50 + 8 * m};  104 + m = {104 + m}")
    for f2, lab in [(0.02, 'nhỏ'), (0.15, 'trung bình'), (0.35, 'lớn')]:
        print(f"   Phân tích công suất, f² = {f2} ({lab}): N = {regression_power_n(m, f2)}")

    print("\n3) PLS-SEM, căn bậc hai nghịch đảo")
    for pm in [0.10, 0.15, 0.20, 0.25, 0.30]:
        print(f"   p_min = {pm:.2f} -> N = {inverse_square_root_n(pm)}")

    q = cfa_free_params(N_CONSTRUCTS, P)
    moments = P * (P + 1) // 2
    df = moments - q
    print(f"\n4) CB-SEM (CFA {N_CONSTRUCTS} khái niệm): tham số tự do q = {q}, df = {df}")
    print(f"   Tỷ lệ N:q 10:1 -> {10 * q};  20:1 -> {20 * q}")
    print(f"   Công suất RMSEA (0,05 so với 0,08): N = {rmsea_power_n(df)}")

    print("\n5) Ước lượng tỷ lệ (thống kê mô tả)")
    print(f"   Cochran (p = 0,5; e = 5%): {cochran_n()}")
    for N in [500, 2000, 100000]:
        print(f"   Yamane với N = {N}: {yamane_n(N)}")

    target, loss = 250, 0.15
    print(f"\n6) Phát phiếu: mục tiêu {target} hợp lệ, dự phòng {loss:.0%} -> {math.ceil(target / (1 - loss))}")
