      SUBROUTINE SVTDEL(INDEX,IVACT)
      IMPLICIT NONE
C----------
C BASE $Id: svtdel.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C
C     STAND VISUALIZATION GENERATION
C     N.L.CROOKSTON -- RMRS MOSCOW -- NOVEMBER 1998
C
C     DELETE REFERENCES FROM THE OBJECT LIST TO TREES THAT ARE
C     BEING DELETED.  
C
C     CALLED FROM TREDEL. 
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'SVDATA.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'WORKCM.F77'
C
C
COMMONS
C
      INTEGER IVACT,I,II,ISVOBJ,IPT
      INTEGER INDEX(MAXTRE)
      INTEGER IWKCM1(MAXTRE)
      EQUIVALENCE (IWKCM1,WORK1)
C
      IF (JSVOUT.EQ.0) RETURN
      IF (IVACT.EQ.0) RETURN
C
      DO I=1,ITRN
         IWKCM1(I)=0
      ENDDO
      DO I=1,IVACT
         II=-INDEX(I)
         IWKCM1(II)=1
      ENDDO
      DO ISVOBJ=1,NSVOBJ
         I=IS2F(ISVOBJ)
         IF (I.GT.0 .AND. IOBJTP(ISVOBJ).EQ.1) THEN
            IPT=IWKCM1(I)
            IF (IPT.EQ.1) IS2F(ISVOBJ)=0
         ENDIF
      ENDDO
      RETURN
      END
