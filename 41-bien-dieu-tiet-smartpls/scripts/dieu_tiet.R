# =====================================================================
# Bài 41. Biến điều tiết trong PLS-SEM: NIEMTIN có điều tiết tác động HAILONG -> YDINH không?
# Cách tiếp cận hai giai đoạn (two-stage, Becker et al., 2018), giống mặc định của SmartPLS 4:
#   Giai đoạn 1: ước lượng mô hình chính, lấy điểm biến tiềm ẩn (đã chuẩn hóa).
#   Giai đoạn 2: thêm biến tương tác một chỉ báo = điểm HAILONG x điểm NIEMTIN.
# Bootstrap 5000 mẫu cho giai đoạn 2 (gần đúng: không lặp lại giai đoạn 1 trong từng mẫu).
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-40.
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript dieu_tiet.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../../bai-33/du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- na.omit(d[, cau]); cat("N =", nrow(x), "\n")
do <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4'
cau_truc <- '
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
'
f1 <- csem(x, paste(do, cau_truc, "\n  YDINH ~ XACNHAN + GIATRI + HAILONG + NIEMTIN"),
           .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
sc <- f1$Estimates$Construct_scores
x$INTx <- sc[, "HAILONG"] * sc[, "NIEMTIN"]
f2 <- csem(x, paste(do, "\n  INT =~ INTx", cau_truc, "\n  YDINH ~ XACNHAN + GIATRI + HAILONG + NIEMTIN + INT"),
           .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
P <- f2$Estimates$Path_estimates
r2_co <- f2$Estimates$R2["YDINH"]; r2_khong <- f1$Estimates$R2["YDINH"]
cat("Hệ số YDINH:\n"); print(round(P["YDINH", ], 3))
cat("R2 YDINH khi không có / có tương tác:", round(r2_khong, 3), round(r2_co, 3), "\n")
cat("f2 của tương tác:", round((r2_co - r2_khong) / (1 - r2_co), 4), "\n")
set.seed(2026)
bs <- resamplecSEMResults(f2, .R = 5000, .seed = 2026)
s <- summarize(bs, .ci = "CI_percentile")$Estimates$Path_estimates
s <- s[grepl("^YDINH", s$Name), c("Name", "Estimate", "Std_err", "t_stat", "p_value", "CI_percentile.95%L", "CI_percentile.95%U")]
options(width = 200); print(s, digits = 3, row.names = FALSE)
# Độ dốc đơn giản: tác động của HAILONG lên YDINH khi NIEMTIN ở -1, 0, +1 độ lệch chuẩn
b_hl <- P["YDINH", "HAILONG"]; b_int <- P["YDINH", "INT"]
# SmartPLS giữ nguyên biến tương tác (không chuẩn hóa tích điểm): đổi hệ số chuẩn hóa về thang của tích
b_int_tich <- b_int / sd(x$INTx)
cat("Độ lệch chuẩn của tích điểm:", round(sd(x$INTx), 3), " Hệ số tương tác theo thang của tích:", round(b_int_tich, 3), "\n")
doc <- data.frame(niem_tin = c(-1, 0, 1), do_doc = b_hl + b_int_tich * c(-1, 0, 1))
print(round(doc, 3))
write.csv(s, "dieu_tiet_bootstrap.csv", row.names = FALSE)
write.csv(doc, "do_doc_don_gian.csv", row.names = FALSE)
