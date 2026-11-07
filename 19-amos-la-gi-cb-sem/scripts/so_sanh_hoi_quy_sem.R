# =====================================================================
# Bài 19. So sánh hồi quy trên điểm trung bình (SPSS/PSPP) với CB-SEM
# (mô hình biến tiềm ẩn) trên cùng dữ liệu mẫu.
# Cách chạy: Rscript so_sanh_hoi_quy_sem.R
# Yêu cầu:   R 4.x, gói lavaan (install.packages("lavaan"))
# lavaan dùng ước lượng hợp lý cực đại (ML) như AMOS; dữ liệu thiếu được
# xử lý bằng FIML, tương đương tùy chọn "Estimate means and intercepts" của AMOS.
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_phan_tich.csv"))

# 1. Hồi quy trên điểm trung bình (như Bài 14), biến chuẩn hóa để có beta
z <- as.data.frame(scale(d[, c("XN", "HI", "HL", "NT", "YD")]))
m1 <- lm(HI ~ XN, z); m2 <- lm(HL ~ XN + HI, z); m3 <- lm(YD ~ XN + HI + HL + NT, z)
cat("\n=== Hồi quy trên điểm trung bình (beta chuẩn hóa) ===\n")
print(round(coef(m1)[-1], 3)); print(round(coef(m2)[-1], 3)); print(round(coef(m3)[-1], 3))
cat("R2:", round(summary(m1)$r.squared, 3), round(summary(m2)$r.squared, 3), round(summary(m3)$r.squared, 3), "\n")

# 2. CB-SEM: mô hình đo lường + mô hình cấu trúc
mo_hinh <- '
  # Mô hình đo lường
  XN =~ XN1 + XN2 + XN3 + XN4
  HI =~ HI1 + HI2 + HI3 + HI4
  HL =~ HL1 + HL2 + HL3 + HL4
  NT =~ NT1 + NT2 + NT3 + NT4R
  YD =~ YD1 + YD2 + YD3 + YD4
  # Mô hình cấu trúc
  HI ~ XN
  HL ~ XN + HI
  YD ~ XN + HI + HL + NT
'
cau_hoi <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), paste0("NT", 1:3), "NT4R", paste0("YD", 1:4))
fit <- sem(mo_hinh, data = d[, cau_hoi], estimator = "ML", missing = "ml")
cat("\n=== CB-SEM ===\n")
cat("N =", lavInspect(fit, "nobs"), "\n")
print(round(fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "srmr")), 3))
pe <- standardizedSolution(fit)
print(subset(pe, op == "~")[, c("lhs", "op", "rhs", "est.std", "se", "pvalue")], digits = 3)
cat("R2:\n"); print(round(lavInspect(fit, "r2")[c("HI", "HL", "YD")], 3))
cat("Hệ số tải chuẩn hóa: ", paste(range(round(subset(pe, op == "=~")$est.std, 2)), collapse = " đến "), "\n")

# Lưu bảng so sánh cho hình
ss <- subset(pe, op == "~")
hq <- c(coef(m1)[-1], coef(m2)[-1], coef(m3)[-1])
p_hq <- c(summary(m1)$coef[-1, 4], summary(m2)$coef[-1, 4], summary(m3)$coef[-1, 4])
out <- data.frame(duong = paste(ss$rhs, "->", ss$lhs), hoi_quy = round(hq, 3), p_hoi_quy = round(p_hq, 4),
                  sem = round(ss$est.std, 3), p_sem = round(ss$pvalue, 4))
print(out)
write.csv(out, file.path(here, "so_sanh_hoi_quy_sem.csv"), row.names = FALSE)
