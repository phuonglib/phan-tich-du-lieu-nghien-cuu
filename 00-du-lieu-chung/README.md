# Bộ dữ liệu mẫu: Ý định mua lại trên sàn X

Bộ dữ liệu **giả lập** dùng chung cho loạt bài phân tích dữ liệu nghiên cứu định lượng trên phuongacademy.com. Dữ liệu chỉ dùng để học, không phải kết quả khảo sát thật.

**Đề tài mẫu:** Các yếu tố ảnh hưởng đến ý định mua lại của khách hàng trên sàn thương mại điện tử X: vai trò trung gian của sự hài lòng.

## Các file

| File | Dùng để |
|---|---|
| `du_lieu_mau_san_x.sav` | Mở trực tiếp trong PSPP hoặc SPSS (đã có nhãn biến, nhãn giá trị, cấp độ đo lường) |
| `du_lieu_mau_san_x.csv` | Thực hành nhập dữ liệu dạng văn bản |
| `du_lieu_mau_san_x.ods` | Thực hành nhập bảng tính vào PSPP (PSPP không đọc trực tiếp .xlsx) |
| `du_lieu_mau_san_x.xlsx` | Dùng với SPSS, SmartPLS hoặc Excel |
| `tao_du_lieu.py` | Script tạo dữ liệu (seed cố định, chạy lại cho kết quả y hệt) |
| `nhap_du_lieu.sps` | Cú pháp nhập CSV, gán nhãn và lưu .sav: `pspp --syntax-encoding=UTF-8 nhap_du_lieu.sps` |
| `du_lieu_sach.sav` | Bộ dữ liệu đã làm sạch ở Bài 8 (267 phiếu), dùng cho các bài phân tích tiếp theo |
| `lam_sach.sps` | Cú pháp làm sạch dữ liệu của Bài 8 (chạy trong thư mục scripts của bai-08) |
| `du_lieu_phan_tich.sav` | Dữ liệu sạch + NT4R đã mã hóa ngược + 5 biến đại diện XN, HI, HL, NT, YD (Bài 10) |
| `bien_dai_dien.sps` | Cú pháp mã hóa ngược và tính biến đại diện của Bài 10 |

## Danh sách biến (300 phiếu, 28 biến)

| Nhóm | Biến | Mô tả | Cấp độ đo lường |
|---|---|---|---|
| Định danh | ID | Mã phiếu | Nominal |
| Gạn lọc | SL1 | Đã mua trên sàn X trong 6 tháng qua (1 = Có, 2 = Chưa) | Nominal |
| Nhân khẩu học | GIOITINH | 1 = Nam, 2 = Nữ, 3 = Khác | Nominal |
| | TUOI | Tuổi (năm) | Scale |
| | NGHE | 1 = Sinh viên, 2 = Nhân viên văn phòng, 3 = Kinh doanh tự do, 4 = Khác | Nominal |
| | THUNHAP | 1 = Dưới 10 triệu, 2 = 10–dưới 20, 3 = 20–dưới 30, 4 = Từ 30 triệu | Ordinal |
| | TANSUAT | Số lần mua trên sàn X trong 6 tháng qua | Scale |
| Xác nhận kỳ vọng | XN1–XN4 | Likert 1–5 | Ordinal |
| Nhận thức hữu ích | HI1–HI4 | Likert 1–5 | Ordinal |
| Sự hài lòng | HL1–HL4 | Likert 1–5 | Ordinal |
| Kiểm tra chú ý | AC1 | "Hãy chọn mức 2 cho câu này" (nằm giữa HL2 và HL3) | Ordinal |
| Niềm tin | NT1–NT4 | Likert 1–5; **NT4 là câu đảo chiều, chưa mã hóa lại** | Ordinal |
| Ý định mua lại | YD1–YD4 | Likert 1–5 | Ordinal |

Lưu ý: tên biến giới tính là `GIOITINH`, không dùng `GT`, vì `GT` là từ khóa dành riêng trong cú pháp SPSS/PSPP (phép so sánh "lớn hơn").

## Các vấn đề được cài sẵn để thực hành làm sạch dữ liệu

Dành cho người hướng dẫn; người học nên tự phát hiện trước khi đọc phần này.

- 14 phiếu trả lời "Chưa" ở câu gạn lọc SL1.
- 11 phiếu trả lời sai câu kiểm tra chú ý AC1.
- 8 phiếu chọn cùng một mức cho mọi câu Likert.
- 12 phiếu bỏ trống 1–2 câu Likert.
- 3 lỗi hoặc giá trị ngoại lai: một tuổi bằng 230, một số lần mua bằng 95, một giá trị 55 ở câu HL2.

Sau khi loại các phiếu không hợp lệ (33 phiếu: 14 gạn lọc, 19 sai câu chú ý, trong đó có 8 phiếu trả lời một mức), còn 267 phiếu, vượt cỡ mẫu mục tiêu 250 ở Bài 4.

## Mô hình dùng để sinh dữ liệu

Hệ số chuẩn hóa trong tổng thể giả lập: HI = 0,55·XN; HL = 0,45·XN + 0,30·HI; YD = 0,20·HI + 0,40·HL + 0,25·NT; tương quan giữa XN và NT là 0,35. Kết quả phân tích trên mẫu sẽ dao động quanh các giá trị này.
