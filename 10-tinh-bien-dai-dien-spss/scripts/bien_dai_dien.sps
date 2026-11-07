* =====================================================================.
* Bài 10. Mã hóa lại biến (RECODE) và tính biến đại diện (COMPUTE MEAN).
* Dữ liệu: du_lieu_sach.sav (267 phiếu, đã làm sạch ở Bài 8).
* Cách chạy: pspp --syntax-encoding=UTF-8 bien_dai_dien.sps
* Kết quả lưu thành du_lieu_phan_tich.sav, file gốc không bị ghi đè.
* =====================================================================.
GET FILE='../du-lieu/du_lieu_sach.sav'.

* ---------------------------------------------------------------------.
* Phần 1. Mã hóa ngược câu đảo chiều NT4 vào biến MỚI NT4R.
* ---------------------------------------------------------------------.
RECODE NT4 (1=5) (2=4) (3=3) (4=2) (5=1) INTO NT4R.
* Cách viết ngắn tương đương cho thang 1-5: COMPUTE NT4R = 6 - NT4.
VARIABLE LABELS NT4R 'NT4 đã mã hóa ngược: Tôi KHÔNG lo ngại sàn X không giữ cam kết'.
VALUE LABELS NT4R 1 'Hoàn toàn không đồng ý' 2 'Không đồng ý' 3 'Trung lập' 4 'Đồng ý' 5 'Hoàn toàn đồng ý'.
FORMATS NT4R (F1.0).
VARIABLE LEVEL NT4R (ORDINAL).
EXECUTE.

* Kiểm tra 1: bảng chéo NT4 x NT4R phải nằm trên đường chéo ngược.
CROSSTABS /TABLES=NT4 BY NT4R.
* Kiểm tra 2: tương quan với các câu cùng thang đo phải đổi từ âm sang dương.
CORRELATIONS /VARIABLES=NT1 NT2 NT3 NT4 NT4R.

* ---------------------------------------------------------------------.
* Phần 2. Ba cách tính trung bình của một thang đo và số phiếu bị thiếu.
* ---------------------------------------------------------------------.
COMPUTE XN_CONG = (XN1 + XN2 + XN3 + XN4) / 4.
COMPUTE XN_MEAN = MEAN(XN1, XN2, XN3, XN4).
COMPUTE XN_MEAN3 = MEAN.3(XN1, XN2, XN3, XN4).
DESCRIPTIVES XN_CONG XN_MEAN XN_MEAN3 /STATISTICS=MEAN STDDEV MIN MAX.

* ---------------------------------------------------------------------.
* Phần 3. Hai lỗi hay gặp khi dùng TO và khi quên câu đảo chiều.
* ---------------------------------------------------------------------.
* Lỗi 1: HL1 TO HL4 lấy theo VỊ TRÍ trong file, nên gồm cả AC1 nằm giữa HL2 và HL3.
COMPUTE HL_SAI = MEAN(HL1 TO HL4).
COMPUTE HL_DUNG = MEAN(HL1, HL2, HL3, HL4).
* Lỗi 2: dùng NT4 chưa mã hóa ngược.
COMPUTE NT_SAI = MEAN(NT1, NT2, NT3, NT4).
COMPUTE NT_DUNG = MEAN(NT1, NT2, NT3, NT4R).
DESCRIPTIVES HL_SAI HL_DUNG NT_SAI NT_DUNG /STATISTICS=MEAN STDDEV MIN MAX.
CORRELATIONS /VARIABLES=HL_SAI HL_DUNG NT_SAI NT_DUNG YD1.

* ---------------------------------------------------------------------.
* Phần 4. Tính biến đại diện cho 5 thang đo (tạm thời, chờ kiểm định ở Bài 11-12).
* MEAN.3: chỉ tính khi phiếu trả lời ít nhất 3 trong 4 câu.
* ---------------------------------------------------------------------.
COMPUTE XN = MEAN.3(XN1, XN2, XN3, XN4).
COMPUTE HI = MEAN.3(HI1, HI2, HI3, HI4).
COMPUTE HL = MEAN.3(HL1, HL2, HL3, HL4).
COMPUTE NT = MEAN.3(NT1, NT2, NT3, NT4R).
COMPUTE YD = MEAN.3(YD1, YD2, YD3, YD4).
VARIABLE LABELS XN 'Xác nhận kỳ vọng (trung bình XN1-XN4)'
  /HI 'Nhận thức hữu ích (trung bình HI1-HI4)'
  /HL 'Sự hài lòng (trung bình HL1-HL4)'
  /NT 'Niềm tin (trung bình NT1-NT3, NT4R)'
  /YD 'Ý định mua lại (trung bình YD1-YD4)'.
FORMATS XN HI HL NT YD (F4.2).
VARIABLE LEVEL XN HI HL NT YD (SCALE).
DESCRIPTIVES XN HI HL NT YD /STATISTICS=MEAN STDDEV MIN MAX SKEWNESS KURTOSIS.

* ---------------------------------------------------------------------.
* Phần 5. Nhóm biến định lượng thành biến thứ bậc (để mô tả, không thay biến gốc).
* ---------------------------------------------------------------------.
RECODE TUOI (LOWEST THRU 24=1) (25 THRU 34=2) (35 THRU 44=3) (45 THRU HIGHEST=4) INTO NHOMTUOI.
RECODE TANSUAT (1 THRU 2=1) (3 THRU 5=2) (6 THRU 10=3) (11 THRU HIGHEST=4) INTO NHOMTS.
VARIABLE LABELS NHOMTUOI 'Nhóm tuổi' /NHOMTS 'Nhóm số lần mua trong 6 tháng'.
VALUE LABELS NHOMTUOI 1 '18-24 tuổi' 2 '25-34 tuổi' 3 '35-44 tuổi' 4 'Từ 45 tuổi'
  /NHOMTS 1 '1-2 lần' 2 '3-5 lần' 3 '6-10 lần' 4 'Trên 10 lần'.
FORMATS NHOMTUOI NHOMTS (F1.0).
VARIABLE LEVEL NHOMTUOI NHOMTS (ORDINAL).
FREQUENCIES NHOMTUOI NHOMTS /STATISTICS=NONE.
* Kiểm tra ranh giới nhóm: mỗi nhóm phải có tuổi nhỏ nhất và lớn nhất đúng như quy định.
MEANS TABLES=TUOI BY NHOMTUOI /CELLS=MIN MAX COUNT.

* ---------------------------------------------------------------------.
* Phần 6. Lưu file phân tích (bỏ các biến minh họa).
* ---------------------------------------------------------------------.
SAVE OUTFILE='../du-lieu/du_lieu_phan_tich.sav'
  /DROP=XN_CONG XN_MEAN XN_MEAN3 HL_SAI HL_DUNG NT_SAI NT_DUNG.
