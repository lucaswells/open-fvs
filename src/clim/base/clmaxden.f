      SUBROUTINE CLMAXDEN (SDIDEF,XMAX) 
      IMPLICIT NONE
C----------
C CLIM-BASE $Id: clmaxden.f 2442 2018-07-09 14:51:05Z gedixon $
C----------
C
C     CLIMATE EXTENSION 
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'CLIMATE.F77'
C
COMMONS
C

      REAL SDIDEF(MAXSP),XMAX
      REAL SUMWTSFIRST,WEISUMFIRST,SUMWTSCURR,WEISUMCURR ,FIRSTYEAR,
     >     CURRENTYEAR,FIRSTYRSCORE,CURRENTSCORE,MAXFIRST,MAXCURR,XX
      REAL ALGSLP
      INTEGER I,I2
      LOGICAL DEBUG

      INTEGER MYACT(1),IDT,IACT,NP,ITODO,NTODO
      REAL PRMS(1)
      DATA MYACT/2804/

      IF (.NOT.LCLIMATE) RETURN 
      
      CALL DBCHK (DEBUG,'CLMAXDEN',8,ICYC)

      IF (DEBUG) WRITE (JOSTND,10) ICYC,XMAX
   10 FORMAT ('IN CLMAXDEN, ICYC=',I2,' INITIAL XMAX=',F10.4)

      CALL OPFIND(1,MYACT,NTODO)
      IF (NTODO.GT.0) THEN
        DO ITODO=1,NTODO
          CALL OPGET(ITODO,1,IDT,IACT,NP,PRMS)
          IF (IACT.LT.0 .OR. NP.NE.1) CYCLE
          CALL OPDONE (ITODO,IY(ICYC))
          CLMXDENMULT = PRMS(1)
        ENDDO
      ENDIF

      MXDENMLT = 1.0

      IF (ICYC.LE.1) RETURN
      
C     IF ALL OF THE SPECIES ARE NOT BEING MODELED, THEN RETURN.

      DO I=1,MAXSP
        IF (INDXSPECIES(I).GT.0) GOTO 15
      ENDDO
      RETURN   
   15 CONTINUE
   
      SUMWTSCURR =0
      WEISUMCURR =0
      SUMWTSFIRST=0
      WEISUMFIRST=0       
      FIRSTYEAR  = FLOAT(IY(1))
      CURRENTYEAR= FLOAT(IY(ICYC)+ ((IY(ICYC+1)-IY(ICYC))/2) )

      MAXFIRST = 0
      MAXCURR  = 0
      DO I=1,MAXSP
      
        IF (INDXSPECIES(I).GT.0) THEN
          I2 = INDXSPECIES(I) 
          
C         CURRENTSCORE AND FIRSTYRSCORE ARE THE SPECIES VIABILITY SCORES.
          
          XX = ALGSLP (FIRSTYEAR,FLOAT(YEARS),ATTRS(1,I2),NYEARS)
          XX = -1. + 2.5*XX
          IF (XX.LT.0.) XX=0.
          IF (XX.GT.1.) XX=1.
          FIRSTYRSCORE = XX

          XX = ALGSLP (CURRENTYEAR, FLOAT(YEARS),ATTRS(1,I2),NYEARS) 
          XX = -1. + 2.5*XX
          IF (XX.LT.0.) XX=0.
          IF (XX.GT.1.) XX=1.
          CURRENTSCORE = XX

          IF (FIRSTYRSCORE.GT.MAXFIRST) MAXFIRST=FIRSTYRSCORE
          IF (CURRENTSCORE.GT.MAXCURR ) MAXCURR =CURRENTSCORE
          SUMWTSFIRST = SUMWTSFIRST + FIRSTYRSCORE
          WEISUMFIRST = WEISUMFIRST + (FIRSTYRSCORE*SDIDEF(I))
          SUMWTSCURR  = SUMWTSCURR  + CURRENTSCORE
          WEISUMCURR  = WEISUMCURR  + (CURRENTSCORE*SDIDEF(I))
        ENDIF  
      ENDDO

C     ADD THE COMPLIMENT OF THE MAXIMUM WEIGHT TO THE SUM OF THE WEIGHTS
C     THIS WILL ACCOUNT FOR A "TYPE" THAT HAS ZERO POTENTIAL MAXIMUM DENSITY
C     ...DO THIS WITH SCALED VALUES USING THE SCALING RULES FROM CLAUESTB.

      SUMWTSFIRST = SUMWTSFIRST+(1.-MAXFIRST) 
      SUMWTSCURR  = SUMWTSCURR +(1.-MAXCURR)  
      
      FIRSTYRSCORE =  WEISUMFIRST/SUMWTSFIRST
      CURRENTSCORE =  WEISUMCURR /SUMWTSCURR
      
C     WATCH OUT FOR THE TYRANNY OF ZEROS!      
      IF (ABS(CURRENTSCORE-FIRSTYRSCORE) .LE. 1E-5) THEN
        XX = 1.
      ELSE IF (FIRSTYRSCORE .LE. 1E-10)  THEN
        IF (CURRENTSCORE .GT. 1E-10) THEN
          XX = 1.5819767
        ELSE
          XX = 1.
        ENDIF
      ELSE 
        XX = CURRENTSCORE/FIRSTYRSCORE

C       1.5819767 = (1./(1-EXP(-1.))) AND CAUSES XX=1 TO STAY 1.

        XX = 1.5819767*(1.-(EXP(-XX)))
        IF (XX .LT. .15) XX=.15
      ENDIF
      
      MXDENMLT = 1.+((XX-1.)*CLMXDENMULT)
      IF (MXDENMLT .LT. 0) MXDENMLT=0.
      
      XMAX = XMAX * MXDENMLT
      
      IF (DEBUG) WRITE (JOSTND,20) MAXFIRST,MAXCURR,
     >           FIRSTYRSCORE,CURRENTSCORE,XX,XMAX
   20 FORMAT ('LEAVING CLMAXDEN, MAXFIRST, MAXCURR=',2E14.7,
     >        ' FIRSTYRSCORE,CURRENTSCORE=',2E14.7,
     >        ' XX=',F10.4,' ADJUSTED XMAX=',F10.4)

      RETURN
      END
