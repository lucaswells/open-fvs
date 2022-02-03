      SUBROUTINE DUNN (SS)
C----------
C CANADA-ON $Id: dunn.f 2461 2018-07-24 18:00:57Z gedixon $
C----------
C
C     THIS SUBROUTINE ORIGINALLY IS FOR PROCESSES THE DUNNING 
C     SITE CODE INFORMATION ENTERED ON THE SITECODE KEYWORD. 
C     THE ONTARIO VARIANT DOES NOT HAVE THAT INFORMATION, BUT
C     IT MIGHT HAVE ENTERED A NEGATIVE VALUE, MEANING TOP HEIGHT.
C     TO AVOID CHANGING THE BASE/INITRE ROUTINE, WE WILL PUT
C     THE NEGATIVE VALUE INTO SITEAR WHERE IT WILL BE PICKED
C     UP IN THE SITSET ROUTINE.
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'PLOT.F77'
C
C
      SITEAR(ISISP) = SS

      RETURN
      END
