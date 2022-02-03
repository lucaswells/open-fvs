      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C CR $Id: crown.f 2444 2018-07-09 16:00:55Z gedixon $
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND
C  COMPUTE CROWN RATIO CHANGES.
C  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  PROCESSING OF
C  CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY **REGENT**.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE  'ARRAYS.F77'
C
C
      INCLUDE  'COEFFS.F77'
C
C
      INCLUDE  'CONTRL.F77'
C
C
      INCLUDE  'GGCOM.F77'
C
C
      INCLUDE  'OUTCOM.F77'
C
C
      INCLUDE  'PLOT.F77'
C
C
      INCLUDE  'PDEN.F77'
C
C
      INCLUDE  'VARCOM.F77'
C
C
COMMONS
C
      REAL CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP),CRNEW(MAXTRE),PRM(5)
      INTEGER ICFLG(MAXSP),MYACTS(1)
      INTEGER NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP,ISPC
      INTEGER I1,I2,I3,ICLS,ICRI,JJ
      REAL D,H,PCTI,TBAU,HF,DF,BRATIO,CR,CHG,PDIFPY,CRLN,CRMAX,HN,HD,CL
      DATA MYACTS/81/
      LOGICAL DEBUG
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN CYCLE =',I5)
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      CALL BADIST(DEBUG)
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
          CRNEW(JJ)=0.0
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
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
      DO 60 I3=I1,I2
      I = IND1(I3)
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
      PCTI = PCT(I)
      ICLS = INT(D+1.0)
      IF(ICLS .GT. 41) ICLS=41
      TBAU = BAU(ICLS)
      HF = H + HTG(I)
      DF = D + DG(I)/BRATIO(ISP(I),DBH(I),HF)
      IF(DF .LT. D) DF=D
C----------
C   CALL GEMCR TO CALCULATE CROWN RATIO.
C----------
      CALL GEMCR(IMODTY,ISPC,CR,TBAU,BA,HF,DF,H,RELDEN,PCTI)
      CRNEW(I) = CR*100.
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - ICR(I)
      PDIFPY=CHG/REAL(ICR(I))/FINT
      IF(PDIFPY.GT.0.01)CHG=REAL(ICR(I))*(0.01)*FINT
      IF(PDIFPY.LT.-0.01)CHG=REAL(ICR(I))*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/' IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I) .GE. DLOW(ISPC) .AND. DBH(I) .LE. DHI(ISPC))THEN
        CRNEW(I) = REAL(ICR(I)) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = REAL(ICR(I)) + CHG
      ENDIF
 9052 ICRI = INT(CRNEW(I)+0.5)
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &  ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
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
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),CHG
 9004 FORMAT(' CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(ICRI.GT.CRMAX) ICRI=INT(CRMAX+0.5)
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=INT(CRMAX+0.5)
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,ICRI,CL
 9030 FORMAT(' IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
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
      PCTI=PCT(I)
      ICLS=INT(D+1.0)
      IF(ICLS .GT. 41)ICLS=41
      TBAU = BAU(ICLS)
      CALL GEMCR(IMODTY,ISPC,CR,TBAU,BA,H,D,H,RELDEN,PCTI)
      ICRI=INT(CR*100.)
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
C----------
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
      RETURN
      END
