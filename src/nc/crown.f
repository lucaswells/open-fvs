      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C NC $Id: crown.f 3758 2021-08-25 22:42:32Z lancedavid $
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND
C  COMPUTE CROWN RATIO CHANGES FOR TREES THAT ARE GREATER THAN
C  3 INCHES DBH.  THE EQUATION USED PREDICTS CROWN RATIO FROM
C  HABITAT TYPE, BASAL AREA, CROWN COMPETITION FACTOR, DBH, TREE
C  HEIGHT, AND PERCENTILE IN THE BASAL AREA DISTRIBUTION.  WHEN
C  THE EQUATION IS USED TO PREDICT CROWN RATIO CHANGE, VALUES
C  OF THE PREDICTOR VARIABLES FROM THE START OF THE CYCLE ARE USED
C  TO PREDICT OLD CROWN RATIO, VALUES FROM THE END OF THE CYCLE
C  ARE USED TO PREDICT NEW CROWN RATIO, AND THE CHANGE IS
C  COMPUTED BY SUBTRACTION.  THE CHANGE IS APPLIED TO ACTUAL
C  CROWN RATIO.  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO WHEN DBH IS LESS THAN 3 INCHES.  PROCESSING OF
C  CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY **REGENT**.
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
C
C----------
      REAL CRNEW(MAXTRE),WEIBA(12),WEIBB0(12),
     & WEIBB1(12),WEIBC0(12),WEIBC1(12),C0(12),C1(12),
     & PRM(5),CRNMLT(12),DLOW(12),DHI(12)
      INTEGER MYACTS(1),ICFLG(12),ISORT(MAXTRE)
      INTEGER JJ,NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM
      INTEGER IG,IGSP,J1,ISPC,I1,I2,I3,IITRE,ICRI
      REAL RELSDI,ACRNEW,A,B,C,D,H,SCALE,X,RNUMB
      REAL CHG,PDIFPY,CRLN,CRMAX,HN,HD,CL,TPCT,TPCCF,CR
      DATA MYACTS/81/
      REAL BAPLT,QMDPLT,TPAPLT,PRD,DBHLO,DBHHI,SDICS,SDICZ,XMAX
      REAL ZRD(MAXPLT),HDR
      INTEGER IWHO
C----------
C  SPECIES ORDER 1=OC, 2=SP, 3=DF, 4=WF, 5=M , 6=IC, 7=BO, 8=TO,
C                9=RF, 10=PP, 11=OH, 12 = RW
C----------
      LOGICAL DEBUG
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN CYCLE =',I5)
C-----------
C  CALL SDICAL TO LOAD THE POINT MAX SDI WEIGHTED BY SPECIES ARRAY XMAXPT()
C  RECENT DEAD ARE NOT INCLUDED. IF THEY NEED TO BE, SDICAL.F NEEDS MODIFIED
C  TO DO SO. IWHO PARAMETER HAS NO AFFECT ON XMAXPT ARRAY VALUES.
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
      DO 70 ISPC=1,12
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
C
      IF(DEBUG) WRITE(JOSTND,9001) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,SDIDEF(ISPC)
 9001 FORMAT(' IN CROWN 9001 ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B,
     &C,SDIDEF = ',/,1H ,I5,F8.2,F8.4,F8.2,F8.2,4F10.4)
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
      IF (LSTART) GOTO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)

C     CALCULATE HEIGHT DIEMTER RATIO AND CONSTRAIN IF NEEDED
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
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------

      SELECT CASE(ISPC)

C----------
C BRANCH FOR RW
C----------
      CASE(12)
        X = -1.021064 + 0.309296*LOG(HDR) + 
     &         0.869720*PRD - 0.116274*(D/QMDPLT)
        X = 1.0/(1.0+EXP(X))

        IF(DEBUG)WRITE(JOSTND,*)' IN CROWN - RW DEBUG', ' D=',D,
     &     ' H=',H,' PRD=',PRD,' QMDPLT=',QMDPLT,' HDR=',HDR,' CR=',X
C----------
C ALL OTHER SPECIES
C----------
      CASE DEFAULT
        SCALE=1.5-RELSDI
        IF(SCALE .GT. 1.0) SCALE = 1.0
        IF(SCALE .LT. 0.30) SCALE = 0.30
        IF(DBH(I) .GT. 0.0) THEN
          X = (REAL(ISORT(I)) / REAL(ITRN)) * SCALE
        ELSE
          CALL RANN(RNUMB)
          X = RNUMB * SCALE
        ENDIF
      END SELECT

C  CONSTRAIN CR IF NEEDED
      IF(X .LT. .05) X=.05
      IF(X .GT. .95) X=.95

C DETERMINE CRNEW BASED ON SPECIES
      IF(ISPC .EQ. 12) THEN
        CRNEW(I) = X * 10
      ELSE
        CRNEW(I) = A + B*((-1.0*ALOG(1-X))**(1.0/C))
      ENDIF

C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
      IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I),LSTART
 9002 FORMAT(' IN CROWN 9002 I,X,CRNEW,ICR,LSTART = ',I5,2F10.5,
     &I5,L2)
      CRNEW(I) = CRNEW(I)*10.0
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
      IF(DBH(I) .GE. DLOW(ISPC) .AND. DBH(I) .LE. DHI(ISPC))THEN
        CRNEW(I) = REAL(ICR(I)) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = REAL(ICR(I)) + CHG
      ENDIF
 9052 ICRI = INT(CRNEW(I)+0.5)
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &    ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*REAL(ICR(I))/100.
C----------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C----------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT(' CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(REAL(ICRI).GT.CRMAX) ICRI=INT(CRMAX+0.5)
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=INT(CRMAX+0.5)
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
 9030 FORMAT(' IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 3.0 IN ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 3 INCHES.
C----------
   58 CONTINUE
      IF(ICR(I).NE.0) GO TO 60
      TPCT = PCT(I)
      TPCCF = PCCF(IITRE)
      CALL DUBSCR(ISPC,D,H,PRD,QMDPLT,CR,TPCT,TPCCF)
      IF(DEBUG) WRITE(JOSTND,*) 'RETURN FORM DUBSCR IN CROWN'
      ICRI=INT(CR*100.0+0.5)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
      ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
      ENDIF
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10 .AND. CRNMLT(ISPC).EQ.1) ICRI=10
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
      TPCT=PCT(I)
      IITRE=ITRE(I)
      TPCCF=PCCF(IITRE)

C  CALCULATE PLOT LEVEL QMD
C  USED FOR RW CR CALCULATION
      BAPLT = PTBAA(IITRE)
      TPAPLT = PTPA(IITRE)
      IF(TPAPLT .GT. 0.0) THEN
        QMDPLT = SQRT((BAPLT/TPAPLT)/0.005454)
      ELSE
        QMDPLT = 0.0
      ENDIF

C  CALCULATE RD AND CONSTRAIN RD IF NECCESARY
C  USED FOR RW CR CALCULATION
      IF (XMAXPT(IITRE).LE.0.0) THEN
        PRD = 0.01
      ELSE
        PRD = ZRD(IITRE) / XMAXPT(IITRE)
      ENDIF

C  CALL DUBSCR
      CALL DUBSCR (ISPC,D,H,PRD,QMDPLT,CR,TPCT,TPCCF)
      ICRI=INT(CR*100.0 + 0.5)
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
 9010 FORMAT(' LEAVING CROWN 9010 ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN CYCLE =',I5)
      RETURN
      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C
C SPECIES ORDER
C  1=OC,  2=SP,  3=DF,  4=WF,  5=M ,  6=IC,  7=BO,
C  8=TO,  9=RF, 10=PP, 11=OH,  12 = RW
C
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C----------
      DATA WEIBA/ 12*0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBB0/  0.52909,  0.25115,  0.52909,  0.48464,  0.08402,
     &              0.29964,  0.06607,  0.25667,  0.16601,  0.03685,
     &              0.25667,  0.00000/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBB1/  1.00677, 1.05987,  1.00677,  1.01272,  1.10297,
     &              1.05398, 1.10705,  1.06474,  1.08150,  1.09499,
     &              1.06474, 0.00000/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBC0/ -3.48211,  0.33383, -3.48211, -2.78353,  0.91078,
     &             -1.09270,  2.04714,  0.11729,  0.91420,  4.01340,
     &              0.11729,  0.00000/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBC1/  1.38780,  0.63833,  1.38780,  1.27283,  0.45819,
     &              0.80687,  0.15070,  0.61681,  0.45768,  0.04946,
     &              0.61681,  0.00000/
C----------
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C----------
      DATA C0/7.48846, 6.92893, 7.48846,  7.44422,  3.64292,
     &        5.12357, 6.82187, 5.95912,  6.14578,  6.04928,
     &        5.95912, 0.00000/
C----------
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C----------
      DATA C1/-0.02899, -0.04053, -0.02899, -0.04779, -0.00317,
     &        -0.01042, -0.02247, -0.01812, -0.02781, -0.01091,
     &        -0.01812,  0.00000/
C
      DATA CRNMLT/12*1.0/
      DATA ICFLG/12*0/
      DATA DLOW/12*0.0/
      DATA DHI/12*99.0/
      RETURN
      END
