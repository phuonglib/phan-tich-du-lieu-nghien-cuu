* =====================================================================.
* Bài 29. Chuẩn bị dữ liệu cho phân tích đa nhóm và biến điều tiết.
* Đầu vào: du_lieu_amos.sav (267 phiếu, Bài 21).
* Đầu ra:  du_lieu_da_nhom.sav     (262 phiếu Nam, Nữ; giữ ô thiếu, dùng với FIML)
*          du_lieu_da_nhom_du.sav  (250 phiếu Nam, Nữ trả lời đủ, dùng với AMOS)
*          du_lieu_tich.sav        (267 phiếu + 4 chỉ báo tích HLxNT1-HLxNT4)
*          du_lieu_tich_du.sav     (254 phiếu trả lời đủ + 4 chỉ báo tích)
* Cách chạy: pspp --syntax-encoding=UTF-8 chuan_bi_bai29.sps
* =====================================================================.

* ---------------------------------------------------------------------.
* Phần A. File cho phân tích đa nhóm theo giới tính.
* Bỏ 5 người chọn "Khác" vì nhóm quá nhỏ để ước lượng một mô hình riêng.
* ---------------------------------------------------------------------.
GET FILE='../du-lieu/du_lieu_amos.sav'.
SELECT IF (GIOITINH = 1 OR GIOITINH = 2).
VALUE LABELS GIOITINH 1 'Nam' 2 'Nữ'.
VARIABLE LEVEL GIOITINH (NOMINAL).
FREQUENCIES GIOITINH.
SAVE OUTFILE='../du-lieu/du_lieu_da_nhom.sav'.

COUNT SO_THIEU = XN1 TO YD4 (MISSING).
SELECT IF (SO_THIEU = 0).
FREQUENCIES GIOITINH.
SAVE OUTFILE='../du-lieu/du_lieu_da_nhom_du.sav' /DROP=SO_THIEU.

* ---------------------------------------------------------------------.
* Phần B. Chỉ báo tích cho biến tương tác HAILONG x NIEMTIN.
* Ghép cặp theo thứ tự: HL1 x NT1, HL2 x NT2, HL3 x NT3, HL4 x NT4R.
* Lấy tâm kép (Lin et al., 2010):
*   (1) trừ trung bình của từng câu hỏi gốc,
*   (2) nhân theo cặp,
*   (3) trừ trung bình của tích.
* ---------------------------------------------------------------------.
GET FILE='../du-lieu/du_lieu_amos.sav'.
AGGREGATE OUTFILE=* MODE=ADDVARIABLES
  /mHL1=MEAN(HL1) /mHL2=MEAN(HL2) /mHL3=MEAN(HL3) /mHL4=MEAN(HL4)
  /mNT1=MEAN(NT1) /mNT2=MEAN(NT2) /mNT3=MEAN(NT3) /mNT4=MEAN(NT4R).
COMPUTE t1 = (HL1 - mHL1) * (NT1 - mNT1).
COMPUTE t2 = (HL2 - mHL2) * (NT2 - mNT2).
COMPUTE t3 = (HL3 - mHL3) * (NT3 - mNT3).
COMPUTE t4 = (HL4 - mHL4) * (NT4R - mNT4).
AGGREGATE OUTFILE=* MODE=ADDVARIABLES
  /mt1=MEAN(t1) /mt2=MEAN(t2) /mt3=MEAN(t3) /mt4=MEAN(t4).
COMPUTE HLxNT1 = t1 - mt1.
COMPUTE HLxNT2 = t2 - mt2.
COMPUTE HLxNT3 = t3 - mt3.
COMPUTE HLxNT4 = t4 - mt4.
VARIABLE LABELS HLxNT1 'Tích HL1 x NT1 (tâm kép)' HLxNT2 'Tích HL2 x NT2 (tâm kép)'
  HLxNT3 'Tích HL3 x NT3 (tâm kép)' HLxNT4 'Tích HL4 x NT4R (tâm kép)'.
VARIABLE LEVEL HLxNT1 TO HLxNT4 (SCALE).
FORMATS HLxNT1 TO HLxNT4 (F8.4).
DESCRIPTIVES VARIABLES=HLxNT1 TO HLxNT4 /STATISTICS=MEAN STDDEV MIN MAX.
SAVE OUTFILE='../du-lieu/du_lieu_tich.sav'
  /DROP=mHL1 TO mt4.
SAVE TRANSLATE OUTFILE='../du-lieu/du_lieu_tich.csv' /TYPE=CSV /FIELDNAMES /REPLACE
  /DROP=mHL1 TO mt4.

COUNT SO_THIEU = XN1 TO YD4 (MISSING).
SELECT IF (SO_THIEU = 0).
SAVE OUTFILE='../du-lieu/du_lieu_tich_du.sav' /DROP=mHL1 TO mt4 SO_THIEU.
