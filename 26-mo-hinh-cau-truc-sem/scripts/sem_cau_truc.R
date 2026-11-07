# =====================================================================
# Bài 26. Mô hình cấu trúc (SEM) cho mô hình ý định mua lại trên sàn X.
# Thiết lập như AMOS: ML, FIML (Estimate means and intercepts),
# hệ số tải đầu tiên cố định bằng 1, phần dư cấu trúc d1-d3.
# Cách chạy: LANG=C.UTF-8 Rscript sem_cau_truc.R
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]
do_luong <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
cau_truc <- '
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + HAILONG + NIEMTIN
  XACNHAN ~~ NIEMTIN'
cfa_fit <- cfa(do_luong, data = x, missing = "ml")
sem_fit <- sem(paste(do_luong, cau_truc), data = x, missing = "ml")
fm <- c("npar", "chisq", "df", "pvalue", "cfi", "tli", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "srmr", "aic", "bic")
t <- rbind(CFA = fitMeasures(cfa_fit, fm), SEM = fitMeasures(sem_fit, fm))
print(round(t, 3)); write.csv(round(t, 4), file.path(here, "do_phu_hop_cfa_sem.csv"))
print(anova(cfa_fit, sem_fit))
pe <- parameterEstimates(sem_fit, standardized = TRUE)
dd <- subset(pe, op == "~")[, c("lhs", "rhs", "est", "se", "z", "pvalue", "std.all")]
print(dd, digits = 3); write.csv(dd, file.path(here, "he_so_duong_dan.csv"), row.names = FALSE)
r2 <- lavInspect(sem_fit, "r2")[c("GIATRI", "HAILONG", "YDINH")]; print(round(r2, 3))
write.csv(data.frame(bien = names(r2), r2 = r2), file.path(here, "r2.csv"), row.names = FALSE)
cv <- subset(pe, op == "~~" & lhs == "XACNHAN" & rhs == "NIEMTIN"); print(cv[, c("est", "pvalue", "std.all")])
# Hệ số tải gần như không đổi so với CFA
l1 <- subset(standardizedSolution(cfa_fit), op == "=~")$est.std
l2 <- subset(standardizedSolution(sem_fit), op == "=~")$est.std
cat("Chênh lệch hệ số tải lớn nhất CFA - SEM:", round(max(abs(l1 - l2)), 4), "\n")
# Phần dư cấu trúc (phương sai chuẩn hóa = 1 - R2)
print(subset(standardizedSolution(sem_fit), op == "~~" & lhs %in% c("GIATRI", "HAILONG", "YDINH") & lhs == rhs)[, c("lhs", "est.std")])
# Chỉ số điều chỉnh cho đường dẫn cấu trúc bị bỏ
mi <- modindices(sem_fit)
print(subset(mi, op == "~" & lhs %in% c("GIATRI", "HAILONG", "YDINH", "XACNHAN", "NIEMTIN"))[, c("lhs", "op", "rhs", "mi", "sepc.all")], digits = 3)

# Lỗi hay gặp: quên vẽ hiệp phương sai giữa hai biến ngoại sinh (AMOS mặc định coi bằng 0)
sem_qu <- sem(paste(do_luong, sub("XACNHAN ~~ NIEMTIN", "XACNHAN ~~ 0*NIEMTIN", cau_truc)), data = x, missing = "ml")
cat("\nQuên hiệp phương sai XACNHAN-NIEMTIN:\n")
print(round(fitMeasures(sem_qu, c("chisq", "df", "cfi", "rmsea", "srmr")), 3))
print(anova(sem_fit, sem_qu))
