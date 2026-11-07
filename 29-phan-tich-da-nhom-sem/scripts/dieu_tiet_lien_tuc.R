# =====================================================================
# Bài 29 (phần 2). Biến điều tiết liên tục trong CB-SEM:
# NIEMTIN có điều tiết tác động HAILONG -> YDINH không?
# Cách làm: chỉ báo tích (product indicators), ghép cặp 4 cặp,
# lấy tâm kép (double mean centering, Lin et al., 2010).
# So sánh thêm cách chia nhóm theo trung vị (không khuyến khích).
# Cách chạy: LANG=C.UTF-8 Rscript dieu_tiet_lien_tuc.R
# =====================================================================
library(lavaan); library(semTools)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv"))
hl <- paste0("HL", 1:4); nt <- c("NT1", "NT2", "NT3", "NT4R")
# Tâm kép: trừ trung bình từng chỉ báo, nhân theo cặp, rồi trừ trung bình của tích
dc <- d
for (v in c(hl, nt)) dc[[v]] <- d[[v]] - mean(d[[v]], na.rm = TRUE)
for (i in 1:4) {
  p <- dc[[hl[i]]] * dc[[nt[i]]]
  d[[paste0("HLxNT", i)]] <- p - mean(p, na.rm = TRUE)
}
# Kiểm tra bằng semTools::indProd (phải cho cùng kết quả)
chk <- indProd(read.csv(file.path(here, "..", "du-lieu", "du_lieu_amos.csv")), var1 = hl, var2 = nt,
               match = TRUE, meanC = TRUE, residualC = FALSE, doubleMC = TRUE, namesProd = paste0("chk", 1:4))
cat("Sai lệch tối đa so với indProd:", max(abs(chk$chk1 - d$HLxNT1), na.rm = TRUE), "\n")

mh <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  NIEMTIN =~ NT1 + NT2 + NT3 + NT4R
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  HLxNT   =~ HLxNT1 + HLxNT2 + HLxNT3 + HLxNT4
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + h6*HAILONG + h7*NIEMTIN + h8*HLxNT
  XACNHAN ~~ NIEMTIN
  XACNHAN ~~ HLxNT
  NIEMTIN ~~ HLxNT
  # ghép cặp (HL1 x NT1, HL2 x NT2...) nên các chỉ báo tích không dùng chung
  # chỉ báo gốc nào, nên không cần cho sai số của chúng tương quan với nhau'
f <- sem(mh, data = d, missing = "ml")
fm <- fitMeasures(f, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")); print(round(fm, 3))
pe <- subset(parameterEstimates(f, standardized = TRUE), op == "~" & lhs == "YDINH")
print(pe[, c("rhs", "label", "est", "se", "z", "pvalue", "ci.lower", "ci.upper", "std.all")], digits = 3)
r2 <- lavInspect(f, "r2")["YDINH"]; cat("R2 YDINH (có tương tác):", round(r2, 3), "\n")
# Mô hình không có tương tác (h8 = 0) để tính delta R2
f0 <- sem(sub("h8\\*HLxNT", "0*HLxNT", mh), data = d, missing = "ml")
r20 <- lavInspect(f0, "r2")["YDINH"]; cat("R2 YDINH (h8 = 0):", round(r20, 3), " f2 =", round((r2 - r20) / (1 - r2), 4), "\n")
print(anova(f0, f))
# Độ dốc đơn giản (simple slopes) của HAILONG tại NIEMTIN = -1 SD, 0, +1 SD
v_nt <- lavInspect(f, "cov.lv")["NIEMTIN", "NIEMTIN"]; sdnt <- sqrt(v_nt)
b <- coef(f); V <- vcov(f)
doc <- t(sapply(c(-1, 0, 1), function(k) {
  w <- k * sdnt; est <- b["h6"] + b["h8"] * w
  se <- sqrt(V["h6", "h6"] + w^2 * V["h8", "h8"] + 2 * w * V["h6", "h8"])
  c(muc = k, NIEMTIN = w, doc = est, se = se, z = est / se, p = 2 * pnorm(-abs(est / se)))
}))
print(round(doc, 3))

# Cách chia đôi theo trung vị (minh họa vì sao không nên)
d$NT_tb <- rowMeans(d[, nt], na.rm = TRUE)
d$NHOM_NT <- ifelse(d$NT_tb > median(d$NT_tb), "Cao", "Thap")
cat("Trung vị NT:", median(d$NT_tb), "\n"); print(table(d$NHOM_NT))
mh2 <- '
  XACNHAN =~ XN1 + XN2 + XN3 + XN4
  GIATRI  =~ HI1 + HI2 + HI3 + HI4
  HAILONG =~ HL1 + HL2 + HL3 + HL4
  YDINH   =~ YD1 + YD2 + YD3 + YD4
  GIATRI  ~ XACNHAN
  HAILONG ~ XACNHAN + GIATRI
  YDINH   ~ XACNHAN + GIATRI + c(a1, a2)*HAILONG'
g1 <- sem(mh2, data = d, group = "NHOM_NT", group.label = c("Thap", "Cao"), missing = "ml", group.equal = "loadings")
g0 <- sem(sub("c\\(a1, a2\\)", "c(a, a)", mh2), data = d, group = "NHOM_NT", group.label = c("Thap", "Cao"),
          missing = "ml", group.equal = "loadings")
p2 <- subset(parameterEstimates(g1), label %in% c("a1", "a2")); print(p2[, c("group", "est", "se", "pvalue")], digits = 3)
print(anova(g0, g1))
out <- data.frame(pe[, c("rhs", "est", "se", "z", "pvalue", "ci.lower", "ci.upper", "std.all")])
write.csv(out, file.path(here, "dieu_tiet_lien_tuc.csv"), row.names = FALSE)
write.csv(as.data.frame(doc), file.path(here, "do_doc_don_gian.csv"), row.names = FALSE)
# Đối chiếu với chỉ báo tích tạo bằng cú pháp chuan_bi_bai29.sps (PSPP)
ps <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_tich.csv"))
cat("Sai lệch tối đa so với PSPP:", max(abs(as.matrix(ps[, paste0("HLxNT", 1:4)]) - as.matrix(d[, paste0("HLxNT", 1:4)])), na.rm = TRUE), "\n")

# Dữ liệu đủ (254 phiếu, như AMOS) với chỉ báo tích lấy từ du_lieu_tich_du (tâm theo 267 phiếu)
du <- na.omit(ps[, c(paste0("XN", 1:4), paste0("HI", 1:4), hl, nt, paste0("YD", 1:4), paste0("HLxNT", 1:4))])
fd <- sem(mh, data = du)
cat("\nDữ liệu đủ: N =", nrow(du), "\n"); print(round(fitMeasures(fd, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")), 3))
ped <- subset(parameterEstimates(fd, standardized = TRUE), op == "~" & lhs == "YDINH")
print(ped[, c("rhs", "est", "se", "z", "pvalue", "std.all")], digits = 3)
write.csv(ped[, c("rhs", "est", "se", "z", "pvalue", "std.all")], file.path(here, "dieu_tiet_lien_tuc_du.csv"), row.names = FALSE)
