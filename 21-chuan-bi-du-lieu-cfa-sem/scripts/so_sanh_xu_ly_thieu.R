# =====================================================================
# Bài 21. Dữ liệu thiếu trước khi chạy CFA/SEM:
#   1. Kiểm định MCAR của Little (1988)
#   2. So sánh ba cách xử lý trên mô hình đo lường 5 nhân tố:
#      xóa theo danh sách (listwise), FIML, thay bằng trung bình.
# Cách chạy: Rscript so_sanh_xu_ly_thieu.R
# Yêu cầu:   R 4.x, gói lavaan
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]

cat("Số ô thiếu:", sum(is.na(x)), "trên", prod(dim(x)), sprintf("(%.2f%%)\n", 100 * mean(is.na(x))))
cat("Số người thiếu ít nhất một câu:", sum(!complete.cases(x)), "\n")
mau <- apply(is.na(x), 1, function(r) paste(as.integer(r), collapse = ""))
cat("Số mẫu hình thiếu (kể cả mẫu hình đủ):", length(unique(mau)), "\n")

# ---- 1. Kiểm định MCAR của Little ---------------------------------------
# Trung bình và hiệp phương sai ước lượng bằng ML với dữ liệu thiếu (EM/FIML)
bao_hoa <- lavCor(x, missing = "ml", output = "fit", estimator = "ML")
mu <- lavInspect(bao_hoa, "implied")$mean
S <- lavInspect(bao_hoa, "implied")$cov
d2 <- 0; df <- 0
for (m in unique(mau)) {
  hang <- which(mau == m)
  co <- which(!is.na(x[hang[1], ]))
  tb <- colMeans(x[hang, co, drop = FALSE])
  lech <- tb - mu[co]
  d2 <- d2 + length(hang) * as.numeric(t(lech) %*% solve(S[co, co]) %*% lech)
  df <- df + length(co)
}
df <- df - ncol(x)
cat(sprintf("Little's MCAR: chi2 = %.2f, df = %d, p = %.3f\n", d2, df, pchisq(d2, df, lower.tail = FALSE)))

# ---- 2. So sánh ba cách xử lý -------------------------------------------
mo_hinh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
'
tb_thay <- x
for (v in cau) tb_thay[is.na(tb_thay[[v]]), v] <- mean(x[[v]], na.rm = TRUE)

chay <- list(
  "Xóa theo danh sách" = cfa(mo_hinh, data = x, estimator = "ML", missing = "listwise"),
  "FIML"               = cfa(mo_hinh, data = x, estimator = "ML", missing = "ml"),
  "Thay bằng trung bình" = cfa(mo_hinh, data = tb_thay, estimator = "ML")
)
kq <- do.call(rbind, lapply(names(chay), function(k) {
  f <- chay[[k]]
  fm <- fitMeasures(f, c("chisq", "df", "cfi", "tli", "rmsea", "srmr"))
  tai <- subset(standardizedSolution(f), op == "=~")$est.std
  data.frame(cach = k, N = lavInspect(f, "nobs"), chisq = round(fm[["chisq"]], 2), df = fm[["df"]],
             cfi = round(fm[["cfi"]], 3), tli = round(fm[["tli"]], 3), rmsea = round(fm[["rmsea"]], 3),
             srmr = round(fm[["srmr"]], 3), tai_min = round(min(tai), 3), tai_max = round(max(tai), 3),
             tai_HL2 = round(tai[10], 3))
}))
print(kq, row.names = FALSE)
write.csv(kq, file.path(here, "so_sanh_xu_ly_thieu.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# Chênh lệch lớn nhất của hệ số tải chuẩn hóa so với FIML
tai <- sapply(chay, function(f) subset(standardizedSolution(f), op == "=~")$est.std)
cat("Chênh lệch hệ số tải lớn nhất so với FIML:\n")
print(round(apply(abs(tai - tai[, "FIML"]), 2, max), 4))
