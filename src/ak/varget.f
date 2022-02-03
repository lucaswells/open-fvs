      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      IMPLICIT NONE
C----------
C AK $Id: varget.f 3617 2021-05-28 17:02:44Z lancedavid $
C----------
C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ESPARM.F77'

      INCLUDE 'ESCOMN.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).  
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=2,MXR=5)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS(*)
      REAL REALS(*)
      LOGICAL LDANUW
      REAL RDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = LOGICS(1)
      RDANUW = REALS(1)
      RDANUW = WK3(1)
C----------
C
C     GET THE INTEGER SCALARS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      IIFORTP  = INTS ( 1)
      IFT0     = INTS ( 2)
C
C     GET THE INTEGER ARRAYS.
C
C     GET THE LOGICAL SCALARS.
C
C**   CALL LFREAD (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     GET THE REAL SCALARS.
C
C**   CALL BFREAD (WK3, IPNT, ILIMIT, REALS, MXR, 2)
C**           = REALS( 1)
C
C     READ THE REAL ARRAYS
C
      CALL BFREAD (WK3, IPNT, ILIMIT, OCURFT,    MAXSP*14, 2) ! from ESCOMN.F77
      CALL BFREAD (WK3, IPNT, ILIMIT, HTT11,     MAXSP,    2) ! from ESCOMN.F77
      CALL BFREAD (WK3, IPNT, ILIMIT, HTT12,     MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, HTT13,     MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, XMAXPT,    MAXPLT,   2)

      RETURN
      END

      SUBROUTINE VARCHGET (CBUFF, IPNT, LNCBUF)
      IMPLICIT NONE
C----------
C     Get variant-specific character data
C----------

      INCLUDE 'PRGPRM.F77'

      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      INTEGER IDANUW
      CHARACTER CDANUW
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = IPNT
      CDANUW = CBUFF(1)

      RETURN
      END
