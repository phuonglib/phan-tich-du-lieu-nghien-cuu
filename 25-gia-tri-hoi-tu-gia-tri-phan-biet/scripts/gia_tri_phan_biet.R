# =====================================================================
# Bài 25. Giá trị hội tụ và giá trị phân biệt.
#   1. Fornell-Larcker: căn bậc hai AVE so với tương quan giữa các nhân tố
#   2. HTMT (Henseler et al., 2015) và khoảng tin cậy bootstrap
#   3. Kiểm định tương quan khác 1 bằng so sánh mô hình (chi bình phương)
# Cách chạy: LANG=C.UTF-8 Rscript gia_tri_phan_biet.R
# =====================================================================
library(lavaan); library(semTools)
set.seed(2026)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]
nt <- c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH")
mo_hinh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
fit <- cfa(mo_hinh, data = x, missing = "ml")
R <- lavInspect(fit, "cor.lv")[nt, nt]
ave <- read.csv(file.path(here, "cr_ave.csv"))
FL <- R; diag(FL) <- sqrt(ave$AVE[match(nt, ave$nhan_to)])
cat("Ma trận Fornell-Larcker (đường chéo = căn bậc hai AVE):\n"); print(round(FL, 3))
write.csv(round(FL, 4), file.path(here, "fornell_larcker.csv"))

# HTMT trên dữ liệu (pairwise, giống SmartPLS và JASP)
H <- htmt(mo_hinh, data = x, missing = "pairwise", htmt2 = FALSE)
cat("HTMT:\n"); print(round(H, 3))
write.csv(round(as.matrix(H), 4), file.path(here, "htmt.csv"))
H2 <- htmt(mo_hinh, data = x, missing = "pairwise", htmt2 = TRUE)
cat("HTMT2 (trung bình nhân):\n"); print(round(H2, 3))

# Bootstrap KTC 95% cho HTMT (2000 mẫu, percentile)
B <- 2000; n <- nrow(x)
ds <- replicate(B, { i <- sample(n, n, TRUE); m <- as.matrix(htmt(mo_hinh, data = x[i, ], missing = "pairwise", htmt2 = FALSE)); m[lower.tri(m)] })
ci <- t(apply(ds, 1, quantile, c(0.025, 0.975)))
idx <- which(lower.tri(as.matrix(H)), arr.ind = TRUE)
bang <- data.frame(cap = paste(rownames(H)[idx[, 1]], colnames(H)[idx[, 2]], sep = " - "),
                   htmt = as.matrix(H)[lower.tri(as.matrix(H))], low = ci[, 1], up = ci[, 2])
print(bang, digits = 3)
write.csv(bang, file.path(here, "htmt_bootstrap.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# Kiểm định tương quan GIATRI-HAILONG bằng 1 (mô hình ràng buộc)
mh_rb <- paste(mo_hinh, '
  XACNHAN ~~ 1*XACNHAN
  GIATRI ~~ 1*GIATRI
  HAILONG ~~ 1*HAILONG
  NIEMTIN ~~ 1*NIEMTIN
  YDINH ~~ 1*YDINH')
mh_rb <- gsub("=~ ", "=~ NA*", mh_rb)
f0 <- cfa(mh_rb, data = x, missing = "ml")
f1 <- cfa(paste(mh_rb, "\n  GIATRI ~~ 1*HAILONG"), data = x, missing = "ml")
print(anova(f0, f1))
ss <- subset(standardizedSolution(fit), op == "~~" & lhs != rhs & lhs %in% nt)
print(ss[, c("lhs", "rhs", "est.std", "ci.lower", "ci.upper")], digits = 3)
