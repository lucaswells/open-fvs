      SUBROUTINE EVIF (KEYWRD,ARRAY,LNOTBK,IRECNT,IREAD,RECORD,
     >                 KARD,JOSTND,LDEBUG,LKECHO)
      IMPLICIT NONE
C----------
C BASE $Id: evif.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     COMPILES AND STORES THE IF EXPRESSION.
C
C     EVENT MONITOR ROUTINE - NL CROOKSTON - AUG 1982 - MOSCOW, ID.
C
C     ARGUMENTS:
C     KEYWRD= THE 8-CHAR KEYWORD.
C     ARRAY = THE ARRAY OF VALUES ON THE KEYWORD RECORD.
C     LNOTBK= TRUE IF CORRESPONDING VALUE ON THE KEYWORD RECORD IS
C             ENTERED, FALSE IF LEFT BLANK.
C     IRECNT= THE KEYWORD FILE RECORD COUNT.
C     RECORD= CHAR RECORD STRING.
C     KARD  = C*10 BY 7 KEYWORD FIELDS.
C     IREAD = THE KEYWORD FILE DATA SET REFERENCE NUMBER.
C     JOSTND= PRINT DATA SET REFERENCE NUMBER.
C     LDEBUG= TRUE IF DEBUGGING.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      INTEGER JOSTND,IREAD,IRECNT,IWAIT,IRC,IRTNCD
      REAL ARRAY(7)
      LOGICAL LNOTBK(7),LDEBUG,LKECHO
      CHARACTER*8 KEYWRD
      CHARACTER RECORD*(*),KARD(7)*10
C
C     IF THIS IF FOLLOWS ANOTHER IF WITHOUT AN INTERMEDIATE ENDIF,
C     THEN: CALL EVEND TO CLOSE THE PREVIOUS EVENT.
C
      IF (LOPEVN) CALL EVEND (LDEBUG,JOSTND,IRECNT,KEYWRD,ARRAY,
     >                        LNOTBK,KARD,-1,LKECHO)
C
C     ENTRY EVEND IN SUBROUTINE EVTACT INCREMENTS IEVT.  CHECK ON
C     THE MAGNITUDE OF IEVT TO INSURE IT IS NOT OVER MAXEVT.  IF
C     IT IS, ISSUE AN ERROR AND ABEND THE RUN.
C
      IF (IEVT.GT.MAXEVT) CALL ERRGRO(.FALSE.,10)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     WRITE THE KEYWORD AND FIRST PARM.
C
      IWAIT=1
      IF (LNOTBK(1)) IWAIT=IFIX(ARRAY(1))
      IF(LKECHO)WRITE(JOSTND,5) KEYWRD,IWAIT
    5 FORMAT (/A8,'   MINIMUM DELAY TIME BETWEEN RESPONSES',
     >        ' TO THE EVENT = ',I5)
C
C     SET UP THE POINTERS IN THE EVENT ARRAY.
C
      IEVNTS(IEVT,1)=ICOD
      IEVNTS(IEVT,2)=-1
      IEVNTS(IEVT,3)=IWAIT
      LEVUSE=.TRUE.
C
C     READ AND COMPILE THE IF-EXPRESSION.
C
      CALL EVCOMP (IRC,IREAD,JOSTND,RECORD,LDEBUG,IRECNT,LKECHO)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     SET LOPEVN=TRUE TO INDECATE THAT THE EVENT HAS BEEN ENTERED.
C
      LOPEVN=.TRUE.
      RETURN
      END
