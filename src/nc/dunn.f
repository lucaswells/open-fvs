      SUBROUTINE DUNN (SS)
      IMPLICIT NONE
C----------
C NC $Id: dunn.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C THIS SUBROUTINE PROCESSES THE DUNNING CODE INFORMATION THAT WAS
C ENTERED BY KEYWORD.
C
C THIS ROUTINE IS ENTERED WITH A VLAUE BETWEEN 0 AND 7. THIS VALUE
C IS THE TRANSLATED INTO THE SITE INDEX FOR LARGE TREES. THE SITE
C INDEX FOR SMALL TREES IS ALSO SET AS THE VALUE OF DU50.
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
C----------
      REAL ADJFAC(12),DUNN50(8),XST2(8),SS,DU50
      INTEGER IST,ISPC,I
      DATA ADJFAC/ 0.90, 0.90, 1.00, 1.00, 0.57, 0.76,
     &             0.57, 0.57, 1.00, 1.00, 0.57, 1.00/
      DATA DUNN50/106.,90.,75.,56.,49.,39.,31.,23./
C
      IST=INT(SS+1.0)
      DU50=DUNN50(IST)
C----------
C   SET SITE INDEX VALUES BASED ON DUNNING VALUES ENTERED.
C----------
      DO 20 ISPC=1,MAXSP
      SITEAR(ISPC) = DU50 * ADJFAC(ISPC)
   20 CONTINUE
      RETURN
C----------
C   NC FIRE MODEL NEEDS SITE INDICES FOR DUNNING CODES.
C----------
      ENTRY GETDUNN(XST2)
      DO I=1,8
      XST2(I) = DUNN50(I)
      ENDDO
      RETURN
      END
