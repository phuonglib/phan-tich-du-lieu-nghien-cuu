# =====================================================================
# Bài 34. Đánh giá mô hình đo lường reflective của mô hình sàn X (PLS-SEM).
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33.
# Chỉ số: hệ số tải, độ tin cậy câu hỏi (bình phương hệ số tải), Cronbach's alpha,
#         rho_A (Dijkstra-Henseler), rho_c (composite reliability), AVE.
# So sánh: PLS-SEM (như SmartPLS mặc định), PLSc-SEM, và CB-SEM của Bài 24.
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript danh_gia_do_luong.R
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
kn <- c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH")

pls <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
plsc <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = TRUE)

# 1. Hệ số tải và độ tin cậy câu hỏi
tai <- summarize(pls)$Estimates$Loading_estimates
bang_tai <- data.frame(khai_niem = sub(" =~.*", "", tai$Name), cau = sub(".*=~ ", "", tai$Name),
                       he_so_tai = tai$Estimate, do_tin_cay_cau = tai$Estimate^2)
bang_tai <- bang_tai[order(match(bang_tai$khai_niem, kn), bang_tai$cau), ]
print(bang_tai, digits = 3, row.names = FALSE)

# 2. Độ tin cậy nhất quán nội tại và AVE
a <- assess(pls, .quality_criterion = c("cronbachs_alpha", "reliability", "ave"))
# rho_A theo Dijkstra & Henseler (2015): (w'w)^2 * w'(S - diag S)w / w'(ww' - diag ww')w,
# với w là trọng số ước lượng (chuẩn hóa để biến tổng hợp có phương sai 1), S là ma trận tương quan câu hỏi.
# (assess() của cSEM trả rho_A = 1 khi .disattenuate = FALSE nên tính trực tiếp.)
S <- cor(x)
W <- pls$Estimates$Weight_estimates
rho_A <- sapply(kn, function(k) {
  v <- colnames(W)[W[k, ] != 0]; w <- W[k, v]; s <- S[v, v]  # ghép theo tên câu hỏi
  (sum(w^2))^2 * as.numeric(t(w) %*% (s - diag(diag(s))) %*% w) /
    as.numeric(t(w) %*% (w %*% t(w) - diag(w^2)) %*% w)
})
rel <- data.frame(khai_niem = kn,
                  alpha = a$Reliability$Cronbachs_alpha[kn],
                  rho_A = rho_A[kn],
                  rho_c = a$Reliability$Joereskogs_rho[kn],
                  AVE = a$AVE[kn], row.names = NULL)
print(rel, digits = 3)

# Kiểm tra bằng công thức: rho_c = (tổng L)^2 / [(tổng L)^2 + tổng(1 - L^2)], AVE = trung bình L^2
tay <- do.call(rbind, lapply(split(bang_tai$he_so_tai, bang_tai$khai_niem), function(L)
  c(rho_c = sum(L)^2 / (sum(L)^2 + sum(1 - L^2)), AVE = mean(L^2))))
print(round(tay[kn, ], 3))

# 3. AVE theo PLSc (hiệu chỉnh) để so với CB-SEM ở Bài 24
ac <- assess(plsc, .quality_criterion = c("ave", "reliability"))
so_sanh <- data.frame(khai_niem = kn, AVE_PLS = a$AVE[kn], AVE_PLSc = ac$AVE[kn],
                      rho_c_PLS = rel$rho_c, rho_c_PLSc = ac$Reliability$Joereskogs_rho[kn], row.names = NULL)
print(so_sanh, digits = 3)

# 4. Thử loại câu tải thấp nhất của mỗi thang đo (minh họa quy tắc 0,40 đến 0,708)
cat("Hệ số tải thấp nhất:", round(min(bang_tai$he_so_tai), 3), "(", bang_tai$cau[which.min(bang_tai$he_so_tai)], ")\n")
cat("Số câu dưới 0,708:", sum(bang_tai$he_so_tai < 0.708), "\n")

write.csv(bang_tai, "he_so_tai.csv", row.names = FALSE)
write.csv(rel, "do_tin_cay_ave.csv", row.names = FALSE)
write.csv(so_sanh, "ave_pls_plsc.csv", row.names = FALSE)
