      SUBROUTINE DGF(DIAM)
      IMPLICIT NONE
C----------
C ACD $Id: dgf.f 2561 2018-11-17 00:28:06Z lancedavid $
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  DDS IS PREDICTED FROM DBH, SITE INDEX, AND BASAL AREA IN
C  LARGER TREES.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED
C  AS THE ARGUMENT DIAM.  THE PROGRAM THUS HAS THE FLEXIBILITY
C  TO PROCESS DIFFERENT CALIBRATION OPTIONS.  THIS ROUTINE IS
C  CALLED BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR
C  GROWTH PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO
C  LOAD SITE DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED
C  ONCE.
C
C
C  DIAMETER GROWTH EQUATIONS ARE FROM NE-TWIGS VERSION 3.01
C  OR SEE 'INDIVIDUAL-TREE DIAMETER GROWTH MODEL FOR THE NORTHEASTERN
C  UNITED STATES' TECK & HILT. RESEARCH PAPER NE-649
C
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
COMMONS
C----------
C  VARIABLES DEFINED:
C  POTBAG--POTENTIAL BASAL AREA GROWTH (PER YEAR)
C  BAG   --INDIVIDUAL TREE BASAL-AREA GROWTH RATE (PER YEAR)
C
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C       B1 -- ARRAY CONTAINING THE COEFFICIENTS FOR THE SITE
C	      INDEX FACTOR TERM IN THE BASAL AREA GROWTH MODEL
C	      FOR THE NORTHEASTERN UNITED STATES (ONE COEFFICIENT
C	      PER SPECIES).
C	B2 -- ARRAY CONTAINING THE COEFFICIENTS FOR THE DBH TERM
C	      IN THE BASAL AREA GROWTH MODEL FOR THE NORTHEASTERN
C	      UNITED STATES (ONE COEFFICIENT PER SPECIES).
C	B3 -- ARRAY CONTAINING THE COEFFICIENTS FOR THE BAL TERM
C	      IN THE BASAL AREA GROWTH MODEL FOR THE NORTHEASTERN
C	      UNITED STATES (ONE COEFFICIENT PER SPECIES).
C             THESE COEFFICIENTS WERE MOVED TO SUBROUTINE **BALMOD**
C             SO THE SAME EFFECT COULD BE INCORPORATED INTO SUBROUTINES
C             **HTGF** AND **RGNTHW**. OTHERWISE, YOU ENDED UP WITH
C             TALL SKINNY TREES SINCE DG WAS REDUCED AND HTG KEPT ON
C             GOING.
C----------
      LOGICAL DEBUG
C
      REAL DIAM(MAXTRE),B1(MAXSP),B2(MAXSP),TEMD(MAXTRE)
      INTEGER I,ISPC,I1,I2,I3,ILOOP
      REAL DGB1,DGB2,D,POTBAG,BAGMOD,DELD,QTRBA,QDBH,BARK,BRATIO
      REAL DIAGR,DDS,X1
      DATA B1/
     % .0008829,.0009933,.0008721,4*.0008236, 0.0009252,
     % .0011303,.0009252,.0006634,4*.0009050,2*.0008737,
     % 8*.0006634, 0.0007906,3*.0007439,3*.0006668,2*.0009766,
     % 5*.0007993, 0.0006911,5*.0008992,3*.0008815,5*.0011885,
     % 0.0007929,5*.0007417,4*.0008769,3*.0008238,2*.0008920,
     % 2*.0008550,27*.0009567,11*.0003604/
      DATA B2/
     % 0.0602785, 0.0816995, 0.0578650,4*.0549439, 0.1134195,
     % 0.0934796, 0.1134195, 0.1083470,4*.0517297,2*.0940538,
     % 8*.1083470, 0.0651982,3*.0706905,3*.0768212,2*.0832328,
     % 5*.0779654, 0.0730441,5*.0925395,3*.1419212,5*.0920050,
     % 0.1568904,5*.0867535,4*.0866621,3*.0790660,2*.0979702,
     % 2*.0957964,27*.1038458,11*.0328767/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE DGF  CYCLE =',I5)
C----------
C  STORE DIAMETERS FOR ITERATIVE PROCESSING
C----------
      DO 4 I=1,MAXTRE
      TEMD(I)=DIAM(I)
    4 CONTINUE
C----------
C  COMPUTE BAL FOR ALL THE TREES
C----------
      CALL BADIST(DEBUG)
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES DEPENDENT
C----------
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      DGB1=B1(ISPC)
      DGB2=B2(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
C----------
C  ITERATE 10 TIMES, SINCE DG EQUATION IS AN ANNUAL BASIS
C----------
      DO 1000 ILOOP=1,10
      D=TEMD(I)
      WK2(I)=0.0
      IF(D .LE. 0.0) GO TO 10
      POTBAG = DGB1*SITEAR(ISPC)*(1.0-EXP(-(DGB2*D)))
      POTBAG = POTBAG *0.7
      IF(DEBUG)
     &WRITE(16,*)' ILOOP,I,ISPC,SITE,D,DGB1,DGB2,POTBAG= ',
     &ILOOP,I,ISPC,SITEAR(ISPC),D,DGB1,DGB2,POTBAG
C----------
C  GET BAL MODIFIER AND ADJUST THE DIAMETER GROWTH ESTIMATE. 
C----------
      CALL BALMOD(ISPC,D,BAGMOD)
      IF(DEBUG) WRITE(JOSTND,*)'I=',I,' POTBAG=',POTBAG,' SITEAR=',
     &     SITEAR(ISPC), ' D=',D,' ISPC=',ISPC,' BAGMOD=',
     &     BAGMOD,' PCT(I)=',PCT(I)
      IF(DEBUG)WRITE(JOSTND,*)' AFTER BALMOD BAGMOD,HT,AVH= ',
     & BAGMOD,HT(I),AVH
      DELD=POTBAG*BAGMOD
      IF(DEBUG)
     &WRITE(16,*)' I,POTBAG,BAGMOD,DELD= ',I,POTBAG,BAGMOD,DELD
      QTRBA=DELD+(D*D*.0054542)
      QDBH=(QTRBA/.0054542)**.5
      TEMD(I)=QDBH
 1000 CONTINUE
C
      BARK=BRATIO(ISPC,TEMD(I),HT(I))
      DIAGR=(TEMD(I)-DIAM(I))*BARK
      IF(DEBUG)
     &WRITE(JOSTND,*)' I,TEMD,DIAM,BARK,DIAGR= ',
     &I,TEMD(I),DIAM(I),BARK,DIAGR
      IF (LDCOR2 .AND. COR2(ISPC) .GT. 0.0) DIAGR=DIAGR*COR2(ISPC)
      IF(DIAGR.LE. .0001) DIAGR=.0001
      IF(DEBUG)WRITE(16,*)' I,ISPC,COR2,DIAGR,LDCOR2= ',
     &I,ISPC,COR2(ISPC),DIAGR,LDCOR2
      DDS=DIAGR*(2.0*DIAM(I)*BARK+DIAGR)
      IF(DEBUG)WRITE(16,*)' I,DIAGR,DIAM(I),BARK,DDS= ',
     &I,DIAGR,DIAM(I),BARK,DDS
C
      IF(DEBUG) WRITE(JOSTND,*)' DDS=',DDS,
     &       BAGMOD,'  DDS=',DDS,' DIAGR=',DIAGR
C---------
      WK2(I)=ALOG(DDS)+COR(ISPC)
      IF(DEBUG)WRITE(16,*)' I,DDS,COR,WK2= ',
     &I,DDS,COR(ISPC),WK2(I)
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9001) I,ISPC,D,BA,DDS
 9001 FORMAT(' IN DGF, I=',I4,',  ISPC=',I3,',  DBH=',F7.2,
     &      ',  BA=',F9.3,',  LOG(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,100)ICYC
  100 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
      ENTRY DGCONS
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C----------
      DO 30 ISPC=1,MAXSP
      DGCON(ISPC)=0.
      ATTEN(ISPC)=1000.
      SMCON(ISPC)=0.
   30 CONTINUE
      RETURN
      END
