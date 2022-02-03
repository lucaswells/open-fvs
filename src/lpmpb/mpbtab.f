      SUBROUTINE MPBTAB(CFTVOL)
      IMPLICIT NONE
C----------
C LPMPB $Id: mpbtab.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
C
C  PRINTS OUT THE SUMMARY OF MORTALITY BY MPB.  THIS TABLE IS PRINTED
C  TO THE MACHINE READABLE FILE THAT IS DEFINED BY KEYWORD MPBECHO.
C  THIS IS THE SUMMARY THAT SHOWS TOTALS FOR MORTALITY BY DBH CLASS.
C  THIS IS THE SECOND TABLE THAT IS PRINTED IN THE MACHINE READABLE
C  FILE.
C
C  CALLED BY :
C     COLMRT  [MPB]
C
C  CALLS :
C     COLIND  (SUBROUTINE)  [MPB]
C
C  PARAMETERS :
C     CFTVOL - ARRAY THAT HOLDS THE CUBIC FOOT VOLUME LOST DUE TO MPB
C              FOR EACH DBH CLASS.
C
C  LOCAL VARIABLES :
C     DCLASS - ARRAY THAT HOLDS THE DIAMETER CLASS HEADINGS THAT ARE
C              TO BE PRINTED IN THE SUMMARY TABLE.
C     DEADLP - ARRAY THAT HOLDS THE TOTAL NUMBER OF DEAD LODGEPOLE
C              PINE TREES/ACRE AT THE END OF THE OUTBREAK BY DBH CLASS.
C     I, J   - INDEX COUNTERS.
C     INDEX  - THE DBH CLASS OF THE CURRENT TREE RECORD.
C     LIVELP - ARRAY THAT HOLDS THE TOTAL NUMBER OF LIVE LODGEPOLE PINE
C              TREES/ACRE THAT EXIST AFTER THE OUTBREAK BY DBH CLASS.
C     NUMYR  - NUMBER OF YEARS IN THE OUTBREAK.
C     TOTGRN - ARRAY THAT HOLDS THE TOTAL LIVE TREES/ACRE FOR EACH DBH
C              CLASS IN THE STAND.
C     TTDEAD - HOLDS THE TOTAL NUMBER OF LODGEPOLE PINE THAT ARE KILLED
C              BY MPB (TREES/ACRE).
C     TTLIVE - HOLDS THE TOTAL NUMBER OF LIVE LODGEPOLE PINE
C              (TREES/ACRE).
C     TTTOTL - HOLDS THE TOTAL NUMBER OF LIVE TREES (TREES/ACRE).
C     TTVOL  - HOLDS THE TOTAL CUBIC FOOT VOLUME LOST DUE TO THE MPB.
C     YRTEST - USED TO TEST FOR THE NUMBER OF YEARS IN THE OUTBREAK.
C
C  COMMON BLOCK VARIABLES USED :
C     DBH    - (ARRAYS)  INPUT
C     DEAD   - (COLCOM)  INPUT
C     GREEN  - (COLCOM)  INPUT
C     ICYC   - (CONTRL)  INPUT
C     ITRN   - (CONTRL)  INPUT
C     IY     - (CONTRL)  INPUT
C     JOMPBX - (MPBCOM)  INPUT
C     PROB   - (ARRAYS)  INPUT
C
C Revision History
C   03/26/91 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C   08/22/14 Lance R. David (FMSC)
C     Function name was used as variable name.
C     changed variable INDEX to INDX
C----------
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'MPBCOM.F77'
C
C
      INCLUDE 'COLCOM.F77'
C
COMMONS
C

      INTEGER I, J, INDX, NUMYR

      REAL    TOTGRN(10), CFTVOL(10), LIVELP(10), DEADLP(10)
      REAL    TTLIVE, TTDEAD, TTTOTL, TTVOL, YRTEST

      CHARACTER*8 DCLASS(10)

      DATA DCLASS / ' 1 -  3',' 3 -  5',' 5 -  7',' 7 -  9',' 9 - 11',
     &              '11 - 13','13 - 15','15 - 17','17 - 19','19 - 20+' /

C
C     TEST TO SEE IF MACHINE READABLE OUTPUT IS BEING PRINTED.
C     IF IT IS NOT THEN DO NOT PRINT THIS TABLE.
C
      IF (JOMPBX .EQ. 0) GOTO 1000

C
C     INITIALIZE TOTGRN, LIVELP, DEADLP.
C     FIND THE NUMBER OF YEARS IN THE OUTBREAK BY TESTING TO SEE WHEN
C     GREEN EQUALS ZERO FOR ALL SIZE CLASSES.
C
      NUMYR = 0
      DO 100 I = 1,10
         TOTGRN(I) = 0.0
         LIVELP(I) = 0.0
         DEADLP(I) = 0.0

         YRTEST = 0.0
         DO 90 J = 1,10
            YRTEST = YRTEST + GREEN(I,J)
   90    CONTINUE
         IF (YRTEST .GT. 0.0) NUMYR = NUMYR + 1
  100 CONTINUE

C
C     BREAK PROGNOSIS PROB ARRAY INTO DBH CLASSES.
C
      DO 200 I = 1, ITRN
         CALL COLIND (DBH(I), INDX)
         TOTGRN(INDX) = TOTGRN(INDX) + PROB(I)
  200 CONTINUE

C
C     PRINT FIRST LINE SO THAT THIS TABLE CAN BE DISTINGUISHED FROM
C     THE OTHER MACHINE READABLE TABLE.  ALSO PRINT THE CYCLE YEAR.
C
      WRITE(JOMPBX,*)
      WRITE(JOMPBX,*) 'SUMMARY BY DBH'

      WRITE (JOMPBX,300) IY(ICYC)
  300 FORMAT (I4)

C
C     CALCULATE THE TOTALS FOR LIVE AND DEAD LODGEPOLE FOR EACH DBH
C     CLASS.
C
      DO 500 I = 1,10
         DO 400 J = 1,10
            DEADLP(I) = DEADLP(I) + DEAD(J,I)
  400    CONTINUE
         LIVELP(I) = LIVELP(I) + GREEN(NUMYR,I)
  500 CONTINUE

C
C     INITIALIZE THE VARIABLES THAT KEEP THE TOTALS.
C
      TTLIVE = 0.0
      TTDEAD = 0.0
      TTTOTL = 0.0
      TTVOL  = 0.0

C
C     PRINT OUT SUMMARY TABLE INFORMATION AND CALCULATE TOTALS.
C
      DO 600 I = 1,10
         TOTGRN(I) = TOTGRN(I) - DEADLP(I)
         WRITE (JOMPBX,700) DCLASS(I), TOTGRN(I), LIVELP(I),
     &                      DEADLP(I), CFTVOL(I)

         TTLIVE = TTLIVE + LIVELP(I)
         TTDEAD = TTDEAD + DEADLP(I)
         TTTOTL = TTTOTL + TOTGRN(I)
         TTVOL  = TTVOL  + CFTVOL(I)
  600 CONTINUE

C
C     PRINT OUT THE SUMMARY TABLE TOTALS.
C
      WRITE (JOMPBX,710)
      WRITE (JOMPBX,720) TTTOTL, TTLIVE, TTDEAD, TTVOL

  700 FORMAT (2X,A8,2X,F7.1,5X,F7.1,5X,F7.1,4X,F8.1)
  710 FORMAT (1X,'           ----------  ----------  ---------- ',
     &        ' ----------')
  720 FORMAT (12X,F7.1,5X,F7.1,5X,F7.1,4X,F8.1)

 1000 CONTINUE
      RETURN
      END
