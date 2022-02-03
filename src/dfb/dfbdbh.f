      SUBROUTINE DFBDBH
      IMPLICIT NONE
C----------
C DFB $Id: dfbdbh.f 2446 2018-07-09 22:54:33Z gedixon $
C----------
C
C  INITIALIZATION ROUTINE FOR DFB MODEL.  INITIALIZES THE START ARRAY.
C
C  CALLED BY :
C     DFBDRV  [DFB]
C
C  CALLS :
C     DFBIND  (SUBROUTINE)   [DFB]
C
C  LOCAL VARIABLES :
C     I,J    - COUNTER INDEXES.
C     I1,I2  - INDEXES FOR THE ARRAY IND1.  I1 IS THE STARTING
C              INDEX FOR A SPECIES IN ARRAY IND1 (DF = IDFSPC).
C              I2 IS THE ENDING INDEX FOR A SPECIES IN ARRAY IND1
C              (DF = IDFSPC).
C     INDEX  - HOLDS DBH CLASS (1-10) OF THE TREE RECORD.
C
C  COMMON BLOCK VARIABLES USED :
C     DBH    - (ARRAYS)   INPUT
C     IDFSPC - (DFBCOM)   INPUT
C     IND1   - (ARRAYS)   INPUT
C     ISCT   - (CONTRL)   INPUT
C     PROB   - (ARRAYS)   INPUT
C     START  - (DFBCOM)   OUTPUT
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
COMMONS
C
      INTEGER I, I1, I2, J, I3

C.... INITIALIZE START ARRAY

      DO 100 I = 1,20
         START(I)  = 0.0
  100 CONTINUE

C.... DETERMINE NUMBER OF TREES PER DBH CLASS IN THE STAND

      I1 = ISCT(IDFSPC,1)
      IF (I1 .EQ. 0) GOTO 400
      I2 = ISCT(IDFSPC,2)

      DO 300 I = I1,I2
         J = IND1(I)

C....    LOAD THE START ARRAY WITH THE NUMBER OF TREES PER ACRE THAT
C....    THIS TREE RECORD REPRESENTS.

         CALL DFBIND (DBH(J),I3)
         START(I3) = START(I3) + PROB(J)
  300 CONTINUE

  400 CONTINUE

      RETURN
      END
