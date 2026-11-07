* =====================================================================.
* Nhập file Google Forms (CSV) vào PSPP/SPSS và chuyển câu trả lời chữ thành mã số.
* Cách chạy: mở file trong cửa sổ Syntax và chọn Run > All,
* hoặc dòng lệnh: pspp --syntax-encoding=UTF-8 nhap_google_forms.sps.
* Sửa đường dẫn ở /FILE cho đúng vị trí file trên máy bạn.
* =====================================================================.

* Bước 1. Nhập dữ liệu, tự đặt tên biến ngắn (bỏ qua dòng tiêu đề bằng FIRSTCASE=2).
* Câu trả lời dạng chữ được nhập tạm vào các biến chuỗi có hậu tố _S.
* GET DATA yêu cầu khai báo định dạng cho từng biến (A30 = chuỗi tối đa 30 ký tự).
GET DATA
  /TYPE=TXT
  /FILE='../du-lieu/phan_hoi_google_forms.csv'
  /ENCODING='UTF-8'
  /ARRANGEMENT=DELIMITED
  /DELCASE=LINE
  /FIRSTCASE=2
  /DELIMITERS=','
  /QUALIFIER='"'
  /VARIABLES=
    THOIGIAN A19 SL1_S A10 GIOITINH_S A10 TUOI F3.0 NGHE_S A30 THUNHAP_S A40 TANSUAT F3.0
    XN1_S A30 XN2_S A30 XN3_S A30 XN4_S A30 HI1_S A30 HI2_S A30 HI3_S A30
    HI4_S A30 HL1_S A30 HL2_S A30 AC1_S A30 HL3_S A30 HL4_S A30 NT1_S A30
    NT2_S A30 NT3_S A30 NT4_S A30 YD1_S A30 YD2_S A30 YD3_S A30 YD4_S A30.

* Bước 2. Chuyển câu trả lời chữ thành mã số.
RECODE SL1_S ('Có'=1) ('Chưa'=2) INTO SL1.
RECODE GIOITINH_S ('Nam'=1) ('Nữ'=2) ('Khác'=3) INTO GIOITINH.
RECODE NGHE_S ('Sinh viên'=1) ('Nhân viên văn phòng'=2) ('Kinh doanh tự do'=3) ('Khác'=4) INTO NGHE.
RECODE THUNHAP_S ('Dưới 10 triệu'=1) ('Từ 10 đến dưới 20 triệu'=2)
  ('Từ 20 đến dưới 30 triệu'=3) ('Từ 30 triệu trở lên'=4) INTO THUNHAP.

* 21 câu Likert dùng chung một quy tắc: dùng DO REPEAT để không phải viết 21 lệnh.
DO REPEAT CHU = XN1_S XN2_S XN3_S XN4_S HI1_S HI2_S HI3_S HI4_S HL1_S HL2_S AC1_S
                HL3_S HL4_S NT1_S NT2_S NT3_S NT4_S YD1_S YD2_S YD3_S YD4_S
         /SO  = XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 AC1
                HL3 HL4 NT1 NT2 NT3 NT4 YD1 YD2 YD3 YD4.
  RECODE CHU ('Hoàn toàn không đồng ý'=1) ('Không đồng ý'=2) ('Trung lập'=3)
             ('Đồng ý'=4) ('Hoàn toàn đồng ý'=5) INTO SO.
END REPEAT.
EXECUTE.

* Bước 3. Kiểm tra: mọi câu trả lời phải được chuyển thành số.
* Nếu có ô chữ không rỗng mà biến số tương ứng bị thiếu, là do chính tả không khớp.
COUNT CHUA_MA = XN1 TO YD4 (SYSMIS).
COUNT O_TRONG = XN1_S TO YD4_S ('').
COMPUTE LOI_MA = CHUA_MA - O_TRONG.
FREQUENCIES LOI_MA /STATISTICS=NONE.

* Bước 4. Giữ lại các biến số theo đúng thứ tự bảng hỏi (bỏ các biến chữ tạm), gán nhãn và lưu file.
MATCH FILES /FILE=* /KEEP=THOIGIAN SL1 GIOITINH TUOI NGHE THUNHAP TANSUAT XN1 TO YD4.
VALUE LABELS
  SL1 1 'Có' 2 'Chưa'
  /GIOITINH 1 'Nam' 2 'Nữ' 3 'Khác'
  /NGHE 1 'Sinh viên' 2 'Nhân viên văn phòng' 3 'Kinh doanh tự do' 4 'Khác'
  /THUNHAP 1 'Dưới 10 triệu' 2 'Từ 10 đến dưới 20 triệu' 3 'Từ 20 đến dưới 30 triệu' 4 'Từ 30 triệu trở lên'
  /XN1 TO YD4 1 'Hoàn toàn không đồng ý' 2 'Không đồng ý' 3 'Trung lập' 4 'Đồng ý' 5 'Hoàn toàn đồng ý'.
FORMATS SL1 GIOITINH NGHE THUNHAP XN1 TO YD4 (F1.0).
VARIABLE LEVEL SL1 GIOITINH NGHE (NOMINAL) /THUNHAP XN1 TO YD4 (ORDINAL) /TUOI TANSUAT (SCALE).
SAVE OUTFILE='../du-lieu/google_forms_da_ma_hoa.sav'.
LIST /VARIABLES=SL1 GIOITINH TUOI NGHE THUNHAP XN1 XN2 HL1 YD1 /CASES=FROM 1 TO 5.
