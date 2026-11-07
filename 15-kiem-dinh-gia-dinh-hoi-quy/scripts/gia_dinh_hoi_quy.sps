* =====================================================================.
* Bài 15. Kiểm định các giả định của hồi quy tuyến tính bội (Mô hình 2: YD).
* Dữ liệu: du_lieu_phan_tich.sav. Cách chạy: pspp --syntax-encoding=UTF-8 gia_dinh_hoi_quy.sps
* PSPP 2.0 chỉ lưu được giá trị dự đoán (PRED) và phần dư (RESID); các thống kê còn lại
* (phần dư chuẩn hóa, đòn bẩy, khoảng cách Cook, Breusch-Pagan, Durbin-Watson) được tính bằng cú pháp.
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.
DATASET NAME CHINH.
DATASET COPY HQ.
DATASET ACTIVATE HQ.
SELECT IF NMISS(XN, HI, HL, NT, YD) = 0.
EXECUTE.

* Bước 1. Chạy hồi quy, có thống kê đa cộng tuyến, lưu giá trị dự đoán và phần dư.
REGRESSION /VARIABLES=XN HI HL NT /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF R ANOVA TOL /SAVE=PRED RESID.
RENAME VARIABLES (PRED1 = DUDOAN) (RES1 = PHANDU).

* Bước 2. Chuẩn hóa giá trị dự đoán và phần dư.
* Phần dư chuẩn hóa = phần dư / sai số chuẩn của ước lượng (căn của MSE, bậc tự do N - k - 1).
COMPUTE PD2 = PHANDU ** 2.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /SSE = SUM(PD2) /N_HQ = N(PHANDU)
  /TB_DD = MEAN(DUDOAN) /SD_DD = SD(DUDOAN).
COMPUTE ZRESID = PHANDU / SQRT(SSE / (N_HQ - 5)).
COMPUTE ZPRED = (DUDOAN - TB_DD) / SD_DD.
VARIABLE LABELS ZRESID 'Phần dư chuẩn hóa' /ZPRED 'Giá trị dự đoán chuẩn hóa'.
EXECUTE.

* Bước 2b. Dạng tuyến tính: kiểm định RESET của Ramsey.
* Thêm bình phương giá trị dự đoán vào mô hình; nếu hệ số của nó có ý nghĩa, quan hệ có thể không tuyến tính.
COMPUTE DD2 = DUDOAN ** 2.
REGRESSION /VARIABLES=XN HI HL NT DD2 /DEPENDENT=YD /METHOD=ENTER /STATISTICS=COEFF.

* Bước 3. Phân phối chuẩn của phần dư: histogram, biểu đồ Q-Q, kiểm định Shapiro-Wilk.
EXAMINE VARIABLES=ZRESID /PLOT=HISTOGRAM NPPLOT /STATISTICS=DESCRIPTIVES EXTREME(5) /ID=ID.

* Bước 4. Phương sai sai số không đổi: biểu đồ phân tán ZRESID theo ZPRED.
GRAPH /SCATTERPLOT(BIVAR)=ZPRED WITH ZRESID.

* Kiểm định Breusch-Pagan (phiên bản Koenker): hồi quy bình phương phần dư theo các biến độc lập.
* Thống kê LM = N x R bình phương của hồi quy phụ, có phân phối khi bình phương với 4 bậc tự do.
REGRESSION /VARIABLES=XN HI HL NT /DEPENDENT=PD2 /METHOD=ENTER /STATISTICS=R ANOVA.

* Bước 5. Tính độc lập của phần dư: hệ số Durbin-Watson (phụ thuộc vào thứ tự phiếu trong file).
SORT CASES BY ID.
COMPUTE CHENH2 = (PHANDU - LAG(PHANDU)) ** 2.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /TONG_CHENH2 = SUM(CHENH2).
COMPUTE DW = TONG_CHENH2 / SSE.
FORMATS DW (F6.3).
TEMPORARY.
SELECT IF $CASENUM = 1.
LIST /VARIABLES=DW SSE N_HQ.

* Bước 6. Điểm có ảnh hưởng: đòn bẩy (leverage) và khoảng cách Cook, tính bằng MATRIX.
MATRIX.
GET X /VARIABLES=XN HI HL NT.
GET E /VARIABLES=PHANDU.
GET MAID /VARIABLES=ID.
COMPUTE N = NROW(X).
COMPUTE X1 = {MAKE(N, 1, 1), X}.
COMPUTE P = NCOL(X1).
COMPUTE H = DIAG(X1 * INV(T(X1) * X1) * T(X1)).
COMPUTE MSE = CSSQ(E) / (N - P).
COMPUTE COOK = (E &** 2 / (P * MSE)) &* (H &/ (1 - H) &** 2).
COMPUTE SRESID = E &/ SQRT(MSE * (1 - H)).
SAVE {MAID, H, COOK, SRESID} /OUTFILE='../du-lieu/anh_huong.sav' /VARIABLES=ID DONBAY COOK SRESID.
END MATRIX.
SORT CASES BY ID.
MATCH FILES /FILE=* /FILE='../du-lieu/anh_huong.sav' /BY ID.
FORMATS ID (F4.0) DONBAY COOK SRESID (F7.3).
* Ngưỡng: Cook > 4/N; đòn bẩy > 2(k+1)/N; phần dư studentized có trị tuyệt đối > 3.
COMPUTE COOK_CAO = (COOK > 4 / N_HQ).
COMPUTE DONBAY_CAO = (DONBAY > 2 * 5 / N_HQ).
COMPUTE SRES_CAO = (ABS(SRESID) > 3).
FREQUENCIES COOK_CAO DONBAY_CAO SRES_CAO /STATISTICS=NONE.
DESCRIPTIVES COOK DONBAY SRESID /STATISTICS=MEAN MIN MAX.
SORT CASES BY COOK (D).
LIST /VARIABLES=ID YD DUDOAN PHANDU SRESID DONBAY COOK /CASES=FROM 1 TO 6.
SORT CASES BY ID.

* Bước 7. Phân tích độ nhạy: chạy lại hồi quy khi bỏ các phiếu có Cook > 4/N.
TEMPORARY.
SELECT IF COOK <= 4 / N_HQ.
REGRESSION /VARIABLES=XN HI HL NT /DEPENDENT=YD /METHOD=ENTER /STATISTICS=COEFF R ANOVA.

SAVE OUTFILE='../du-lieu/phan_du_hoi_quy.sav'
  /KEEP=ID YD DUDOAN PHANDU ZPRED ZRESID SRESID DONBAY COOK.
DATASET ACTIVATE CHINH.
DATASET CLOSE HQ.
