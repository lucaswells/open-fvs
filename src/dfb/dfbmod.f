      SUBROUTINE DFBMOD
      IMPLICIT NONE
C----------
C DFB $Id: dfbmod.f 2446 2018-07-09 22:54:33Z gedixon $
C----------
C
C  THIS ROUTINE CALCULATES THE PROJECTED NUMBER OF DOUGLAS-FIR TREES TO
C  KILL IN THE CURRENT DFB OUTBREAK.
C
C  CALLED BY :
C     DFBDRV  [DFB]
C
C  CALLS :
C     BACHLO (FUNCTION)   [PROGNOSIS]
C     DFBRAN (FUNCTION)   [DFB]        - CALLED THROUGH BACHLO.
C
C  LOCAL VARIABLES :
C     NUMYRS - LENGTH OF OUTBREAK.
C     DFBRAN - NAME OF RANDOM NUMBER GENERATOR ROUTINE CALLED BY BACHLO.
C
C  COMMON BLOCK VARIABLES USED :
C     BA9    - (DFBCOM)  INPUT
C     BADF9  - (DFBCOM)  INPUT
C     DEBUIN - (DFBCOM)  INPUT
C     DFKILL - (DFBCOM)  OUTPUT
C     EXPCTD - (DFBCOM)  INPUT
C     EXSTDV - (DFBCOM)  INPUT
C     ICYC   - (CONTRL)  INPUT
C     IFINT  - (PL0T)    INPUT
C     ILENTH - (DFBCOM)  INPUT
C     IYOUT  - (DFBCOM)  INPUT
C     JODFB  - (DFBCOM)  INPUT
C     LINPRG - (DFBCOM)  INPUT
C     OKILL  - (DFBCOM)  INPUT
C     PERDD  - (DFBCOM)  INPUT
C     PREKLL - (DFBCOM)  INPUT
C     START  - (DFBCOM)  INPUT
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'DFBCOM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
      INTEGER NUMYRS
      REAL    BACHLO
      EXTERNAL DFBRAN

C
C     SET NUMYRS TO THE LENGTH OF OUTBREAK IN YEARS.
C
      IF (ILENTH .GT. IFINT) THEN
         NUMYRS = IFINT
      ELSE
         NUMYRS = ILENTH
      ENDIF

      IF (NUMYRS .GT. 10)  NUMYRS = 10

      IF (LINPRG .AND. ICYC .EQ. 1) THEN
C
C        OUTBREAK IN PROGRESS. USE USER ENTERED VALUES.
C
         NUMYRS = NUMYRS - IYOUT
         IF (IYOUT .GT. 4.0) THEN
C
C           OUTBREAK TO LONG TO USE THIS FUNCTION.  OUTBREAK ASSUMED TO
C           BE OVER.
C
            DFKILL = 0.0
         ELSEIF (PREKLL .LE. 0.0) THEN
C
C           USER DID NOT ENTER ANY MORTALITY VALUES.  CALCULATE
C           HOW MANY TREES SHOULD BE KILLED TO FINISH A 4 YEAR OUTBREAK.
C           IF DFKILL IS LESS THEN ZERO THEN RECALCULATE WITH NEW RANDOM
C           NUMBER.
C
  100       CONTINUE
               DFKILL = BACHLO(EXPCTD,EXSTDV,DFBRAN) * (BADF9 / BA9) *
     &                  4.0 * (1.0 - PERDD(IYOUT))
            IF (DFKILL .LT. 0.0) GOTO 100

         ELSE
C
C           USER ENTERED MORTALITY VALUES.
C           CALCULATE HOW MANY MORE TO KILL.
C
            DFKILL = PREKLL / PERDD(IYOUT) - PREKLL
         ENDIF
      ELSE
C
C        CALCULATE NUMBER OF DF TO KILL IF NEW OUTBREAK.
C        IF DFKILL IS LESS THEN ZERO THEN RECALCULATE WITH NEW RANDOM
C        NUMBER.
C
  200    CONTINUE
            DFKILL = BACHLO(EXPCTD,EXSTDV,DFBRAN) * (BADF9 / BA9) *
     &               NUMYRS + OKILL
         IF (DFKILL .LT. 0.0) GOTO 200
      ENDIF

  400 CONTINUE

      IF (DEBUIN) WRITE (JODFB,*) ' ** LEAVING SUBROUTINE DFBMOD'

      RETURN
      END
