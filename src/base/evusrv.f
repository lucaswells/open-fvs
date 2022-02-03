      SUBROUTINE EVUSRV (RECORD,KEYWRD,ARRAY,LNOTBK,IREAD,JOSTND,
     >                   LDEBUG,IRECNT)
      IMPLICIT NONE
C----------
C BASE $Id: evusrv.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     CALLED FROM INITRE.  READS, COMPILES, AND STORES USER
C     DEFINED VARIABLES.  CALLS ALGCMP TO COMPILE THEM.
C
C     EVENT MONITOR ROUTINE - N.L. CROOKSTON  - APRIL 1987
C     FORESTRY SCIENCES LABORATORY - MOSCOW, ID 83843
C
C     RECORD= CHARACTER STRING.
C     ARRAY = ARRAY OF PARAMETERS
C     LNOTBK= TRUE IF CORRESPONDING PARM FIELD IS NOT BLANK.
C     IREAD = READER DATA SET REFERENCE NUMBER.
C     JOSTND= OUTPUT DATA SET REFERENCE NUMBER.
C     LDEBUG= DEBUG OUTPUT IS REQUESTED.
C     IRECNT= RECORD COUNTER.
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
      INTEGER IRECNT,JOSTND,IREAD,IDT,IRC,LCLFT,LENCEX,IRCKEY,IKEY
      INTEGER IRTNCD
      REAL ARRAY(7)
      LOGICAL LDEBUG,LNOTBK(7)
      CHARACTER CLEFT*20,RECORD*(*),KEYWRD*8
C
C     SET UP THE DEFAULT DATE FOR SCHEDULING THE COMPUTATIONS AND
C     WRITE THE MESSAGE:
C
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
      WRITE (JOSTND,4031) KEYWRD,IDT
 4031 FORMAT (/A8,'   DATE/CYCLE=',I5,'; DEFINE THE FOLLOWING:'/)
C
C     READ THE EXPRESSION AND PLACE IT INTO THE CEXPRS ARRAY.
C
   10 CONTINUE
      CALL ALGEXP (CEXPRS,LENCEX,MXEXPR,CLEFT,LCLFT,RECORD,IRECNT,
     >             IREAD,JOSTND,IRC)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     RETURN CODES, IRC: 0=OK,1='END  ' WAS FOUND. OTHER ERRORS ARE
C     HANDLED INTERNALLY.
C
      IF (IRC.EQ.1) GOTO 30
C
C     FIND OUT IF THE LEFT HAND TOKEN (USER DEFINED VARIABLE) IS A
C     RESERVED KEYWORD (AN EVENT MONITOR VARIABLE OR A LEVEL
C     USER DEFINED VARIABLE).
C
      CALL ALGKEY (CLEFT,LCLFT,IKEY,IRCKEY)
      IF(IRCKEY.NE.0) THEN
         CALL EVMKV(CLEFT)
         CALL ALGKEY (CLEFT,LCLFT,IKEY,IRCKEY)
      ENDIF
C
C     IF IRCKEY IS ZERO AND IF IKEY IS LESS THAN 500 OR OVER 599, IT IS
C     RESERVED...ISSUE AN ERROR MESSAGE AND BRANCH TO PROCESS ANOTHER.
C
      IF (IRCKEY.EQ.0) THEN
         IF (IKEY.LT.500 .OR. IKEY.GT.500+MXTST5) THEN
            CALL ERRGRO (.TRUE.,15)
            GOTO 10
         ENDIF
      ENDIF
C
C     IF IRCKEY IS NOT ZERO, THEN THE VARIABLE NAME CAN NOT BE
C     DEFINED. ISSUE ERROR MSG AND BRANCH TO PROCESS NEXT EXPRESSION.
C
      IF (IRCKEY.EQ.1) THEN
         CALL ERRGRO (.TRUE.,10)
         CALL ERRGRO (.TRUE.,12)
         GOTO 10
      ENDIF
C
C     CALL ALGCMP TO COMPILE THE EXPRESSION.  SAVE THE STARTING
C     LOCATION OF THE OPCODE IN ARRAY(4)...(THIRD PARMS FOR THE OP).
C
      ARRAY(4)=FLOAT(ICOD)
      CALL ALGCMP (IRC,.FALSE.,CEXPRS,LENCEX,JOSTND,LDEBUG,1000,
     >   IPTODO,MXPTDO,IEVCOD,ICOD,MAXCOD,PARMS,IMPL,ITOPRM,MAXPRM)
C
C     IF WE GET A NON-ZERO RETURN CODE, ISSUE A GENERAL PURPOSE
C     ERROR MESSAGE AND BRANCH TO PROCESS THE NEXT EXPRESSION.
C
      IF (IRC.GT.0) THEN
         CALL ERRGRO (.TRUE.,12)
         GOTO 10
      ENDIF
C
C     CALL OPNEW TO ADD THE OPTION TO THE ACTIVITY SCHEDULE...
C     (THE FIRST PARAMETER WILL BE 0.0).
C
      ARRAY(2)=0.0
      ARRAY(3)=FLOAT(IKEY)
      CALL OPNEW (IRC,IDT,33,3,ARRAY(2))
C
C     IF THE RETURN CODE IS GT 0, A WARNING MSG WAS ISSUED VIA ERRGRO.
C
      IF (IRC.GT.0) GOTO 10
C
C     PROCESS THE NEXT EXPRESSION.
C
      GOTO 10
   30 CONTINUE
      RETURN
      END
