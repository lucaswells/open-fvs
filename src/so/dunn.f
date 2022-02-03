      SUBROUTINE DUNN (SS)
      IMPLICIT NONE
C----------
C SO $Id: dunn.f 2455 2018-07-19 19:58:41Z gedixon $
C----------
C THIS SUBROUTINE PROCESSES THE DUNNING CODE INFORMATION THAT WAS
C ENTERED BY KEYWORD.
C
C WHEN A DUNNING CODE IS ENTERED (IE ANY OF THE SITEAR VALUES BETWEEN
C 0 AND 7)  THEN SITE VALUES FOR ALL SPECIES ARE AUTOMATICALLY SET.  IF
C ANY SITEAR VALUES ARE BETWEEN 8 AND 10 THIS IS AN ERROR AND THE
C DEFAULT VALUE SET IN GRINIT IS MAINTAINED. THIS ROUTINE IS CALLED FROM
C INITRE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C
      REAL ADJFAC(MAXSP),DUNN50(8),DUNN99(8),SS,DU50,DU99
      INTEGER I99(MAXSP),IST,ISPC
      DATA ADJFAC/
     & 0.90, 0.90, 1.00, 1.00, 0.90, 0.76, 0.82, 1.00, 1.00, 1.00,
     & 0.57, 1.00, 1.00, 1.00, 1.00, 0.90, 1.00, 1.00, 0.90, 0.76,
     & 1.00, 0.57, 0.57, 0.57, 0.57, 1.00, 0.76, 0.57, 1.00, 1.00,
     & 1.00, 1.00, 0.57/                                          
      DATA I99/
     &    0,    1,    0,    0,    1,    0,    0,    1,    0,    1,
     &    1,    0,    1,    0,    1,    1,    0,    1,    0,    1,
     &    1,    1,    1,    2,    1,    1,    0,    1,    1,    1,
     &    1,    0,    1/                                          
      DATA DUNN50/106.,90.,75.,56.,49.,39.,31.,23./
      DATA DUNN99/140.,121.,102.,81.,67.,54.,44.,36./
C
C
      IST=INT(SS+1.0)
      DU50=DUNN50(IST)
      DU99=DUNN99(IST)
C----------
C  SET SITE INDEX VALUES BASED ON DUNNING VALUES ENTERED.
C----------
      DO 20 ISPC=1,MAXSP
      SITEAR(ISPC) = DU50 * ADJFAC(ISPC)
      IF(I99(ISPC).EQ. 1)SITEAR(ISPC) = DU99 * ADJFAC(ISPC)
   20 CONTINUE
C----------
C  ADJUST ASPEN FROM THE CURRENT SETTING AT 50 YEAR BASE AGE TO AN 
C  80 YEAR BASE AGE BY INTERPOLATION.
C----------
      SITEAR(24) = SITEAR(24)+(DU99*ADJFAC(24)-SITEAR(24))*(3./5.)
C----------
C  ADJUST MOUNTAIN HEMLOCK TO METRIC
C----------
      SITEAR(5)=SITEAR(5)/3.28083333
C
      RETURN
      END
