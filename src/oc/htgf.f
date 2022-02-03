      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C OC $Id: htgf.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
C  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
C  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
C  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
C  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
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
      INCLUDE 'ORGANON.F77'
C
C
COMMONS
C
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,ITFN
      REAL AGP10,HGUESS,SCALE,XHT,SINDX,AGMAX,H,POTHTG,XMOD,CRATIO
      REAL RELHT,CRMOD,RHMOD,TEMHTG
      REAL SITAGE,SITHT,HTMAX,HTMAX2,D1,D2,LTHTG,DGLT
      REAL MISHGF
      REAL BRAT,BRATIO,DG10,HGBND
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF CYCLE =',I5)
C
      SCALE=FINT/YR
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- IY(ICYC),XHMULT= ',
     & IY(ICYC), XHMULT
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=XHMULT(ISPC)
      SINDX = SITEAR(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C
C   XHT CONTAINS THE HEIGHT GROWTH MULTIPLIER FROM THE HTGMULT KEYWORD
C   HTCON CONTAINS THE HEIGHT GROWTH MULTIPLIER FROM THE READCORH KEYWORD
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0) GO TO 161
C----------
C  START ORGANON
C
      IF(LORGANON .AND. (IORG(I) .EQ. 1)) THEN
        HTG(I)=SCALE*XHT*HGRO(I)*EXP(HTCON(ISPC))
        IF(DEBUG)WRITE(JOSTND,*)' HTGF ORGANON I,ISP,DBH,HT,HTG,HGRO,',
     &  'SCALE,XHT,HTCON,IORG= ',I,ISP(I),DBH(I),HT(I),HTG(I),HGRO(I),
     &  SCALE,XHT,HTCON(ISPC),IORG(I)
        GO TO 161
      ENDIF
C
C  END ORGANON
C----------
      H=HT(I)
      AGP10 = 0.0
      HGUESS = 0.0
C
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      D2 = 0.0
      DGLT=DG(I)

C BEGIN PROCESSING SPECIES
C DETERMINE HTG CALCULATION METHOD BASED ON SPECIES
      SELECT CASE(ISPC)

C BRANCH FOR RW AND GS
        CASE(23,50)

C--------
C  CALCULATE HTG FOR REDWOOD AND GIANT SEQUIOA USING THE FOLLOWING
C  FUNCTIONAL FORM
C
C  HI = EXP(X)
C  X = B1 + D1^2 + LOG(D1) + LOG(SI) + LOG(DGLT) + LOG(H)
C
C  WHERE
C  HI = ANNUAL HEIGHT INCREMENT
C  D1 = DIAMETER AT BREAST HEIGHT
C  SI = SITE INDEX (BASE AGE 50)
C  DGLT = 10-YEAR OUTSIDE BARK DIAMETER GROWTH
C  H = TOTAL TREE HEIGHT
C--------

C SCALE DGLT TO 10 YEAR DIAMETER GROWTH
          DGLT = DGLT * 2.0

C CONVERT DGLT TO OUTSIDE BARK DIAMETER GROWTH
          BRAT = BRATIO(ISPC,D1,H)
          DG10 = DGLT/BRAT

C APPLY CONSTRAINTS IF H OF INCOMING TREE IS LESS THAN 4.5 FT
C HERE DG10 IS ASSUMED TO BE 0.1
          IF(H .LT. 4.5) DG10=0.1

          IF(DEBUG)WRITE(JOSTND,*)' IN HTGF - RW/GS DEBUG',' I=',I,
     &    ' ISPC=',ISPC,' D=',D1,' BRAT=',BRAT,' DGLT=', DGLT,
     &    ' DG10=',DG10

          LTHTG=EXP(1.412947 - 0.000204*D1**2 + 0.31971*LOG(D1) +
     &    0.394005*LOG(SINDX) + 0.399888*LOG(DG10) - 0.451708*LOG(H))
     
C SCALE LTHTG TO 5 YEARS
          LTHTG =LTHTG * 0.5

C BOUND HEIGHT GROWTH BASED ON THE HEIGHT OF RECORD. BOUNDING IS
C APPLIED TO AVOID HAVING TREES REACH UNREALISTIC HEIGHTS.THE HEIGHT
C GROWTH BOUNDING FUNCTION PROPORTIONALLY ADJUSTS HEIGHT GROWTH VALUES
C SO HEIGHTS OF A RECORD WILL EVENTUALLY CONVERGE TO THE UPPER HEIGHT
C BOUNDING VALUE. LOWER BOUNDING VALUE (217 FT) IS BASED ON MAXIMUM TREE
C HEIGHT FOUND IN THE DATASET USED TO FIT THE RW HEIGHT GROWTH EQUATION.
C UPPER BOUNDING VALUE FOUND IN THE DATASET IS BASED ON CURRENT HEIGHT
C MAXIMUM FOUND IN NATURE: HYPERION REDWOOD (~380 FT).
C 
C BOUNDING LOGIC:
C 1) IF HT IS BETWEEN 217 FT AND 380 FT, THEN HEIGHT GROWTH IS
C    BOUND.
C 2) IF THE HT IS BELOW 217 FT THEN HEIGHT GROWTH IS NOT
C    BOUND.
C 3) IF THE HT IS ABOVE 380 FT, THEN HEIGHT GROWTH BOUNDING
C    VALUE IS SET TO 0.1.
          IF(H .GE. 217.0 .AND. H .LT. 380.0) THEN
            HGBND= 1.0 - ((H - 217.0)/(380.0 - 217.0))
            IF(HGBND .LT. 0.1) HGBND=0.1
          ELSEIF (H .LT. 217.0) THEN
            HGBND=1.0
          ELSE
            HGBND=0.1
          ENDIF

          IF(DEBUG)WRITE(JOSTND,*)'IN HTGF - RW/GS DEBUG',' H=',H,
     &    ' HGBND=',HGBND,' LTHTG=',LTHTG

          HTG(I)=LTHTG * HGBND

C DEBUG
          IF(DEBUG)WRITE(JOSTND,*)'IN HTGF - RW/GS DEBUG',' D=', D1,
     &    ' H=',H,' SI=',SINDX,' DG10=', DG10,' HTG5YR=',HTG(I)

C  BEGIN PROCESSING OF ALL OTHER SPECIES IN CA
        CASE DEFAULT
          CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &    DEBUG)
C
C----------
C  NORMAL HEIGHT INCREMENT CALCULATON BASED ON INCOMMING TREE AGE
C  FIRST CHECK FOR MAX, ASMYPTOTIC HEIGHT
C----------
          IF (SITAGE .GT. AGMAX) THEN
            POTHTG = 0.10
            GO TO 1320
          ELSE
            AGP10= SITAGE + 5.0
          ENDIF
C----------
C R5 USE DUNNING/LEVITAN SITE CURVE.
C R6 USE VARIOUS SPECIES SITE CURVES.
C SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
C SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
C----------
          CALL HTCALC(IFOR,SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
C
          POTHTG= HGUESS - SITHT
C
          IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AGP10,HGUESS,H
91200     FORMAT(' IN GUESS AN AGE--I,ISPC,AGEP10,HGUESS,H ',2I5,3F10.2)
C----------
C ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
C----------
 1320     CONTINUE
          XMOD=1.0
          CRATIO=ICR(I)/100.0
          RELHT=H/AVH
          IF(RELHT .GT. 1.0)RELHT=1.0
          IF(PCCF(ITRE(I)) .LT. 100.0)RELHT=1.0
C--------
C  THE TREE HEIGHT GROWTH MODIFIER (SMHMOD) IS BASED ON THE RITCHIE &
C  HANN WORK (FOR.ECOL.&MGMT. 1986. 15:135-145).  THE ORIGINAL COEFF.
C  (1.117148) IS CHANGED TO 1.016605 TO MAKE THE SMALL TREE HEIGHTS
C  CLOSE TO THE SITE INDEX CURVE.  THE MODIFIER HAS TWO PARTS, ONE
C  (CRMOD) FOR TREE VIGOR USING CROWN RATIO AS A SURROGATE; OTHER
C  (RHMOD) FOR COMPETITION FROM NEIGHBORING TREES USING RELATIVE TREE
C  HEIGHT AS A SURROGATE.
C----------
          CRMOD=(1.0-EXP(-4.26558*CRATIO))
          RHMOD=(EXP(2.54119*(RELHT**0.250537-1.0)))
          XMOD= 1.016605*CRMOD*RHMOD
          HTG(I) = POTHTG * XMOD
C
          IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I),
     &    POTHTG,AVH,HTG(I),DBH(I),RMAI,HGUESS,AGP10,XMOD,ABIRTH(I)
  901     FORMAT(' HTGF',I5,14F9.2)
      END SELECT

C  ENFORCE MINIMUM HEIGHT GROWTH
      IF(HTG(I) .LT. 0.1) HTG(I)=0.1
C----------
C  HTG IS MULTIPLIED BY SCALE TO CHANGE FROM A YR  PERIOD TO FINT AND
C  MULTIPLIED BY XHT AND HTCON TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
C
      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,DBH,DG,H,HTG,SCALE,XHT,HTCON= ',
     &I,ISPC,DBH(I),DG(I),H,HTG(I),SCALE,XHT,HTCON(ISPC)
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
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
C
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC
C  CONTAINS HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT
C  DEPENDENT COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2
C  CONTAINS HABITAT DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED
C  TERM, AND HGHC CONTAINS SPECIES DEPENDENT INTERCEPTS.  HABITAT
C  TYPE IS INDEXED BY ITYPE (SEE /PLOT/ COMMON AREA).
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
      RETURN
      END
