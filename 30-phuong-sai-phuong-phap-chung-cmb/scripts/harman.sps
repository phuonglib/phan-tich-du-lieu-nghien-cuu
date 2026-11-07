* =====================================================================.
* Bài 30. Kiểm định một nhân tố của Harman trên 20 câu hỏi của mô hình.
* Phân tích nhân tố KHÔNG XOAY, xem phần trăm phương sai của nhân tố đầu tiên.
* Chạy hai cách: (1) để phần mềm tự chọn số nhân tố có giá trị riêng > 1,
* (2) ép trích đúng 1 nhân tố (cách hay gặp trong luận văn).
* Cách chạy: pspp --syntax-encoding=UTF-8 chuan_bi_harman.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_amos.sav'.

* (1) Thành phần chính, không xoay, giá trị riêng > 1.
FACTOR /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=LISTWISE
  /EXTRACTION=PC
  /CRITERIA=MINEIGEN(1)
  /ROTATION=NOROTATE
  /PRINT=INITIAL EXTRACTION.

* (2) Trục chính (PAF), ép 1 nhân tố, không xoay.
FACTOR /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=LISTWISE
  /EXTRACTION=PAF
  /CRITERIA=FACTORS(1) ITERATE(100)
  /ROTATION=NOROTATE
  /PRINT=INITIAL EXTRACTION.
