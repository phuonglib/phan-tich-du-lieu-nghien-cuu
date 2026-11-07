# =====================================================================
# Bài 20. Mô hình đầu tiên: CFA một nhân tố cho thang đo Sự hài lòng (HL1-HL4).
# Cách chạy: Rscript mo_hinh_dau_tien.R
# Yêu cầu:   R 4.x, gói lavaan
# Thiết lập giống AMOS: ước lượng ML, hệ số tải của HL1 cố định bằng 1,
# dữ liệu thiếu xử lý bằng FIML ("Estimate means and intercepts").
# =====================================================================
library(lavaan)
args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("--file=", "", args[grep("--file=", args)])))
d <- read.csv(file.path(here, "..", "du-lieu", "du_lieu_phan_tich.csv"))
cau_hoi <- paste0("HL", 1:4)
cat("Số người thiếu ít nhất một câu HL:", sum(!complete.cases(d[, cau_hoi])), "\n")

# Tên biến tiềm ẩn không được trùng tên biến có trong dữ liệu (file có sẵn cột HL),
# nên đặt là HAILONG, giống quy tắc đặt tên trong AMOS.
mo_hinh <- 'HAILONG =~ HL1 + HL2 + HL3 + HL4'
fit <- cfa(mo_hinh, data = d[, cau_hoi], estimator = "ML", missing = "ml")
summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE)
cat("\nBậc tự do: số moment =", 4 * 5 / 2, "(không tính trung bình); tham số tự do (không tính trung bình) = 8\n")
pe <- parameterEstimates(fit, standardized = TRUE)
out <- subset(pe, op %in% c("=~", "~~"))[, c("lhs", "op", "rhs", "est", "se", "z", "pvalue", "std.all")]
print(out, digits = 3)
write.csv(out, file.path(here, "ket_qua_mo_hinh_dau_tien.csv"), row.names = FALSE)
print(round(fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")), 3))
