# =====================================================================
# Bài 36. Đánh giá mô hình đo lường formative (project mẫu "Corporate reputation (primer)" của SmartPLS 4).
# Mô hình "2 Extended model": ATTR, CSOR, PERF, QUAL formative -> COMP, LIKE (reflective) -> CUSA -> CUSL.
# Ô thiếu: Mean replacement (như thiết lập của project mẫu), N = 344.
# Các bước (Hair et al., 2022): (1) giá trị hội tụ bằng phân tích dư thừa, (2) đa cộng tuyến (VIF),
# (3) ý nghĩa và mức liên quan của trọng số (bootstrap 5000 mẫu, percentile).
# Dữ liệu đọc trực tiếp từ workspace SmartPLS (không chép vào gói bài viết).
# Gói: cSEM 0.7.1. Cách chạy: LANG=C.UTF-8 Rscript danh_gia_formative.R
# =====================================================================
suppressMessages(library(cSEM))
tep <- file.path(Sys.getenv("HOME"), "smartpls4_workspace", "Example - Corporate reputation (primer)", "Complete data.txt")
d <- read.table(tep, sep = ";", header = TRUE, na.strings = c("", " "))
cat("N =", nrow(d), " Ô thiếu:", sum(is.na(d)), "\n")
x <- as.data.frame(lapply(d, function(v) { v[is.na(v)] <- mean(v, na.rm = TRUE); v }))  # Mean replacement

khoi <- list(ATTR = paste0("attr_", 1:3), CSOR = paste0("csor_", 1:5), PERF = paste0("perf_", 1:5),
             QUAL = paste0("qual_", 1:8))
mh <- '
  ATTR <~ attr_1 + attr_2 + attr_3
  CSOR <~ csor_1 + csor_2 + csor_3 + csor_4 + csor_5
  PERF <~ perf_1 + perf_2 + perf_3 + perf_4 + perf_5
  QUAL <~ qual_1 + qual_2 + qual_3 + qual_4 + qual_5 + qual_6 + qual_7 + qual_8
  COMP =~ comp_1 + comp_2 + comp_3
  LIKE =~ like_1 + like_2 + like_3
  CUSA =~ cusa
  CUSL =~ cusl_1 + cusl_2 + cusl_3
  COMP ~ ATTR + CSOR + PERF + QUAL
  LIKE ~ ATTR + CSOR + PERF + QUAL
  CUSA ~ COMP + LIKE
  CUSL ~ COMP + LIKE + CUSA'
f <- csem(x, mh, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
cat("Hội tụ:", unlist(verify(f))[1] == FALSE, "\n")

# 1. Giá trị hội tụ: phân tích dư thừa (khái niệm formative -> câu hỏi tổng quát một mục)
red <- sapply(names(khoi), function(k) {
  g <- paste0(tolower(k), "_global")
  m <- paste0(k, "_F <~ ", paste(khoi[[k]], collapse = " + "), "\n", k, "_G =~ ", g, "\n", k, "_G ~ ", k, "_F")
  r <- csem(x, m, .PLS_weight_scheme_inner = "path", .disattenuate = FALSE)
  summarize(r)$Estimates$Path_estimates$Estimate
})
print(round(red, 3))

# 2. VIF của câu hỏi formative: 1 / (1 - R^2) khi hồi quy mỗi câu trên các câu còn lại cùng khối
vif <- do.call(rbind, lapply(names(khoi), function(k) {
  v <- khoi[[k]]
  data.frame(khai_niem = k, cau = v, VIF = sapply(v, function(i)
    1 / (1 - summary(lm(reformulate(setdiff(v, i), i), data = x))$r.squared)), row.names = NULL)
}))

# 3. Trọng số, hệ số tải và bootstrap
W <- f$Estimates$Weight_estimates; L <- f$Estimates$Loading_estimates
vif$trong_so <- mapply(function(k, i) W[k, i], vif$khai_niem, vif$cau)
vif$he_so_tai <- mapply(function(k, i) L[k, i], vif$khai_niem, vif$cau)
set.seed(2026)
bs <- resamplecSEMResults(f, .R = 5000, .seed = 2026)
sw <- summarize(bs)$Estimates$Weight_estimates
sl <- summarize(bs)$Estimates$Loading_estimates
ten <- paste(vif$khai_niem, "<~", vif$cau)
vif$t_trong_so <- sw$t_stat[match(ten, sw$Name)]
vif$p_trong_so <- sw$p_value[match(ten, sw$Name)]
ten_l <- paste(vif$khai_niem, "=~", vif$cau)
vif$p_he_so_tai <- sl$p_value[match(ten_l, sl$Name)]
print(vif, digits = 3, row.names = FALSE)

write.csv(data.frame(khai_niem = names(red), duong_dan = red), "du_thua.csv", row.names = FALSE)
write.csv(vif, "formative_vif_trong_so.csv", row.names = FALSE)
