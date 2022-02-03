      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C CR $Id: htgf.f 2444 2018-07-09 16:00:55Z gedixon $
C-----------
C   THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C   INCREMENT FOR EACH CYCLE AND LOADS IT INTO
C    AN ARRAY, HTG.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
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
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
COMMONS
C----------
      EXTERNAL RANN
      LOGICAL DEBUG
      REAL HTOSI(6,MAXSP),TEMHTG,BACHLO,ZZRAN,ASPFAC,TEMSI,HGU,HGE
      REAL THTG,H30,TCCF,DFUT,AGEFUT,HTGI,TSITE,AP,DGI,PCCFI,XWT,SCALE
      REAL HHU2,HHU1,HHE2,HHE1,HNOW,BAUTBA,BRATIO,BARK,D,ADJUST,SSITE
      REAL MISHGF
      INTEGER I3,ICLS,I,ISPC,I1,I2,ITFN
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
C LOAD HEIGHT-TO-SITE FOR SOUTHWEST MC MODEL TYPE
C----------
      DATA (HTOSI(1,I),I=1,MAXSP)/
     & 1.25, 1.25, 1.18, 1.00, 1.20, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.20, 1.00, 1.20, 1.20, 1.20, 1.00, 1.20, 1.20, 1.20, 1.00,
     & 1.15, 1.15, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.20, 1.15, 1.15/
C----------
C LOAD HEIGHT-TO-SITE FOR SOUTHWEST PP MODEL TYPE
C----------
      DATA (HTOSI(2,I),I=1,MAXSP)/
     & 1.25, 1.25, 1.18, 1.00, 1.20, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.15, 1.00, 1.20, 1.15, 1.20, 1.00, 1.20, 1.20, 1.20, 1.00,
     & 1.15, 1.15, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.20, 1.15, 1.15/
C----------
C LOAD HEIGHT-TO-SITE FOR BLACK HILL PP MODEL TYPE
C----------
      DATA (HTOSI(3,I),I=1,MAXSP)/
     & 1.13, 1.13, 1.10, 1.10, 1.13, 1.10, 1.10, 1.10, 1.00, 1.07,
     & 1.13, 1.00, 1.10, 1.10, 1.10, 1.00, 1.15, 1.15, 1.15, 1.00,
     & 1.05, 1.05, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.10, 1.05, 1.15/
C----------
C LOAD HEIGHT-TO-SITE FOR SPRUCE-FIR MODEL TYPE
C----------
      DATA (HTOSI(4,I),I=1,MAXSP)/
     & 1.15, 1.15, 1.18, 1.00, 1.15, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.10, 1.00, 1.15, 1.05, 1.15, 1.00, 1.10, 1.10, 1.10, 1.00,
     & 1.05, 1.05, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.15, 1.05, 1.05/
C----------
C LOAD HEIGHT-TO-SITE FOR LODGEPOLE PINE MODEL TYPE
C----------
      DATA (HTOSI(5,I),I=1,MAXSP)/
     & 1.25, 1.25, 1.25, 1.10, 1.25, 1.10, 1.10, 1.10, 1.00, 1.07,
     & 1.30, 1.00, 1.25, 1.20, 1.20, 1.00, 1.20, 1.20, 1.20, 1.00,
     & 1.18, 1.18, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.25, 1.15, 1.20/
C----------
C LOAD HEIGHT-TO-SITE FOR ASPEN MODEL TYPE
C----------
      DATA (HTOSI(6,I),I=1,MAXSP)/
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00/
C
      SCALE=FINT/YR
      ISMALL=0
C-----------
C CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
C----------
C GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,9099)XHMULT,SCALE
 9099 FORMAT( ' HTGF MULT=',F10.3,'SCALE=',F10.3)
C----------
C BEGIN SPECIES LOOP
C----------
      DO 400 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 400
      I2 = ISCT(ISPC,2)
      SSITE = SITEAR(ISPC)
      ADJUST = HTOSI(IMODTY,ISPC)
C----------------
C BEGIN TREE LOOP WITHIN SPECIES LOOP
C--------------
      DO 300 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I) .LE. 0.0 ) GO TO 161
C----------
C SAVE POINTERS TO SMALL TREES
C BYPASS CALCULATION IF DIAMETER IS LESS THAN LOWER LIMIT
C----------
      IF (DBH(I).LT.0.5 .OR. HT(I).LE.4.5)THEN
        ISMALL=ISMALL + 1
        IND2(ISMALL) = I
        GO TO 161
      ENDIF
      D=DBH(I)
      ICLS = IFIX(D + 1.0)
      IF(ICLS .GT. 41) ICLS = 41
      BARK=BRATIO(ISPC,D,HT(I))
      BAUTBA= BAU(ICLS)/BA
      HNOW=HT(I)
      HHE1 = 0.0
      HHE2 = 0.0
      HHU1 = 0.0
      HHU2 = 0.0
      XWT  = 0.0
      PCCFI=PCCF(ITRE(I))
      DGI=DG(I)
      AP=ABIRTH(I)
C----------
C  ADJUST AP FOR BREAST HIGH AGE CURVES IF NECESSARY
C----------
      IF(IMODTY.EQ.1 .OR. IMODTY.EQ.2 .OR. IMODTY.EQ.4)THEN
        IF(ISPC.EQ.20 .OR. ISPC.EQ.28 .OR. ISPC.EQ.38 
     &    .OR. ISPC.EQ.14 .OR. (IMODTY.EQ.3 .AND.
     &  (ISPC.EQ.21 .OR. ISPC.EQ.22 .OR. ISPC.EQ.37 .OR. ISPC.EQ.16
     &  .OR. (ISPC.GE.29 .AND. ISPC.LE.32))))THEN
          AP=AP-(4.5/(0.1+SSITE/50.))
        ELSEIF(IMODTY.EQ.1)THEN
          TSITE=SSITE
          IF(TSITE.LT.30.)TSITE=30.
          AP=AP-(4.5/(-0.642+0.02285*TSITE))
        ELSEIF(IMODTY.EQ.2)THEN
          AP=AP-(4.5/(0.25+0.00467*SSITE))
        ELSEIF(IMODTY.EQ.4)THEN
          TSITE=SSITE
          IF(TSITE.LT.20.)TSITE=20.
          AP=AP-(4.5/(-0.22+0.0155*TSITE))
        ENDIF
        IF(AP.LT.1.)AP=1.
      ENDIF
C
      HHE1=0.
      HHU1=0.
      IHTG=0
      HTGI=0.
      IF(DEBUG)WRITE(JOSTND,*)' IN HTGF 1ST CALL TO GEMHT ARGS= ',
     &IMODTY,HHE1,HHU1,SSITE,D,HNOW,ISPC,BA,AP,BAUTBA,
     &PCCFI,DGI,BARK,IHTG,HTGI
C----------
C GEMHT NOW COMPUTES BOTH EVEN/UNEVEN-AGE REGARDLESS.
C----------
      CALL GEMHT(IMODTY,HHE1,HHU1,SSITE,D,HNOW,ISPC,BA,AP,
     & BAUTBA,PCCFI,DGI,BARK,IHTG,HTGI)
C
      IF(DEBUG)WRITE(JOSTND,*)' RETURN FROM 1ST GEMHT HHE1,HHU1,IHTG,',
     &   'HTGI= ',HHE1,HHU1,IHTG,HTGI
C----------
C  IF HEIGHT GROWTH IS ALREADY A DIRECT ESTIMATE, SKIP NEXT SECTION.
C----------
      IF(IHTG .EQ. 1) THEN
        HTG(I)=HTGI*ADJUST
        GO TO 190
      ENDIF
C----------
C HTG IS A TEN YEAR ESTIMATE AT THIS POINT, BUT IS SCALED TO A
C FINT YEAR BASIS BELOW.
C----------
      AGEFUT = AP + 10.0
      DFUT=D + DGI/BARK
C
      IF(DEBUG)WRITE(JOSTND,*)' IN HTGF 2ND CALL TO GEMHT ARGS= ',
     &IMODTY,HHE2,HHU2,SSITE,DFUT,HNOW,ISPC,BA,AGEFUT,BAUTBA,
     &PCCFI,DGI,BARK,IHTG,HTGI
C
      CALL GEMHT(IMODTY,HHE2,HHU2,SSITE,DFUT,HNOW,ISPC,BA,AGEFUT,
     &           BAUTBA,PCCFI,DGI,BARK,IHTG,HTGI)
C
      IF(DEBUG)WRITE(JOSTND,*)' RETURN FROM 2ND GEMHT HHE2,HHU2= ',
     &   HHE2,HHU2
C----------
C REALIGN HHE1 AND HHE2 FOR BLACK HILLS
C----------
      IF(IMODTY .EQ. 3) THEN
        HHE2 = HHE1
        HHE1 = HT(I)
      ENDIF
C----------
C IF EVEN-AGED,UNEVEN-AGED AND BA .LT. 70, OR UNEVEN-AGED AND PCT(I)
C IS .GE.40 (OVERSTORY) THEN HTG(I) IS EVEN-AGED HT GROWTH ESTIMATE.
C----------
      HTG(I) = (HHE2 - HHE1)*ADJUST
C----------
C  NEED TO GET LPP MODEL TYPE EVEN-AGED YOUNG TREES TO HIT CARL'S
C  SITE FUNCTION EVALUATED AT AGE 30.
C----------
      IF(IMODTY.EQ.5 .AND. ABIRTH(I).LE.31.)THEN
        TCCF=PCCF(ITRE(I))
        IF(TCCF.LE.125.)TCCF=0.
        H30=5.25621 + 0.37515*SSITE - 0.00082*TCCF*SSITE
        H30=H30*ABIRTH(I)/31.
        THTG=H30-HT(I)
        IF(THTG .GT. HTG(I))THEN
          HTG(I)=THTG
          HHE2=H30
          HHE1=HT(I)
        ENDIF
      ENDIF
C----------
C IF STAND IS UNEVEN-AGED AND BA IS .GE. TO 70 THEN USE A BLEND.
C TREES WITH PCT() .LE. 10 (OVERTOPPED TREES) GET UNEVEN-AGED
C HEIGHT GROWTH; TREES WITH PCT() .GT. 10 AND .LT. 40 GET A
C WEIGHTED AVERAGE OF EVEN/UNEVEN-AGED HEIGHT GROWTH.
C----------
      IF(AGERNG .GT. 40.0 .AND. BA .GE. 70.0) THEN
        IF(PCT(I) .LE. 10.)HTG(I) = HHU2 - HHU1
        IF((PCT(I) .GT. 10.0) .AND. (PCT(I) .LT. 40.0)) THEN
           HGE = (HHE2 - HHE1)*ADJUST
           HGU = HHU2 - HHU1
           XWT = ((PCT(I)-10.)*(10./3.))/100.
           HTG(I) = XWT*HGE + (1.0-XWT)*HGU
         ENDIF
      ENDIF
C----------
C  ADJUSTMENT TO HEIGHT GROWTH FOR ASPEN AND PAPER BIRCH
C----------
      IF(ISPC.EQ.20 .OR. ISPC.EQ.28) THEN
        TEMSI=SITEAR(ISPC)
        IF(TEMSI .LT. 30.)TEMSI=30.
        IF(TEMSI .GT. 90.)TEMSI=90.
        ASPFAC = 0.6253 + 0.00583*TEMSI
        HTG(I)=HTG(I)*ASPFAC
      ENDIF
C----------
C     ADD RANDOM INCREMENT TO HTG.  GETS AWAY FROM ALL TREES HAVING
C     THE SAME INCREMENT (ESP UNDER EDMINSTERS EVEN-AGED LOGIC).
C----------
  190 CONTINUE
      ZZRAN = 0.0
      IF(DGSD .GT. 0.0) THEN
        ZZRAN=BACHLO(0.0,1.0,RANN)
        IF(ZZRAN .GT. DGSD .OR. ZZRAN .LT. (-DGSD)) GO TO 190
        IF(DEBUG)WRITE(JOSTND,9984) I,HTG(I),ZZRAN,SCALE
 9984   FORMAT(1H ,'IN HTGF 9984 FORMAT',I5,2X,3(F10.4,2X))
      ENDIF
      HTG(I) = HTG(I) + ZZRAN*0.1
C----------
C  IF STAGNATION EFFECT IS ON FOR THIS SPECIES,
C  ONLY REDUCE HT GROWTH BY HALF OF DSTAG, NOT DSTAG. DIXON 3-9-93
C----------
      IF(ISTAGF(ISPC).NE.0)HTG(I)=HTG(I)*(DSTAG+1.0)*.5
      IF(HTG(I) .LT. 0.1) HTG(I) = 0.1
      IF(DEBUG)
     &WRITE(JOSTND,*)' HTGF I,ISPC,XWT,HHE1,HHE2,HHU1,HHU2,HT,HTG = ',
     &                I,ISPC,XWT,HHE1,HHE2,HHU1,HHU2,HT(I),HTG(I)
C----------
C  CALCULATE HEIGHT GROWTH
C  NEGATIVE HEIGHT GROWTH IS NOT ALLOWED
C----------
      HTG(I)= HTG(I)*EXP(HTCON(ISPC))*SCALE*XHMULT(ISPC)
C----------
C  LIMIT BLACK HILLS WHITE SPRUCE TO 90 FEET.
C  LIMIT BLACK HILLS ASPEN AND PAPER BIRCH TO 54 FEET.
C     HFUT=HNOW+HTG(I)
C     IF(IMODTY.EQ.3 .AND. ISPC.EQ.17.AND. HFUT.GT.90.)HTG(I)=0.1
C     IF(IMODTY.EQ.3 .AND. ISPC.EQ.18.AND. HFUT.GT.90.)HTG(I)=0.1
C     IF(IMODTY.EQ.3 .AND. ISPC.EQ.19.AND. HFUT.GT.90.)HTG(I)=0.1
C     IF(IMODTY.EQ.3 .AND. ISPC.EQ.20.AND. HFUT.GT.54.)HTG(I)=0.1
C     IF(IMODTY.EQ.3 .AND. ISPC.EQ.28.AND. HFUT.GT.54.)HTG(I)=0.1
C----------
C
  161 CONTINUE
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT. LTRIP) GO TO 9002
      ITFN = ITRN + 2*I - 1
      HTG(ITFN) = TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1) = TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,9001)HTG(ITFN),HTG(ITFN+1),ISPC,I
 9001 FORMAT('  LOWER HTG = ',F8.4,'  UPPER HTG = ',F8.4,2I5)
 9002 CONTINUE
  300 CONTINUE
C--------------
C END OF SPECIES LOOP
C--------------
  400 CONTINUE
      RETURN
C
      ENTRY HTCONS
C----------------
C  LOAD HTCON.  IF CORRECTION TERMS ARE TO BE USED, MODIFY ACCORDINGLY
C---------------
C  LOAD OVER INTERCEPT FOR EACH SPECIES
C-------------------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
