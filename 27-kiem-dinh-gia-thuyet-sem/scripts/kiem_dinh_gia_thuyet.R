# =====================================================================
# Bài 27. Kiểm định giả thuyết trong SEM và đọc hệ số chuẩn hóa.
#   1. Hệ số chưa chuẩn hóa, chuẩn hóa, C.R., p, KTC 95%
#   2. Bootstrap KTC (2000 mẫu, 254 người trả lời đủ) để kiểm tra độ vững
#   3. Hệ số ảnh hưởng f² của từng biến dự báo cho YDINH
#   4. So sánh hai hệ số: NIEMTIN với HAILONG đến YDINH
# Cách chạy: LANG=C.UTF-8 Rscript kiem_dinh_gia_thuyet.R
# =====================================================================
library(lavaan)
set.seed(2026)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]; xd <- na.omit(x)
dl <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
ct <- '
  GIATRI  ~ h1*XACNHAN
  HAILONG ~ h2*XACNHAN + h3*GIATRI
  YDINH   ~ h4*XACNHAN + h5*GIATRI + h6*HAILONG + h7*NIEMTIN
  XACNHAN ~~ NIEMTIN
  hieu_NT_HL := h7 - h6'
fit <- sem(paste(dl, ct), data = x, missing = "ml")
pe <- parameterEstimates(fit, standardized = TRUE)
ss <- standardizedSolution(fit)
gt <- subset(pe, op == "~"); sg <- subset(ss, op == "~")
bang <- data.frame(gia_thuyet = paste0("H", 1:7), duong = paste(gt$rhs, "->", gt$lhs),
                   B = gt$est, SE = gt$se, CR = gt$z, p = gt$pvalue, B_low = gt$ci.lower, B_up = gt$ci.upper,
                   beta = sg$est.std, beta_low = sg$ci.lower, beta_up = sg$ci.upper)
# Bootstrap trên dữ liệu đủ (như AMOS)
fd <- sem(paste(dl, ct), data = xd, se = "bootstrap", bootstrap = 2000)
bb <- subset(parameterEstimates(fd, boot.ci.type = "perc"), op == "~")
bang$boot_low <- bb$ci.lower; bang$boot_up <- bb$ci.upper
print(bang, digits = 3, row.names = FALSE)
write.csv(bang, file.path(here, "gia_thuyet.csv"), row.names = FALSE)
cat("\nSo sánh h7 - h6 (chưa chuẩn hóa):\n"); print(subset(pe, op == ":=")[, c("est", "se", "z", "pvalue", "ci.lower", "ci.upper")])
cat("Chuẩn hóa:\n"); print(subset(ss, op == ":=")[, c("est.std", "se", "pvalue")])
# Kiểm định Wald (tương đương)
print(lavTestWald(fit, "h7 == h6"))
# f² cho từng biến dự báo của YDINH
r2_full <- lavInspect(fit, "r2")["YDINH"]
f2 <- sapply(c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN"), function(v) {
  ct2 <- sub(paste0(" \\+ h[0-9]\\*", v, "|h[0-9]\\*", v, " \\+ "), "", sub("hieu_NT_HL := h7 - h6", "", ct))
  ct2 <- sub(paste0("YDINH   ~ (.*)"), "YDINH ~ \\1", ct2)
  m2 <- sem(paste(dl, ct2), data = x, missing = "ml")
  r2 <- lavInspect(m2, "r2")["YDINH"]
  c(r2_bo = unname(r2), f2 = unname((r2_full - r2) / (1 - r2_full)))
})
print(round(t(f2), 4)); cat("R2 YDINH đầy đủ:", round(r2_full, 4), "\n")
write.csv(round(t(f2), 4), file.path(here, "f2.csv"))
