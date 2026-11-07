# =====================================================================
# Bài 40. Phân tích biến trung gian của mô hình sàn X (PLS-SEM): tác động gián tiếp cụ thể,
# tổng tác động gián tiếp, tác động tổng. Bootstrap 5000 mẫu, khoảng tin cậy percentile 95%.
# Tác động gián tiếp cụ thể = tích các hệ số đường dẫn, tính trong từng mẫu bootstrap.
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-39.
# Gói: cSEM 0.7.1. Kết quả dao động nhẹ theo mẫu bootstrap ngẫu nhiên (seed 2026).
# Cách chạy: LANG=C.UTF-8 Rscript trung_gian.R
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
B <- bs$Estimates$Estimates_resample$Estimates1$Path_estimates$Resampled
O <- bs$Estimates$Estimates_resample$Estimates1$Path_estimates$Original
duong <- list(
  "XACNHAN -> GIATRI -> HAILONG"          = c("GIATRI ~ XACNHAN", "HAILONG ~ GIATRI"),
  "XACNHAN -> GIATRI -> YDINH"            = c("GIATRI ~ XACNHAN", "YDINH ~ GIATRI"),
  "XACNHAN -> HAILONG -> YDINH"           = c("HAILONG ~ XACNHAN", "YDINH ~ HAILONG"),
  "GIATRI -> HAILONG -> YDINH"            = c("HAILONG ~ GIATRI", "YDINH ~ HAILONG"),
  "XACNHAN -> GIATRI -> HAILONG -> YDINH" = c("GIATRI ~ XACNHAN", "HAILONG ~ GIATRI", "YDINH ~ HAILONG"))
tom <- function(ten, goc, mau) {
  p <- 2 * min(mean(mau <= 0), mean(mau >= 0))  # p hai phía theo phân phối bootstrap
  data.frame(tac_dong = ten, he_so = goc, trung_binh = mean(mau), do_lech_chuan = sd(mau),
             t = abs(goc) / sd(mau), p_bootstrap = p,
             ci_duoi = unname(quantile(mau, .025)), ci_tren = unname(quantile(mau, .975)))
}
cu_the <- do.call(rbind, lapply(names(duong), function(k)
  tom(k, prod(O[duong[[k]]]), apply(B[, duong[[k]], drop = FALSE], 1, prod))))
gt <- function(ks) { g <- Reduce(`+`, lapply(ks, function(k) prod(O[duong[[k]]])))
  m <- Reduce(`+`, lapply(ks, function(k) apply(B[, duong[[k]], drop = FALSE], 1, prod))); list(g, m) }
tong_gt <- rbind(
  do.call(tom, c("Tổng gián tiếp XACNHAN -> YDINH", gt(names(duong)[c(2, 3, 5)]))),
  do.call(tom, c("Tổng gián tiếp GIATRI -> YDINH", gt(names(duong)[4]))),
  do.call(tom, c("Tổng gián tiếp XACNHAN -> HAILONG", gt(names(duong)[1]))))
g1 <- gt(names(duong)[c(2, 3, 5)]); g2 <- gt(names(duong)[4])
tong <- rbind(tom("Tác động tổng XACNHAN -> YDINH", g1[[1]] + O["YDINH ~ XACNHAN"], g1[[2]] + B[, "YDINH ~ XACNHAN"]),
              tom("Tác động tổng GIATRI -> YDINH", g2[[1]] + O["YDINH ~ GIATRI"], g2[[2]] + B[, "YDINH ~ GIATRI"]))
truc_tiep <- rbind(tom("Trực tiếp XACNHAN -> YDINH", O["YDINH ~ XACNHAN"], B[, "YDINH ~ XACNHAN"]),
                   tom("Trực tiếp GIATRI -> YDINH", O["YDINH ~ GIATRI"], B[, "YDINH ~ GIATRI"]))
kq <- rbind(cu_the, tong_gt, tong, truc_tiep)
options(width = 200); print(kq, digits = 3, row.names = FALSE)
# VAF: tỷ lệ tác động gián tiếp trong tác động tổng
cat("VAF XACNHAN -> YDINH:", round(g1[[1]] / (g1[[1]] + O["YDINH ~ XACNHAN"]), 3), "\n")
cat("VAF GIATRI -> YDINH:", round(g2[[1]] / (g2[[1]] + O["YDINH ~ GIATRI"]), 3), "\n")
write.csv(kq, "trung_gian.csv", row.names = FALSE)
