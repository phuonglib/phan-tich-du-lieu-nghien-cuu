# =====================================================================
# Bài 33. Số liệu đối chiếu cho mô hình sàn X vẽ trong SmartPLS 4.
# PLS-SEM, sơ đồ trọng số đường dẫn (path weighting), kết quả chuẩn hóa,
# hai cách xử lý giá trị thiếu giống SmartPLS:
#   (1) Casewise deletion: bỏ người có ô thiếu (254 người)
#   (2) Mean replacement: thay ô thiếu bằng trung bình của câu hỏi (267 người)
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript doi_chieu_pls.R
# =====================================================================
suppressMessages({ library(cSEM); library(foreign) })
d <- read.spss("../du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
x <- d[, cau]
cat("Số người:", nrow(x), " Ô thiếu:", sum(is.na(x)), " Người có ô thiếu:", sum(!complete.cases(x)), "\n")
cat("Tỷ lệ thiếu lớn nhất của một câu hỏi (%):", round(100 * max(colMeans(is.na(x))), 2), "\n")

mh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + HAILONG + NIEMTIN'
duong <- c("GIATRI ~ XACNHAN", "HAILONG ~ XACNHAN", "HAILONG ~ GIATRI", "YDINH ~ XACNHAN",
           "YDINH ~ GIATRI", "YDINH ~ HAILONG", "YDINH ~ NIEMTIN")

x_bo <- na.omit(x)
x_tb <- as.data.frame(lapply(x, function(v) { v[is.na(v)] <- mean(v, na.rm = TRUE); v }))

uoc <- function(du) csem(du, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
lay <- function(f, k) { p <- summarize(f)$Estimates[[k]]; setNames(p$Estimate, p$Name) }
bo <- uoc(x_bo); tb <- uoc(x_tb)

bang <- data.frame(H = paste0("H", 1:7), duong = duong,
                   casewise = lay(bo, "Path_estimates")[duong], mean_replacement = lay(tb, "Path_estimates")[duong],
                   row.names = NULL)
r2 <- data.frame(bien = c("GIATRI", "HAILONG", "YDINH"),
                 casewise = summarize(bo)$Estimates$R2[c("GIATRI", "HAILONG", "YDINH")],
                 mean_replacement = summarize(tb)$Estimates$R2[c("GIATRI", "HAILONG", "YDINH")], row.names = NULL)
tai_bo <- lay(bo, "Loading_estimates"); tai_tb <- lay(tb, "Loading_estimates")
tai <- data.frame(ten = names(tai_bo), casewise = tai_bo, mean_replacement = tai_tb[names(tai_bo)], row.names = NULL)
print(bang, digits = 3); print(r2, digits = 3); print(tai, digits = 3)
cat("Số vòng lặp: casewise", bo$Information$Weight_info$Number_iterations,
    " mean replacement", tb$Information$Weight_info$Number_iterations, "\n")
write.csv(bang, "doi_chieu_duong_dan.csv", row.names = FALSE)
write.csv(r2, "doi_chieu_r2.csv", row.names = FALSE)
write.csv(tai, "doi_chieu_he_so_tai.csv", row.names = FALSE)

# Kiểm tra: Casewise deletion của SmartPLS bỏ người thiếu ở biến trong mô hình (254 người),
# không bỏ theo mọi cột của file (253 người, vì ID 59 thiếu NHOMTUOI nhưng đủ 20 câu hỏi).
x_moi_cot <- d[complete.cases(d), cau]
mc <- uoc(x_moi_cot)
cat("Bỏ theo mọi cột:", nrow(x_moi_cot), "người; H1 =", round(lay(mc, "Path_estimates")[duong[1]], 3),
    "; R2 YDINH =", round(summarize(mc)$Estimates$R2["YDINH"], 3), "\n")
cat("Bỏ theo 20 câu hỏi:", nrow(x_bo), "người; H1 =", round(bang$casewise[1], 3),
    "; R2 YDINH =", round(r2$casewise[3], 3), "\n")
