* =====================================================================.
* Bài 16. Biến giả (dummy) và biến điều tiết (moderator) trong hồi quy.
* Dữ liệu: du_lieu_phan_tich.sav. Cách chạy: pspp --syntax-encoding=UTF-8 bien_gia_dieu_tiet.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* ---------------------------------------------------------------------.
* Phần 1. Tạo biến giả cho Nghề nghiệp (4 nhóm -> 3 biến giả, nhóm tham chiếu: Sinh viên).
* ---------------------------------------------------------------------.
RECODE NGHE (2=1) (1,3,4=0) (MISSING=SYSMIS) INTO D_VANPHONG.
RECODE NGHE (3=1) (1,2,4=0) (MISSING=SYSMIS) INTO D_KINHDOANH.
RECODE NGHE (4=1) (1,2,3=0) (MISSING=SYSMIS) INTO D_KHAC.
VARIABLE LABELS D_VANPHONG 'Nhân viên văn phòng (so với Sinh viên)'
  /D_KINHDOANH 'Kinh doanh tự do (so với Sinh viên)' /D_KHAC 'Nghề khác (so với Sinh viên)'.
FORMATS D_VANPHONG D_KINHDOANH D_KHAC (F1.0).
* Kiểm tra: mỗi nhóm nghề phải ứng đúng một tổ hợp 0/1.
MEANS TABLES=D_VANPHONG D_KINHDOANH D_KHAC BY NGHE /CELLS=MEAN COUNT.

* Biến giả cho Giới tính: Nữ = 1, Nam = 0; nhóm "Khác" (n rất nhỏ) để giá trị thiếu.
RECODE GIOITINH (2=1) (1=0) (ELSE=SYSMIS) INTO D_NU.
VARIABLE LABELS D_NU 'Nữ (so với Nam)'.
FORMATS D_NU (F1.0).

* So sánh trung bình YD theo nghề nghiệp để đối chiếu với hệ số biến giả.
MEANS TABLES=YD BY NGHE /CELLS=MEAN COUNT STDDEV.

* ---------------------------------------------------------------------.
* Phần 2. Hồi quy với biến giả.
* ---------------------------------------------------------------------.
* 2a. Chỉ biến giả nghề nghiệp: hằng số = trung bình YD của nhóm tham chiếu.
REGRESSION /VARIABLES=D_VANPHONG D_KINHDOANH D_KHAC /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF R ANOVA.
* 2b. Bẫy biến giả: đưa cả 4 biến giả cùng hằng số.
RECODE NGHE (1=1) (2,3,4=0) INTO D_SINHVIEN.
REGRESSION /VARIABLES=D_SINHVIEN D_VANPHONG D_KINHDOANH D_KHAC /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF R TOL.
* 2c. Mô hình 2 của Bài 14 cộng thêm biến giả nghề nghiệp và giới tính làm biến kiểm soát.
DATASET NAME CHINH.
DATASET COPY DAYDU.
DATASET ACTIVATE DAYDU.
SELECT IF NMISS(XN, HI, HL, NT, YD, D_VANPHONG, D_NU) = 0.
REGRESSION /VARIABLES=XN HI HL NT /DEPENDENT=YD /METHOD=ENTER /STATISTICS=R ANOVA.
REGRESSION /VARIABLES=XN HI HL NT D_VANPHONG D_KINHDOANH D_KHAC D_NU /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF R ANOVA TOL.
DATASET ACTIVATE CHINH.
DATASET CLOSE DAYDU.

* ---------------------------------------------------------------------.
* Phần 3. Biến điều tiết: Niềm tin có điều tiết tác động của Sự hài lòng đến Ý định mua lại?
* ---------------------------------------------------------------------.
* 3a. Biến tích không chuẩn hóa tâm (để thấy đa cộng tuyến "giả").
COMPUTE HLxNT_THO = HL * NT.
* 3b. Chuẩn hóa tâm (mean centering): trừ trung bình rồi mới nhân.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /TB_HL = MEAN(HL) /TB_NT = MEAN(NT) /TB_XN = MEAN(XN) /TB_HI = MEAN(HI)
  /SD_NT = SD(NT).
COMPUTE HL_C = HL - TB_HL.
COMPUTE NT_C = NT - TB_NT.
COMPUTE XN_C = XN - TB_XN.
COMPUTE HI_C = HI - TB_HI.
COMPUTE HLxNT = HL_C * NT_C.
VARIABLE LABELS HL_C 'HL (đã trừ trung bình)' /NT_C 'NT (đã trừ trung bình)' /HLxNT 'HL x NT (đã trừ trung bình)'.
EXECUTE.

DATASET NAME CHINH.
DATASET COPY DT.
DATASET ACTIVATE DT.
SELECT IF NMISS(XN, HI, HL, NT, YD) = 0.
* Khối 1: các biến chính. Khối 2: thêm biến tích.
REGRESSION /VARIABLES=XN_C HI_C HL_C NT_C /DEPENDENT=YD /METHOD=ENTER /STATISTICS=R ANOVA.
REGRESSION /VARIABLES=XN_C HI_C HL_C NT_C HLxNT /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF CI(95) R ANOVA TOL.
* So sánh: biến tích chưa chuẩn hóa tâm.
REGRESSION /VARIABLES=XN HI HL NT HLxNT_THO /DEPENDENT=YD /METHOD=ENTER /STATISTICS=COEFF TOL.

* 3c. Độ dốc đơn giản (simple slopes): tác động của HL khi NT thấp (-1 SD), trung bình, cao (+1 SD).
* Kỹ thuật: dời gốc của NT đến mức cần xét, tạo lại biến tích, hệ số của HL_C lúc đó là độ dốc đơn giản.
COMPUTE NT_THAP = NT_C + SD_NT.
COMPUTE NT_CAO = NT_C - SD_NT.
COMPUTE HLxNT_THAP = HL_C * NT_THAP.
COMPUTE HLxNT_CAO = HL_C * NT_CAO.
REGRESSION /VARIABLES=XN_C HI_C HL_C NT_THAP HLxNT_THAP /DEPENDENT=YD /METHOD=ENTER /STATISTICS=COEFF CI(95).
REGRESSION /VARIABLES=XN_C HI_C HL_C NT_CAO HLxNT_CAO /DEPENDENT=YD /METHOD=ENTER /STATISTICS=COEFF CI(95).
DATASET ACTIVATE CHINH.
DATASET CLOSE DT.
