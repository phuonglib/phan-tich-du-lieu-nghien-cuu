* =====================================================================.
* Bài 8. Làm sạch dữ liệu: loại phiếu không hợp lệ, sửa lỗi nhập liệu,
* xử lý giá trị thiếu và phát hiện giá trị ngoại lai.
* Cách chạy: mở trong cửa sổ Syntax và chọn Run > All,
* hoặc dòng lệnh: pspp --syntax-encoding=UTF-8 lam_sach.sps.
* File gốc KHÔNG bị ghi đè: kết quả lưu thành du_lieu_sach.sav.
* =====================================================================.

GET FILE='../du-lieu/du_lieu_mau_san_x.sav'.

* ---------------------------------------------------------------------.
* Bước 1. Rà soát nhanh: tần số các câu kiểm soát, khoảng giá trị của mọi biến.
* ---------------------------------------------------------------------.
FREQUENCIES SL1 AC1 /STATISTICS=NONE.
DESCRIPTIVES TUOI TANSUAT XN1 TO YD4 /STATISTICS=MEAN STDDEV MIN MAX.

* ---------------------------------------------------------------------.
* Bước 2. Đánh dấu phiếu không hợp lệ (chưa xóa, chỉ tạo biến cờ 0/1).
* ---------------------------------------------------------------------.
* Độ lệch chuẩn của 20 câu Likert trong một phiếu (không tính câu AC1).
COMPUTE DOLECH = SD(XN1 TO HL2, HL3 TO YD4).
COMPUTE LOI_GANLOC = (SL1 = 2).
COMPUTE LOI_CHUY = (AC1 <> 2).
COMPUTE LOI_MOTMUC = (DOLECH = 0).
COMPUTE LOAI = MAX(LOI_GANLOC, LOI_CHUY, LOI_MOTMUC).
FORMATS DOLECH (F4.2) LOI_GANLOC LOI_CHUY LOI_MOTMUC LOAI (F1.0).
VALUE LABELS LOI_GANLOC LOI_CHUY LOI_MOTMUC LOAI 0 'Không' 1 'Có'.
FREQUENCIES LOI_GANLOC LOI_CHUY LOI_MOTMUC LOAI /STATISTICS=NONE.
CROSSTABS /TABLES=LOI_CHUY BY LOI_MOTMUC.

* Xem các phiếu trả lời một mức trước khi loại.
TEMPORARY.
SELECT IF LOI_MOTMUC = 1.
LIST /VARIABLES=ID AC1 XN1 HI1 HL1 NT1 NT4 YD1 DOLECH.

* ---------------------------------------------------------------------.
* Bước 3. Loại phiếu không hợp lệ.
* ---------------------------------------------------------------------.
SELECT IF LOAI = 0.
EXECUTE.

* ---------------------------------------------------------------------.
* Bước 4. Sửa lỗi nhập liệu ngoài khoảng hợp lệ.
* Không có phiếu gốc để đối chiếu, nên giá trị sai được chuyển thành giá trị thiếu.
* ---------------------------------------------------------------------.
COUNT SAI_THANG = XN1 TO HL2 HL3 TO YD4 (LOWEST THRU 0, 6 THRU HIGHEST).
TEMPORARY.
SELECT IF TUOI > 60 OR TUOI < 18 OR SAI_THANG > 0.
LIST /VARIABLES=ID TUOI SAI_THANG XN1 TO HL2.
IF (TUOI > 60 OR TUOI < 18) TUOI = $SYSMIS.
RECODE XN1 TO HL2 HL3 TO YD4 (6 THRU HIGHEST = SYSMIS) (LOWEST THRU 0 = SYSMIS).
EXECUTE.

* ---------------------------------------------------------------------.
* Bước 5. Đánh giá giá trị thiếu.
* ---------------------------------------------------------------------.
COMPUTE SOTHIEU = NMISS(XN1 TO HL2, HL3 TO YD4).
FORMATS SOTHIEU (F2.0).
FREQUENCIES SOTHIEU /STATISTICS=NONE.
DESCRIPTIVES XN1 TO HL2 HL3 TO YD4 /STATISTICS=MEAN MIN MAX.

* Kiểm tra sơ bộ: phiếu có ô thiếu có khác phiếu đầy đủ ở các biến khác không?
COMPUTE CO_THIEU = (SOTHIEU > 0).
VALUE LABELS CO_THIEU 0 'Đầy đủ' 1 'Có ô thiếu'.
T-TEST GROUPS=CO_THIEU(0 1) /VARIABLES=TUOI TANSUAT.
CROSSTABS /TABLES=GIOITINH BY CO_THIEU /STATISTICS=CHISQ.

* ---------------------------------------------------------------------.
* Bước 6. Phát hiện ngoại lai đơn biến: điểm z và biểu đồ hộp.
* DESCRIPTIVES /SAVE tạo biến ZTUOI, ZTANSUAT, ZXN1... trong dữ liệu.
* ---------------------------------------------------------------------.
DESCRIPTIVES TUOI TANSUAT XN1 TO HL2 HL3 TO YD4 /SAVE /STATISTICS=MEAN STDDEV MIN MAX.
COMPUTE NGOAILAI_Z = ANY(1, ABS(ZTUOI) > 3.29, ABS(ZTANSUAT) > 3.29).
TEMPORARY.
SELECT IF NGOAILAI_Z = 1.
LIST /VARIABLES=ID TUOI ZTUOI TANSUAT ZTANSUAT.
EXAMINE VARIABLES=TANSUAT TUOI /PLOT=BOXPLOT /STATISTICS=EXTREME(5).

* ---------------------------------------------------------------------.
* Bước 7. Phát hiện ngoại lai đa biến: khoảng cách Mahalanobis trên 20 câu Likert.
* Ngưỡng: chi bình phương với df = 20, p < .001 là 45.31.
* ---------------------------------------------------------------------.
DATASET NAME SACH.
DATASET COPY DAYDU.
DATASET ACTIVATE DAYDU.
SELECT IF SOTHIEU = 0.
MATCH FILES /FILE=* /KEEP=ID XN1 TO HL2 HL3 TO YD4.
MATRIX.
GET X /VARIABLES=XN1 TO YD4.
GET MAID /VARIABLES=ID.
COMPUTE N = NROW(X).
COMPUTE XC = X - MAKE(N, 1, 1) * CSUM(X) / N.
COMPUTE S = T(XC) * XC / (N - 1).
COMPUTE D2 = RSUM((XC * INV(S)) &* XC).
SAVE {MAID, D2} /OUTFILE=* /VARIABLES=ID MAHAL.
END MATRIX.
COMPUTE P_MAHAL = SIG.CHISQ(MAHAL, 20).
FORMATS ID (F4.0) MAHAL (F6.2) P_MAHAL (F6.4).
SORT CASES BY MAHAL (D).
LIST /CASES=FROM 1 TO 5.
COMPUTE NGOAILAI_DB = (P_MAHAL < .001).
FREQUENCIES NGOAILAI_DB /STATISTICS=NONE.
SORT CASES BY ID.
DATASET NAME MAHALANOBIS.

* Ghép khoảng cách Mahalanobis vào dữ liệu chính theo ID.
DATASET ACTIVATE SACH.
SORT CASES BY ID.
MATCH FILES /FILE=* /TABLE=MAHALANOBIS /BY ID.
DATASET CLOSE MAHALANOBIS.

* ---------------------------------------------------------------------.
* Bước 8. Lưu bộ dữ liệu sạch (bỏ các biến cờ trung gian).
* ---------------------------------------------------------------------.
SAVE OUTFILE='../du-lieu/du_lieu_sach.sav'
  /DROP=SAI_THANG LOI_GANLOC LOI_CHUY LOI_MOTMUC LOAI CO_THIEU NGOAILAI_Z ZTUOI ZTANSUAT ZXN1 TO ZYD4.
DESCRIPTIVES TUOI TANSUAT XN1 TO HL2 HL3 TO YD4 /STATISTICS=MEAN STDDEV MIN MAX.
