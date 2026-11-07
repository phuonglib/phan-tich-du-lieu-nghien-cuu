# =====================================================================
# Bài 23. Các chỉ số độ phù hợp: so sánh ba mô hình đo lường
#   M5: 5 nhân tố (mô hình lý thuyết)
#   M4: 4 nhân tố, gộp Giá trị cảm nhận và Sự hài lòng
#   M1: 1 nhân tố (mọi câu đo cùng một khái niệm)
# Cách chạy: LANG=C.UTF-8 Rscript so_sanh_do_phu_hop.R
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]; xd <- na.omit(x)

m5 <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
m4 <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GTHL    =~ HI1 + HI2 + HI3 + HI4 + HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
m1 <- paste("CHUNG =~", paste(cau, collapse = " + "))

chi_so <- c("npar", "chisq", "df", "pvalue", "cfi", "tli", "nfi", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper",
            "rmsea.pvalue", "srmr", "gfi", "agfi", "aic", "bic")
bang <- function(du_lieu, thieu) {
  fits <- list(M5 = cfa(m5, du_lieu, missing = thieu), M4 = cfa(m4, du_lieu, missing = thieu),
               M1 = cfa(m1, du_lieu, missing = thieu))
  t <- t(sapply(fits, function(f) fitMeasures(f, chi_so)))
  t <- cbind(t, cmin_df = t[, "chisq"] / t[, "df"])
  list(fits = fits, t = t)
}
fiml <- bang(x, "ml")
du <- bang(xd, "listwise")
cat("=== FIML, N = 267 ===\n"); print(round(fiml$t, 3))
cat("=== Trả lời đủ, N = 254 (như AMOS khi có GFI, AGFI) ===\n"); print(round(du$t, 3))
write.csv(round(fiml$t, 4), file.path(here, "do_phu_hop_fiml.csv"))
write.csv(round(du$t, 4), file.path(here, "do_phu_hop_du.csv"))

cat("=== Kiểm định chênh lệch chi bình phương (FIML) ===\n")
print(anova(fiml$fits$M5, fiml$fits$M4))
print(anova(fiml$fits$M4, fiml$fits$M1))
cat("Tương quan GIATRI-HAILONG trong M5:",
    round(subset(standardizedSolution(fiml$fits$M5), lhs == "GIATRI" & rhs == "HAILONG")$est.std, 3), "\n")

# Chi bình phương phụ thuộc cỡ mẫu: cùng mức sai lệch, cỡ mẫu gấp đôi, gấp bốn
cat("=== Chi bình phương của M4 khi nhân đôi, nhân bốn cỡ mẫu (cùng ma trận hiệp phương sai) ===\n")
S <- cov(xd)
for (n in c(254, 508, 1016)) {
  f <- cfa(m4, sample.cov = S, sample.nobs = n)
  fm <- fitMeasures(f, c("chisq", "df", "pvalue", "cfi", "rmsea", "srmr"))
  cat(sprintf("N = %4d: chi2 = %7.2f, p = %.4f, CFI = %.3f, RMSEA = %.3f, SRMR = %.3f\n",
              n, fm["chisq"], fm["pvalue"], fm["cfi"], fm["rmsea"], fm["srmr"]))
}
