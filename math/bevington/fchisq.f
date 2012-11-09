C FUNCTION FCHISQ.F
C
C SOURCE
C   BEVINGTON, PAGE 194.
C
C PURPOSE
C   EVALUATE REDUCED CHI SQUARE FOR FIT OF DATA 
C     FCHISQ = SUM ((Y-YFIT)**2 / SIGMA**2) / NFREE
C
C USAGE 
C   RESULT = FCHISQ (Y, SIGMAY, NPTS, NFREE, MODE, YFIT)
C
C DESCRIPTION OF PARAMETERS
C   Y	   - ARRAY OF DATA POINTS
C   SIGMAY - ARRAY OF STANDARD DEVIATIONS FOR DATA POINTS
C   NPTS   - NUMBER OF DATA POINTS
C   NFREE  - NUMBER OF DEGREES OF FREEDOM
C   MODE   - DETERMINES METHOD OF WEIGHTING LEAST-SQUARES FIT
C	     +1 (INSTRUMENTAL) WEIGHT(I) = 1./SIGMAY(I)**2
C	      0 (NO WEIGHTING) WEIGHT(I) = 1.
C	     -1 (STATISTICAL)  WEIGHT(I) = 1./Y(I)
C   YFIT   - ARRAY OF CALCULATED VALUES OF Y
C
C SUBROUTINES AND FUNCTION SUBPROGRAMS REQUIRED 
C   NONE
C
	FUNCTION FCHISQ (Y,SIGMAY,NPTS,NFREE,MODE,YFIT) 
	DOUBLE PRECISION CHISQ,WEIGHT
	DIMENSION Y(1),SIGMAY(1),YFIT(1)
11	CHISQ=0.
12	IF (NFREE) 13,13,20
13	FCHISQ=0.
	GOTO 40 
C
C ACCUMULATE CHI SQUARE 
C
20	DO 30 I=1,NPTS
21	IF (MODE) 22,27,29
22	IF (Y(I)) 25,27,23
23	WEIGHT=1./Y(I)
	GOTO 30 
25	WEIGHT=1./(-Y(I))
	GOTO 30 
27	WEIGHT=1.
	GOTO 30 
29	WEIGHT=1./SIGMAY(I)**2
30	CHISQ=CHISQ+WEIGHT*(Y(I)-YFIT(I))**2
C
C	DIVIDE BY NUMBER OF DEGREES OF FREEDOM
C
31	FREE=NFREE
32	FCHISQ=CHISQ/FREE
40	RETURN
	END