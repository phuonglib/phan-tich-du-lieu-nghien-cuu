* =====================================================================.
* Bài 21. Chuẩn bị file dữ liệu cho AMOS và JASP.
* Đầu vào: du_lieu_phan_tich.sav (267 phiếu hợp lệ, Bài 8 và Bài 10).
* Đầu ra:  du_lieu_amos.sav       (267 phiếu, giữ giá trị thiếu, dùng với FIML)
*          du_lieu_amos_du.sav    (254 phiếu trả lời đủ 20 câu, dùng khi cần bootstrap)
*          du_lieu_amos.csv       (bản văn bản cho phần mềm không đọc được .sav)
* Cách chạy: pspp --syntax-encoding=UTF-8 chuan_bi_du_lieu_amos.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* ---------------------------------------------------------------------.
* Bước 1. Kiểm tra phạm vi giá trị và số người trả lời từng câu.
* ---------------------------------------------------------------------.
DESCRIPTIVES VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /STATISTICS=MEAN STDDEV MIN MAX.

* ---------------------------------------------------------------------.
* Bước 2. Đếm số câu bỏ trống của mỗi người.
* ---------------------------------------------------------------------.
COUNT SO_THIEU = XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4 (MISSING).
VARIABLE LABELS SO_THIEU 'Số câu bỏ trống (trong 20 câu của mô hình)'.
FREQUENCIES SO_THIEU.

* ---------------------------------------------------------------------.
* Bước 3. Khai báo các câu hỏi là biến định lượng (SCALE).
* AMOS không đọc thông tin này, nhưng JASP thì có: biến Ordinal sẽ
* được ước lượng bằng DWLS thay vì ML (xem Bài 20).
* ---------------------------------------------------------------------.
VARIABLE LEVEL XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4 (SCALE).

* ---------------------------------------------------------------------.
* Bước 4. Lưu file gọn cho AMOS: chỉ giữ biến dùng trong mô hình và
* biến nhóm. Bỏ các điểm trung bình XN, HI, HL, NT, YD để tránh trùng tên
* với biến tiềm ẩn.
* ---------------------------------------------------------------------.
SAVE OUTFILE='../du-lieu/du_lieu_amos.sav'
  /KEEP=ID GIOITINH NGHE THUNHAP NHOMTUOI
        XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
        NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4 SO_THIEU.
SAVE TRANSLATE OUTFILE='../du-lieu/du_lieu_amos.csv' /TYPE=CSV /FIELDNAMES /REPLACE
  /KEEP=ID GIOITINH NGHE THUNHAP NHOMTUOI
        XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
        NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4.

* ---------------------------------------------------------------------.
* Bước 5. Lưu thêm bản chỉ gồm người trả lời đủ 20 câu.
* ---------------------------------------------------------------------.
GET FILE='../du-lieu/du_lieu_amos.sav'.
SELECT IF SO_THIEU = 0.
SAVE OUTFILE='../du-lieu/du_lieu_amos_du.sav' /DROP=SO_THIEU.
DESCRIPTIVES VARIABLES=SO_THIEU /STATISTICS=MAX.
