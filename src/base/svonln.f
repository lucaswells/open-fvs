      SUBROUTINE SVONLN (X,Y,X1,Y1,X2,Y2,KODE)
      IMPLICIT NONE
C----------
C BASE $Id: svonln.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     STAND VISUALIZATION GENERATION
C     N.L.CROOKSTON -- RMRS MOSCOW -- NOVEMBER 1998
C
C     RETURN KODE = 0 IF X,Y IS NOT WITHIN THE INTERVAL (X1,Y1),(X2,Y2)
C     RETURN KODE = 1 IF THIS POINT IS WITHIN THE INTERVAL.
C
C     THIS ROUTINE ONLY WORKS IF (X,Y) IS ON THE LINE...IT ONLY
C     CHECKS IF THE POINT IS ON THE INTERVAL...INCLUDING THE
C     ENDPOINTS.
C
      INTEGER KODE
      REAL X,Y,X1,Y1,X2,Y2
      KODE = 0
      IF (X1.LT.X2) THEN
         IF (X1.LE.X .AND. X.LE.X2) GOTO 10
      ELSE
         IF (X2.LE.X .AND. X.LE.X1) GOTO 10
      ENDIF
      RETURN
C
 10   CONTINUE
      IF (Y1.LT.Y2) THEN
         IF (Y1.LE.Y .AND. Y.LE.Y2) GOTO 20
      ELSE
         IF (Y2.LE.Y .AND. Y.LE.Y1) GOTO 20
      ENDIF
C      
      RETURN
 20   CONTINUE
      KODE = 1
      RETURN
      END
