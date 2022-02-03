      SUBROUTINE CVINIT
      IMPLICIT NONE
C----------
C COVR $Id: cvinit.f 2443 2018-07-09 15:07:14Z gedixon $
C----------
C  INITIALIZES COVER VARIABLES FOR THE CURRENT STAND.
C  CALLED FROM **INITRE**.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'CVCOM.F77'
C
C
COMMONS
C
      INTEGER I,J
      ICVBGN = 0
      JOSHRB = JOSTND
C
C     VARIABLES ADDED TO CONTROL PRINTING NOHEADING OUTPUT OF COVER.
C
      JCVNOH = 24
      LCVNOH = .FALSE.
C
      LBROW = .FALSE.
      LCOV = .FALSE.
      LCNOP = .FALSE.
      LCOVER = .TRUE.
      LSHOW = .FALSE.
      LSHRUB = .TRUE.
      LCVSUM = .TRUE.
      LCAL1 = .FALSE.
      LCAL2 = .FALSE.
      LCALIB = .FALSE.
      DO 10 I = 1,3
      AVGBHT(I) = -99999.0
      AVGBPC(I) = -99999.0
   10 CONTINUE
      DO 15 I = 1,31
      SHRBHT(I) = -99999.0
      SHRBPC(I) = -99999.0
      BHTCF(I) = 1.0
      BPCCF(I) = 1.0
   15 CONTINUE
      DO 20 J=1,MAXCY1
      LTHIND(J) = .FALSE.
   20 CONTINUE
      RETURN
      END
