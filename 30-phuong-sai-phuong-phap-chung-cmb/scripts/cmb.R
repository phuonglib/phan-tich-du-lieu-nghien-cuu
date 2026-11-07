# =====================================================================
# Bài 30. Phương sai phương pháp chung (common method bias, CMB).
# 1. Kiểm định một nhân tố của Harman: EFA không xoay trên 20 câu
# 2. Harman dạng CFA: mô hình 1 nhân tố so với 5 nhân tố
# 3. Nhân tố phương pháp chung (CLF): thêm một nhân tố tải lên cả 20 câu,
#    hệ số tải bằng nhau, không tương quan với 5 nhân tố
# 4. Kiểm tra độ vững của 7 đường dẫn khi đưa CLF vào mô hình SEM
# Cách chạy: LANG=C.UTF-8 Rscript cmb.R
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]; xd <- na.omit(x)
chiso <- c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")

# ---- 1. Harman: EFA không xoay (dữ liệu đủ, như SPSS mặc định listwise)
R <- cor(xd)
ev <- eigen(R)$values
cat("N đủ =", nrow(xd), "\nGiá trị riêng (PCA):", round(ev[1:6], 3), "\n")
cat("% phương sai nhân tố 1 (PCA):", round(100 * ev[1] / 20, 2), "\n")
cat("Số nhân tố có giá trị riêng > 1:", sum(ev > 1), "\n")
cat("% tích lũy 5 nhân tố:", round(100 * sum(ev[1:5]) / 20, 2), "\n")
# Trục chính (PAF) 1 nhân tố, lặp tính lại tính chung (communality) như SPSS
h2 <- 1 - 1 / diag(solve(R))
for (k in 1:100) { Rr <- R; diag(Rr) <- h2; e <- eigen(Rr); l <- sqrt(e$values[1]) * e$vectors[, 1]; h2n <- l^2
  if (max(abs(h2n - h2)) < 1e-3) break; h2 <- h2n }
cat("% phương sai 1 nhân tố (PAF, sau", k, "vòng lặp):", round(100 * sum(l^2) / 20, 2), "\n")
write.csv(data.frame(thanh_phan = 1:20, gia_tri_rieng = ev, phan_tram = 100 * ev / 20, tich_luy = cumsum(100 * ev / 20)),
          file.path(here, "harman_gia_tri_rieng.csv"), row.names = FALSE)

# ---- 2. CFA 1 nhân tố so với 5 nhân tố (FIML, N = 267)
m5 <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
m1 <- paste("CHUNG =~", paste(cau, collapse = " + "))
f5 <- cfa(m5, data = x, missing = "ml"); f1 <- cfa(m1, data = x, missing = "ml")
# ---- 3. CLF: hệ số tải bằng nhau (nhãn m), trực giao với 5 nhân tố
mclf <- paste0(m5, '
  CLF =~ NA*XN1 + ', paste0("m*", cau, collapse = " + "), '
  CLF ~~ 1*CLF
  CLF ~~ 0*XACNHAN + 0*GIATRI + 0*HAILONG + 0*NIEMTIN + 0*YDINH')
fc <- cfa(mclf, data = x, missing = "ml")
# CLF hệ số tải tự do (bản không ràng buộc) để đối chiếu
mclf2 <- paste0(m5, '
  CLF =~ ', paste(cau, collapse = " + "), '
  CLF ~~ 0*XACNHAN + 0*GIATRI + 0*HAILONG + 0*NIEMTIN + 0*YDINH')
fc2 <- suppressWarnings(cfa(mclf2, data = x, missing = "ml"))
cat("CLF hệ số tải tự do hội tụ?", lavInspect(fc2, "converged"), "\n")
if (!lavInspect(fc2, "converged")) fc2 <- NULL
bang <- rbind("1 nhân tố (Harman CFA)" = fitMeasures(f1, chiso), "5 nhân tố (Bài 22)" = fitMeasures(f5, chiso),
              "5 nhân tố + CLF (tải bằng nhau)" = fitMeasures(fc, chiso))
print(round(bang, 3))
print(anova(f1, f5)); print(anova(f5, fc))
write.csv(data.frame(mo_hinh = rownames(bang), bang, row.names = NULL), file.path(here, "cmb_do_phu_hop.csv"), row.names = FALSE)
# So sánh hệ số tải chuẩn hóa
s5 <- subset(standardizedSolution(f5), op == "=~")
sc <- subset(standardizedSolution(fc), op == "=~")
tai <- data.frame(cau = s5$rhs, nhan_to = s5$lhs, tai_khong_CLF = s5$est.std,
                  tai_co_CLF = sc$est.std[sc$lhs != "CLF"], tai_CLF = sc$est.std[sc$lhs == "CLF"])
tai$chenh_lech <- tai$tai_khong_CLF - tai$tai_co_CLF
tai$pv_phuong_phap <- tai$tai_CLF^2
print(tai, digits = 3)
pm <- subset(parameterEstimates(fc), label == "m")[1, ]
cat("Hệ số tải CLF chưa chuẩn hóa m =", round(pm$est, 4), " SE =", round(pm$se, 4), " z =", round(pm$z, 3), " p =", signif(pm$pvalue, 3),
    " KTC:", round(pm$ci.lower, 3), round(pm$ci.upper, 3), "\n")
cat("Phương sai CLF (cố định 1). Trung bình % phương sai do phương pháp:", round(100 * mean(tai$pv_phuong_phap), 2),
    "%; khoảng", round(100 * range(tai$pv_phuong_phap), 2), "\n")
cat("Chênh lệch hệ số tải lớn nhất:", round(max(abs(tai$chenh_lech)), 3), "\n")
if (!is.null(fc2)) { s2 <- subset(standardizedSolution(fc2), op == "=~" & lhs == "CLF"); cat("CLF tự do, tải chuẩn hóa:", round(range(s2$est.std), 3), "; TB % phương sai:", round(100 * mean(s2$est.std^2), 2), "\n") }
write.csv(tai, file.path(here, "cmb_he_so_tai.csv"), row.names = FALSE)
# Tương quan giữa nhân tố trước/sau CLF
cat("Phương sai tiềm ẩn âm? FIML SEM sau:\n")
cat("Tương quan nhân tố không CLF:\n"); print(round(lavInspect(f5, "cor.lv"), 3))
cat("Tương quan nhân tố có CLF:\n"); print(round(lavInspect(fc, "cor.lv")[1:5, 1:5], 3))

# ---- 4. SEM có và không có CLF
cautruc <- '
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + HAILONG + NIEMTIN
  XACNHAN ~~ NIEMTIN'
s0 <- sem(paste0(m5, cautruc), data = x, missing = "ml")
s1 <- sem(paste0(mclf, cautruc), data = x, missing = "ml")
p0 <- subset(parameterEstimates(s0, standardized = TRUE), op == "~")
p1 <- subset(parameterEstimates(s1, standardized = TRUE), op == "~")
dd <- data.frame(H = paste0("H", 1:7), duong = paste(p0$lhs, "~", p0$rhs), beta_khong = p0$std.all, p_khong = p0$pvalue,
                 beta_CLF = p1$std.all, p_CLF = p1$pvalue)
dd$chenh <- dd$beta_khong - dd$beta_CLF
print(dd, digits = 3)
pv <- subset(parameterEstimates(s1), op == "~~" & lhs == rhs & lhs %in% c("XACNHAN","GIATRI","HAILONG","NIEMTIN","YDINH","CLF"))
print(pv[, c("lhs", "est", "se", "pvalue")], digits = 3)
print(round(rbind(khong = fitMeasures(s0, chiso), CLF = fitMeasures(s1, chiso)), 3))
cat("R2 không CLF:", round(lavInspect(s0, "r2")[c("GIATRI", "HAILONG", "YDINH")], 3), "\n")
cat("R2 có CLF:", round(lavInspect(s1, "r2")[c("GIATRI", "HAILONG", "YDINH")], 3), "\n")
write.csv(dd, file.path(here, "cmb_duong_dan.csv"), row.names = FALSE)

# ---- 5. Dữ liệu đủ (như AMOS)
f5d <- cfa(m5, data = xd); f1d <- cfa(m1, data = xd); fcd <- cfa(mclf, data = xd)
bd <- rbind("1 nhân tố" = fitMeasures(f1d, chiso), "5 nhân tố" = fitMeasures(f5d, chiso), "5 nhân tố + CLF" = fitMeasures(fcd, chiso))
cat("\nDữ liệu đủ N =", nrow(xd), "\n"); print(round(bd, 3)); print(anova(f1d, f5d)); print(anova(f5d, fcd))
scd <- subset(standardizedSolution(fcd), op == "=~" & lhs == "CLF"); s5d <- subset(standardizedSolution(f5d), op == "=~")
scd2 <- subset(standardizedSolution(fcd), op == "=~" & lhs != "CLF")
cat("CLF tải chuẩn hóa (đủ):", round(range(scd$est.std), 3), " m =", round(subset(parameterEstimates(fcd), label == "m")$est[1], 4), " p =", signif(subset(parameterEstimates(fcd), label == "m")$pvalue[1], 3),
    "; chênh lệch tải lớn nhất:", round(max(abs(s5d$est.std - scd2$est.std)), 3), "; TB % pv:", round(100 * mean(scd$est.std^2), 2), "\n")
write.csv(data.frame(mo_hinh = rownames(bd), bd, row.names = NULL), file.path(here, "cmb_do_phu_hop_du.csv"), row.names = FALSE)
s0d <- sem(paste0(m5, cautruc), data = xd); s1d <- sem(paste0(mclf, cautruc), data = xd)
q0 <- subset(standardizedSolution(s0d), op == "~"); q1 <- subset(standardizedSolution(s1d), op == "~")
cat("Beta đường dẫn (đủ) không/có CLF:\n"); print(round(cbind(q0$est.std, q0$pvalue, q1$est.std, q1$pvalue), 3))

# ---- 6. Mặt hợp lý theo hệ số tải CLF (cố định m từ 0 đến 0,5): vì sao CLF khó xác định
prof <- t(sapply(seq(0, 0.5, by = 0.025), function(mv) {
  mc <- paste0(m5, '\n CLF =~ ', paste0(mv, "*", cau, collapse = " + "),
               '\n CLF ~~ 1*CLF\n CLF ~~ 0*XACNHAN + 0*GIATRI + 0*HAILONG + 0*NIEMTIN + 0*YDINH')
  a <- cfa(mc, data = x, missing = "ml"); b <- sem(paste0(mc, cautruc), data = x, missing = "ml")
  sa <- subset(standardizedSolution(a), op == "=~" & lhs == "CLF")$est.std
  c(m = mv, tai_chuan_hoa_tb = mean(sa), chisq_CFA = fitMeasures(a, "chisq"), chisq_SEM = fitMeasures(b, "chisq"))
}))
print(round(prof, 3))
write.csv(as.data.frame(prof), file.path(here, "cmb_mat_hop_ly.csv"), row.names = FALSE)
