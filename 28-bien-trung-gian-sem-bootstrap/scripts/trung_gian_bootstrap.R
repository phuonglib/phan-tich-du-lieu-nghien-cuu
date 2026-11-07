# =====================================================================
# Bài 28. Phân tích trung gian bằng bootstrap.
# Tác động gián tiếp cụ thể = tích các hệ số trên đường đi.
# 1. FIML (N = 267) + bootstrap 2000 mẫu, KTC percentile (như JASP)
# 2. Dữ liệu đủ (N = 254) + bootstrap 2000 mẫu, KTC percentile và
#    bias-corrected (như AMOS)
# 3. Kiểm định Sobel (phương pháp delta) để so sánh
# Cách chạy: LANG=C.UTF-8 Rscript trung_gian_bootstrap.R
# =====================================================================
library(lavaan)
set.seed(2026)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]; xd <- na.omit(x)
mh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  GIATRI  ~ h1*XACNHAN
  HAILONG ~ h2*XACNHAN + h3*GIATRI
  YDINH   ~ h4*XACNHAN + h5*GIATRI + h6*HAILONG + h7*NIEMTIN
  XACNHAN ~~ NIEMTIN
  # Tác động gián tiếp cụ thể
  XN_GT_YD    := h1*h5
  XN_HL_YD    := h2*h6
  XN_GT_HL_YD := h1*h3*h6
  GT_HL_YD    := h3*h6
  XN_GT_HL    := h1*h3
  # Tổng gián tiếp và tổng
  XN_YD_gian_tiep := h1*h5 + h2*h6 + h1*h3*h6
  XN_YD_tong      := h4 + h1*h5 + h2*h6 + h1*h3*h6
  GT_YD_tong      := h5 + h3*h6
  # So sánh hai đường gián tiếp
  hieu_GT_HL := h1*h5 - h2*h6'
cat("== Delta (Sobel) ==\n")
f0 <- sem(mh, data = x, missing = "ml")
sob <- subset(parameterEstimates(f0), op %in% c(":=", "~"))[, c("label", "est", "se", "z", "pvalue", "ci.lower", "ci.upper")]
print(sob, digits = 3)
cat("== FIML + bootstrap 2000 ==\n")
f1 <- sem(mh, data = x, missing = "ml", se = "bootstrap", bootstrap = 2000)
b1 <- subset(parameterEstimates(f1, boot.ci.type = "perc", standardized = TRUE), op %in% c(":=", "~"))
print(b1[, c("label", "est", "se", "pvalue", "ci.lower", "ci.upper", "std.all")], digits = 3)
cat("== Dữ liệu đủ + bootstrap 2000 ==\n")
f2 <- sem(mh, data = xd, se = "bootstrap", bootstrap = 2000)
p2 <- subset(parameterEstimates(f2, boot.ci.type = "perc"), op %in% c(":=", "~"))
b2 <- subset(parameterEstimates(f2, boot.ci.type = "bca.simple"), op %in% c(":=", "~"))
kq2 <- data.frame(label = p2$label, est = p2$est, perc_low = p2$ci.lower, perc_up = p2$ci.upper,
                  bc_low = b2$ci.lower, bc_up = b2$ci.upper)
print(kq2, digits = 3)
out <- data.frame(label = b1$label, B = b1$est, SE_boot = b1$se, low = b1$ci.lower, up = b1$ci.upper,
                  beta = b1$std.all, sobel_z = sob$z, sobel_p = sob$pvalue,
                  du_perc_low = kq2$perc_low, du_perc_up = kq2$perc_up, du_bc_low = kq2$bc_low, du_bc_up = kq2$bc_up)
write.csv(out, file.path(here, "trung_gian.csv"), row.names = FALSE)
