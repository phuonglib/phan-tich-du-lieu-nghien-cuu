* =====================================================================.
* Bài 11. Kiểm định độ tin cậy thang đo bằng Cronbach's Alpha.
* Dữ liệu: du_lieu_phan_tich.sav (267 phiếu, đã có NT4R ở Bài 10).
* Cách chạy: pspp --syntax-encoding=UTF-8 cronbach_alpha.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* Thang đo 1. Xác nhận kỳ vọng.
RELIABILITY /VARIABLES=XN1 XN2 XN3 XN4 /SCALE('Xác nhận kỳ vọng') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.
* Thang đo 2. Nhận thức hữu ích.
RELIABILITY /VARIABLES=HI1 HI2 HI3 HI4 /SCALE('Nhận thức hữu ích') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.
* Thang đo 3. Sự hài lòng.
RELIABILITY /VARIABLES=HL1 HL2 HL3 HL4 /SCALE('Sự hài lòng') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.
* Thang đo 4. Niềm tin (dùng NT4R đã mã hóa ngược).
RELIABILITY /VARIABLES=NT1 NT2 NT3 NT4R /SCALE('Niềm tin') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.
* Thang đo 5. Ý định mua lại.
RELIABILITY /VARIABLES=YD1 YD2 YD3 YD4 /SCALE('Ý định mua lại') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.

* Minh họa lỗi: chạy thang Niềm tin với NT4 CHƯA mã hóa ngược.
RELIABILITY /VARIABLES=NT1 NT2 NT3 NT4 /SCALE('Niềm tin - dùng NT4 gốc (SAI)') ALL
  /MODEL=ALPHA /SUMMARY=TOTAL.

* Ma trận tương quan giữa các câu trong một thang đo (kiểm tra tương quan giữa các câu).
CORRELATIONS /VARIABLES=NT1 NT2 NT3 NT4R.

* Độ tin cậy hai nửa (Split-half) để tham khảo.
RELIABILITY /VARIABLES=YD1 YD2 YD3 YD4 /SCALE('Ý định mua lại') ALL /MODEL=SPLIT(2).
