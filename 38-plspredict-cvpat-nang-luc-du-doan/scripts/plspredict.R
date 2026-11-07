# =====================================================================
# Bài 38. Năng lực dự báo ngoài mẫu của mô hình sàn X: PLSpredict (Shmueli et al., 2016, 2019).
# 10 nhóm (folds), lặp 10 lần, so sánh PLS-SEM với mô hình hồi quy tuyến tính (LM) làm chuẩn.
# Chỉ số: Q²predict, RMSE, MAE cho từng câu hỏi của biến phụ thuộc cuối (YDINH) và các biến trung gian.
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-37.
# Gói: cSEM 0.7.1. Kết quả dao động nhẹ theo cách chia nhóm ngẫu nhiên (seed 2026).
# Cách chạy: LANG=C.UTF-8 Rscript plspredict.R
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
p <- predict(f, .benchmark = "lm", .cv_folds = 10, .r = 10, .disattenuate = FALSE)
kq <- p$Prediction_metrics
print(kq, digits = 3)
write.csv(kq, "plspredict.csv", row.names = FALSE)
