# =====================================================================
# Bài 37. Đánh giá mô hình cấu trúc của mô hình sàn X (PLS-SEM):
# đa cộng tuyến giữa các biến tiềm ẩn (VIF), R², R² hiệu chỉnh, f².
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-35.
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript mo_hinh_cau_truc.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../../bai-33/du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- na.omit(d[, cau]); n <- nrow(x); cat("N =", n, "\n")
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
LV <- as.data.frame(f$Estimates$Construct_scores)
pt <- list(GIATRI = "XACNHAN", HAILONG = c("XACNHAN", "GIATRI"), YDINH = c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN"))

r2 <- function(y, xs) summary(lm(reformulate(xs, y), data = LV))$r.squared
# 1. VIF giữa các biến tiềm ẩn dự báo cùng một biến phụ thuộc
vif <- do.call(rbind, lapply(names(pt), function(y) {
  xs <- pt[[y]]
  data.frame(phu_thuoc = y, doc_lap = xs, VIF = sapply(xs, function(v)
    if (length(xs) == 1) 1 else 1 / (1 - r2(v, setdiff(xs, v)))), row.names = NULL)
}))
# 2. R² và R² hiệu chỉnh
R2 <- data.frame(bien = names(pt), R2 = sapply(names(pt), function(y) r2(y, pt[[y]])),
                 k = sapply(pt, length), row.names = NULL)
R2$R2_hieu_chinh <- 1 - (1 - R2$R2) * (n - 1) / (n - R2$k - 1)
# 3. f² = (R² đủ - R² khi bỏ biến) / (1 - R² đủ)
vif$f2 <- mapply(function(y, v) {
  du <- r2(y, pt[[y]]); bo <- if (length(pt[[y]]) == 1) 0 else r2(y, setdiff(pt[[y]], v))
  (du - bo) / (1 - du)
}, vif$phu_thuoc, vif$doc_lap)
vif$duong_dan <- mapply(function(y, v) f$Estimates$Path_estimates[y, v], vif$phu_thuoc, vif$doc_lap)
print(R2, digits = 3); print(vif, digits = 3)
cat("Đối chiếu R² của cSEM:", round(summarize(f)$Estimates$R2, 3), "\n")
write.csv(R2, "r2.csv", row.names = FALSE)
write.csv(vif, "vif_f2.csv", row.names = FALSE)
