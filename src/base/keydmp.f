      SUBROUTINE KEYDMP (IOUT,IRECNT,KEYWRD,ARRAY,KARD)
      IMPLICIT NONE
C----------
C BASE $Id: keydmp.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
      INTEGER IRECNT,IOUT
      REAL ARRAY(7)
      CHARACTER*10 KARD(7)
      CHARACTER*8 KEYWRD
      WRITE (IOUT,70) IRECNT,KEYWRD,ARRAY,KARD
   70 FORMAT (/,' CARD NUM =',I5,'; KEYWORD FIELD = ''',A8,''''/
     >        '      PARAMETERS ARE:',7F14.7,/
     >        '      COL 11 TO 80 =''',7A10,'''')
C
      RETURN
      END
