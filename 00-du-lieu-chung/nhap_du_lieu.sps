* Nhập dữ liệu mẫu (du_lieu_mau_san_x.csv) vào PSPP, gán nhãn và lưu file .sav.
* Cách chạy:  pspp --syntax-encoding=UTF-8 nhap_du_lieu.sps   (trong thư mục chứa file CSV)
* Hoặc mở file này trong cửa sổ Syntax của PSPP/SPSS và chọn Run > All.

GET DATA
  /TYPE=TXT
  /FILE='du_lieu_mau_san_x.csv'
  /ENCODING='UTF-8'
  /ARRANGEMENT=DELIMITED
  /DELCASE=LINE
  /FIRSTCASE=2
  /DELIMITERS=','
  /VARIABLES=
    ID F4.0 SL1 F1.0 GIOITINH F1.0 TUOI F3.0 NGHE F1.0 THUNHAP F1.0 TANSUAT F3.0
    XN1 F2.0 XN2 F2.0 XN3 F2.0 XN4 F2.0
    HI1 F2.0 HI2 F2.0 HI3 F2.0 HI4 F2.0
    HL1 F2.0 HL2 F2.0 AC1 F1.0 HL3 F2.0 HL4 F2.0
    NT1 F2.0 NT2 F2.0 NT3 F2.0 NT4 F2.0
    YD1 F2.0 YD2 F2.0 YD3 F2.0 YD4 F2.0.

VARIABLE LABELS
  ID 'Mã phiếu'
  SL1 'Trong 6 tháng qua, bạn đã mua hàng trên sàn X chưa?'
  GIOITINH 'Giới tính'
  TUOI 'Tuổi'
  NGHE 'Nghề nghiệp'
  THUNHAP 'Thu nhập hằng tháng'
  TANSUAT 'Số lần mua trên sàn X trong 6 tháng qua'
  XN1 'Trải nghiệm mua hàng trên sàn X tốt hơn tôi kỳ vọng'
  XN2 'Chất lượng sản phẩm nhận được tốt hơn tôi kỳ vọng'
  XN3 'Dịch vụ giao hàng của sàn X tốt hơn tôi kỳ vọng'
  XN4 'Nhìn chung, hầu hết kỳ vọng của tôi về sàn X đều được đáp ứng'
  HI1 'Mua hàng trên sàn X giúp tôi tiết kiệm thời gian'
  HI2 'Mua hàng trên sàn X giúp tôi tìm được giá tốt'
  HI3 'Sàn X giúp tôi dễ so sánh và lựa chọn sản phẩm'
  HI4 'Nhìn chung, sàn X hữu ích cho nhu cầu mua sắm của tôi'
  HL1 'Tôi hài lòng với các lần mua hàng trên sàn X'
  HL2 'Mua hàng trên sàn X là một lựa chọn đúng đắn'
  AC1 'Để kiểm tra mức độ chú ý, hãy chọn mức 2 cho câu này'
  HL3 'Tôi cảm thấy vui khi mua hàng trên sàn X'
  HL4 'Nhìn chung, tôi hài lòng với sàn X'
  NT1 'Tôi tin sàn X trung thực với khách hàng'
  NT2 'Tôi tin sàn X bảo vệ thông tin cá nhân của tôi'
  NT3 'Tôi tin sàn X giải quyết khiếu nại công bằng'
  NT4 'Tôi lo ngại sàn X không giữ đúng cam kết (câu đảo chiều)'
  YD1 'Tôi dự định tiếp tục mua hàng trên sàn X'
  YD2 'Tôi sẽ ưu tiên sàn X cho lần mua sắm trực tuyến tới'
  YD3 'Tôi có khả năng mua lại trên sàn X trong 3 tháng tới'
  YD4 'Tôi sẽ mua trên sàn X thường xuyên hơn'.

VALUE LABELS
  SL1 1 'Có' 2 'Chưa'
  /GIOITINH 1 'Nam' 2 'Nữ' 3 'Khác'
  /NGHE 1 'Sinh viên' 2 'Nhân viên văn phòng' 3 'Kinh doanh tự do' 4 'Khác'
  /THUNHAP 1 'Dưới 10 triệu' 2 'Từ 10 đến dưới 20 triệu' 3 'Từ 20 đến dưới 30 triệu' 4 'Từ 30 triệu trở lên'
  /XN1 TO YD4 1 'Hoàn toàn không đồng ý' 2 'Không đồng ý' 3 'Trung lập' 4 'Đồng ý' 5 'Hoàn toàn đồng ý'.

VARIABLE LEVEL
  ID GIOITINH NGHE SL1 (NOMINAL)
  /THUNHAP XN1 TO YD4 (ORDINAL)
  /TUOI TANSUAT (SCALE).

SAVE OUTFILE='du_lieu_mau_san_x.sav'.
DISPLAY DICTIONARY.
