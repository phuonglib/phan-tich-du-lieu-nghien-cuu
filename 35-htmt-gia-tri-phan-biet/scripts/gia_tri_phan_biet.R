# =====================================================================
# Bài 35. Giá trị phân biệt của mô hình sàn X trong PLS-SEM:
# HTMT (Henseler et al., 2015), tiêu chí Fornell-Larcker, hệ số tải chéo,
# và khoảng tin cậy bootstrap của HTMT (percentile, 5000 mẫu, seed 2026).
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-34.
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript gia_tri_phan_biet.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../../bai-33/du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
nhom <- list(XACNHAN = paste0("XN", 1:4), GIATRI = paste0("HI", 1:4), HAILONG = paste0("HL", 1:4),
             NIEMTIN = c("NT1", "NT2", "NT3", "NT4R"), YDINH = paste0("YD", 1:4))
kn <- names(nhom); cau <- unlist(nhom)
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
pls <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)

# 1. HTMT: trung bình tương quan khác thang đo / căn bậc hai (tích trung bình tương quan cùng thang đo)
htmt_mat <- function(dat) {
  R <- cor(dat)
  mono <- sapply(nhom, function(v) { r <- R[v, v]; mean(r[lower.tri(r)]) })
  H <- matrix(NA, 5, 5, dimnames = list(kn, kn))
  for (i in 2:5) for (j in 1:(i - 1)) {
    H[i, j] <- mean(R[nhom[[i]], nhom[[j]]]) / sqrt(mono[i] * mono[j])
  }
  H
}
H <- htmt_mat(x); print(round(H, 3))

# 2. Khoảng tin cậy bootstrap của HTMT
set.seed(2026)
B <- 5000
cap <- which(lower.tri(H), arr.ind = TRUE)
bs <- t(replicate(B, { h <- htmt_mat(x[sample(nrow(x), replace = TRUE), ]); h[lower.tri(h)] }))
ten_cap <- paste(kn[cap[, 1]], "<->", kn[cap[, 2]])
htmt_bang <- data.frame(cap = ten_cap, HTMT = H[lower.tri(H)],
                        ktc_duoi = apply(bs, 2, quantile, 0.025), ktc_tren = apply(bs, 2, quantile, 0.975),
                        q95 = apply(bs, 2, quantile, 0.95), row.names = NULL)
htmt_bang <- htmt_bang[order(-htmt_bang$HTMT), ]
print(htmt_bang, digits = 3, row.names = FALSE)

# 3. Fornell-Larcker: căn bậc hai AVE trên đường chéo, tương quan giữa các biến tiềm ẩn ngoài đường chéo
a <- assess(pls, .quality_criterion = "ave")
LVcor <- cor(pls$Estimates$Construct_scores[, kn])
FL <- LVcor; diag(FL) <- sqrt(a$AVE[kn]); FL[upper.tri(FL)] <- NA
print(round(FL, 3))

# 4. Hệ số tải chéo: tương quan của mỗi câu hỏi với điểm của từng biến tiềm ẩn
CL <- cor(x[, cau], pls$Estimates$Construct_scores[, kn])
print(round(CL, 3))
own <- sapply(seq_along(cau), function(i) CL[i, names(which(sapply(nhom, function(v) cau[i] %in% v)))])
other <- sapply(seq_along(cau), function(i) max(CL[i, setdiff(kn, names(which(sapply(nhom, function(v) cau[i] %in% v))))]))
cat("Chênh lệch nhỏ nhất giữa tải riêng và tải chéo lớn nhất:", round(min(own - other), 3),
    "(", cau[which.min(own - other)], ")\n")

write.csv(round(H, 4), "htmt.csv")
write.csv(htmt_bang, "htmt_bootstrap.csv", row.names = FALSE)
write.csv(round(FL, 4), "fornell_larcker.csv")
write.csv(round(CL, 4), "he_so_tai_cheo.csv")
