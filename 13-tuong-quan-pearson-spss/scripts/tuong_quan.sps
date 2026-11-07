* =====================================================================.
* Bài 13. Phân tích tương quan Pearson giữa các biến đại diện.
* Dữ liệu: du_lieu_phan_tich.sav (267 phiếu; biến đại diện tính ở Bài 10).
* Cách chạy: pspp --syntax-encoding=UTF-8 tuong_quan.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* Phần 1. Ma trận tương quan Pearson giữa 5 biến đại diện (loại theo cặp, mặc định).
CORRELATIONS /VARIABLES=XN HI HL NT YD /PRINT=TWOTAIL NOSIG /STATISTICS=DESCRIPTIVES.

* Phần 2. Cùng ma trận nhưng loại theo danh sách: mọi hệ số dùng cùng một tập phiếu.
CORRELATIONS /VARIABLES=XN HI HL NT YD /MISSING=LISTWISE.

* Phần 3. Tương quan của biến kết quả YD với tuổi và số lần mua.
CORRELATIONS /VARIABLES=YD TUOI TANSUAT.
* Tương quan hạng Spearman: ít nhạy với giá trị ngoại lai (phiếu 99 có TANSUAT = 95).
* PSPP 2.0 chưa có lệnh NONPAR CORR. Spearman chính là Pearson tính trên thứ hạng,
* nên ta xếp hạng bằng RANK rồi chạy CORRELATIONS trên biến thứ hạng.
RANK VARIABLES=YD TUOI TANSUAT (A) /RANK INTO R_YD R_TUOI R_TS /TIES=MEAN.
CORRELATIONS /VARIABLES=R_YD R_TUOI R_TS.
* Tương quan Pearson khi bỏ phiếu 99.
TEMPORARY.
SELECT IF ID <> 99.
CORRELATIONS /VARIABLES=YD TANSUAT.

* Phần 4. Tương quan riêng phần: HL và YD khi kiểm soát XN và HI.
* PSPP 2.0 chưa có lệnh PARTIAL CORR. Cách làm tương đương: lấy phần dư của HL và của YD
* sau khi hồi quy từng biến theo XN và HI, rồi tính tương quan giữa hai phần dư.
* Chỉ dùng phiếu có đủ 4 biến, trên một bản sao dữ liệu, để không ảnh hưởng dữ liệu chính.
DATASET NAME CHINH.
DATASET COPY RIENGPHAN.
DATASET ACTIVATE RIENGPHAN.
SELECT IF NMISS(HL, YD, XN, HI) = 0.
REGRESSION /VARIABLES=XN HI /DEPENDENT=HL /SAVE=RESID.
RENAME VARIABLES (RES1 = E_HL).
REGRESSION /VARIABLES=XN HI /DEPENDENT=YD /SAVE=RESID.
RENAME VARIABLES (RES1 = E_YD).
VARIABLE LABELS E_HL 'HL sau khi loại ảnh hưởng của XN, HI' /E_YD 'YD sau khi loại ảnh hưởng của XN, HI'.
CORRELATIONS /VARIABLES=E_HL E_YD.
DATASET ACTIVATE CHINH.
DATASET CLOSE RIENGPHAN.

* Phần 5. Biểu đồ phân tán để kiểm tra dạng quan hệ tuyến tính.
GRAPH /SCATTERPLOT(BIVAR)=HL WITH YD.
GRAPH /SCATTERPLOT(BIVAR)=TANSUAT WITH YD.
