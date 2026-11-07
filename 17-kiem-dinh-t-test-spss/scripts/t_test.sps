* =====================================================================.
* Bài 17. Kiểm định T-test: hai mẫu độc lập, mẫu cặp và một mẫu.
* Dữ liệu: du_lieu_phan_tich.sav. Cách chạy: pspp --syntax-encoding=UTF-8 t_test.sps
* PSPP không in hệ số ảnh hưởng Cohen's d; file này tính d bằng AGGREGATE.
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* ---------------------------------------------------------------------.
* Phần 1. Independent Samples T-test: nam và nữ có ý định mua lại khác nhau không?
* Nhóm giới tính "Khác" (mã 3) không thuộc hai nhóm so sánh nên tự động bị loại.
* ---------------------------------------------------------------------.
EXAMINE VARIABLES=YD BY GIOITINH /PLOT=BOXPLOT /STATISTICS=NONE.
T-TEST /VARIABLES=YD HL TANSUAT /GROUPS=GIOITINH(1,2) /MISSING=ANALYSIS /CRITERIA=CI(0.95).

* Cohen's d = chênh lệch trung bình / độ lệch chuẩn gộp.
DATASET NAME CHINH.
DATASET COPY TINH_D.
DATASET ACTIVATE TINH_D.
SELECT IF ANY(GIOITINH, 1, 2) AND NOT MISSING(YD).
* AGGREGATE theo nhóm cần dữ liệu được sắp xếp theo biến nhóm trước.
SORT CASES BY GIOITINH.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /BREAK=GIOITINH /TB_NHOM=MEAN(YD).
IF (GIOITINH = 1) YD_NAM = YD.
IF (GIOITINH = 2) YD_NU = YD.
COMPUTE BP_LECH = (YD - TB_NHOM) ** 2.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /TB_NAM=MEAN(YD_NAM) /TB_NU=MEAN(YD_NU)
  /SS_TRONG=SUM(BP_LECH) /N_TONG=N(YD).
COMPUTE SD_GOP = SQRT(SS_TRONG / (N_TONG - 2)).
COMPUTE COHEN_D = (TB_NAM - TB_NU) / SD_GOP.
FORMATS TB_NAM TB_NU SD_GOP COHEN_D (F7.3).
TEMPORARY.
SELECT IF $CASENUM = 1.
LIST /VARIABLES=N_TONG TB_NAM TB_NU SD_GOP COHEN_D.
DATASET ACTIVATE CHINH.
DATASET CLOSE TINH_D.

* Phương án phi tham số: kiểm định Mann-Whitney U.
NPAR TESTS /M-W=YD BY GIOITINH(1 2).

* ---------------------------------------------------------------------.
* Phần 2. Paired Samples T-test: khách hàng đánh giá lợi ích "tìm được giá tốt" (HI2)
* và "dễ so sánh, lựa chọn sản phẩm" (HI3) có khác nhau không?
* ---------------------------------------------------------------------.
T-TEST /PAIRS=HI2 WITH HI3 (PAIRED) /CRITERIA=CI(0.95).
COMPUTE CHENH_HI = HI2 - HI3.
DESCRIPTIVES CHENH_HI /STATISTICS=MEAN STDDEV.
* Cohen's d cho mẫu cặp (d_z) = trung bình chênh lệch / độ lệch chuẩn của chênh lệch.
NPAR TESTS /WILCOXON=HI2 WITH HI3 (PAIRED).

* ---------------------------------------------------------------------.
* Phần 3. One-Sample T-test: so sánh trung bình với một giá trị cho trước.
* 3a. So với 3 (mức Trung lập).  3b. So với 4 (mục tiêu "Đồng ý" của sàn X).
* ---------------------------------------------------------------------.
T-TEST /TESTVAL=3 /VARIABLES=HL YD /CRITERIA=CI(0.95).
T-TEST /TESTVAL=4 /VARIABLES=HL YD /CRITERIA=CI(0.95).
