C----------
C VOLUME $Id: fvsbrucedemars.f 2458 2018-07-22 19:09:30Z gedixon $
C----------
      SUBROUTINE FVSBRUCEDEMARS(VN,VM,VMAX,D,H,ISPC,BARK,LCONE,CTKFLG)
      IMPLICIT NONE
C  This routine calculates volumes for the AK variant using
C  the Bruce and Demars method METHC = 8
C  called from **FVSVOL
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
C      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C

      REAL VMAX,BARK,H,D,VM,VN,BBF,VVN,VOLT
      REAL DMRCH,HTMRCH,VOLM,S3,STUMP
      REAL BEHRE
      INTEGER ISPC
      LOGICAL LCONE,CTKFLG
C
      VVN=0.0
      BBF=0.0
      IF (H .LE. 4.5) GO TO 50
      IF(D .LE. 3.5 .OR. H .LT. 18.0) GO TO 10
      IF(D .GE. 9.0 .AND. H .GT. 40.0)GO TO 30
      CALL FVSOLDSEC(ISPC,VVN,D,H)
      GO TO 50
   10 CALL FVSOLDFST (ISPC,VVN,D,H)
      GO TO 50
   30 CALL FVSOLDGRO(ISPC,VVN,D,H,BBF)
   50 CONTINUE
      VN=VVN
      VMAX=VVN
C----------
C  COMPUTE MERCHANTABLE CUBIC VOLUME USING TOP DIAMETER, MINIMUM
C  DBH, AND STUMP HEIGHT SPECIFIED BY THE USER.
C----------
      IF(VN .EQ. 0.) THEN
        VM = 0.
        CTKFLG = .FALSE.
        GO TO 60
      ENDIF
      CALL BEHPRM (VMAX,D,H,BARK,LCONE)
      VOLT=BEHRE(0.0,1.0)
      STUMP = 1. - (STMP(ISPC)/H)
      IF(D.LT.DBHMIN(ISPC).OR.D.LT.TOPD(ISPC)) THEN
        VM=0.0
      ELSE
        DMRCH=TOPD(ISPC)/D
        HTMRCH=((BHAT*DMRCH)/(1.0-(AHAT*DMRCH)))
        IF(.NOT.LCONE) THEN
          VOLM=BEHRE(HTMRCH,STUMP)
          VM=VMAX*VOLM/VOLT
        ELSE
C----------
C       PROCESS CONES.
C----------
          S3=STUMP**3
          VOLM=S3-HTMRCH**3
          VM=VMAX*VOLM
        ENDIF
      ENDIF
      CTKFLG = .TRUE.
   60 CONTINUE
      RETURN
      END
