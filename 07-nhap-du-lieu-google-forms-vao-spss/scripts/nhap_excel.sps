* =====================================================================.
* Nhập dữ liệu Excel (đã mã hóa số) vào PSPP/SPSS: bốn tình huống thường gặp.
* Chỉ chạy MỘT khối lệnh phù hợp với file của bạn (bôi đen khối đó, chọn Run > Selection).
* Sửa đường dẫn ở /FILE cho đúng vị trí file trên máy bạn.
* /VARIABLES phải liệt kê ĐỦ mọi cột trong file, theo đúng thứ tự.
* =====================================================================.

* Tình huống 1. Excel lưu bằng "CSV UTF-8 (Comma delimited)": khuyến nghị.
GET DATA /TYPE=TXT /FILE='../du-lieu/du_lieu_excel_utf8.csv' /ENCODING='UTF-8'
  /ARRANGEMENT=DELIMITED /DELCASE=LINE /FIRSTCASE=2 /DELIMITERS=','
  /VARIABLES=
    ID F4.0 SL1 F1.0 GIOITINH F1.0 TUOI F3.0 NGHE F1.0 THUNHAP F1.0 TANSUAT F3.0
    XN1 F1.0 XN2 F1.0 XN3 F1.0 XN4 F1.0 HI1 F1.0 HI2 F1.0 HI3 F1.0
    HI4 F1.0 HL1 F1.0 HL2 F1.0 AC1 F1.0 HL3 F1.0 HL4 F1.0 NT1 F1.0
    NT2 F1.0 NT3 F1.0 NT4 F1.0 YD1 F1.0 YD2 F1.0 YD3 F1.0 YD4 F1.0.
LIST /VARIABLES=ID SL1 GIOITINH TUOI XN1 YD4 /CASES=FROM 1 TO 3.

* Tình huống 2. Excel lưu bằng "CSV (Comma delimited)" trên Windows tiếng Việt:
* file dùng bảng mã Windows-1258, phải khai báo đúng ENCODING thì chữ có dấu mới đúng.
GET DATA /TYPE=TXT /FILE='../du-lieu/du_lieu_excel_ansi.csv' /ENCODING='windows-1258'
  /ARRANGEMENT=DELIMITED /DELCASE=LINE /FIRSTCASE=2 /DELIMITERS=','
  /VARIABLES=
    ID F4.0 GHICHU A20 SL1 F1.0 GIOITINH F1.0 TUOI F3.0 NGHE F1.0 THUNHAP F1.0 TANSUAT F3.0
    XN1 F1.0 XN2 F1.0 XN3 F1.0 XN4 F1.0 HI1 F1.0 HI2 F1.0 HI3 F1.0
    HI4 F1.0 HL1 F1.0 HL2 F1.0 AC1 F1.0 HL3 F1.0 HL4 F1.0 NT1 F1.0
    NT2 F1.0 NT3 F1.0 NT4 F1.0 YD1 F1.0 YD2 F1.0 YD3 F1.0 YD4 F1.0.
LIST /VARIABLES=ID GHICHU SL1 GIOITINH /CASES=FROM 1 TO 3.

* Tình huống 3. Máy dùng định dạng vùng Việt Nam: Excel ngăn cách bằng dấu chấm phẩy.
GET DATA /TYPE=TXT /FILE='../du-lieu/du_lieu_excel_champhay.csv' /ENCODING='UTF-8'
  /ARRANGEMENT=DELIMITED /DELCASE=LINE /FIRSTCASE=2 /DELIMITERS=';'
  /VARIABLES=
    ID F4.0 SL1 F1.0 GIOITINH F1.0 TUOI F3.0 NGHE F1.0 THUNHAP F1.0 TANSUAT F3.0
    XN1 F1.0 XN2 F1.0 XN3 F1.0 XN4 F1.0 HI1 F1.0 HI2 F1.0 HI3 F1.0
    HI4 F1.0 HL1 F1.0 HL2 F1.0 AC1 F1.0 HL3 F1.0 HL4 F1.0 NT1 F1.0
    NT2 F1.0 NT3 F1.0 NT4 F1.0 YD1 F1.0 YD2 F1.0 YD3 F1.0 YD4 F1.0.
LIST /CASES=FROM 1 TO 3.

* Tình huống 4. Lưu file Excel sang định dạng ODS (LibreOffice) rồi nhập trực tiếp.
* READNAMES=ON: dùng dòng đầu tiên làm tên biến.
GET DATA /TYPE=ODS /FILE='../../du-lieu-mau/du_lieu_mau_san_x.ods' /READNAMES=ON.
LIST /VARIABLES=ID SL1 GIOITINH TUOI /CASES=FROM 1 TO 3.
