# =====================================================================
# Bài 29. Phân tích đa nhóm (multi-group) theo giới tính.
# Bước 1: bất biến đo lường  (configural -> metric -> scalar)
# Bước 2: bất biến cấu trúc  (ràng buộc 7 hệ số đường dẫn bằng nhau)
# Bước 3: so sánh từng đường dẫn (kiểm định chi bình phương 1 bậc tự do
#          và tỷ số tới hạn của hiệu số, như AMOS)
# Chạy trên 2 cách xử lý dữ liệu thiếu: FIML (như JASP) và dữ liệu đủ (như AMOS)
# Cách chạy: LANG=C.UTF-8 Rscript da_nhom.R
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
cau <- c(paste0("XN", 1:4), paste0("HI", 1:4), paste0("HL", 1:4), "NT1", "NT2", "NT3", "NT4R", paste0("YD", 1:4))
d <- d[d$GIOITINH %in% 1:2, c("GIOITINH", cau)]           # bỏ 5 người chọn "Khác"
d$NHOM <- ifelse(d$GIOITINH == 1, "Nam", "Nu")
cat("Cỡ nhóm (FIML):"); print(table(d$NHOM))
dd <- na.omit(d); cat("Cỡ nhóm (dữ liệu đủ):"); print(table(dd$NHOM))

mh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + HAILONG + NIEMTIN
  XACNHAN ~~ NIEMTIN'
duong <- c("GIATRI~XACNHAN", "HAILONG~XACNHAN", "HAILONG~GIATRI", "YDINH~XACNHAN",
           "YDINH~GIATRI", "YDINH~HAILONG", "YDINH~NIEMTIN")
ten_h <- paste0("H", 1:7)
chiso <- c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")

chay <- function(dat, thieu) {
  f <- function(...) sem(mh, data = dat, group = "NHOM", group.label = c("Nam", "Nu"), missing = thieu, ...)
  m <- list(
    "M1 Cấu hình (configural)" = f(),
    "M2 Hệ số tải (metric)"    = f(group.equal = "loadings"),
    "M3 Hệ số chặn (scalar)"   = f(group.equal = c("loadings", "intercepts")),
    "M4 Đường dẫn (structural)" = f(group.equal = c("loadings", "regressions")))
  bang <- t(sapply(m, fitMeasures, chiso))
  so <- function(a, b) { t <- anova(m[[a]], m[[b]]); c(dchisq = t[2, "Chisq diff"], ddf = t[2, "Df diff"], p = t[2, "Pr(>Chisq)"]) }
  ss <- rbind("M2 vs M1" = so(1, 2), "M3 vs M2" = so(2, 3), "M4 vs M2" = so(2, 4))
  ss <- cbind(ss, dCFI = c(bang[2, "cfi"] - bang[1, "cfi"], bang[3, "cfi"] - bang[2, "cfi"], bang[4, "cfi"] - bang[2, "cfi"]),
              dRMSEA = c(bang[2, "rmsea"] - bang[1, "rmsea"], bang[3, "rmsea"] - bang[2, "rmsea"], bang[4, "rmsea"] - bang[2, "rmsea"]),
              dSRMR = c(bang[2, "srmr"] - bang[1, "srmr"], bang[3, "srmr"] - bang[2, "srmr"], bang[4, "srmr"] - bang[2, "srmr"]))
  list(m = m, bang = bang, ss = ss)
}

# Ràng buộc từng đường dẫn: viết lại cú pháp có nhãn c(a,a) cho đường thứ i
mh_rang <- function(i) {
  lhs <- sub("~.*", "", duong[i]); rhs <- sub(".*~", "", duong[i])
  s <- mh
  # tách khai báo hồi quy của lhs và gắn nhãn cho rhs
  dong <- regmatches(s, regexpr(paste0("\n  ", lhs, " +~ [^\n]*"), s))
  dong_moi <- sub(paste0("(~ |\\+ )", rhs, "(\\b)"), paste0("\\1c(a,a)*", rhs, "\\2"), dong)
  sub(dong, dong_moi, s, fixed = TRUE)
}

phan_tich <- function(dat, thieu, nhan) {
  cat("\n==================", nhan, "==================\n")
  r <- chay(dat, thieu)
  print(round(r$bang, 3)); print(round(r$ss, 4))
  m2 <- r$m[[2]]
  tung <- t(sapply(seq_along(duong), function(i) {
    mi <- sem(mh_rang(i), data = dat, group = "NHOM", group.label = c("Nam", "Nu"), missing = thieu, group.equal = "loadings")
    t <- anova(m2, mi); c(dchisq = t[2, "Chisq diff"], ddf = t[2, "Df diff"], p = t[2, "Pr(>Chisq)"])
  }))
  # Hệ số từng nhóm từ M2 + tỷ số tới hạn của hiệu (như AMOS Critical ratios for differences)
  pe <- parameterEstimates(m2, standardized = TRUE)
  he <- t(sapply(duong, function(p) {
    lhs <- sub("~.*", "", p); rhs <- sub(".*~", "", p)
    a <- pe[pe$lhs == lhs & pe$rhs == rhs & pe$op == "~", ]
    V <- vcov(m2); nm <- paste0(lhs, "~", rhs, c("", ".g2"))
    v <- V[nm[1], nm[1]] + V[nm[2], nm[2]] - 2 * V[nm[1], nm[2]]
    c(B_nam = a$est[a$group == 1], se_nam = a$se[a$group == 1], beta_nam = a$std.all[a$group == 1], p_nam = a$pvalue[a$group == 1],
      B_nu = a$est[a$group == 2], se_nu = a$se[a$group == 2], beta_nu = a$std.all[a$group == 2], p_nu = a$pvalue[a$group == 2],
      cr_hieu = (a$est[a$group == 2] - a$est[a$group == 1]) / sqrt(v))
  }))
  kq <- data.frame(H = ten_h, duong = duong, he, tung)
  print(kq, digits = 3)
  cat("Nhóm 1 =", lavInspect(m2, "group.label")[1], "\n")
  # R2 từng nhóm
  print(round(sapply(lavInspect(m2, "r2"), function(z) z[c("GIATRI", "HAILONG", "YDINH")]), 3))
  # Kiểm định đa biến cho M4 (score test: đường nào vi phạm ràng buộc nhiều nhất)
  lt <- lavTestScore(r$m[[4]])$uni; print(lt[order(-lt$X2), ][1:7, ], digits = 3)
  list(r = r, kq = kq)
}

kq_fiml <- phan_tich(d, "ml", "FIML (như JASP)")
kq_du   <- phan_tich(dd, "listwise", "Dữ liệu đủ (như AMOS)")
cat("\nNhãn nhóm M2:", lavInspect(kq_fiml$r$m[[2]], "group.label"), "\n")

ghi <- function(k, ten) {
  b <- data.frame(mo_hinh = rownames(k$r$bang), k$r$bang, row.names = NULL)
  write.csv(b, file.path(here, paste0("bat_bien_", ten, ".csv")), row.names = FALSE)
  s <- data.frame(so_sanh = rownames(k$r$ss), k$r$ss, row.names = NULL)
  write.csv(s, file.path(here, paste0("so_sanh_", ten, ".csv")), row.names = FALSE)
  write.csv(k$kq, file.path(here, paste0("duong_dan_", ten, ".csv")), row.names = FALSE)
}
ghi(kq_fiml, "fiml"); ghi(kq_du, "du")

# Trung bình tiềm ẩn (chỉ có nghĩa khi đạt bất biến scalar): nhóm Nữ so với Nam
m3 <- kq_fiml$r$m[[3]]
tb <- subset(parameterEstimates(m3), op == "~1" & lhs %in% c("XACNHAN", "GIATRI", "HAILONG", "NIEMTIN", "YDINH") & group == 2)
cat("\nTrung bình tiềm ẩn nhóm 2 so với nhóm 1 (FIML, M3):\n"); print(tb[, c("lhs", "est", "se", "z", "pvalue")], digits = 3)
write.csv(tb[, c("lhs", "est", "se", "z", "pvalue")], file.path(here, "trung_binh_tiem_an.csv"), row.names = FALSE)

# Score test trên M2: hệ số tải nào khác biệt nhiều nhất giữa hai nhóm
m2 <- kq_fiml$r$m[[2]]; lt <- lavTestScore(m2)$uni
pt <- parTable(m2); nhan <- function(pl) { r <- pt[pt$plabel == pl, ]; paste0(r$lhs, r$op, r$rhs) }
lt$tham_so <- sapply(lt$lhs, nhan)
cat("\nScore test M2 (bất biến hệ số tải):\n"); print(lt[order(-lt$X2), c("tham_so", "X2", "df", "p.value")][1:5, ], digits = 3)
write.csv(lt[order(-lt$X2), c("tham_so", "X2", "df", "p.value")], file.path(here, "score_test_metric.csv"), row.names = FALSE)


# Mô hình kiểu AMOS khi bật Estimate means: Structural weights = hệ số tải + hệ số chặn + đường dẫn
m5 <- function(dat, thieu) sem(mh, data = dat, group = "NHOM", group.label = c("Nam", "Nu"), missing = thieu,
                                group.equal = c("loadings", "intercepts", "regressions"))
for (k in list(list(d, "ml", "fiml", kq_fiml), list(dd, "listwise", "du", kq_du))) {
  f5 <- m5(k[[1]], k[[2]]); t <- anova(k[[4]]$r$m[[3]], f5)
  r <- c(fitMeasures(f5, chiso), dchisq = t[2, "Chisq diff"], ddf = t[2, "Df diff"], p = t[2, "Pr(>Chisq)"])
  cat("\nM5 (scalar + đường dẫn),", k[[3]], ":\n"); print(round(r, 4))
  write.csv(as.data.frame(t(r)), file.path(here, paste0("m5_", k[[3]], ".csv")), row.names = FALSE)
}
