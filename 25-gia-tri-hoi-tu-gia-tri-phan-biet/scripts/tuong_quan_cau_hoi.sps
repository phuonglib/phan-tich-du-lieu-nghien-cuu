* Bài 25. Ma trận tương quan 20 câu hỏi để tính HTMT trong Excel (htmt_mau.xlsx).
* Cách chạy: pspp --syntax-encoding=UTF-8 tuong_quan_cau_hoi.sps
GET FILE='../du-lieu/du_lieu_amos.sav'.
CORRELATIONS /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4
    NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=PAIRWISE /PRINT=NOSIG.
