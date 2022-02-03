      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C BM $Id: ccfcal.f 2472 2018-08-20 21:22:34Z gedixon $
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, PRTRLS, SSTAGE, AND CVCW.
C
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
C             NOT USED ANY MORE; CROWN WIDTHS COMPUTED WITH SUBROUTINES
C             CWIDTH AND CWCALC
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DEFINITIONS:
C
C     CCF COEFFICIENTS FOR TREES THAT ARE GREATER THAN 10.0 IN. DBH:
C      RD1 -- CONSTANT TERM IN CROWN COMPETITION FACTOR EQUATION,
C             SUBSCRIPTED BY SPECIES
C      RD2 -- COEFFICIENT FOR SUM OF DIAMETERS TERM IN CROWN
C             COMPETITION FACTOR EQUATION,SUBSCRIPTED BY SPECIES
C      RD3 -- COEFFICIENT FOR SUM OF DIAMETER SQUARED TERM IN
C             CROWN COMPETITION EQUATION, SUBSCRIPTED BY SPECIES
C
C     CCF COEFFICIENTS FOR TREES THAT ARE LESS THAN 10.0 IN. DBH:
C      RDA -- MULTIPLIER.
C      RDB -- EXPONENT.  CCF(I) = RDA*DBH**RDB
C
C  CCF EQUATIONS DERIVED FROM PAINE AND HANN ORE STATE UNIV RP46
C
C----------
C  SPECIES ORDER:
C   1=WP,  2=WL,  3=DF,  4=GF,  5=MH,  6=WJ,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=WB, 12=LM, 13=PY, 14=YC, 15=AS, 16=CW,
C  17=OS, 18=OH
C
C  SPECIES EXPANSION:
C  WJ USES SO JU (ORIGINALLY FROM UT VARIANT; REALLY PP FROM CR VARIANT)
C  WB USES SO WB (ORIGINALLY FROM TT VARIANT)
C  LM USES UT LM
C  PY USES SO PY (ORIGINALLY FROM WC VARIANT)
C  YC USES WC YC
C  AS USES SO AS (ORIGINALLY FROM UT VARIANT)
C  CW USES SO CW (ORIGINALLY FROM WC VARIANT)
C  OS USES BM PP BARK COEFFICIENT
C  OH USES SO OH (ORIGINALLY FROM WC VARIANT)
C----------
C
C  SOURCES OF COEFFICIENTS:
C     1 = PAINE AND HANN TABLE 2: WESTERN WHITE PINE
C     2 = PAINE AND HANN TABLE 2: SUGAR PINE
C     3 = PAINE AND HANN TABLE 2: DOUGLAS-FIR
C     4 = PAINE AND HANN TABLE 2: WHITE/GRAND FIR
C     5 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: PONDEROSA PINE 
C     6 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C     7 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE 
C     8 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: ENGELMANN SPRUCE
C     9 = PAINE AND HANN TABLE 2: RED FIR
C    10 = PAINE AND HANN TABLE 2: PONDEROSA PINE
C    11 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE 
C    12 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE 
C    13 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    14 = PAINE AND HANN TABLE 2: INCENSE CEDAR
C    15 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    16 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    17 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    18 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C
C      PAINE AND HANN, 1982. MAXIMUM CROWN WIDTH EQUATIONS FOR
C        SOUTHWESTERN OREGON TREE SPECIES. RES PAP 46, FOR RES LAB
C        SCH FOR, OSU, CORVALLIS. 20PP.
C
C      WYKOFF, CROOKSTON, STAGE, 1982. USER'S GUIDE TO THE STAND
C        PROGNOSIS MODEL. GEN TECH REP INT-133. OGDEN, UT:
C        INTERMOUNTAIN FOREST AND RANGE EXP STN. 112P.
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL LDANUW,LTHIN
C
      INTEGER IDANUW,ISPC,JCR,MODE
C
      REAL CCFT,CRWDTH,D,H,P,RDANUW
      REAL RD1(MAXSP),RD2(MAXSP),RD3(MAXSP),RDA(MAXSP),RDB(MAXSP)
C
C----------
C  DATA STATEMENTS:
C----------
      DATA RD1/
     &  .0186,  .0392,  .0388,  .0690,    .03,
     & .01925, .01925,    .03,  .0172,  .0219, 
     & .01925, .01925,  .0204,  .0194,    .03,
     &  .0204,  .0219,  .0204/
C
      DATA RD2/
     &  .0146,  .0180,  .0269,  .0225,   .018,
     & .01676, .01676,  .0173, .00877,  .0169,
     & .01676, .01676,  .0246,  .0142,  .0238,
     &  .0246,  .0169,  .0246/
C
      DATA RD3/
     & .00288, .00207, .00466, .00183, .00281,
     & .00365, .00365, .00259, .00112, .00325,
     & .00365, .00365,  .0074, .00261, .00490,
     &  .0074, .00325,  .0074/
C
      DATA RDA/
     & 0.009884, 0.007244, 0.017299, 0.015248, 0.011109,
     & 0.009187, 0.009187, 0.007875, 0.011402, 0.007813,
     & 0.009187, 0.009187,      0.0,      0.0, 0.008915,
     &      0.0, 0.007813,      0.0/
C
      DATA RDB/
     &   1.6667,  1.8182,  1.5571,  1.7333,  1.7250,
     &   1.7600,  1.7600,  1.7360,  1.7560,  1.7780,
     &   1.7600,  1.7600,     0.0,     0.0,  1.7800,
     &      0.0,  1.7780,     0.0/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = H
      IDANUW = JCR
      LDANUW = LTHIN
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
C----------
C  COMPUTE CCF
C----------
      IF(MODE.EQ.1 .OR. ISPC.EQ.6 .OR. ISPC.EQ.12 .OR. ISPC.EQ.15) THEN
C      
        SELECT CASE (ISPC)
C----------
C  ORIGINAL BM VARIANT SPECIES
C  UT VARIANT SPECIES
C  TT VARIANT SPECIES
C----------
        CASE(1:12,15,17)
          IF (D .GE. 1.0) THEN
            CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
          ELSE IF(D.GT.0.1) THEN
            CCFT = RDA(ISPC) * (D**RDB(ISPC))
          ELSE
            CCFT=0.001
          ENDIF
          CCFT = P * CCFT
C----------
C  WC VARIANT SPECIES
C----------
        CASE(13,14,16,18)
          IF (D .LT. 1.0) THEN
            CCFT = D * (RD1(ISPC)+RD2(ISPC)+RD3(ISPC))
          ELSE
            CCFT = RD1(ISPC) + RD2(ISPC)*D + RD3(ISPC)*D**2.0
          ENDIF
          CCFT = CCFT * P
        END SELECT
      ENDIF
C----------
C  COMPUTE CROWN WIDTH. (NOT USED ANY MORE; REPLACED BY CWCALC)
C----------
      IF(MODE.EQ.2) THEN
        CRWDTH = 0.
C
C        SELECT CASE (ISPC)
C        CASE(1:5,7:11,13:15,17:18)
C          CALL R6CRWD (ISPC,D,H,CRWDTH)
C        CASE(6,12,16)
C          CRWDTH = SQRT(CCFT/0.001803)
C        END SELECT
C        IF(CRWDTH .GT. 99.9) CRWDTH=99.9
C
      ENDIF
C
      RETURN
      END
