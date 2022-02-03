      SUBROUTINE LOGS(DBH,HT,IBCD,BDMIN,ISP,STMP,BV)
      IMPLICIT NONE
C----------
C EM $Id: logs.f 2447 2018-07-10 16:31:11Z gedixon $
C----------
C  REGION 5 BOARD FOOT VOLUME MODELS.
C  BY K.STUMPF, ADAPTED BY B.KRUMLAND, P.J.DAUGHERTY
C  NOT FOR USE IN REGION 1, SO JUST SET BV TO ZERO AND RETURN
C----------
C
      REAL DBH,HT,BDMIN,STMP,BV
      INTEGER IBCD,ISP
      REAL RDANUW
      INTEGER IDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = BDMIN
      RDANUW = DBH
      RDANUW = HT
      IDANUW = IBCD
      IDANUW = ISP
      RDANUW = STMP
C
C
      BV=0.
      RETURN
      END
