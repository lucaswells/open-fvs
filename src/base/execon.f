      SUBROUTINE EXECON
      IMPLICIT NONE
C----------
C BASE $Id: execon.f 2438 2018-07-05 16:54:21Z gedixon $
C-------
C
C     EXTRA EXTERNAL REFERENCES FOR THE ECON EXTENSION.
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ECNCOM.F77'
C
C
      INTEGER I1,I2,I3,ICYC,IT,IS,II,IRECNT,KEY
      REAL PREM2,GROSPC,ARRAY22,D
      LOGICAL LKECHO,LPRTND,LTMP
      CHARACTER*4 CARRAY(*),CH1_4,CARRAY2(*)
      CHARACTER*8 KEYWRD
      CHARACTER NPLT*26,ITITLE*72
      REAL RDANUW
      INTEGER IDANUW
      CHARACTER*1 CDANUW
      LOGICAL LDANUW
C
      REAL ARRAY(*),ARRAY1(*)
      INTEGER IY(*),IARRAY(*)
C----------
C ENTRY ECSETP CALLED FROM CUTS
C----------
      ENTRY ECSETP(IY)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = IY(1)
      RETURN
C----------
C ENTRY ECSETP CALLED FROM GRINCR
C----------
      ENTRY ECSTATUS(I3, I2, IARRAY, I1)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = I3
        IDANUW = I2
        IDANUW = IARRAY(1)
        IDANUW = I1
      RETURN
C----------
C ENTRY ECHARV CALLED FROM CUTS
C----------
      ENTRY ECHARV (ARRAY,D,ARRAY22,GROSPC,PREM2,IS,
     &  IT,ICYC,IY)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        RDANUW = ARRAY(1)
        RDANUW = D
        RDANUW = ARRAY22
        RDANUW = GROSPC
        RDANUW = PREM2
        IDANUW = IS
        IDANUW = IT
        IDANUW = ICYC
        IDANUW = IY(1)
      RETURN
C----------
C ENTRY ECCALC CALLED FROM GRADD
C----------
      ENTRY ECCALC(IARRAY,II,CARRAY, CH1_4, NPLT, ITITLE)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = IARRAY(1)
        IDANUW = II
        CDANUW = CARRAY(1)(1:1)
        CDANUW = CH1_4(1:1)
        CDANUW = NPLT(1:1)
        CDANUW = ITITLE(1:1)
      RETURN
C----------
C ENTRY ECLOAD CALLED FROM CUTS
C----------
      ENTRY GETISPRETENDACTIVE(LPRTND)
        LPRTND=.FALSE.
      RETURN
C----------
C ENTRY ECIN CALLED FROM INITRE
C----------
      ENTRY ECIN(IRECNT,I1,I2,CARRAY2,I3,LKECHO,IARRAY)
        CALL ERRGRO (.TRUE.,11)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = IRECNT
        IDANUW = I1
        IDANUW = I2
        CDANUW = CARRAY2(1)(1:1)
        IDANUW = I3
        LDANUW = LKECHO
        IDANUW = IARRAY(1)
      RETURN
C----------
C ENTRY ECKEY CALLED FROM OPLIST
C----------
      ENTRY ECKEY (KEY,KEYWRD)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        CDANUW = KEYWRD(1:1)
        IDANUW = KEY
      RETURN
C----------
C ENTRY ECINIT CALLED FROM INITRE
C----------
      ENTRY ECINIT
        isEconToBe=.FALSE.
      RETURN
C----------
C ENTRY ECVOL CALLED FROM VOLS
C----------
      ENTRY ECVOL (I1,I2,ARRAY,ARRAY1,LTMP)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        IDANUW = I1
        IDANUW = I2
        RDANUW = ARRAY(1)
        RDANUW = ARRAY1(1)
        LDANUW = LTMP
      RETURN
C----------
C ENTRY ECNGET CALLED FROM GETSTD
C----------
      ENTRY ECNGET (ARRAY,I1,I2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        RDANUW = ARRAY(1)
        IDANUW = I1
        IDANUW = I2
      RETURN
C----------
C ENTRY ECNPUT CALLED FROM PUTSTD
C----------
      ENTRY ECNPUT (ARRAY,I1,I2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
        IF(.TRUE.)RETURN
        RDANUW = ARRAY(1)
        IDANUW = I1
        IDANUW = I2
      RETURN
C
      END
