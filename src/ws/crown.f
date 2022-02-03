      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C WS $Id: crown.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND
C  COMPUTE CROWN RATIO CHANGES FOR TREES THAT ARE GREATER THAN
C  1 INCH DBH.  
C  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO WHEN DBH IS LESS THAN 1 INCH.
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
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER MYACTS(1),ICFLG(MAXSP),ISORT(MAXTRE)
      INTEGER JJ,NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP,J1
      INTEGER ISPC,I1,I2,I3,IITRE,ICRI
      REAL CRNEW(MAXTRE),WEIBA(MAXSP),WEIBB0(MAXSP),
     & WEIBB1(MAXSP),WEIBC0(MAXSP),WEIBC1(MAXSP),C0(MAXSP),C1(MAXSP),
     & CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP),PRM(5)
      REAL RELSDI,ACRNEW,A,B,C,D,H,SCALE,X,RNUMB,CHG
      REAL PDIFPY,CRLN,CRMAX,HN,HD,CL,TPCT,TPCCF,CR,HF
      REAL BAPLT,QMDPLT,TPAPLT,PRD,DBHLO,DBHHI,SDICS,SDICZ,XMAX
      REAL ZRD(MAXPLT),HDR
      INTEGER IWHO
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINQUAPIN (GC)             CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH) 
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE), 
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C----------
C
      DATA MYACTS/81/
C
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
C-----------
C  CALL SDICAL TO LOAD THE POINT MAX SDI WEIGHTED BY SPECIES ARRAY XMAXPT()
C  RECENT DEAD ARE NOT INCLUDED. IF THEY NEED TO BE, SDICAL.F NEEDS MODIFIED
C  TO DO SO. IWHO PARAMETER HAS NO AFFECT ON XMAXPT ARRAY VALUES.
C  MARK CASTLE: MAY NEED TO ADD XMAXPT ARRAY TO COMMONS
C-----------
      IWHO = 2
      CALL SDICAL (IWHO, XMAX)
C-----------
C  LOAD SDI (ZEIDI) FOR INDIVIDUAL POINTS.
C  ALL SPECIES AND ALL SIZES INCLUDED FOR THIS CALCULATION.
C  SDI USED IN CR CALCULATION
C  POINT SDI IS USED IN CR CALCULATION FOR RW/GS
C-----------
      DBHLO = 0.0
      DBHHI = 500.0
      ISPC = 0
      IWHO = 1
      I2 = INT(PI)
      
      DO I1 = 1, I2
         CALL SDICLS (ISPC,DBHLO,DBHHI,IWHO,SDICS,SDICZ,A,B,I1)
         ZRD(I1) = SDICZ
      END DO
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
        ISORT(JJ)=0
   10   CONTINUE
      ENDIF
C----------
C  DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C----------
C IF THERE ARE NO TREE RECORDS, THEN RETURN
C----------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
      ENDIF
C-----------
C  PROCESS CRNMULT KEYWORD.
C-----------
      CALL OPFIND(1,MYACTS,NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,5,IDATE,IACTK,NP,PRM)
      IDT=IDATE
      CALL OPDONE(I,IDT)
      ISPCC=INT(PRM(1))
C----------
C  ISPCC<0 CHANGE FOR ALL SPECIES IN THE SPECIES GROUP
C  ISPCC=0 CHANGE FOR ALL SPEICES
C  ISPCC>0 CHANGE THE INDICATED SPECIES
C----------
      IF(ISPCC .LT. 0)THEN
        IGRP = -ISPCC
        IULIM = ISPGRP(IGRP,1)+1
        DO 21 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        IF(PRM(2) .GE. 0.0)CRNMLT(IGSP)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(IGSP)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(IGSP)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(IGSP)=1
   21   CONTINUE
      ELSEIF(ISPCC .EQ. 0)THEN
        DO 22 ISPCC=1,MAXSP
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
   22   CONTINUE
      ELSE
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
      ENDIF
   24 CONTINUE
   25 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,11F6.2)/))
C----------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C----------
      DO 11 JJ=1,ITRN
      J1 = ITRN - JJ + 1
      ISORT(IND(JJ)) = J1
   11 CONTINUE
      IF(DEBUG)THEN
        WRITE(JOSTND,7900)ITRN,(IND(JJ),JJ=1,ITRN)
 7900   FORMAT(' IN CROWN 7900 ITRN,IND =',I6,/,86(1H ,32I4,/))
        WRITE(JOSTND,7901)ITRN,(ISORT(JJ),JJ=1,ITRN)
 7901   FORMAT(' IN CROWN 7900 ITRN,ISORT =',I6,/,86(1H ,32I4,/))
      ENDIF
C----------
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
C----------
C ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C----------
      IF(SDIDEF(ISPC) .GT. 0.)THEN
        RELSDI = SDIAC / SDIDEF(ISPC)
      ELSE
        RELSDI = 1.0
      ENDIF
      IF(RELSDI .GT. 1.5)RELSDI = 1.5
      ACRNEW = C0(ISPC) + C1(ISPC) * RELSDI*100.0
      A = WEIBA(ISPC)
      B = WEIBB0(ISPC) + WEIBB1(ISPC) * ACRNEW
      C = WEIBC0(ISPC) + WEIBC1(ISPC)*ACRNEW
      IF(B .LT. 3.0) B=3.0
      IF(C .LT. 2.0) C=2.0

      IF(DEBUG) WRITE(JOSTND,9001) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,SDIDEF(ISPC)
 9001 FORMAT(' IN CROWN 9001 WRITE ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B,
     &C,SDIDEF = ',/1X,I5,F8.2,F8.4,F8.2,F8.2,4F10.4)
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE=ITRE(I)
C----------
C  IF THIS IS THE INITIAL ENTRY TO 'CROWN' AND THE TREE IN QUESTION
C  HAS A CROWN RATIO ASCRIBED TO IT, THE WHOLE PROCESS IS BYPASSED.
C----------
      IF(LSTART .AND. ICR(I).GT.0)GOTO 60
C----------
C  IF ICR(I) IS NEGATIVE, CROWN RATIO CHANGE WAS COMPUTED IN A
C  PEST DYNAMICS EXTENSION.  SWITCH THE SIGN ON ICR(I) AND BYPASS
C  CHANGE CALCULATIONS.
C----------
      IF (LSTART) GO TO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (/' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
      
C     CALCULATE HEIGHT DIAMETER RATIO
      HDR = (H*12)/D

C  CALCULATE PLOT LEVEL QMD - USED IN RW/GS CR CALCULATION
      BAPLT = PTBAA(ITRE(I))
      TPAPLT = PTPA(ITRE(I))
      IF(TPAPLT .GT. 0.0) THEN
        QMDPLT = SQRT((BAPLT/TPAPLT)/0.005454)
      ELSE
        QMDPLT = 0.0
      ENDIF

C  CALCULATE RD AND CONSTRAIN RD IF NECCESARY
      IF (XMAXPT(ITRE(I)).LE.0.0) THEN
        PRD = 0.01
      ELSE
        PRD = ZRD(ITRE(I)) / XMAXPT(ITRE(I))
      ENDIF
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LESS THAN 1 IN.
C----------
      IF(D.LT.1.0 .AND. LSTART) GO TO 58
C
      SELECT CASE(ISPC)
C----------
C  GREAT BASIN BRISTLECONE PINE FROM THE UT VARIANT
C----------
      CASE(21)
        HF = H + HTG(I)
        CL = -0.59373 + 0.67703 * HF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CRNEW(I) = (CL/HF)*100.
        IF(DEBUG)WRITE(JOSTND,*)' I,HF,BA,CL,CRNEW= ',
     &  I,HF,BA,CL,CRNEW(I)
     
C----------
C GS AND RW
C----------
      CASE(4,23)
        X = -1.021064 + 0.309296*LOG(HDR) + 
     &        0.869720*PRD - 0.116274*(D/QMDPLT)
        X = 1.0/(1.0+EXP(X))

C CONSTRAIN CR
        IF(X .LT. .05) X=.05
        IF(X .GT. .95) X=.95

        IF(DEBUG)WRITE(JOSTND,*)' IN CROWN - RW/GS DEBUG', ' D=',D,
     &   ' H=',H,' PRD=',PRD,' QMDPLT=',QMDPLT,' HDR=',HDR,' CR=',X

C SET CRNEW
        CRNEW(I) = X * 100
C
      CASE DEFAULT
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        SELECT CASE (ISPC)
          CASE(9:10,12,14:17,19:20,25:27)
            SCALE=1.5-RELSDI
          CASE(1:8,11,13,18,22:24,28:40,42:43)
            SCALE = (1.0 - .00333 * (RELDEN-50.0))
          CASE(41)
            SCALE = (1.0 - .00167 * (RELDEN-100.0))
        END SELECT
        IF(SCALE .GT. 1.0) SCALE = 1.0
        IF(SCALE .LT. 0.30) SCALE = 0.30
        IF(DBH(I) .GT. 0.0) THEN
          X = (REAL(ISORT(I)) / REAL(ITRN)) * SCALE
        ELSE
          CALL RANN(RNUMB)
          X = RNUMB * SCALE
        ENDIF

C CONSTRAIN CR
        IF(X .LT. .05) X=.05
        IF(X .GT. .95) X=.95
        
C DETERMINE CRNEW
        CRNEW(I) = A + B*((-1.0*ALOG(1-X))**(1.0/C))
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
        IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002   FORMAT(/' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',
     &          I5,2F10.5,I5)
        CRNEW(I) = CRNEW(I)*10.0
C
      END SELECT
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - REAL(ICR(I))
      PDIFPY=CHG/REAL(ICR(I))/FINT
      IF(PDIFPY.GT.0.01)CHG=REAL(ICR(I))*(0.01)*FINT
      IF(PDIFPY.LT.-0.01)CHG=REAL(ICR(I))*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
        CRNEW(I) = REAL(ICR(I)) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = REAL(ICR(I)) + CHG
      ENDIF
 9052 ICRI = INT(CRNEW(I)+0.5)
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
          ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
        ENDIF
      ENDIF
C
C CALC CROWN LENGTH NOW
C
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*REAL(ICR(I))/100.
C
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT(/' CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=INT(CRMAX+0.5)
      IF(REAL(ICRI).GT.CRMAX) ICRI=INT(CRMAX+0.5)
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT(/'  IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 1.0 IN ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 1 INCHES.
C----------
   58 CONTINUE
      IF(ICR(I) .NE. 0) GO TO 60
C
      SELECT CASE(ISPC)
C
       CASE(21)
        HF = H + HTG(I)
        CL = -0.59373 + 0.67703 * HF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        ICRI = INT((CL/HF)*100. + 0.5)
        IF(DEBUG)WRITE(JOSTND,*)' I,HF,BA,CL,CRNEW= ',
     &  I,HF,BA,CL,CRNEW(I)
C
      CASE DEFAULT
        TPCT = PCT(I)
        TPCCF = PCCF(IITRE)
        CALL DUBSCR(ISPC,D,H,PRD,QMDPLT,CR,TPCT,TPCCF)
        IF(DEBUG) WRITE(JOSTND,*) 'RETURN FROM DUBSCR IN CROWN'
        ICRI=INT(CR*100.0+0.5)
C
      END SELECT
C
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &   ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0) ICRI=10
      IF(ICRI.LT.1)ICRI=1
      ICR(I)= ICRI
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 80
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
      IITRE=ITRE(I)

C  CALCULATE PLOT LEVEL QMD
C  USED FOR RW/GS CR CALCULATION
      BAPLT = PTBAA(IITRE)
      TPAPLT = PTPA(IITRE)
      IF(TPAPLT .GT. 0.0) THEN
        QMDPLT = SQRT((BAPLT/TPAPLT)/0.005454)
      ELSE
        QMDPLT = 0.0
      ENDIF

C  CALCULATE RD AND CONSTRAIN RD IF NECCESARY
C  USED FOR RW/GS CR CALCULATION
      IF (XMAXPT(IITRE).LE.0.0) THEN
        PRD = 0.01
      ELSE
        PRD = ZRD(IITRE) / XMAXPT(IITRE)
      ENDIF
C
      SELECT CASE(ISPC)
C
       CASE(21)
         CL = -0.59373 + 0.67703 * H
         IF(CL .LT. 1.0) CL = 1.0
         IF(CL .GT. H) CL = H
         ICRI = INT((CL/H)*100. + 0.5)
         IF(DEBUG)WRITE(JOSTND,*)' I,H,BA,CL,ICRI= ',
     &   I,HF,BA,CL,ICRI
C
      CASE DEFAULT
        TPCT=PCT(I)
        IITRE=ITRE(I)
        TPCCF=PCCF(IITRE)
        CALL DUBSCR (ISPC,D,H,PRD,QMDPLT,CR,TPCT,TPCCF)
        ICRI=INT(CR*100.0 + 0.5)
      END SELECT
C
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C
   80 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(/' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
C
C
      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C  1=SP,  2=DF,  3=WF,  4=GS,  5=IC,  6=JP,  7=RF,  8=PP,  9=LP, 10=WB,
C 11=WP, 12=PM, 13=SF, 14=KP, 15=FP, 16=CP, 17=LM, 18=MP, 19=GP, 20=WE,
C 21=GB, 22=BD, 23=RW, 24=MH, 25=WJ, 26=UJ, 27=CJ, 28=LO, 29=CY, 30=BL,
C 31=BO, 32=VO, 33=IO, 34=TO, 35=GC, 36=AS, 37=CL, 38=MA, 39=DG, 40=BM,
C 41=MC, 42=OS, 43=OH       
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH) 
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE), 
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C----------
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C----------
      DATA WEIBA/
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        2.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,
     &        0.0,      0.0,      0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBB0/
     &    0.32957,  0.39996,  0.17606,  0.32957,  0.15500,
     &   -1.24580,  0.16601,  0.20199, -0.13121, -0.13121,
     &    0.32957,  0.16267,  0.17606,  0.16267,  0.16267,
     &    0.16267,  0.16267,  0.20199,  0.16267,  0.16267,
     &        0.0,  0.39996,  0.32957,  0.32957,  0.16267,
     &    0.16267,  0.16267, -0.14217, -0.14217, -0.14217,
     &   -0.14217, -0.14217, -0.14217, -0.14217, -0.14217,
     &   -0.14217, -0.14217, -0.14217, -0.14217, -0.14217,
     &   -0.23830, -0.09800, -0.14217/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBB1/
     &    1.03916,  1.03150,  1.07984,  1.03916,  1.08747,
     &    0.94476,  1.08150,  1.07198,  1.15976,  1.15976,
     &    1.03916,  1.07340,  1.07984,  1.07340,  1.07340,
     &    1.07340,  1.07340,  1.07198,  1.07340,  1.07340,
     &        0.0,  1.03150,  1.03916,  1.03916,  1.07340,
     &    1.07340,  1.07340,  1.15448,  1.15448,  1.15448,
     &    1.15448,  1.15448,  1.15448,  1.15448,  1.15448,
     &    1.15448,  1.15448,  1.15448,  1.15448,  1.15448,
     &    1.18016,  1.11809,  1.15448/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBC0/
     &   -0.83314, -0.98287, -0.89140, -0.83314,  0.85877,
     &  -10.54490,  0.91420,  0.75409,  2.59824,  2.59824,
     &   -0.83314,  3.28850, -0.89140,  3.28850,  3.28850,
     &    3.28850,  3.28850,  0.75409,  3.28850,  3.28850,
     &        0.0, -0.98287, -0.83314, -0.83314,  3.28850,
     &    3.28850,  3.28850,  0.59185,  0.59185,  0.59185,
     &    0.59185,  0.59185,  0.59185,  0.59185,  0.59185,
     &    0.59185,  0.59185,  0.59185,  0.59185,  0.59185,
     &       3.04,  4.05181,  0.59185/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBC1/
     &    0.91493,  0.88449,  0.76518,  0.91493,  0.40125,
     &    2.45822,  0.45768,  0.52191,      0.0,      0.0,
     &    0.91493,      0.0,  0.76518,      0.0,      0.0,
     &        0.0,      0.0,  0.52191,      0.0,      0.0,
     &        0.0,  0.88449,  0.91493,  0.91493,      0.0,
     &        0.0,      0.0,  0.37245,  0.37245,  0.37245,
     &    0.37245,  0.37245,  0.37245,  0.37245,  0.37245,
     &    0.37245,  0.37245,  0.37245,  0.37245,  0.37245,
     &        0.0,      0.0,  0.37245/
C----------
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C----------
      DATA C0/
     &    7.12189,  5.91609,  6.86237,  7.12189,  6.32336,
     &    7.33055,  6.14578,  6.15172,  4.89032,  4.89032,
     &    7.12189,  6.48494,  6.86237,  6.48494,  6.48494,
     &    6.48494,  6.48494,  6.15172,  6.48494,  6.48494,
     &        0.0,  5.91609,  7.12189,  7.12189,  6.48494,
     &    6.48494,  6.48494,  4.00579,  4.00579,  4.00579,
     &    4.00579,  4.00579,  4.00579,  4.00579,  4.00579,
     &    4.00579,  4.00579,  4.00579,  4.00579,  4.00579,
     &    4.62512,  6.35669,  4.00579/
C----------
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C----------
      DATA C1/
     &   -0.02817, -0.00943, -0.03278, -0.02817, -0.02987,
     &   -0.01539, -0.02781, -0.01994, -0.01884, -0.01884,
     &   -0.02817, -0.02325, -0.03278, -0.02325, -0.02325,
     &   -0.02325, -0.02325, -0.01994, -0.02325, -0.02325,
     &        0.0, -0.00943, -0.02817, -0.02817, -0.02325,
     &   -0.02325, -0.02325, -0.00522, -0.00522, -0.00522,
     &   -0.00522, -0.00522, -0.00522, -0.00522, -0.00522,
     &   -0.00522, -0.00522, -0.00522, -0.00522, -0.00522,
     &   -0.01604, -0.00846, -0.00522/
C
C----------
C LOAD COEFFICIENTS FOR GIANT SEQUIOA (GS) CR EQUATION
C----------

      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
C
      RETURN
      END
