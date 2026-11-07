* =====================================================================.
* Bài 14. Hồi quy tuyến tính bội: kiểm định các giả thuyết H1-H6.
* Dữ liệu: du_lieu_phan_tich.sav (267 phiếu; biến đại diện tính ở Bài 10).
* Cách chạy: pspp --syntax-encoding=UTF-8 hoi_quy.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* Mô hình 0 (H1). Hồi quy đơn: Xác nhận kỳ vọng -> Nhận thức hữu ích.
REGRESSION /VARIABLES=XN /DEPENDENT=HI /METHOD=ENTER
  /STATISTICS=COEFF CI(95) R ANOVA.

* Mô hình 1 (H2, H3). Xác nhận kỳ vọng và Nhận thức hữu ích -> Sự hài lòng.
REGRESSION /VARIABLES=XN HI /DEPENDENT=HL /METHOD=ENTER
  /STATISTICS=COEFF CI(95) R ANOVA TOL.

* Mô hình 2 (H4, H5, H6). Bốn biến -> Ý định mua lại.
* XN được đưa vào để kiểm tra XN có tác động trực tiếp đến YD ngoài con đường qua HL hay không.
REGRESSION /VARIABLES=XN HI HL NT /DEPENDENT=YD /METHOD=ENTER
  /STATISTICS=COEFF CI(95) R ANOVA TOL.

* Hồi quy thứ bậc: HL giải thích thêm bao nhiêu phương sai của YD?
* PSPP 2.0 chưa hỗ trợ nhiều khối /METHOD trong một lệnh REGRESSION, nên chạy hai mô hình
* trên CÙNG một tập phiếu đầy đủ rồi so sánh R bình phương.
DATASET NAME CHINH.
DATASET COPY DAYDU.
DATASET ACTIVATE DAYDU.
SELECT IF NMISS(XN, HI, HL, NT, YD) = 0.
REGRESSION /VARIABLES=XN HI NT /DEPENDENT=YD /METHOD=ENTER /STATISTICS=R ANOVA.
REGRESSION /VARIABLES=XN HI NT HL /DEPENDENT=YD /METHOD=ENTER /STATISTICS=R ANOVA.
DATASET ACTIVATE CHINH.
DATASET CLOSE DAYDU.
