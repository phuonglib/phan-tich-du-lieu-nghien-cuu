# =====================================================================
# Bài 42 (phần 2). Mô hình bậc cao minh họa: DANHGIA (Đánh giá sau mua) là khái niệm bậc cao
# reflective-reflective của GIATRI và HAILONG, cách lặp chỉ báo (repeated indicators; Sarstedt et al., 2019).
#   DANHGIA đo bằng cả 8 câu HI1-HI4, HL1-HL4 (lặp lại); DANHGIA -> GIATRI, DANHGIA -> HAILONG.
#   Cấu trúc: XACNHAN -> DANHGIA -> YDINH; XACNHAN -> YDINH; NIEMTIN -> YDINH.
# Đây là ví dụ kỹ thuật, không phải mô hình lý thuyết của chuỗi bài.
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người). Gói: cSEM 0.7.1.
# Cách chạy: LANG=C.UTF-8 Rscript bac_cao.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../../bai-33/du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- na.omit(d[, cau]); cat("N =", nrow(x), "\n")
lap <- c(paste0("HI", 1:4), paste0("HL", 1:4))
for (v in lap) x[[paste0(v, "_r")]] <- x[[v]]   # bản lặp của 8 câu cho DANHGIA
mh <- paste0('
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  DANHGIA =~ ', paste(paste0(lap, "_r"), collapse = " + "), '
  GIATRI  ~ DANHGIA
  HAILONG ~ DANHGIA
  DANHGIA ~ XACNHAN
  YDINH   ~ XACNHAN + DANHGIA + NIEMTIN')
f <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
cat("Hội tụ:", unlist(verify(f))[1] == FALSE, "\n")
P <- f$Estimates$Path_estimates
cat("Hệ số DANHGIA -> GIATRI, HAILONG (đọc như hệ số tải bậc cao):", round(P["GIATRI", "DANHGIA"], 3), round(P["HAILONG", "DANHGIA"], 3), "\n")
print(round(P[c("DANHGIA", "YDINH"), c("XACNHAN", "DANHGIA", "NIEMTIN")], 3))
print(round(f$Estimates$R2, 3))
# Độ tin cậy và giá trị hội tụ của khái niệm bậc cao tính từ hai "hệ số tải" bậc cao
l <- c(P["GIATRI", "DANHGIA"], P["HAILONG", "DANHGIA"])
cat("AVE bậc cao:", round(mean(l^2), 3), " rho_c bậc cao:", round(sum(l)^2 / (sum(l)^2 + sum(1 - l^2)), 3), "\n")
set.seed(2026)
bs <- resamplecSEMResults(f, .R = 5000, .seed = 2026)
s <- summarize(bs, .ci = "CI_percentile")$Estimates$Path_estimates
options(width = 200); print(s[, c("Name", "Estimate", "Std_err", "t_stat", "p_value", "CI_percentile.95%L", "CI_percentile.95%U")], digits = 3, row.names = FALSE)
write.csv(s[, c("Name", "Estimate", "Std_err", "t_stat", "p_value", "CI_percentile.95%L", "CI_percentile.95%U")], "bac_cao_bootstrap.csv", row.names = FALSE)
