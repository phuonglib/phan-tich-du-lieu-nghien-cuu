* =====================================================================.
* Bài 9. Thống kê mô tả: mô tả mẫu và mô tả các biến nghiên cứu.
* Dữ liệu: du_lieu_sach.sav (267 phiếu, đã làm sạch ở Bài 8).
* Cách chạy: pspp --syntax-encoding=UTF-8 thong_ke_mo_ta.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_sach.sav'.

* Phần 1. Mô tả đặc điểm mẫu: biến định danh và thứ bậc dùng tần số.
FREQUENCIES GIOITINH NGHE THUNHAP /STATISTICS=NONE /BARCHART.

* Phần 2. Biến định lượng (Scale): trung bình, trung vị, độ lệch chuẩn, độ lệch, độ nhọn.
* FORMATS cho hai chữ số thập phân (TUOI và TANSUAT khai báo F3.0, số nguyên).
FORMATS TUOI TANSUAT (F5.2).
FREQUENCIES TUOI TANSUAT /FORMAT=NOTABLE
  /STATISTICS=MEAN MEDIAN STDDEV MINIMUM MAXIMUM SKEWNESS SESKEW KURTOSIS SEKURT
  /PERCENTILES=25 75 /HISTOGRAM=NORMAL.

* Phần 3. Các câu Likert: trung bình, độ lệch chuẩn, độ lệch và độ nhọn.
DESCRIPTIVES XN1 TO HL2 HL3 TO YD4
  /STATISTICS=MEAN STDDEV MIN MAX SKEWNESS KURTOSIS.

* Phân bố tần số của từng mức trả lời (ví dụ thang Sự hài lòng).
FREQUENCIES HL1 HL2 HL3 HL4 /STATISTICS=MEDIAN MODE.

* Phần 4. Mô tả theo nhóm: trung bình câu YD1 theo giới tính và thu nhập.
* MEANS in số theo định dạng của biến: cần FORMATS để có hai chữ số thập phân.
FORMATS TUOI TANSUAT YD1 (F5.2).
MEANS TABLES=TUOI TANSUAT YD1 BY GIOITINH /CELLS=MEAN COUNT STDDEV.
CROSSTABS /TABLES=NGHE BY THUNHAP /CELLS=COUNT ROW.
