* =====================================================================.
* Bài 18. Phân tích phương sai ANOVA một chiều và kiểm định sâu (post-hoc).
* Dữ liệu: du_lieu_phan_tich.sav. Cách chạy: pspp --syntax-encoding=UTF-8 anova.sps
* PSPP 2.0.0 không có Welch ANOVA và không in eta bình phương;
* Phần 3 tính cả hai bằng AGGREGATE.
* =====================================================================.
GET FILE='../du-lieu/du_lieu_phan_tich.sav'.
DATASET NAME CHINH.

* ---------------------------------------------------------------------.
* Phần 1. Kiểm tra giả định: biểu đồ hộp YD theo nhóm thu nhập.
* ---------------------------------------------------------------------.
EXAMINE VARIABLES=YD BY THUNHAP /PLOT=BOXPLOT /STATISTICS=NONE.

* ---------------------------------------------------------------------.
* Phần 2. ANOVA một chiều: YD theo thu nhập, kèm Levene, post-hoc
* và tương phản xu hướng tuyến tính (-3 -1 1 3).
* ---------------------------------------------------------------------.
ONEWAY /VARIABLES=YD BY THUNHAP
  /STATISTICS=DESCRIPTIVES HOMOGENEITY
  /POSTHOC=TUKEY BONFERRONI GH
  /CONTRAST=-3 -1 1 3.

* ---------------------------------------------------------------------.
* Phần 3. Welch ANOVA, eta bình phương và omega bình phương.
* ---------------------------------------------------------------------.
DATASET COPY TINH_W.
DATASET ACTIVATE TINH_W.
SELECT IF NOT MISSING(YD) AND NOT MISSING(THUNHAP).
SORT CASES BY THUNHAP.
* Gộp dữ liệu thành một dòng cho mỗi nhóm.
AGGREGATE /OUTFILE=* /BREAK=THUNHAP /N_J=N(YD) /TB_J=MEAN(YD) /SD_J=SD(YD).
COMPUTE W_J = N_J / SD_J ** 2.
COMPUTE WTB_J = W_J * TB_J.
COMPUTE NTB_J = N_J * TB_J.
COMPUTE SSW_J = (N_J - 1) * SD_J ** 2.
COMPUTE MOT = 1.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /BREAK=MOT
  /W=SUM(W_J) /SUM_WTB=SUM(WTB_J) /N=SUM(N_J) /SUM_NTB=SUM(NTB_J) /SSW=SUM(SSW_J) /K=N(N_J).
COMPUTE TB_W = SUM_WTB / W.
COMPUTE TB_CHUNG = SUM_NTB / N.
COMPUTE A_J = W_J * (TB_J - TB_W) ** 2.
COMPUTE H_J = (1 - W_J / W) ** 2 / (N_J - 1).
COMPUTE SSB_J = N_J * (TB_J - TB_CHUNG) ** 2.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /BREAK=MOT
  /SUM_A=SUM(A_J) /SUM_H=SUM(H_J) /SSB=SUM(SSB_J).
COMPUTE F_WELCH = (SUM_A / (K - 1)) / (1 + 2 * (K - 2) / (K ** 2 - 1) * SUM_H).
COMPUTE DF1 = K - 1.
COMPUTE DF2 = (K ** 2 - 1) / (3 * SUM_H).
COMPUTE P_WELCH = 1 - CDF.F(F_WELCH, DF1, DF2).
COMPUTE MSW = SSW / (N - K).
COMPUTE ETA2 = SSB / (SSB + SSW).
COMPUTE OMEGA2 = (SSB - (K - 1) * MSW) / (SSB + SSW + MSW).
FORMATS F_WELCH DF2 (F8.2) ETA2 OMEGA2 (F8.3) P_WELCH (F8.4) DF1 (F3.0).
VARIABLE LABELS F_WELCH 'Welch F' DF1 'df1' DF2 'df2' P_WELCH 'Sig.' ETA2 'Eta bình phương' OMEGA2 'Omega bình phương'.
TEMPORARY.
SELECT IF $CASENUM = 1.
LIST /VARIABLES=F_WELCH DF1 DF2 P_WELCH ETA2 OMEGA2.
DATASET ACTIVATE CHINH.
DATASET CLOSE TINH_W.

* ---------------------------------------------------------------------.
* Phần 4. Kiểm định phi tham số thay thế: Kruskal-Wallis.
* ---------------------------------------------------------------------.
NPAR TESTS /K-W=YD BY THUNHAP(1, 4).

* ---------------------------------------------------------------------.
* Phần 5. Ví dụ không có ý nghĩa: YD theo nghề nghiệp (đối chiếu Bài 16).
* ---------------------------------------------------------------------.
ONEWAY /VARIABLES=YD BY NGHE /STATISTICS=DESCRIPTIVES HOMOGENEITY.
