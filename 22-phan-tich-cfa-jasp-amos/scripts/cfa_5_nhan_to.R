# =====================================================================
# Bài 22. Phân tích nhân tố khẳng định (CFA) cho 5 thang đo.
# Cách chạy: LANG=C.UTF-8 Rscript cfa_5_nhan_to.R
# Yêu cầu:   R 4.x, gói lavaan
# Thiết lập giống AMOS: ML, cố định hệ số tải đầu tiên bằng 1,
# FIML cho dữ liệu thiếu (Estimate means and intercepts).
# Kiểm định Mardia và bootstrap Bollen-Stine làm trên 254 người trả lời
# đủ, vì AMOS chỉ tính hai kết quả này khi dữ liệu không có ô trống.
# =====================================================================
library(lavaan)
set.seed(2026)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]; xd <- na.omit(x)

mo_hinh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
'
# ---- 1. Phân phối chuẩn (giống "Assessment of normality" của AMOS) ----
n <- nrow(xd); p <- ncol(xd)
sk <- sapply(xd, function(v) { z <- v - mean(v); mean(z^3) / mean(z^2)^1.5 })
ku <- sapply(xd, function(v) { z <- v - mean(v); mean(z^4) / mean(z^2)^2 - 3 })
chuan <- data.frame(bien = cau, min = sapply(xd, min), max = sapply(xd, max),
                    skew = round(sk, 3), cr_skew = round(sk / sqrt(6 / n), 3),
                    kurtosis = round(ku, 3), cr_kurt = round(ku / sqrt(24 / n), 3))
S <- cov(xd) * (n - 1) / n
Z <- scale(xd, scale = FALSE)
D2 <- rowSums((Z %*% solve(S)) * Z)
b2p <- mean(D2^2)
mardia <- b2p - p * (p + 2)
cr_mardia <- mardia / sqrt(8 * p * (p + 2) / n)
cat(sprintf("N = %d. Mardia (multivariate kurtosis) = %.3f, c.r. = %.3f\n", n, mardia, cr_mardia))
print(chuan, row.names = FALSE)
write.csv(rbind(chuan, data.frame(bien = "Multivariate", min = NA, max = NA, skew = NA, cr_skew = NA,
                                  kurtosis = round(mardia, 3), cr_kurt = round(cr_mardia, 3))),
          file.path(here, "phan_phoi_chuan.csv"), row.names = FALSE, fileEncoding = "UTF-8")
# Quan sát xa tâm nhất (Mahalanobis d2, giống AMOS)
d2s <- D2 * n / (n - 1)  # AMOS dùng hiệp phương sai mẫu không chệch
o <- order(d2s, decreasing = TRUE)[1:5]
p1 <- pchisq(d2s[o], p, lower.tail = FALSE)
cat("5 quan sát xa tâm nhất (ID, d2, p1):\n")
print(data.frame(ID = d$ID[complete.cases(x)][o], d2 = round(d2s[o], 2), p1 = round(p1, 3)))

# ---- 2. CFA với FIML trên 267 người ------------------------------------
fit <- cfa(mo_hinh, data = x, estimator = "ML", missing = "ml")
print(round(fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "rmsea.ci.lower",
                               "rmsea.ci.upper", "srmr")), 3))
pe <- parameterEstimates(fit, standardized = TRUE)
tai <- subset(pe, op == "=~")[, c("lhs", "rhs", "est", "se", "z", "pvalue", "std.all")]
tai$r2 <- tai$std.all^2
print(tai, digits = 3, row.names = FALSE)
write.csv(tai, file.path(here, "he_so_tai.csv"), row.names = FALSE, fileEncoding = "UTF-8")
tq <- subset(pe, op == "~~" & lhs != rhs & lhs %in% c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH"))
print(tq[, c("lhs", "rhs", "est", "pvalue", "std.all")], digits = 3, row.names = FALSE)
write.csv(tq[, c("lhs", "rhs", "est", "se", "pvalue", "std.all")], file.path(here, "tuong_quan_nhan_to.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
pv <- subset(pe, op == "~~" & lhs == rhs)
cat("Phương sai âm (Heywood)?", any(pv$est < 0), "\n")

# ---- 3. Chỉ số điều chỉnh và phần dư chuẩn hóa ---------------------------
mi <- modindices(fit, sort. = TRUE, minimum.value = 4)
print(head(mi[, c("lhs", "op", "rhs", "mi", "epc", "sepc.all")], 10), digits = 3)
write.csv(head(mi[, c("lhs", "op", "rhs", "mi", "epc", "sepc.all")], 10), file.path(here, "chi_so_dieu_chinh.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
rs <- lavResiduals(fit)$cov.z
cat("Phần dư chuẩn hóa lớn nhất (trị tuyệt đối):", round(max(abs(rs[lower.tri(rs)])), 2), "\n")
cat("Số phần dư chuẩn hóa vượt 2,58:", sum(abs(rs[lower.tri(rs)]) > 2.58), "trên", sum(lower.tri(rs)), "\n")

# ---- 4. Bootstrap Bollen-Stine trên 254 người trả lời đủ ------------------
fit_du <- cfa(mo_hinh, data = xd, estimator = "ML")
bs <- bootstrapLavaan(fit_du, R = 2000, type = "bollen.stine", FUN = fitMeasures, fit.measures = "chisq")
p_bs <- (1 + sum(bs[, 1] >= fitMeasures(fit_du, "chisq"))) / (2000 + 1)
cat(sprintf("Bollen-Stine: chi2 (N=254) = %.2f, p bootstrap = %.3f (2000 mẫu)\n", fitMeasures(fit_du, "chisq"), p_bs))
