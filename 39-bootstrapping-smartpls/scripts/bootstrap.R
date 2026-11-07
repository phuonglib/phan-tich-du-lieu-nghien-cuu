# =====================================================================
# Bài 39. Bootstrapping và kiểm định ý nghĩa bảy đường dẫn của mô hình sàn X (PLS-SEM).
# 5000 mẫu bootstrap, khoảng tin cậy percentile 95%, kiểm định hai phía.
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-38.
# Gói: cSEM 0.7.1. Kết quả dao động nhẹ theo mẫu bootstrap ngẫu nhiên (seed 2026).
# Cách chạy: LANG=C.UTF-8 Rscript bootstrap.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../../bai-33/du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
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
f <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
set.seed(2026)
bs <- resamplecSEMResults(f, .R = 5000, .seed = 2026)
s <- summarize(bs, .ci = "CI_percentile")$Estimates$Path_estimates
boot <- bs$Estimates$Estimates_resample$Estimates1$Path_estimates$Resampled
kq <- data.frame(duong = s$Name, he_so = s$Estimate, trung_binh_bs = colMeans(boot[, s$Name]),
                 do_lech_chuan = s$Std_err, t = s$t_stat, p = s$p_value,
                 ci_duoi = s[["CI_percentile.95%L"]], ci_tren = s[["CI_percentile.95%U"]])
options(width = 200); print(kq, digits = 3, row.names = FALSE)
# t tính tay: hệ số / độ lệch chuẩn bootstrap
h7 <- kq$duong == "YDINH ~ NIEMTIN"; cat("t tính tay H7:", round(kq$he_so[h7] / kq$do_lech_chuan[h7], 3), "\n")
write.csv(kq, "bootstrap_duong_dan.csv", row.names = FALSE)
# Phân phối bootstrap của hai đường dẫn (dùng cho Hình phân phối trong bài): H4 và H7
write.csv(data.frame(H4 = boot[, "YDINH ~ XACNHAN"], H7 = boot[, "YDINH ~ NIEMTIN"]),
          "phan_phoi_bootstrap.csv", row.names = FALSE)
