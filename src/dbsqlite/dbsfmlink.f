      SUBROUTINE DBSFMLINK(I)
      IMPLICIT NONE
C
C DBSQLITE $Id: dbsfmlink.f 2445 2018-07-09 21:23:04Z gedixon $
C
C     PURPOSE: TO PASS SOME INFORMATION FROM FFE TO THE DATABASE
C              EXTENSION, WITHOUT INCLUDING DBSCOM.F77 IN FFE SUBROUTINES.
C              THIS SEEMS NECESSARY IN ORDER TO COMPILE FFE FOR BOTH PC AND UNIX.
C     AUTH: S. REBAIN -- FMSC -- JUNE 2006
C---
COMMONS
C
      INCLUDE 'DBSCOM.F77'
C
COMMONS
C---
      INTEGER  I

      ICANPR = I

      END