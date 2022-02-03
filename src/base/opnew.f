      SUBROUTINE OPNEW (KODE,IDT,IACTK,NPRMS,PRMS)
      IMPLICIT NONE
C----------
C BASE $Id: opnew.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JAN 1981 - MOSCOW
C     MODIFIED AUG 1982 TO STORE ACTIVITIES FOR FUTURE SCHEDULING.
C
C     OPNEW IS USED TO ADD USER-SPCEIFED OPTIONS TO THE
C     ACTIVITY LIST.  IT IS DESIGNED TO BE CALLED DURING
C     THE INITIAL PROCESSING (FROM INITRE, OR A SIMILAR
C     ROUTINE) OF THE OPTIONS.  THE ARGUMENTS:
C
C     KODE = THE RETURN CODE WHERE:
C            0   ALL WENT OK,
C            1   OPTION COULD NOT BE ADDED BECAUSE OPTION ARRAYS
C                ARE FULL.  A WARNING MESSAGE IS ISSUED VIA ERRGRO.
C     IDT  = THE DATE, CYCLE, OR A ZERO (ALL CYCLES) CODE TO
C            INDECATE WHEN THE ACTIVITY IS TO BE IMPLIMENTED.
C     IACTK= THE ACTIVITY CODE.
C     NPRMS= THE NUMBER OF PARAMETERS ASSOCIATED WITH THE ACTIVITY.
C     PRMS = THE PARAMETER LIST.
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
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
      INTEGER NPRMS,IACTK,IDT,KODE,IPEND,I,J
      REAL PRMS(*)
      LOGICAL LMODE,LDEB
C
C     SEE IF WE NEED WRITE DEBUG.
C
      CALL DBCHK (LDEB,'OPNEW',5,ICYC)
C
C     MAKE SURE THERE IS ROOM IN THE ACTIVITY STORAGE AREAS
C     TO STORE THE ACTIVITY AND ITS PARAMETERS.
C
      IPEND=IMPL+NPRMS-1
      IF (IMGL .LE. IEPT+1 .AND. IPEND .LE. ITOPRM) GOTO 10
      KODE=1
      I=0
      CALL ERRGRO (.TRUE.,10)
      GOTO 50
   10 CONTINUE
      KODE=0
C
C     STORE THE ACTIVITY AND THE PARAMETERS; INSURE THAT THE
C     ACTIVITY IS LISTED AS 'NOT ACCOMPLISHED'.
C     IF THE ACTIVITY IS TO BE STORED UNTIL AN EVENT OCCURS, THEN:
C     STORE THE POINTERS IN THE BOTTOM OF IACT.
C
      I=IMGL
      IF (LOPEVN) I=IEPT
      IACT(I,1)=IACTK
      IACT(I,4)=0
      IACT(I,5)=0
C
C     IF THERE ARE NO PARAMETERS;
C     THEN: SET PARAMETER POINTERS TO ZERO.
C
      IF (NPRMS .GT. 0) GOTO 15
      IACT(I,2)=0
      IACT(I,3)=0
      IDATE(I)=IDT
      GOTO 30
   15 CONTINUE
C
C     ELSE:  STORE THE PARAMETERS, POINTERS, AND DATE.
C
      IACT(I,2)=IMPL
      IACT(I,3)=IPEND
      IDATE(I)=IDT
      DO 20 J=IMPL,IPEND
      PARMS(J)=PRMS(J-IMPL+1)
   20 CONTINUE
      IMPL=IPEND+1
   30 CONTINUE
C
C     IF THE ACTIVITY IS BEING STORED FOR SCHEDULING AFTER AN EVENT,
C     THEN: UPDATE THE VALUE OF IEPT AND RETURN.
C
      IF (.NOT.LOPEVN) GOTO 40
      IEPT=IEPT-1
      GOTO 50
   40 CONTINUE
C
C     ELSE: STORE THE POINTER IN IOPSRT AND UPDATE IMGL.
C
      IOPSRT(IMGL)=IMGL
      IMGL=IMGL+1
C
C     BRANCH HERE TO EXIT: WRITE DEBUG IF REQUESTED.
C
   50 CONTINUE
      IF (LDEB) WRITE (JOSTND,60) IACTK,NPRMS,LOPEVN,IDT,IMPL,IMGL,
     >   I,IPEND,KODE
   60 FORMAT (' IN OPNEW: IACTK=',I4,' NPRMS=',I3,' LOPEVN=',L2,
     >        ' IDT=',I4,' IMPL=',I5,' IMGL=',I5,' I=',I5,
     >        ' IPEND=',I5,' KODE=',I2)
      RETURN
C
      ENTRY OPMODE (LMODE)
C
C     RETURNS THE MODE THAT OPTIONS ARE BEING STORED.
C
C     LMODE = TRUE IF OPTIONS FOLLOW AN EVENT AND FALSE
C             IF OPTIONS ARE BEING PROCESSED NORMALLY.
C
      LMODE=LOPEVN
      RETURN
      END
