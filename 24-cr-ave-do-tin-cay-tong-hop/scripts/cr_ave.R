# =====================================================================
# Bài 24. Độ tin cậy tổng hợp (CR) và phương sai trích (AVE).
# Tính từ hệ số tải chuẩn hóa của CFA (Bài 22), đối chiếu với
# Cronbach's Alpha (Bài 11) và omega của semTools.
# Cách chạy: LANG=C.UTF-8 Rscript cr_ave.R
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]
mo_hinh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
fit <- cfa(mo_hinh, data = x, missing = "ml")
ss <- subset(standardizedSolution(fit), op == "=~")
alpha <- function(m) { k <- ncol(m); v <- cov(m); k / (k - 1) * (1 - sum(diag(v)) / sum(v)) }
kq <- do.call(rbind, lapply(split(ss, ss$lhs), function(s) {
  l <- s$est.std; e <- 1 - l^2
  data.frame(nhan_to = s$lhs[1], k = length(l), tai_min = min(l), tai_max = max(l),
             tong_tai = sum(l), tong_tai_bp = sum(l^2), tong_sai_so = sum(e),
             CR = sum(l)^2 / (sum(l)^2 + sum(e)), AVE = mean(l^2),
             alpha = alpha(na.omit(x[, s$rhs])))
}))
kq <- kq[match(c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH"), kq$nhan_to), ]
kq$sqrt_AVE <- sqrt(kq$AVE)
tq <- lavInspect(fit, "cor.lv")
kq$MSV <- sapply(kq$nhan_to, function(f) max(tq[f, colnames(tq) != f]^2))
print(kq, digits = 3, row.names = FALSE)
write.csv(kq, file.path(here, "cr_ave.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# Đối chiếu với semTools nếu có (omega dùng hệ số chưa chuẩn hóa, gần với CR)
if (requireNamespace("semTools", quietly = TRUE)) {
  print(round(semTools::compRelSEM(fit), 3))
  print(round(semTools::AVE(fit), 3))
}

# Minh họa: bỏ câu tải thấp nhất của từng thang đo thì CR, AVE thay đổi thế nào
cat("\nBỏ câu có hệ số tải thấp nhất:\n")
for (f in kq$nhan_to) {
  s <- ss[ss$lhs == f, ]; l <- s$est.std[-which.min(s$est.std)]; e <- 1 - l^2
  cat(sprintf("%-8s bỏ %-4s: CR %.3f -> %.3f, AVE %.3f -> %.3f\n", f, s$rhs[which.min(s$est.std)],
              kq$CR[kq$nhan_to == f], sum(l)^2 / (sum(l)^2 + sum(e)), kq$AVE[kq$nhan_to == f], mean(l^2)))
}
