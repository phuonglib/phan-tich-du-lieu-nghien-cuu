* =====================================================================.
* Bài 12. Phân tích nhân tố khám phá (EFA) cho 20 câu đo lường.
* Dữ liệu: du_lieu_phan_tich.sav (267 phiếu; NT4 đã mã hóa ngược thành NT4R ở Bài 10).
* Cách chạy: pspp --syntax-encoding=UTF-8 efa.sps
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.

* Lần chạy chính: trích nhân tố trục chính (PAF), xoay Promax, giữ nhân tố có eigenvalue > 1.
FACTOR
  /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4 NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=LISTWISE
  /PRINT=INITIAL KMO EXTRACTION ROTATION
  /PLOT=EIGEN
  /FORMAT=SORT BLANK(.30)
  /CRITERIA=MINEIGEN(1) ITERATE(100)
  /EXTRACTION=PAF
  /ROTATION=PROMAX(4).

* Lần chạy so sánh: ép 3 nhân tố theo gợi ý của phân tích song song dựa trên PCA.
FACTOR
  /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4 NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=LISTWISE
  /PRINT=ROTATION
  /FORMAT=SORT BLANK(.30)
  /CRITERIA=FACTORS(3) ITERATE(100)
  /EXTRACTION=PAF
  /ROTATION=PROMAX(4).

* Lần chạy so sánh: cách làm phổ biến PCA + Varimax.
FACTOR
  /VARIABLES=XN1 XN2 XN3 XN4 HI1 HI2 HI3 HI4 HL1 HL2 HL3 HL4 NT1 NT2 NT3 NT4R YD1 YD2 YD3 YD4
  /MISSING=LISTWISE
  /PRINT=EXTRACTION ROTATION
  /FORMAT=SORT BLANK(.30)
  /CRITERIA=MINEIGEN(1) ITERATE(100)
  /EXTRACTION=PC
  /ROTATION=VARIMAX.
