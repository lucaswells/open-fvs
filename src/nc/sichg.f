      SUBROUTINE SICHG(ISISP,SSITE,SIAGE,JOSTND)
      IMPLICIT NONE
C----------
C NC $Id: sichg.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
      CHARACTER*1 ISILOC,REFLOC(12)
      INTEGER IREFAG(12)
      REAL A(12),B(12),SIAGE(12)
      REAL SIMAX(12),SIMIN(12)
      INTEGER JOSTND,ISISP,I,IDIFF
      REAL SSITE,TEMSI,AGE2BH,SPREAD,RELSI
      INTEGER IDANUW
C
      DATA B/-0.08,-0.05,-0.08,-0.07,-0.02,-0.05,-0.05,-0.03,
     &       -0.06,-0.05,-0.03,-0.08/
      DATA A/10.0,12.0,10.0,10.0,3.0,10.0,6.0,4.0,
     &       10.0,12.0,4.0,10.0/
      DATA SIMIN/50.,40.,50.,30.,50.,30.,30.,50.,30.,40.,50.,50./
      DATA SIMAX/150.,120.,150.,130.,100.,130.,70.,90.,130.,120.,90.,
     &           150./
      DATA REFLOC/
     &  'B','T',7*'B','T','B','B'/
      DATA IREFAG/
     & 12*50/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = JOSTND
C
C----------
C  ISILOC IS THE PLACE THE AGE FOR THE SSITE FROM STDINFO IS TAKEN
C----------
      TEMSI = SSITE
      ISILOC = REFLOC(ISISP)
      DO 100 I=1,12
C----------
C  SET UP THE ARRAY TO TELL WHETHER YOU NEED TO SLIDE UP OR DOWN THE SIT
C  LINE TO ADJUST FOR TOTAL AGE OR BREAST HIGH AGE
C----------
      IF(ISILOC .EQ. 'T' .AND. REFLOC(I) .EQ. 'B')IDIFF=-1
      IF(ISILOC .EQ. REFLOC(I))IDIFF=0
      IF(ISILOC .EQ. 'B' .AND. REFLOC(I) .EQ. 'T')IDIFF=1
      AGE2BH=0.0
      IF(IDIFF .LT. 0 .OR. IDIFF .GT. 0)THEN
          IF(TEMSI .LT. SIMIN(ISISP))TEMSI=SIMIN(ISISP)
          IF(TEMSI .GT. SIMAX(ISISP))TEMSI=SIMAX(ISISP)
          SPREAD=SIMAX(ISISP)-SIMIN(ISISP)
          RELSI = 100.0*(TEMSI-SIMIN(ISISP))/SPREAD
          AGE2BH=A(I) + B(I)*RELSI
      END IF
      SIAGE(I) = IREFAG(I) + AGE2BH*IDIFF
  100 CONTINUE
      RETURN
      END
