# =====================================================================
# Bài 42 (phần 1). IPMA (importance-performance map analysis) cho biến mục tiêu YDINH (Ringle & Sarstedt, 2016).
#   Performance: điểm biến tiềm ẩn trên thang 0-100, dùng trọng số ngoài chưa chuẩn hóa đã đổi tổng bằng 1.
#   Importance: tác động tổng của mỗi biến lên YDINH. Ringle & Sarstedt (2016): chưa chuẩn hóa, trên điểm 0-100;
#   SmartPLS 4.1.2.1 báo cáo tác động tổng chuẩn hóa. Script tính cả hai.
# Câu hỏi thang 1-5: x0-100 = (x - 1) / (5 - 1) x 100. Mọi câu hỏi cùng chiều (NT4R đã đảo).
# Dữ liệu: du_lieu_amos.sav, Casewise deletion theo 20 câu hỏi (254 người), như Bài 33-41.
# Gói: cSEM 0.7.1 (hàm doIPMA) và tính tay để kiểm tra. Cách chạy: LANG=C.UTF-8 Rscript ipma.R
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
# Tính tay
W <- f$Estimates$Weight_estimates
x100 <- (x - 1) / 4 * 100
kn <- c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH")
Wu <- t(sapply(kn, function(k) { w <- W[k, ] / sapply(x, sd); w[W[k, ] == 0] <- 0; w / sum(w) }))
LV <- as.matrix(x100) %*% t(Wu[, colnames(x)])
perf <- colMeans(LV)
b <- function(y, xs) coef(lm(reformulate(xs, y), data = as.data.frame(LV)))[xs]
bG <- b("GIATRI", "XACNHAN"); bH <- b("HAILONG", c("XACNHAN", "GIATRI"))
bY <- b("YDINH", c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN"))
imp <- c(XACNHAN = unname(bY["XACNHAN"] + bG * bY["GIATRI"] + bH["XACNHAN"] * bY["HAILONG"] + bG * bH["GIATRI"] * bY["HAILONG"]),
         GIATRI = unname(bY["GIATRI"] + bH["GIATRI"] * bY["HAILONG"]),
         HAILONG = unname(bY["HAILONG"]), NIEMTIN = unname(bY["NIEMTIN"]))
# Tác động tổng chuẩn hóa (cách SmartPLS 4.1 báo cáo importance)
B <- f$Estimates$Path_estimates; TE <- solve(diag(nrow(B)) - B) - diag(nrow(B)); dimnames(TE) <- dimnames(B)
kq <- data.frame(khai_niem = names(imp), importance_chua_chuan_hoa = imp,
                 importance_chuan_hoa = TE["YDINH", names(imp)], performance = perf[names(imp)])
print(kq, digits = 4, row.names = FALSE); cat("Performance YDINH:", round(perf["YDINH"], 3), "\n")
# Mức câu hỏi: importance của câu hỏi = trọng số đã đổi x importance của khái niệm; performance = trung bình 0-100
cq <- do.call(rbind, lapply(names(imp), function(k) { v <- colnames(x)[Wu[k, colnames(x)] != 0]
  data.frame(khai_niem = k, cau = v, importance = Wu[k, v] * imp[k], performance = colMeans(x100[, v])) }))
cq$importance_chuan_hoa <- mapply(function(k, v) W[k, v] * TE["YDINH", k], cq$khai_niem, cq$cau)  # trọng số chuẩn hóa x tác động tổng chuẩn hóa
print(cq, digits = 4, row.names = FALSE)
# Đối chiếu doIPMA của cSEM
ip <- tryCatch(doIPMA(f), error = function(e) { cat("doIPMA lỗi:", conditionMessage(e), "\n"); NULL })
if (!is.null(ip)) print(ip)
write.csv(kq, "ipma_khai_niem.csv", row.names = FALSE); write.csv(cq, "ipma_cau_hoi.csv", row.names = FALSE)
