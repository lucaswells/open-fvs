      SUBROUTINE MPBMOD
      IMPLICIT NONE
C----------
C LPMPB $Id: mpbmod.f 2450 2018-07-11 17:28:41Z gedixon $
C----------
C
C     MOUNTAIN PINE BEETLE POPULATION DYNAMICS SIMULATOR
C
C     BOB ROELKE; PROGRAMMER
C     DON BURNELL; BOSS MAN
C     NICK CROOKSTON; INTERFACE PROGRAMMER
C
C Revision History
C   02/18/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C   08/22/14 Lance R. David (FMSC)
C     Function name was used as variable name.
C     changed variable INT to INCRS
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'MPBCOM.F77'
C
C
COMMONS
C
      CHARACTER*1 IC1,IC2,IC22,IC3,IC4,IC5,IC6,IC7,ICBLK
      DOUBLE PRECISION BETIN, XX, PIODEN, DTA, DSMTA
      INTEGER  INC, INC1, KK,
     &         I, IB, ICALYR, IG, IP, LASTYR, NINC, NTRY

      REAL ADEN, AMPAVE, APD, B1INC, B3ALL, B3INC, BATK, BATKI,
     &     BNEW, BYINC, BYT, E1, E2, E3, EARAT, EDEN, EF3, EFFS,
     &     EGGS, FMX, GEX, GFML1, GFML2, GFML3, GTEB, PCTGEM,
     &     PCTGEX, PCTGF1, PCTGF2, PCTGF3, PCTGSV, PSE1, PSE3,
     &     PSPE1, PSPE3, PSURV, RHO1, RHO2, RHO3, SKILL, SS,
     &     TAGG, TMMPB, TRKILL, XEG, XXG, YOUNG,
     &     AYEAR, BY, EMERG, OS, P, PERCNT, PMSLP, Q, RESIST,
     &     SEXRAT, SQFTPA, SSCUM, TA, TAFIT, TB1, TE1

      REAL   DIAM(30),TREES(30),AGG(30,15),AD(15),PHLOEM(30),
     &       B0(3), B1(3), B2(3), B3(3), B3SUM(3),  EXODUS(3),
     &       BOLD(3), FM1(3), FM2(3), FM3(3), TEB(3),
     &       ANEX(3), EXLOSS(3), ANFML1(3), ANFML2(3), ANFML3(3),
     &       PCTTEB(3),PCTEX(3),PCTFM1(3),PCTFM2(3),PCTFM3(3),PCTSV(3),
     &       FML1(3), FML2(3), FML3(3), GENO(3),
     &       PX(10),TM(30),TKYR(30),
     &       SAK(3), TATRY(3), SEXDBH(30), AMP(15), PGRX(5), TAY(5)
 
      LOGICAL LGO, PASS1

      EQUIVALENCE (CLASS(1,2),DIAM(1)), (CLASS(1,3),PHLOEM(1))

      DATA PGRX /.0,.7,1.,1.3,1.5/, TAY /2.0,2.1,2.4,2.7,3.0/

      DATA IB/1/,SEXRAT/.66/,SQFTPA/43560./,IC1/'*'/,IC2/'$'/,
     >     IC22/'B'/,IC3/'D'/,IC4/'A'/,IC5/'E'/,IC6/'X'/,IC7/'P'/,
     >     ICBLK/' '/
C
C
C     SURF  = SURFACE AREA OF EACH TREE
C     AMP   = AMPLITUDE MULTIPLIER FOR AGGREGATING TREES
C     IBACK = PHERMONE EFFECTIVENESS (NUM OF TIME INTERVALS)
C     PWR   = NO LONGER USED
C     CE    = EXODUS CONSTANT
C     CF1   = CONSTANT FOR FLIGHT MORTALITY OF GENOTYPE ONE
C     CF2   = CONSTANT FOR FLIGHT MORTALITY OF GENOTYPE TWO
C     CF3   = CONSTANT FOR FLIGHT MORTALITY OF GENOTYPE THREE
C     TA    = THRESHOLD OF AGGREGATION
C     DST   = DISTANCE EACH GENOTYPE CAN FLY
C     EXCON = STAND SIZE IN ACRES
C     ACTSRF= ACTUAL SURFACE AREA KILLED IN A REAL OUTBREAK
C     SNOHST= SURFACE AREA OF ALL NON-HOST TREES
C     CRITAD= CRITICAL ATTACK DENSITY. 1.5 BEETLES/SQ FT.
C     NG    = NUMBER OF GENOTYPES
C     MPMXYR= MAX NUMBER OF EPIDEMIC YEARS
C     INCRS = NUM OF EMERGENCE INCREMENTS
C     NACLAS= NUM OF TREE CLASSES, (PREVIOUSLY CALLED N)
C
C     STRBUG= INITIAL BEETLES AS DEFINED BY USER.
C     BY    = NUMBER OF BEETLES PER ACRE
C     HS    = HABITAT SUITABILITY CLASSES ONE FOR EACH
C             RESISTANCE CLASS
C     P     = PROBABILITY OF SELECTING GENOTYPE ONE
C     IPLTNO= PLOT NUMBER FOR GRAPHICS PACKAGE
C     MPBYR = EPIDEMIC YEAR; ALSO USED TO SIGNAL RE-ENTRY
C     ICALYR= CALENDAR YEAR OF EPIDEMIC
C     TM    = TOTAL TREES PER ACRE KILLED ( CUM )
C     TKYR  = NUMBER OF TREES/ACRE KILLLED THIS YEAR
C     MPBGRF= TRUE IF GRAPHICS HAVE BEEN REQUESTED
C     LASTYR= NUMBER OR YEARS MODEL HAS RUN UPON THIS ENTRY
C     SQFTPA= NUMBER SQUARE FEET PER ACRE
C     SEXDBH= PROPORTION FEMALES BY DBH CLASS
C     LAGG  = TRUE IF AGGREGATION PHERMONE IS PRESENT
C     LPS   = TRUE IF PREVENTITIVE SPRAY IS APPLIED
C     LREP  = TRUE IF REPELLING PHERMONE IS PRESENT
C     LDC   = TRUE IF DIRECT CONTROL IS TO BE APPLIED
C     AGGPH = PROPORTIONATE EFFECT OF AGGREGATION PHERM.
C     PSPK  = PROPORTION BEETLES KILLED BY PREVENTITIVE SPRAY
C     PSE3  = EFFECTIVE SURFACE OF PREVENT. SPRAYED TREES
C     PSDL  = PREV. SPRAY DIAMETER LIMITS
C     PSPF  = PROPORTION OF TREES ABOVE 'PSDL' WHICH WERE
C             REALLY SPRAYED
C     REPL  = PROPORTIONATE EFFECT OF REPELLING PHERM.
C     DCPF  = PROPORTION OF ATTACKED TREES REALLY DIR. CONT.
C     DCPK  = PROPORTION OF BEETLES KILLED BY DIR. CONT.
C
C     **********  EXECUTION BEGINS  **********
C
      SSCUM = SADLPP
      IF ( MPBYR .GT. 0 ) GO TO 25
C
C     -- BRANCH TO RE-ENTRY POINT IF THIS IS NOT THE INITIAL CALL
C
      LGO = .TRUE.
      PASS1 = .TRUE.
      IF (NEPIYR .LE. 0) GO TO 5
C
C     *** PARTIAL EPIDEMIC IS IN EFFECT ***
C
      TAMID = (TAMIN + TAMAX)/2.
      NTRY = 1
C
C     ** TURN OFF GRAPHICS AND REGULAR OUTPUT
C
      SAVGRF = MPBGRF
      MPBGRF = .FALSE.
      LGO = .FALSE.
C
C     ** PRINT SURFACE KILLED IN PARTIAL EPIDEMIC
C
      WRITE (JOMPB,6800) SADLPP
C
    5 CONTINUE
C
C     ** COMPUTE EFFECT OF ELEVATION
C
      IF (ELEV .LE. 0.) ELEV = 63
      EFELEV = 2.62 - 2.70E-2*ELEV
C
C     -- NOTE: ELEVATION IS IN HUNDREDS OF FEET
C
      IF (EFELEV .GT. 1.) EFELEV = 1.
      IF (EFELEV .LT. 0.) EFELEV = 0.
C
C     ** COMPUTE EFFECT OF LATITUDE
C
      EFLAT = 4.667 - 8.333E-2*FORLAT
      IF (EFLAT .LT. 0.) EFLAT = 0.
      IF (EFLAT .GT. 1.5) EFLAT = 1.5
C
      IF (DEBUIN) WRITE (JOMPB,7200) EFELEV, EFLAT
C
C     WRITE INITIAL SWITCH VALUES (DEBUG)
C
      IF ( DEBUIN ) WRITE ( JOMPB,2 )  LAGG,LPS,LDC,LREP,MPBGRF
    2 FORMAT (//,'SWITCHES:   LAGG     LPS     LDC     ',
     >        'LREP    MPBGRF',/,T7,5L8)
C
C     **** BRANCH BACK HERE TO RESTART PARTIAL EPIDEMIC ****
C
    8 CONTINUE
      MPBYR = 0
      BY = STRBUG
      P = STRP
C
C     ** SET MORTALITY TABLE TO ZERO
C
      DO 10 I = 1,NACLAS
      TM(I) = 0.0
   10 CONTINUE
      DO 15 I=1,NG
      FM1(I)=0.
   15 CONTINUE
C
C     ** SET UP GRAPHS
C
      IF ( .NOT. MPBGRF ) GO TO 25
      CALL PTSYM(IPLTNO,IC1,IC2,IC22,IC3,IC4,IC5,IC6,IC7,ICBLK,ICBLK)
      CALL PTGRP ( IPLTNO, 2, 10, 0., 0.)
      CALL PTGRP ( IPLTNO, 1, 10, 0., 0.)
      CALL PTGRP ( IPLTNO, 1, 10, 0., 0.)
      CALL PTGRP ( IPLTNO, 2, 11, 0., 40.)
      IF (NG .EQ. 1) CALL PTGRP ( IPLTNO, 1, 11, 0., 1.)
      IF (NG .GT. 1) CALL PTGRP ( IPLTNO, 2, 11, 0., 1.)
C
C     ** INITIALIZE PLOT VARIABLES
C
      DO 20 IP = 1,10
      PX(IP) = 0.
   20 CONTINUE
      PX(3) = BY
      PX(7) = SEXRAT
      PX(8) = P
      AYEAR = IY(ICYC)
      CALL PTINT( IPLTNO, 0, AYEAR, PX)
C
C      **  BRANCH IN HERE UPON RE-ENTRY OF EPIDEMIC IN PROGRESS  **
C
   25 CONTINUE
      NINC = INCRS+1
      LASTYR = MPBYR - 1
      IF (LASTYR .LT. 0.) LASTYR = 0.
C
C
C     ** DISTRIBUTE TREES INTO RESISTANCE CLASSES,
C
      OS = 0.
C
      IF (.NOT. PASS1) GO TO 29
C
C     -- RESISTANCE CALCULATED ON FIRST PASS ONLY
C
      TA=TAFAC
      IF (.NOT.LCRES) GOTO 26
      RESIST=PMSLP(PGR,PGRX,TAY,5)
      TA=RESIST
      IF (RESIST .LT. TAMIN) TA = TAMIN
      IF (RESIST .GT. TAMAX) TA = TAMAX
   26 CONTINUE
      WRITE (JOMPB,6900) PGR, RESIST, TA
C
   29 CONTINUE
      DO 40 I = 1,NACLAS
      TREES(I) = CLASS (I,IMPROB)
C
      SEXDBH(I) = .918 - .0168*DIAM(I)
      EFPHLM(I) = 16.67*PHLOEM(I) - .667
      IF (EFPHLM(I) .LT. 0.) EFPHLM(I) = 0.
      OS = OS + SURF(I)*TREES(I)
   40 CONTINUE
      IF (LGO) OS=OS+SADLPP
C
      IF (DEBUIN) WRITE (JOMPB,7000) (PHLOEM(I), I=1,NACLAS)
      IF (DEBUIN) WRITE (JOMPB,7100) (EFPHLM(I), I=1,NACLAS)
      IF (DEBUIN) WRITE (JOMPB,7250) (SEXDBH(I), I=1,NACLAS)
C
C     ** COMPUTE CONSTANT EXODUS RATE
C
      DO 50 IG = 1,NG
      EXODUS(IG) = (1. - EXP(-CE*DST(IG)*DST(IG)/(EXCON*SQFTPA)))
   50 CONTINUE
C
C     ** WRITE INITIAL SURFACE AREAS & MORTALITY RATES
C
      IF (.NOT. (LGO .OR. DEBUIN)) GO TO 55
      IF ( MPBYR .GT. 0 ) WRITE (JOMPB,4950)
      WRITE (JOMPB,5000) (DIAM(I),I=1,NACLAS)
      WRITE(JOMPB,6000) (SURF(I),I = 1,NACLAS)
      WRITE(JOMPB,6030) (TREES(I),I=1,NACLAS)
C
      IF ( .NOT. DEBUIN ) GO TO 55
C
      WRITE(JOMPB,6100) (IG, EXODUS(IG), IG, FM1(IG), IG=1,NG)
      IF (NG .GT. 1) WRITE(JOMPB,6130)
C
C     *****  BEGIN ANNUAL LOOP  *****
C
   55 CONTINUE
      ICALYR = IY(ICYC) + MPBYR - LASTYR
      MPBYR = MPBYR + 1
      TB1 = 0.0
      TE1 = 0.0
      DO 60 IG = 1,NG
      BOLD(IG) = 0.
      B3SUM(IG) = 0.
      ANEX(IG) = 0.
      ANFML1(IG) = 0.
      ANFML2(IG) = 0.
      ANFML3(IG) = 0.
   60 CONTINUE
C
C     ZERO OUT ARRAY OF TREES KILLED THIS YEAR
C
      DO 65 I=1,NACLAS
      TKYR(I) = 0.0
   65 CONTINUE
C
C     **COMPUTE GENOTYPE RATIOS
C
      Q = 1. - P
      IF (NG .NE. 3) GO TO 70
      GENO(1) = P*P
      GENO(2) = 2.*P*Q
      GENO(3) = Q*Q
      GO TO 80
   70 CONTINUE
C
      GENO(1) = P
      GENO(2) = Q
   80 CONTINUE
C
C      SIMULATE THE EFFECT OF AGGREGATION PHERMONE
C      (TO SIMULATE IMMIGRATION, CODE AN ADDITIVE FUNCTION)
C
      IF (LAGG) BY = BY + BY * AGGPH(MPBYR)
C
C     ** SAVE TOTAL EMERGING BEETLES FOR PRINTOUT
C
      GTEB = BY
      DO 90 IG = 1,NG
      TEB(IG) = BY*GENO(IG)
   90 CONTINUE
C
      IF ((MPBYR .EQ. 1 .AND. LGO) .OR. DEBUIN) WRITE(JOMPB,6140)
      IF ( DEBUIN ) WRITE ( JOMPB,6150 )
C
C     ***  BEGIN EMERGENCE LOOP  ***
C
      DO 220 INC = 1,NINC
      INC1 = INC - 1
C
C     ** COMPUTE SURFACE AREA OF LIVE TREES (E1)
C
      PSE1 = 0.0
      E1 = 0.0
      DO 110 I = 1,NACLAS
      E1 = E1 + SURF(I)*TREES(I)
C
C     PREVENTITIVE SPRAY SURFACE (PSE1)
C
      IF (LPS .AND. DIAM(I) .GE. PSDL(MPBYR))
     >      PSE1 = PSE1 + SURF(I) * TREES(I) * PSPF(MPBYR)
  110 CONTINUE
C
C     ** COMPUTE SURFACE AREA AND DENSITY OF AGGREGATING TREES (E3)
C
      PSE3 = 0.0
      E3 = 0.
      EF3 = 0.
      TAGG = 0.
      AMP(INC) = 0.
      IF (INC .LE. 1)  GO TO 150
      DO 140 KK = IB,INC1
C
C     ** COMPUTE AMPLIFIER
C
      AMP(KK) = AMP1 - AMP2*AD(KK)*(1. - SEXRAT)
      IF (AMP(KK) .LT. 0.) AMP(KK) = 0.
C
      DO 130 I = 1,NACLAS
      TAGG = TAGG + AGG(I,KK)
      E3 = E3 + SURF(I)*AGG(I,KK)
      EF3 = EF3 + SURF(I)*AGG(I,KK)*AMP(KK)
C
C     PREVENTITIVE SPRAY SURFACE (PSE3)
C
      IF (LPS .AND. DIAM(I) .GE. PSDL(MPBYR))
     >      PSE3 = PSE3 + SURF(I) * AGG(I,KK) * PSPF(MPBYR)
  130 CONTINUE
  140 CONTINUE
  150 CONTINUE
C
C     COMPUTE DENSITY OF LIVE TREES
C
      RHO1 = 0.
      DO 151 I=1,NACLAS
      RHO1=RHO1+TREES(I)
  151 CONTINUE
C
C     ** COMPUTE AVERAGE AMPLITUDE
C
      AMPAVE = 0.
      IF (E3 .GT. 0.) AMPAVE = EF3/E3
C
C     COMPUTE PROPORTION OF E1 AND E3 SURFACE SPRAYED WITH
C     PREVENTITIVE SPRAY
C
      IF ( .NOT. LPS ) GO TO 152
      PSPE1 = 1.0
      PSPE3 = 1.0
      IF (E1 .GT. 1.E-30) PSPE1 = PSE1/E1
      IF (E3 .GT. 1.E-30) PSPE3 = PSE3/E3
  152 CONTINUE
C
C     ** COMPUTE SURFACE OF DEAD & POST-AGGREGATING TREES (E2)
C
      E2 = OS - (E1 + E3) + SNOHST
C
C     ** COMPUTE EFFECTIVE SURFACE AREA
C
      EFFS = E1 + E2 + EF3
C
C     ** CALCULATE RHO1, RHO2, AND RHO3 IN TREES PER SQUARE FOOT
C
      RHO3 = TAGG/SQFTPA
      RHO2 = TPROB - TAGG - RHO1
      IF (RHO2.LE.0.0) RHO2=0.0
      RHO2 = RHO2 / SQFTPA
      RHO1 = RHO1 / SQFTPA
C
C     ** EMERGENCE THIS INC
C
      BNEW = EMERG(BY,INC1,INCRS)
C
C     ** GENOTYPE LOOP **
C
      B1INC = 0.
      B3INC = 0.
      DO 160 IG = 1,NG
C
C     ** DIVIDE INTO GENOTYPES AND ADD IN LEFTOVERS FROM LAST INC
C
      B0(IG) = GENO(IG)*BNEW + BOLD(IG)
C
C     ** COMPUTE EXODUS FROM STAND
C
      EXLOSS(IG) = B0(IG)*EXODUS(IG)
C
C     SIMULATE THE EFFECT OF REPELLING PHERMONE
C
      IF (LREP) EXLOSS(IG) = EXLOSS(IG) + EXLOSS(IG) * REPL(MPBYR)
      B0(IG) = B0(IG) - EXLOSS(IG)
C
C     ** SPLIT OFF BEETLES
C
      B1(IG) = B0(IG)*E1/EFFS
      B2(IG) = B0(IG)*E2/EFFS
      B3(IG) = B0(IG)*EF3/EFFS
C
C     ** COMPUTE FLIGHT MORTALITY ATES FOR BEETLES FLYING TO:
C     1-LIVE, 2-DEAD & NON-HOST, AND 3-AGGREGATING SURFACE
C
      FM1(IG) = 0.0
      FMX = -CF1*2.*SQRT(RHO1)*DST(IG)*DST(IG)/DST(1)
      IF (FMX.GT. -80.0) FM1(IG) = EXP(FMX)
      FM2(IG) = 0.0
      FMX = -CF2*2.*SQRT(RHO2)*DST(IG)*DST(IG)/DST(1)
      IF (FMX.GT. -80.0) FM2(IG) = EXP(FMX)
      FM3(IG) = 0.0
      FMX = -CF3*2.*SQRT(RHO3)*DST(IG)*DST(IG)/DST(1)
      IF (FMX.GT. -80.0) FM3(IG) = EXP(FMX)
C
C     ** COMPUTE FLIGHT LOSSES
C
      FML1(IG) = B1(IG)*FM1(IG)
      FML2(IG) = B2(IG)*FM2(IG)
      FML3(IG) = B3(IG)*FM3(IG)
C
C     ** COMPUTE SURVIVAL AFTER FLIGHT
C
      B1(IG) = B1(IG)- FML1(IG)
      B2(IG) = B2(IG)- FML2(IG)
      B3(IG) = B3(IG)- FML3(IG)
C
      IF ( .NOT. LPS ) GO TO 155
      B1(IG) = B1(IG) * (1-PSPE1*PSPK(MPBYR))
      B3(IG) = B3(IG) * (1-PSPE3*PSPK(MPBYR))
  155 CONTINUE
C
C     ** B1 & B2 BEETLES GET TO TRY AGAIN NEXT INC
C
      BOLD(IG) = B1(IG) + B2(IG)
C
C     ** KEEP SUMS
C
      B1INC = B1INC + B1(IG)
      B3INC = B3INC + B3(IG)
      B3SUM(IG) = B3SUM(IG) + B3(IG)
      ANEX(IG) = ANEX(IG) + EXLOSS(IG)
      ANFML1(IG) = ANFML1(IG) + FML1(IG)
      ANFML2(IG) = ANFML2(IG) + FML2(IG)
      ANFML3(IG) = ANFML3(IG) + FML3(IG)
  160 CONTINUE
C
C     ** COMPUTE PIONEER DENSITY
C
      PIODEN = B1INC/E1
C
C     ** COMPUTE PROBABILITY OF AT LEAST 1 ATTACK/SQ FT
C
      XX = 1D0 - DEXP(-PIODEN)
C
C     ** COMPUTE NO. OF AGGREGATORS
C
      DO 180 I = 1,NACLAS
      AGG(I,INC) = 0.
      DTA = TA
      DSMTA = SURF(I) - DTA + 1.
      IF (XX .NE. 0D0 .AND. DSMTA .GT. 0D0 )
     :   AGG(I,INC) = TREES(I)*BETIN(DTA, DSMTA, XX)
C
C        -- REMEMBER THAT BETIN REQUIRES DOUBLE PRECISION ARGUMENTS.
C
C     ** REMOVE AGGREGATORS FROM TREE POOL **
C
      TREES(I) = TREES(I) - AGG(I,INC)
  180 CONTINUE
C
C     ** COMPUTE ATTACK DENSITY
C
      AD(INC) = 0.0
      IF (EF3 .LE. 0.)  GO TO 200
      DO 190 KK = IB,INC1
      AD(KK) = AD(KK) + AMP(KK)*B3INC/EF3
  190 CONTINUE
  200 CONTINUE
C
C     ** ACCUMULATE TOTALS
C
      DO 210 IG = 1,NG
      TB1 = TB1 + B1(IG)
  210 CONTINUE
      TE1 = TE1 + E1

  220 CONTINUE
C
C     *****  END OF EMERGENCE LOOP  *****
C
      SS = 0.
      BATK = 0.
      BY = 0.
      BYT = 0.
      AYEAR = ICALYR
C
C     ***  PRODUCTIVITY LOOP  ***
C
      DO 280 INC = 1,NINC
C
C     ** COMPUTE NUMBER OF EGGS LAID PER SQUARE FOOT
C
      XEG = 0.0
      XXG = -.117*AD(INC)
      IF (XXG.GT. -80.0) XEG = EXP(XXG)
      EGGS = 630.*(1. - XEG)
C
      DO 270 I = 1,NACLAS
C
C     ** COMPUTE YOUNG SURVIVING TO EMERGENCE
C
      PSURV = 1. - EXP(-AD(INC)*.04328)
      IF(AD(INC).GE.2.595) PSURV = PSURV*6.812*EXP(-1.191*SQRT(AD(INC)))
C
      YOUNG = EGGS*PSURV*EFELEV*EFLAT*EFPHLM(I)
C
      IF (AD(INC) .GE. CRITAD) GO TO 230
C
C     ** STRIP KILL -- PUT BACK IN LIVE TREE POOL  **
C
      TREES(I) = TREES(I) + AGG(I,INC)
      AGG(I,INC) = 0.
      GO TO 240
  230 CONTINUE
C
C     **  COMPUTE TOTAL MORTALITY BY DBH CLASS
C
      TRKILL = AGG(I,INC)
      TKYR(I) = TKYR(I) + TRKILL
      TM(I) = TM(I) + TRKILL
C
C     ** COMPUTE SURFACE KILLED AND NUMBER OF BEETLES ATTACKING
C
      SKILL = SURF(I)*TRKILL
      SS = SS + SKILL
      BATKI = SKILL*AD(INC)
      BATK = BATK + BATKI
C
C     ** COMPUTE ANNUAL PRODUCTIVITY
C
      BYINC = YOUNG*SKILL*HS
      BYT = BYT + BYINC
      BY = BY + BYINC*SEXDBH(I)
  240 CONTINUE
  270 CONTINUE
  280 CONTINUE
C
C     ** COMPUTE AVERAGE SEX RATIO FOR EMERGING BEETLES
C
      IF (BYT .GT. 0.) SEXRAT = BY/BYT
C
C     SIMULATE THE EFFECT OF DIRECT CONTROL
C
      IF (LDC) BY = BY - BY * DCPF(MPBYR) * DCPK(MPBYR)
C
C     ** COMPUTE NEW VALUE OF P
C
      B3ALL = 0.
      DO 290 IG = 1,NG
      B3ALL = B3ALL + B3SUM(IG)
  290 CONTINUE
      IF (B3ALL .EQ. 0.) GO TO 300
      IF (NG .EQ. 3) P = (B3SUM(1) + .5*B3SUM(2))/B3ALL
      IF(NG .NE. 3) P = (B3SUM(1)/B3ALL)**2
  300 CONTINUE
C
C     ** ACCUMULATE KILLED SURFACE
C
      SSCUM = SSCUM + SS
C
C     ** COMPUTE AVERAGE ATTACK, EMERGENCE & PIONEER DENSITIES
C
      ADEN = 0.
      EDEN = 0.
      EARAT = 0.
      IF (SS .LE. 0.) GO TO 310
      ADEN = BATK/SS
      EDEN = BYT/SS
  310 CONTINUE
      IF (BATK .GT. 0.) EARAT = BY/BATK
      APD = TB1/TE1
C
C     ** COMPUTE ANNUAL GRAND TOTALS
C
      GEX = 0.
      GFML1 = 0.
      GFML2 = 0.
      GFML3 = 0.
      DO 320 IG = 1,NG
      GEX = GEX + ANEX(IG)
      GFML1 = GFML1 + ANFML1(IG)
      GFML2 = GFML2 + ANFML2(IG)
      GFML3 = GFML3 + ANFML3(IG)
  320 CONTINUE
C
C     ** COMPUTE % LOSS & SURVIVAL
C
      DO 330 IG = 1,NG
      PCTTEB(IG) = PERCNT(TEB(IG), GTEB)
      PCTEX(IG) = PERCNT(ANEX(IG), TEB(IG))
      PCTFM1(IG) = PERCNT(ANFML1(IG), TEB(IG))
      PCTFM2(IG) = PERCNT(ANFML2(IG), TEB(IG))
      PCTFM3(IG) = PERCNT(ANFML3(IG), TEB(IG))
      PCTSV(IG) = PERCNT(B3SUM(IG), TEB(IG))
  330 CONTINUE
      PCTGEM = PERCNT(GTEB, GTEB)
      PCTGEX = PERCNT(GEX, GTEB)
      PCTGF1 = PERCNT(GFML1, GTEB)
      PCTGF2 = PERCNT(GFML2, GTEB)
      PCTGF3 = PERCNT(GFML3, GTEB)
      PCTGSV = PERCNT(B3ALL, GTEB)
C
C     ** SAVE NEW VALUES FOR PLOT
C
      IF (.NOT. MPBGRF) GO TO 333
      PX(1) = SS
      PX(2) = ACTSRF(MPBYR)
      PX(3) = BY
      PX(4) = APD
      PX(5) = ADEN
      PX(6) = EDEN
      PX(7) = SEXRAT
      PX(8) = P
      CALL PTINT( IPLTNO, NINC, AYEAR, PX)
  333 CONTINUE
C
C     ** WRITE OUTPUT
C
      IF (DEBUIN) WRITE(JOMPB,6250)  ICALYR, (DIAM(I), I=1,NACLAS)
      IF (.NOT. (DEBUIN .OR. LGO)) GO TO 375
      WRITE(JOMPB,6300) ICALYR, (TREES(I), I=1,NACLAS)
      WRITE(JOMPB,6325) ICALYR, (TKYR(I),I=1,NACLAS)
      WRITE(JOMPB,6350) ICALYR, (TM(I),I = 1,NACLAS)
      WRITE(JOMPB,6400)
      IF (NG .LE. 1) GO TO 350
      DO 340 IG = 1,NG
      WRITE(JOMPB,6450) IG, ICALYR, IG, TEB(IG), ANEX(IG), ANFML1(IG),
     :             ANFML2(IG), ANFML3(IG), B3SUM(IG)
  340 CONTINUE
  350 CONTINUE
      WRITE(JOMPB,6500) ICALYR, GTEB, GEX, GFML1, GFML2, GFML3, B3ALL
      IF (NG .LE. 1) GO TO 370
      DO 360 IG = 1,NG
      WRITE(JOMPB,6550) IG, ICALYR, IG, PCTTEB(IG), PCTEX(IG),
     :              PCTFM1(IG), PCTFM2(IG), PCTFM3(IG), PCTSV(IG)
  360 CONTINUE
  370 CONTINUE
      WRITE(JOMPB,6600) ICALYR, PCTGEM, PCTGEX, PCTGF1, PCTGF2, PCTGF3,
     :                   PCTGSV
      WRITE(JOMPB,6650) ICALYR,SS,SSCUM,BY,P,ICALYR,ADEN,EDEN,EARAT,APD
C
  375 CONTINUE
      IF (.NOT. LGO) GO TO 420
C
C     ** UPDATE STAND AND CALCULATE MPBTPAK (TMMPB) FOR EVENT MONITOR
C
      TMMPB=0.0
      DO 380 I = 1,NACLAS
      CLASS(I,IMPROB) = TREES(I)
      TMMPB=TMMPB + TM(I)
  380 CONTINUE
      WRITE(JOMPB,889) TMMPB
  889 FORMAT ('MPBTPAK=',F7.1)
C
C     PASS VAULE OF TMMPB TO EVENT MONITOR
C
      CALL EVSET4 (4,TMMPB)
C
C
C     ** END RUN IF .LT. 1 BEETLE PER ACRE
C     *****  END OF ANNUAL LOOP  *****
C
      IF ( BY .GE. 1.0 .AND. MPBYR .LT. MPMXYR) GO TO 390
      MPBYR = 0
      SADLPP=0.
      RETURN
C
  390 CONTINUE
      IF ( ICALYR .NE. IY(ICYC) + IFINT ) GO TO 55
      IF ( ICYC .LT. NCYC ) GO TO 410
      WRITE (JOMPB,6700)
      GO TO 55
C
  410 CONTINUE
      SADLPP=SSCUM
      WORKIN(ICYC+1) = .TRUE.
      RETURN
C
C     **** PARTIAL EPIDEMIC CONTROL LOGIC ****
C
  420 CONTINUE
      IF (BY .GE. 1. .AND. MPBYR .LT. NEPIYR) GO TO 55
C     -- LOOP FOR ANOTHER YEAR
C
      SAK(NTRY) = SSCUM
      TATRY(NTRY) = TA
C
      IF (NTRY .NE. 1) GO TO 430
C
C     ** END OF FIRST CALIBRATION TRY
C
      TA = TAMIN
      IF (TATRY(1) .LT. (TAMIN + TATOL)) TA = TAMID
      IF (DEBUIN) WRITE (JOMPB,7400) RESIST, TA
      PASS1 = .FALSE.
      NTRY = 2
      GO TO 8
C
C     ** END OF SECOND CALIBRATION TRY
C
  430 CONTINUE
      IF (NTRY .NE. 2) GO TO 440
      TA = TAMAX
      IF (TATRY(1) .GT. (TAMAX - TATOL)) TA = TAMID
      IF (DEBUIN) WRITE (JOMPB,7400) RESIST, TA
      NTRY = 3
      GO TO 8
C
C     ** END OF THIRD CALIBRATION TRY -- GO FOR ACTUAL SIMULATION
C
  440 CONTINUE
      TA = TAFIT(TATRY,SAK)
      IF (DEBUIN) WRITE (JOMPB,7400) RESIST, TA
      LGO = .TRUE.
      MPBGRF = SAVGRF
      GO TO 8
C
 4950 FORMAT (//,40('*'),10X,'STAND HAS BEEN UPDATED',
     >        10X,40('*'),//)
 5000 FORMAT (   T9,'DIAMETER CLASSES',5(T2,'ID',T40,10F9.2,/))
 6000 FORMAT (//,T9,'SURFACE AREA/TREE',5(T2,'IS',T40,10F9.2,/))
 6030 FORMAT (//,T9,'TREES/ACRE',5(T2,'IT',T40,10F9.2,/))
 6100 FORMAT(//,'IE',T9,'EXODUS(',I1,') =',F8.5,
     :       ';  FM1(',I1,') =',F8.5)
 6130 FORMAT(/,'%  **NOTE -- IN THE % LOSS TABLES BELOW, THE',
     :             ' PROPORTION OF THE WHOLE POPULATION REPRESENTED',/,
     :        '%    BY EACH GENOTYPE IS GIVEN IN THE ''EMERGENCE''',
     :        ' COLUMN.  ALL OTHER VALUES ARE % WITHIN A GENOTYPE.')
 6140 FORMAT (//,'   YEAR ')
 6150 FORMAT('         INC   PIONEER     EFFECTIVE   LIVE (E1)   ',
     :       'DEAD AND    AGG. (E3)  AMPLITUDE     # AGG.     RHO3',
     :       '      FM3''S:',/,
     :  16X,'DENSITY',2('     SURFACE'),'   NON-HOST SUR  SURFACE',/)
 6250 FORMAT (//,T3,I5,T10, 'DIAMETER CLASSES',5(T2,'DC',T40,
     >        10F9.2,/))
 6300 FORMAT (//,T3,I5,T10, 'SURVIVING TREES/ACRE',5(T2,'ST',T40,
     >        10F9.2,/))
 6325 FORMAT (//,T3,I5,T10, 'T/A KILLED THIS YEAR',5(T2,'TK',T40,
     >        10F9.2,/))
 6350 FORMAT ('0',T4,I5,T10, 'CUMULATIVE MORTALITY',5(T2,'CM',T40,
     >        10F9.2,/))
 6400 FORMAT(/,T39,'   EMERGENCE      EXODUS  MORTALITY1  MORTALITY2',
     >             '  MORTALITY3   SURVIVORS')
 6450 FORMAT('B',I1,I5,T9,'BEETLES -- GENOTYPE ',I1,T40,6F12.3)
 6500 FORMAT('TB',I5,T9,'TOTAL BEETLES',T40,6F12.3,/,'B')
 6550 FORMAT('%',I1,I5,T9,'% GENOTYPE(',I1,')',T40,6F12.3)
 6600 FORMAT('%T',I5,T9,'% TOTAL',T40,6F12.3,/,'%')
 6650 FORMAT('S ',I5,T9,'SURFACE KILLED =',F10.2,';',
     :       '  CUMULATIVE SURFACE KILLED =',F10.2,';',
     :       '  OFFSPRING =',F10.2,';',
     :       '  NEXT P =',F8.5,
     :     /,'D ',I5,T9,'ATTACK DENSITY =',F8.4,';',
     :           ' EMERGENCE DENSITY =',F8.3,';',
     :           ' EMERGENCE/ATTACK =',F8.3,';',
     :           ' PIONEER DENSITY =',F12.8)
 6700 FORMAT (//,25('*'),'    NOTE:  EPIDEMIC IS EXTENDING',
     :        ' PAST THE LAST TREE GROWTH CYCLE YEAR    ',
     :        25('*'))
 6800 FORMAT (//,'SADLPP = ',F10.2)
 6900 FORMAT(/,'PERIODIC GROWTH RATIO = ',F5.3,' RESIST = ',F5.2,
     >       '  THRESHOLD OF AGGREGATION = ',F5.2,/)
 7000 FORMAT (//,'PHLOEM = ',20F6.3)
 7100 FORMAT (//,'EFPHLM = ',20F6.3)
 7250 FORMAT (//,'SEXDBH = ',20F6.3)
 7200 FORMAT (//,'EFELEV = ',F4.2,'  EFLAT = ',F4.2)
 7400 FORMAT (/,100('*'),//,'RESIST = ',F5.2,'  TA = ',5F5.2)
      END
