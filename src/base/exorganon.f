      SUBROUTINE EXORGANON
      IMPLICIT NONE
C----------
C BASE $Id: exorganon.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C  SATISFY EXTERNAL REFRENCES FOR THE ORGANON EXTENSION
C----------
      LOGICAL DEBUG,LKECHO
      INTEGER I,ITFN,JOSTND,IMODTY
      REAL    VAL
      INTEGER IDANUW
      LOGICAL LDANUW
C----------
C  ENTRY ORIN   CALLED FROM INITRE
C----------
      ENTRY ORIN(DEBUG,LKECHO)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        LDANUW = DEBUG
        LDANUW = LKECHO
      RETURN
C----------
C  ENTRY ORGTRIP   CALLED FROM TRIPLE
C----------
      ENTRY ORGTRIP(I,ITFN)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = I
        IDANUW = ITFN
      RETURN
C----------
C  ENTRY ORGTAB   CALLED FROM INITRE
C----------
      ENTRY ORGTAB(JOSTND,IMODTY)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = JOSTND
        IDANUW = IMODTY
      RETURN
C----------
C  ENTRY GETORGV   CALLED FROM EVTSTV
C----------
      ENTRY GETORGV(I,VAL)
        VAL=0.
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = I
      RETURN
C
      END