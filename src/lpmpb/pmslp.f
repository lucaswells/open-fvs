      FUNCTION PMSLP(XX,X,Y,N)
      IMPLICIT NONE
C----------
C LPMPB $Id: pmslp.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
      DIMENSION X(N),Y(N)
C
C.....A LINEAR-INTERPOLATION FUNCTION
C
C     SUPPLIED WITH THE BWMOD AS WRITTEN AT THE MODELING
C     WORKSHOP.  THE NAME IS CHANGED FROM 'SLP' TO 'PMSLP'.
C
C     PART OF THE MOUNTAIN PINE BEETLE EXTENSION OF THE PROGNOSIS
C     SYSTEM. INT-MOSCOW FORESTRY SC. LAB. DEC. 1980
C
C Revision History
C   02/08/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
C
      INTEGER  I, N, NN 
      REAL PMSLP, X, XX, Y 

      NN=N-1
      DO 30 I=1,NN
      IF(XX.LT.X(I).OR.XX.GT.X(I+1)) GO TO 30
      PMSLP=Y(I)+((Y(I+1)-Y(I))/(X(I+1)-X(I)))*(XX-X(I))
      RETURN
 30   CONTINUE
      PMSLP=Y(N)
      RETURN
      END
