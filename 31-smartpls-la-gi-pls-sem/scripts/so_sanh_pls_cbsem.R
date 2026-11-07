# =====================================================================
# Bài 31. So sánh PLS-SEM, PLSc-SEM, CB-SEM và hồi quy trên điểm trung bình
# cho mô hình sàn X (254 người trả lời đủ).
# Gói: cSEM 0.6.1 (cũng là gói mà JASP dùng cho Partial Least Squares SEM),
#      lavaan 0.6.21.
# Cách chạy (R của JASP, có sẵn cSEM):
#   flatpak run --command=Rscript org.jaspstats.JASP so_sanh_pls_cbsem.R
# hoặc trên R thường sau khi install.packages(c("cSEM", "lavaan")).
# =====================================================================
.libPaths(c("/app/Modules/module_libs/jaspSem", .libPaths()))
suppressMessages({ library(cSEM); library(lavaan) })
d <- read.csv("../du-lieu/du_lieu_amos.csv")
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- na.omit(d[, cau]); cat("N =", nrow(x), "\n")

mh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + HAILONG + NIEMTIN'
duong <- c("GIATRI ~ XACNHAN", "HAILONG ~ XACNHAN", "HAILONG ~ GIATRI", "YDINH ~ XACNHAN",
           "YDINH ~ GIATRI", "YDINH ~ HAILONG", "YDINH ~ NIEMTIN")

# 1. PLS-SEM (như SmartPLS mặc định: path weighting) và PLSc-SEM
pls  <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
plsc <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = TRUE)
lay_duong <- function(f) { p <- summarize(f)$Estimates$Path_estimates; setNames(p$Estimate, p$Name) }
lay_tai <- function(f) { p <- summarize(f)$Estimates$Loading_estimates; setNames(p$Estimate, p$Name) }

print(verify(pls)); 

# 2. CB-SEM (lavaan, ML) với hiệp phương sai XACNHAN ~~ NIEMTIN như Bài 26
cb <- sem(paste0(mh, "\n XACNHAN ~~ NIEMTIN"), data = x)
sc <- standardizedSolution(cb)
cb_duong <- setNames(sc$est.std[sc$op == "~"], paste(sc$lhs, "~", sc$rhs)[sc$op == "~"])
cb_tai <- setNames(sc$est.std[sc$op == "=~"], paste(sc$lhs, "=~", sc$rhs)[sc$op == "=~"])
cb_r2 <- lavInspect(cb, "r2")[c("GIATRI", "HAILONG", "YDINH")]

# 3. Hồi quy trên điểm trung bình (cách SPSS, Bài 14)
m <- data.frame(XACNHAN = rowMeans(x[, 1:4]), GIATRI = rowMeans(x[, 5:8]), HAILONG = rowMeans(x[, 9:12]),
                NIEMTIN = rowMeans(x[, 13:16]), YDINH = rowMeans(x[, 17:20]))
z <- as.data.frame(scale(m))
r1 <- lm(GIATRI ~ XACNHAN, z); r2 <- lm(HAILONG ~ XACNHAN + GIATRI, z); r3 <- lm(YDINH ~ XACNHAN + GIATRI + HAILONG + NIEMTIN, z)
hq <- c(coef(r1)[2], coef(r2)[2:3], coef(r3)[2:5]); names(hq) <- duong
hq_r2 <- c(summary(r1)$r.squared, summary(r2)$r.squared, summary(r3)$r.squared)

r2_cs <- function(f) { r <- summarize(f)$Estimates$R2; r[c("GIATRI", "HAILONG", "YDINH")] }
bang <- data.frame(H = paste0("H", 1:7), duong = duong, hoi_quy = hq, PLS = lay_duong(pls)[duong],
                   PLSc = lay_duong(plsc)[duong], CB_SEM = cb_duong[duong], row.names = NULL)
print(bang, digits = 3)
r2 <- data.frame(bien = c("GIATRI", "HAILONG", "YDINH"), hoi_quy = hq_r2, PLS = r2_cs(pls), PLSc = r2_cs(plsc), CB_SEM = cb_r2, row.names = NULL)
print(r2, digits = 3)
tai <- data.frame(ten = names(cb_tai), PLS = lay_tai(pls)[names(cb_tai)], PLSc = lay_tai(plsc)[names(cb_tai)], CB_SEM = cb_tai, row.names = NULL)
print(tai, digits = 3)
cat("Hệ số tải trung bình: PLS", round(mean(tai$PLS), 3), " PLSc", round(mean(tai$PLSc), 3), " CB-SEM", round(mean(tai$CB_SEM), 3), "\n")
cat("Độ phù hợp CB-SEM:"); print(round(fitMeasures(cb, c("chisq", "df", "cfi", "rmsea", "srmr")), 3))
cat("SRMR PLS:", round(calculateSRMR(pls), 3), " SRMR PLSc:", round(calculateSRMR(plsc), 3), "\n")

# 4. Bootstrap PLS (5000 mẫu như khuyến nghị của Hair et al., 2022), hạt giống 2026
set.seed(2026)
bs <- resamplecSEMResults(pls, .R = 5000, .seed = 2026)
pb <- summarize(bs, .ci = "CI_percentile")$Estimates$Path_estimates
print(pb[, c("Name", "Estimate", "Std_err", "t_stat", "p_value")], digits = 3)
ci <- infer(bs, .quantity = "CI_percentile")$Path_estimates$CI_percentile
bang$PLS_se <- pb$Std_err[match(duong, pb$Name)]; bang$PLS_p <- pb$p_value[match(duong, pb$Name)]
bang$PLS_low <- ci["95%L", duong]; bang$PLS_up <- ci["95%U", duong]
pcb <- subset(parameterEstimates(cb), op == "~"); bang$CB_p <- pcb$pvalue
print(bang, digits = 3)
write.csv(bang, "so_sanh_duong_dan.csv", row.names = FALSE)
write.csv(r2, "so_sanh_r2.csv", row.names = FALSE)
write.csv(tai, "so_sanh_he_so_tai.csv", row.names = FALSE)
