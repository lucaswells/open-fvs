      SUBROUTINE ESPRIN (IACTK,IDSDAT,IRECNT,KEYWRD,ARRAY,
     &                   LNOTBK,JOSTND,KARD)
      IMPLICIT NONE
C----------
C ESTB $Id: esprin.f 2448 2018-07-10 17:04:02Z gedixon $
C----------
C     PART OF THE ESTABLISHMENT SUBSYSTEM.  CALLED BY ESIN TO
C     ENTER SITE PREP OPTIONS INTO THE ACTIVITY SCHEDULE.
C     IACTK =THE ACTIVITY CODE ASSOCIATED WITH THE SITE PREP.
C     IDSDAT=THE DATE OF DISTURBANCE.
C     IRECNT=THE KEYWORD RECORD COUNT.
C     KEYWRD=THE KEYWORD READ.
C     ARRAY =THE PARAMETER ARRAY ON THE KEYWORD RECORD.
C     LNOTBK=TRUE IF THE CORRESPONDING MEMBER OF ARRAY WAS ENTERED.
C     JOSTND=THE PRINTER DATA SET REFERENCE NUMBER.
C
      INTEGER JOSTND,IRECNT,IDSDAT,IACTK,IDT,KODE
      REAL ARRAY(7)
      LOGICAL LNOTBK(7)
      CHARACTER*8 KEYWRD
      CHARACTER*10 KARD(7)
      IF(LNOTBK(1)) GO TO 25
      IDT=IDSDAT
      IF(IDT.LT.0) GO TO 26
      GO TO 30
   25 CONTINUE
      IDT=IFIX(ARRAY(1))
      IF(IDSDAT.LE.0) GO TO 30
      IF(IDT.LE.IDSDAT+19) GO TO 30
   26 CONTINUE
      CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
      CALL ERRGRO (.TRUE.,4)
      RETURN
   30 CONTINUE
      IF(ARRAY(2).GE.0.0 .AND. ARRAY(2).LE.100.0) GO TO 40
      CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
      CALL ERRGRO (.TRUE.,4)
      RETURN
   40 CONTINUE
      CALL OPNEW(KODE,IDT,IACTK,1,ARRAY(2))
      IF(KODE.GT.0) RETURN
      WRITE(JOSTND,50) KEYWRD,IDT,ARRAY(2)
   50 FORMAT(/A8,'   DATE/CYCLE=',I5,'; % PLOTS=',F6.1)
      RETURN
      END
