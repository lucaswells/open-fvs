      SUBROUTINE ECOPLS (KEYWRD,IDISP,PARMS,J1,J2)
      IMPLICIT NONE
C----------
C BASE $Id: ecopls.f 2438 2018-07-05 16:54:21Z gedixon $
C----------
C  THIS SUBROUTINE IS CALLED ONCE PER PROJECTION.
C  IT OUTPUTS THE KEYWORD, DATE AND NECESSARY PARAMETERS FOR THE
C  VARIOUS PROGNOSIS MODEL OPTIONS AND/OR EXTENSIONS WHICH ARE
C  RECOGNIZED BY THE ECONOMIC ANALYSIS PROGRAM CHEAPO
C----------
C
C     KEYWRD = CHARACTER*8 KEYWORD.
C     IDISP  = ACTIVITY DISPOSITION CODE WHERE:
C              -1 = DELETED
C               0 = NOT DONE
C              >0 = THE DATE ACTIVITY WAS DONE.
C     PARMS  = THE PARAMETER ARRAY.
C     J1     = IF ZERO THEN THERE ARE NO PARAMETERS FOR THE ACTIVITY.
C              OTHERWISE THE LOCATION OF THE FIRST PARAMETER
C     J2     = THE LOCATION OF THE LAST PARAMETER FOR THE ACTIVITY.
C
COMMONS
C
C
      INCLUDE 'ECON.F77'
C
C
COMMONS
C
      INTEGER J1,J2,IDISP,ITBSZ,I,JTWO,J
      PARAMETER (ITBSZ=7)
      REAL  PARMS(*)
      CHARACTER*8  TABLE(ITBSZ),KEYWRD
C
      DATA  TABLE/'MECHPREP','BURNPREP','PLANT   ','NPV2    ',
     >            'NPV3    ','CHEMICAL','PRUNE   '/
C
      IF (.NOT.LECON) RETURN
C
C----------
C   IF THE KEYWORD IS IN THE TABLE OUTPUT THE NECESSARY INFORMATION
C----------
      DO 200 I=1,ITBSZ
      IF( TABLE(I) .NE. KEYWRD ) GO TO 200
      IF( IDISP .LE. 0 ) RETURN
C----------
C   THERE IS ONLY ROOM TO OUTPUT UP TO SIX(6) PARAMETERS.
C----------
      IF (J1.GT.0 .AND. J2.GE.J1) THEN
         JTWO=J2
         IF( J2-J1 .GT. 5 ) JTWO=J1+5
         WRITE(JOSUME,100) KEYWRD,IDISP,(PARMS(J),J=J1,JTWO)
      ELSE
         WRITE(JOSUME,100) KEYWRD,IDISP
      ENDIF         
  100 FORMAT (A8,I6,6F10.2)
      RETURN
  200 CONTINUE
      RETURN
      END
