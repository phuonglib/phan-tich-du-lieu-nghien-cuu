# Dữ liệu mẫu và script cho loạt bài phân tích dữ liệu nghiên cứu định lượng

Kho này chứa bộ dữ liệu mẫu, file phân tích và script đối chiếu dùng trong loạt bài hướng dẫn SPSS/PSPP, JASP, AMOS và SmartPLS trên [phuongacademy.com](https://phuongacademy.com).

Dữ liệu là **giả lập** theo đề tài mẫu "Các yếu tố ảnh hưởng đến ý định mua lại của khách hàng trên sàn thương mại điện tử X", chỉ dùng để học, không phải kết quả khảo sát thật. Mô tả biến, cách sinh dữ liệu và các lỗi cài sẵn để thực hành làm sạch nằm trong [00-du-lieu-chung/README.md](00-du-lieu-chung/README.md).

## Cách tải

- Tải cả kho: bấm nút **Code > Download ZIP** ở trang chính của kho, rồi giải nén.
- Mỗi thư mục `NN-...` ứng với một bài viết (bảng dưới). Thư mục `du-lieu/` chứa dữ liệu, `scripts/` chứa cú pháp PSPP/SPSS (`.sps`), script R (`.R`) và Python (`.py`). Script đọc dữ liệu theo đường dẫn tương đối `../du-lieu/`, nên hãy giữ nguyên cấu trúc thư mục và chạy script từ trong thư mục `scripts/`.
- Ghi chú trong file có thể nhắc "Bài N"; số N là số thứ tự thư mục trong bảng dưới.

## Phần mềm

- PSPP (miễn phí) hoặc IBM SPSS Statistics cho các file `.sav`, `.sps`.
- JASP (miễn phí) cho các file `.jasp`; AMOS mở file `.sav`.
- R với các gói lavaan, semTools, cSEM để chạy script `.R` (đối chiếu kết quả).
- SmartPLS 4 nhập file `du_lieu_san_x_smartpls.csv` (thư mục 33). Project mẫu Corporate reputation dùng ở bài formative thuộc SmartPLS, không kèm trong kho; cài từ trong phần mềm.

## Thư mục theo bài

| Thư mục | Bài viết |
|---|---|
| `00-du-lieu-chung` | Bộ dữ liệu gốc, dữ liệu đã làm sạch, script tạo dữ liệu |
| `04-co-mau-bao-nhieu-la-du` | [Cỡ mẫu bao nhiêu là đủ cho nghiên cứu định lượng](https://phuongacademy.com/blog/co-mau-bao-nhieu-la-du/) |
| `06-khai-bao-ma-hoa-bien-spss` | [Khai báo và mã hóa biến trong SPSS/PSPP](https://phuongacademy.com/blog/khai-bao-ma-hoa-bien-spss/) |
| `07-nhap-du-lieu-google-forms-vao-spss` | [Đưa dữ liệu khảo sát Google Forms vào SPSS/PSPP](https://phuongacademy.com/blog/nhap-du-lieu-google-forms-vao-spss/) |
| `08-lam-sach-du-lieu-spss` | [Làm sạch dữ liệu khảo sát trong SPSS/PSPP](https://phuongacademy.com/blog/lam-sach-du-lieu-spss/) |
| `09-thong-ke-mo-ta-spss` | [Thống kê mô tả và cách đọc kết quả trong SPSS/PSPP](https://phuongacademy.com/blog/thong-ke-mo-ta-spss/) |
| `10-tinh-bien-dai-dien-spss` | [Mã hóa lại và tính biến đại diện trong SPSS/PSPP](https://phuongacademy.com/blog/tinh-bien-dai-dien-spss/) |
| `11-cronbach-alpha-spss` | [Kiểm định Cronbach's Alpha trong SPSS/PSPP](https://phuongacademy.com/blog/cronbach-alpha-spss/) |
| `12-phan-tich-nhan-to-kham-pha-efa` | [Phân tích nhân tố khám phá EFA trong SPSS/PSPP](https://phuongacademy.com/blog/phan-tich-nhan-to-kham-pha-efa/) |
| `13-tuong-quan-pearson-spss` | [Phân tích tương quan Pearson trong SPSS/PSPP](https://phuongacademy.com/blog/tuong-quan-pearson-spss/) |
| `14-hoi-quy-tuyen-tinh-boi-spss` | [Hồi quy tuyến tính bội trong SPSS/PSPP](https://phuongacademy.com/blog/hoi-quy-tuyen-tinh-boi-spss/) |
| `15-kiem-dinh-gia-dinh-hoi-quy` | [Kiểm định giả định hồi quy tuyến tính trong SPSS/PSPP](https://phuongacademy.com/blog/kiem-dinh-gia-dinh-hoi-quy/) |
| `16-bien-gia-bien-dieu-tiet-hoi-quy` | [Biến giả và biến điều tiết trong hồi quy SPSS/PSPP](https://phuongacademy.com/blog/bien-gia-bien-dieu-tiet-hoi-quy/) |
| `17-kiem-dinh-t-test-spss` | [Kiểm định T-test trong SPSS/PSPP](https://phuongacademy.com/blog/kiem-dinh-t-test-spss/) |
| `18-anova-mot-chieu-post-hoc` | [ANOVA một chiều và kiểm định sau trong SPSS/PSPP](https://phuongacademy.com/blog/anova-mot-chieu-post-hoc/) |
| `19-amos-la-gi-cb-sem` | [AMOS và mô hình cấu trúc tuyến tính CB-SEM](https://phuongacademy.com/blog/amos-la-gi-cb-sem/) |
| `20-ve-mo-hinh-dau-tien-jasp` | [Vẽ mô hình SEM đầu tiên với JASP và AMOS](https://phuongacademy.com/blog/ve-mo-hinh-dau-tien-jasp/) |
| `21-chuan-bi-du-lieu-cfa-sem` | [Chuẩn bị dữ liệu khảo sát cho CFA và SEM](https://phuongacademy.com/blog/chuan-bi-du-lieu-cfa-sem/) |
| `22-phan-tich-cfa-jasp-amos` | [Phân tích nhân tố khẳng định CFA với JASP và AMOS](https://phuongacademy.com/blog/phan-tich-cfa-jasp-amos/) |
| `23-chi-so-do-phu-hop-mo-hinh-sem` | [Chỉ số độ phù hợp của mô hình CFA và SEM](https://phuongacademy.com/blog/chi-so-do-phu-hop-mo-hinh-sem/) |
| `24-cr-ave-do-tin-cay-tong-hop` | [Độ tin cậy tổng hợp CR và phương sai trích AVE](https://phuongacademy.com/blog/cr-ave-do-tin-cay-tong-hop/) |
| `25-gia-tri-hoi-tu-gia-tri-phan-biet` | [Giá trị hội tụ và giá trị phân biệt trong CFA](https://phuongacademy.com/blog/gia-tri-hoi-tu-gia-tri-phan-biet/) |
| `26-mo-hinh-cau-truc-sem` | [Mô hình cấu trúc SEM với JASP và AMOS](https://phuongacademy.com/blog/mo-hinh-cau-truc-sem/) |
| `27-kiem-dinh-gia-thuyet-sem` | [Kiểm định giả thuyết trong mô hình SEM](https://phuongacademy.com/blog/kiem-dinh-gia-thuyet-sem/) |
| `28-bien-trung-gian-sem-bootstrap` | [Phân tích biến trung gian trong SEM bằng bootstrap](https://phuongacademy.com/blog/bien-trung-gian-sem-bootstrap/) |
| `29-phan-tich-da-nhom-sem` | [Phân tích đa nhóm và biến điều tiết trong SEM](https://phuongacademy.com/blog/phan-tich-da-nhom-sem/) |
| `30-phuong-sai-phuong-phap-chung-cmb` | [Phương sai phương pháp chung trong dữ liệu khảo sát](https://phuongacademy.com/blog/phuong-sai-phuong-phap-chung-cmb/) |
| `31-smartpls-la-gi-pls-sem` | [SmartPLS và PLS-SEM khác gì CB-SEM](https://phuongacademy.com/blog/smartpls-la-gi-pls-sem/) |
| `33-nhap-du-lieu-ve-mo-hinh-smartpls` | [Nhập dữ liệu và vẽ mô hình PLS-SEM trong SmartPLS](https://phuongacademy.com/blog/nhap-du-lieu-ve-mo-hinh-smartpls/) |
| `34-danh-gia-mo-hinh-do-luong-reflective` | [Đánh giá mô hình đo lường reflective trong SmartPLS](https://phuongacademy.com/blog/danh-gia-mo-hinh-do-luong-reflective/) |
| `35-htmt-gia-tri-phan-biet` | [HTMT và giá trị phân biệt trong SmartPLS](https://phuongacademy.com/blog/htmt-gia-tri-phan-biet/) |
| `36-danh-gia-mo-hinh-do-luong-formative` | [Đánh giá mô hình đo lường formative trong SmartPLS](https://phuongacademy.com/blog/danh-gia-mo-hinh-do-luong-formative/) |
| `37-danh-gia-mo-hinh-cau-truc-pls-sem` | [Đánh giá mô hình cấu trúc PLS-SEM trong SmartPLS](https://phuongacademy.com/blog/danh-gia-mo-hinh-cau-truc-pls-sem/) |
| `38-plspredict-cvpat-nang-luc-du-doan` | [PLSpredict và năng lực dự đoán trong SmartPLS](https://phuongacademy.com/blog/plspredict-cvpat-nang-luc-du-doan/) |
| `39-bootstrapping-smartpls` | [Bootstrapping kiểm định giả thuyết trong SmartPLS 4](https://phuongacademy.com/blog/bootstrapping-smartpls/) |
| `40-bien-trung-gian-smartpls` | [Phân tích biến trung gian trong SmartPLS](https://phuongacademy.com/blog/bien-trung-gian-smartpls/) |
| `41-bien-dieu-tiet-smartpls` | [Phân tích biến điều tiết trong SmartPLS](https://phuongacademy.com/blog/bien-dieu-tiet-smartpls/) |
| `42-ipma-mo-hinh-bac-cao-smartpls` | [IPMA và mô hình bậc cao trong SmartPLS](https://phuongacademy.com/blog/ipma-mo-hinh-bac-cao-smartpls/) |

Các bài 1, 2, 3, 5 và 32 không dùng file dữ liệu riêng.
