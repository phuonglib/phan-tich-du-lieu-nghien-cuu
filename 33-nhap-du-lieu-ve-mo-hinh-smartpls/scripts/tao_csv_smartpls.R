# =====================================================================
# Bài 33. Tạo file CSV cho SmartPLS từ du_lieu_amos.sav (267 người).
# Chỉ đổi định dạng: dấu phẩy ngăn cột, dấu chấm thập phân, dòng đầu là tên biến,
# ô thiếu ghi bằng mã -99 (giá trị không thể có trong thang Likert 1-5).
# Không sửa giá trị nào khác. Cách chạy: LANG=C.UTF-8 Rscript tao_csv_smartpls.R
# =====================================================================
suppressMessages(library(foreign))
d <- read.spss("../du-lieu/du_lieu_amos.sav", to.data.frame = TRUE, use.value.labels = FALSE)
d <- d[, !(names(d) %in% c("filter_$"))]
thieu <- sum(is.na(d))
d[is.na(d)] <- -99
write.csv(d, "../du-lieu/du_lieu_san_x_smartpls.csv", row.names = FALSE, quote = FALSE)
cat("Đã ghi", nrow(d), "dòng,", ncol(d), "cột;", thieu, "ô thiếu ghi bằng -99\n")
cat("Các cột:", paste(names(d), collapse = ", "), "\n")
