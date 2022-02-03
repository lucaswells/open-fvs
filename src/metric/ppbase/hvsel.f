      SUBROUTINE HVSEL
      IMPLICIT NONE
C----------
C METRIC-PPBASE $Id: hvsel.f 2464 2018-07-27 15:36:37Z gedixon $
C----------
C
C     CALLED BY HVALOC TO SET UP THE STATUS WORD FOR ALL OF
C     THE STANDS AND POLICIES.
C
C     MULTISTAND POLICY ROUTINE - N.L. CROOKSTON  - JULY 1987
C     FORESTRY SCIENCES LABORATORY - MOSCOW, ID 83843
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPEPRM.F77'
C
C
      INCLUDE 'PPHVCM.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
      INCLUDE 'METRIC.F77'
C
COMMONS
C
      INTEGER IRC,IHV,ICPRT,IST,II,IST1,N,JJ,I,IHVST
      REAL XC,CONTIG,PNEED,THNYLD,HRVYLD
      CHARACTER CSEL(5)*5,COUTID(3)*4,VVER*7,TIM*8,DAT*10
      INTEGER IPTOUT(3)
      REAL XCUT(3)
      LOGICAL LODSRT,LMORE
      DATA CSEL/'ERROR','  NO ','  YES','**YES','ENYP '/
C
      LODSRT=.TRUE.
C
C     IF MAX CONTIGUOUS CLEAR CUT ACRE CONSTRAINTS ARE BEING USED,
C     THEN, SET UP NEIGHBORS AND AREAS DATA.
C     IF ERRORS ARE FOUND, TURN OFF THE OPTION.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVSEL: LHIER,LHVMXC,LHVUNT='',
     >     3L2)') LHIER,LHVMXC,LHVUNT
      IF (LHVMXC) THEN
         CALL C26SRT (NOSTND,STDIDS,ISDWK1,.TRUE.)
C
C        EXTRACT THE AREA DATA.
C
         CALL SPLAEX (STDIDS,NOSTND,ISDWK1,IRC)
         IF (IRC.NE.0) THEN
            WRITE (JOPPRT,10) 'AREAS'
   10       FORMAT (/' ********  ERROR: MAX CONTIGUOUS CLEAR',
     >               'CUT HECTARES CONSTRAINT NO LONGER BEING USED.  ',
     >               A,' DATA ERROR.')
            CALL RCDSET (2,.TRUE.)
            LHVMXC=.FALSE.
         ELSE
C
C           EXTRACT THE NEIGHBORS DATA.
C
            CALL SPNBEX (STDIDS,NOSTND,ISDWK1,IRC)
            IF (IRC.NE.0) THEN
               WRITE (JOPPRT,10) 'NEIGHBORS'
               CALL RCDSET (2,.TRUE.)
               LHVMXC=.FALSE.
            ENDIF
         ENDIF
      ENDIF
C
C     IF MAX CONTIG. CLEAR CUT CONSTRANT IS BEING USED, OR IF
C     HIERARCHIES ARE BEING USED, TURN OFF PARTIAL CUTTING.
C
      IF (LHVMXC.OR.LHIER) LPRTCT=.FALSE.
C
C     LOOP OVER POLICIES
C
      DO 200 IHV=1,IXHRVP
C
C     IF THE POLICY IS NOT ACTIVE, SKIP IT
C
      IF (IHVTAB(IHV,1).EQ.0) GOTO 200
C
C     INITIALIZE SOME VARIABLES.
C
      HRVYLD=0.0
      LMORE=.TRUE.
      ICPRT=0
      HVPART(IHV)=0.0
C
C     SORT THE STAND PRIORITIES INTO DESCENDING ORDER.
C     LODSRT IS A SWITCH THAT CONTROLS INITIALIZING ISNSRT.
C
      IF(NOSTND .GT. 0) CALL RDPSRT (NOSTND,HVPRI(1,IHV),ISNSRT,LODSRT)
      LODSRT=.FALSE.
C
C     SUM UP THE YIELD DUE TO THINNING.
C
      THNYLD=0.0
      DO IST=1,NOSTND
         IF (IHVSTA(IST,IHV).EQ.1) THNYLD=THNYLD+HVTHIN(IST,IHV)
      ENDDO
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVSEL: IHV,THNYLD,TRGETS'',
     >    I4,2E15.5)') IHV,THNYLD,TRGETS(IHV)
C
C     IF THE TARGET HAS BEEN REACHED, SET ALL OF THE STATUS
C     CODES TO 2, AND GO ON TO THE NEXT POLICY.
C
      IF (THNYLD.GE.TRGETS(IHV).OR.TRGETS(IHV).LE.0.0) THEN
         DO IST=1,NOSTND
            IF (IABS(IHVSTA(IST,IHV)).EQ.1) IHVSTA(IST,IHV)=2
         ENDDO
      ELSE
C
C        GO THROUGH THE STANDS IN DESCENDING ORDER.
C
         DO 60 II=1,NOSTND
         IST1=ISNSRT(II)
         IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVSEL 1: IHV,IST1='',
     >        2I4,'' IHVSTA,HVYLDS,HRVYLD='',I4,2E15.5)') IHV,IST1,
     >        IHVSTA(IST1,IHV),HVYLDS(IST1,IHV),HRVYLD
C
C        SKIP STANDS THAT HAVE A STATUS CODE NE 1 IN ABS.
C
         IF (IABS(IHVSTA(IST1,IHV)).NE.1) GOTO 60
C
C        IF LHIER IS TRUE (USING HIERARCHIES), THEN:
C        IF WE ARE PROCESSING A SECOND OR SUBSEQUENT POLICY, AND
C        IF THE STAND WAS SELECTED UNDER THE FIRST POLICY, THEN:
C        SET THIS STAND AS "NOT SELECTED", AND BRANCH TO THE NEXT.
C
         IF (LHIER) THEN
            IF (IHV.GT.1 .AND. IABS(IHVSTA(IST1,1)).EQ.3) THEN
               IHVSTA(IST1,IHV)=2
               GOTO 60
            ENDIF
         ENDIF
C
C        IF SELECTING COORDINATED MGMT UNITS (THOSE THAT HAVE THE SAME
C        MGMTID SO LONG AS THE MGMTID IS NOT EQUAL TO NONE), THEN:
C        SET THE UPPER INDEX OF AN INNER DO LOOP EQUAL TO THE
C        NUMBER OF STANDS.  OTHERWISE, SET IT EQUAL TO THE CURRENT ONE.
C
         N=II
         IF (LHVUNT) THEN
            IF (MGMIDS(IST1).NE.'NONE') N=NOSTND
         ENDIF
C
C        OPEN AN INNER DO LOOP FROM THE CURRENT STAND TO THE CURRENT
C        STAND OR THE LAST STAND (AS DEFINED ABOVE).
C
         DO 50 JJ=II,N
C
C        IF WE ARE ON A SUBSEQUENT STAND, THEN: FIND OUT IF THE
C        'FIRST' STAND IN A UNIT WAS SELECTED.  IF NOT, THEN
C        BRANCH TO THE OUTER LOOP.  IF YES, SEARCH FOR THE NEXT STAND
C        IN THE COORDINATED MGMT UNIT IN ORDER OF PRIORITY.
C
         IST=ISNSRT(JJ)
         IF (JJ.GT.II) THEN
            IF (IABS(IHVSTA(IST1,IHV)).EQ.2) GOTO 60
            IF (IABS(IHVSTA( IST,IHV)).NE.1) GOTO 50
            IF (MGMIDS(IST1).NE.MGMIDS(IST)) GOTO 50
         ENDIF

C        IF EXTERNAL SELECTION LOGIC IS BEING USED, WE WILL NEVER SELECT
C        A STAND THAT HAS A PRIORITY OF ZERO OR LESS THAN ZERO.

         IF (IHVEXT.EQ.1) THEN
            IF (HVPRI(IST,IHV).LE.0) THEN
               IHVSTA(IST,IHV)=2
               GOTO 50
            ENDIF
         ENDIF

C        IF MORE STANDS ARE NEEDED, THEN...

         IF (LMORE) THEN
C
C           IF THE YIELD IS ALMOST ZERO, THEN DON'T SELECT
C           THE STAND--SIGNAL THAT IT IS NOT NEEDED AND BRANCH
C           TO THE NEXT STAND.
C
            IF (HVYLDS(IST,IHV).LT. 0.000001) THEN
               PNEED=0.0
               IHVSTA(IST,IHV)=2
               GOTO 50
            ELSEIF (LHVMXC) THEN
C
C              IF THE MAX CONTIGUOUS ACRE CONSTRAINT IS IN USE, AND
C              IF CONTIGUOUS CLEAR CUT ACRES CREATED IF THIS STAND IS
C              SELECTED EXCEEDS THE MAX, DO NOT SELECT THE STAND.
C
               CALL HVCNTG (II,IHV,CONTIG,IRC)
               IF (IRC.GT.0) THEN
                  WRITE (JOPPRT,10) 'AREAS OR NEIGHBORS'
                  CALL RCDSET (2,.TRUE.)
                  LHVMXC=.FALSE.
               ELSEIF (CONTIG.GT.HVMXCC) THEN
                  PNEED=0.0
                  IHVSTA(IST,IHV)=2
                  GOTO 50
               ENDIF
            ENDIF
C
C           COMPUTE THE PORTION OF THE NEXT NEEDED STAND.
C            
            PNEED=(TRGETS(IHV)-(THNYLD+HRVYLD))/HVYLDS(IST,IHV)
C
            IF (LHVDEB) WRITE (JOPPRT,'('' IN HVSEL: IHV,IST='',
     >        2I4,'' PNEED='',E15.5)') IHV,IST,PNEED
C
C           IF THE PROPORTION NEEDED IS GT .999, ASSUME THAT IT IS
C           AT LEAST 1.0.
C
            IF (PNEED.GE.0.999) THEN
C
C              SET THE HARVEST STATUS CODE TO +/-3 (SELECTED), ADD UP
C              THE YIELD AND SUBTRACT THE 'THIN' (NOT SELECTED) YIELD.
C
               IHVSTA(IST,IHV)=3*IHVSTA(IST,IHV)
               HRVYLD=HRVYLD+HVYLDS(IST,IHV)
               THNYLD=THNYLD-HVTHIN(IST,IHV)
            ELSE
C
C              OTHERWISE, ONLY A PORTION OF THE YIELD FOR THIS STAND
C              IS NEEDED.  IF LPRTCT IS TRUE, THEN PREPARE TO SELECT
C              PART OF THE STAND, IF LPRTCT IS FALSE SELECT THE STAND
C              IF PNEED IS OVER 0.5 AND DON'T IF IT IS UNDER 0.5.
C
C              WHEN LPRTCT IS TRUE, AND IF THE PROTION IS VERY SMALL,
C              DO NOT CUT THE STAND, "THIN" IT.
C
C              SAVE THE PORTION IN HVPART...
C              A STATUS OF 4 IS CUT AND THIN.
C
               IF (LPRTCT) THEN
                  IF (PNEED.GT.0.01) THEN
                     IHVSTA(IST,IHV)=4
                     HRVYLD=HRVYLD+(HVYLDS(IST,IHV)*PNEED)
                     HVPART(IHV)=PNEED
                     ICPRT=IST
                  ELSE
                     IHVSTA(IST,IHV)=2
                  ENDIF
               ELSE
                  IF (PNEED.GT.0.5) THEN
                     IHVSTA(IST,IHV)=3*IHVSTA(IST,IHV)
                     HRVYLD=HRVYLD+HVYLDS(IST,IHV)
                     THNYLD=THNYLD-HVTHIN(IST,IHV)
                  ELSE
                     IHVSTA(IST,IHV)=2
                  ENDIF
               ENDIF
               LMORE=.FALSE.
            ENDIF
         ELSE
C
C           ELSE: THE STAND IS NOT NEEDED TO REACH THE TARGET.
C
            IHVSTA(IST,IHV)=2
         ENDIF
         IF (LHVDEB) WRITE (JOPPRT,'('' IN HVSEL 2: IHV,IST1='',
     >        2I4,'' IHVSTA,HVYLDS,HRVYLD='',I4,2E15.5)') IHV,IST1,
     >        IHVSTA(IST1,IHV),HVYLDS(IST,IHV),HRVYLD
         
   50    CONTINUE
   60    CONTINUE
      ENDIF
C
C     MAKE SURE THAT IHVSTA IS POSITIVE (USE OF SIGN BIT HAS ENDED).
C
      DO 90 IST=1,NOSTND
      IHVSTA(IST,IHV)=IABS(IHVSTA(IST,IHV))
   90 CONTINUE
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVSEL: IHV='',I3,'' NOSTND='',
     >   I4,'' LHVOUT(IHV)='',L1)') IHV,NOSTND,LHVOUT(IHV)

C     WRITE OUTPUT STATISTICS:

      IF (LHVDEB.OR.LHVOUT(IHV)) THEN
         WRITE (JOPPRT,100) MIY(MICYC-1),MICYC-1,IHV,
     >                      TRGETS(IHV)*FT3pACRtoM3pHA,
     >                      HVPLAB(IHV)(1:LNHPLB(IHV,1))
  100    FORMAT (//' YEAR=',I5,'  MASTER CYCLE=',I2,'  POLICY=',
     >           I2,'  TARGETED RESOURCE=',E15.7,'  MSPLABEL= ',A)
         IF (LHIER) THEN
            IF (IHV.EQ.1) THEN
               WRITE (JOPPRT,105) IHV,
     >         'CAN NOT BE SELECTED UNDER ANY OTHER POLICY.'
            ELSE
               WRITE (JOPPRT,105) IHV,
     >         'ARE LIMITED TO STANDS NOT SELECTED UNDER POLICY 1.'
  105          FORMAT (' NOTE:  POLICY HIERARCHY IN USE.  ',
     >                 'STANDS SELECTED UNDER POLICY',I3,' ',A)
            ENDIF
         ENDIF
C
C        IF THE TARGET IS GT ZERO, WRITE THE BODY OF THE TABLE, ELSE
C        SKIP THIS OUTPUT.
C
         IF (THNYLD.LT.0.) THNYLD=0.0
         IF (HRVYLD.LT.0.) HRVYLD=0.0
         IF (TRGETS(IHV).GT.0.0) THEN
            WRITE (JOPPRT,110)
  110       FORMAT (2(1X,60('-'),1X)/
     >        2(' STDIDENT',19X,'MGMT  PRIORITY    CREDIT   SELECT ')/
     >        2(' ',26('-'),   ' ---- ---------- ---------- ------ '))
            N=0
            DO 130 II=1,NOSTND
            IST=ISNSRT(II)
C
C           SKIP STANDS THAT DO NOT APPLY TO THIS POLICY.
C
            IF (IHVSTA(IST,IHV).EQ.0) GOTO 130
            N=N+1
            IPTOUT(N)=IST
            IF (IHVSTA(IST,IHV).EQ.2) THEN
               XCUT(N)=HVTHIN(IST,IHV)
            ELSE
               XCUT(N)=HVYLDS(IST,IHV)
            ENDIF
            IF (MGMIDS(IST).EQ.'NONE') THEN
               COUTID(N)=' '
            ELSE
               COUTID(N)=MGMIDS(IST)
            ENDIF
            IF (N.GE.2) THEN
               WRITE (JOPPRT,120) (STDIDS(IPTOUT(I)),COUTID(I),
     >               HVPRI(IPTOUT(I),IHV),XCUT(I)*FT3pACRtoM3pHA,
     >               CSEL(IHVSTA(IPTOUT(I),IHV)), I=1,N)
  120          FORMAT (2(1X,A26,1X,A4,2E11.4,1X,A5,2X))
               N=0
            ENDIF
  130       CONTINUE
            IF (N.NE.0) WRITE (JOPPRT,120) (STDIDS(IPTOUT(I)),
     >                  COUTID(I),HVPRI(IPTOUT(I),IHV),
     >                  XCUT(I)*FT3pACRtoM3pHA,
     >                  CSEL(IHVSTA(IPTOUT(I),IHV)), I=1,N)
C
C           IF ICPRT IS GT 0, WRITE A MSG ABOUT PARTIALLY SELECTED
C           STANDS.
C
            IF (ICPRT.GT.0) WRITE (JOPPRT,140) HVPART(IHV)*100.0,
     >                                         STDIDS(ICPRT)
  140       FORMAT (/' **YES= ',F5.1,' PERCENT OF STAND ',A,
     >              ' WILL BE SELECTED.  THE REMAINING PORTION IS',
     >              ' NOT SELECTED.')
C
C           COMPUTE PERCENT OF TARGET ACTUALLY SELECTED.
C
            PNEED=(((HRVYLD+THNYLD)/TRGETS(IHV))*100.)
            WRITE (JOPPRT,'()')
            WRITE (JOPPRT,150) HRVYLD*FT3pACRtoM3pHA,
     >                         THNYLD*FT3pACRtoM3pHA,
     >                         (HRVYLD+THNYLD)*FT3pACRtoM3pHA,PNEED
  150       FORMAT  (' SELECTED RESOURCE=',E14.7,
     >               '  NON-SELECTED RESOURCE SUPPLY=',E14.7,
     >         '  TOTAL=',E14.7,:,'  PERCENT OF TARGET=',F6.1)
         ELSE
            WRITE (JOPPRT,150) HRVYLD*FT3pACRtoM3pHA,
     >                         THNYLD*FT3pACRtoM3pHA,
     >                         (HRVYLD+THNYLD)*FT3pACRtoM3pHA
         ENDIF
      ENDIF
C
C     WRITE THE MACHINE READABLE VERSION OF THE OUTPUT IF IT IS
C     REQUESTED.
C
      IF (JOHVDS(IHV).GT.0) THEN
C
C        COUNT UP THE NUMBER OF OUTPUT RECORDS.
C
         N=0
         DO 160 II=1,NOSTND
         IF (IHVSTA(ISNSRT(II),IHV).NE.0) N=N+1
  160    CONTINUE
C
C        WRITE THE HEADER RECORDS
C
         CALL VARVER (VVER)
         CALL GRDTIM (DAT,TIM)
         WRITE (JOHVDS(IHV),170) N,MIY(MICYC-1),MICYC-1,IHV,LHIER,
     >         VVER,DAT,TIM,HVPLAB(IHV)(1:LNHPLB(IHV,1)),
     >         TRGETS(IHV)*FT3pACRtoM3pHA,HRVYLD*FT3pACRtoM3pHA,
     >         THNYLD*FT3pACRtoM3pHA,HVPART(IHV)
  170    FORMAT ('-9MS1',2I5,2I3,L2,4(1X,A)/'-9MS2',4E14.7)
C
C        IF THE NUMBER OF OUTPUT RECORDS IS ZERO, SKIP THE POLICY.
C
         IF (N.LE.0) GOTO 200
C
C        WRITE THE BASIC OUTPUT RECORDS.
C
         DO 190 II=1,NOSTND
         IST=ISNSRT(II)
         IHVST=IHVSTA(IST,IHV)
         IF (IHVST.EQ.0) GOTO 190
         IHVST=IABS(IHVST)
         IF (IHVST.EQ.2) THEN
            XC=HVTHIN(IST,IHV)
         ELSE
            XC=HVYLDS(IST,IHV)
         ENDIF
         WRITE (JOHVDS(IHV),180) STDIDS(IST),MGMIDS(IST),
     >          HVPRI(IST,IHV),XC,CSEL(5)(IHVST:IHVST)
  180    FORMAT (A26,1X,A4,2E11.4,1X,A1)
  190    CONTINUE
      ENDIF
C
C     IF EXTERNAL SELECTION METHOD 1 IS USED, WRITE OUT THE ACTUAL SELECTIONS
C     IN STAND-SORTED ORDER.
C      
      IF (IHVEXT.EQ.1) THEN
         CALL C11SRT (NOSTND,CISNUM,ISNSRT,.FALSE.)
         JEXOPT=83
         OPEN (UNIT=JEXOPT,FILE='PPE_ActualSelections.txt',
     >         STATUS='REPLACE')
         WRITE(JEXOPT,'(''"StandID","Year","Selected"'')')
         DO II=1,NOSTND
            IST=ISNSRT(II)
            IF (IHVSTA(IST,1).NE.0) THEN
              N=MAX(1,IHVSTA(IST,1)-1)
              IF (N.GT.2) N=1
              WRITE (JEXOPT,'(''"'',A,''",'',I5,'','',I2)')
     >          TRIM(STDIDS(IST)),MIY(MICYC-1),N
            ENDIF
         ENDDO
         CLOSE (UNIT=JEXOPT)
         WRITE (6,191) MIY(MICYC-1)
  191    FORMAT (/' PPE Note: Year=',I4,
     >            ' SYSTEM CALL MakeNewActivities')
         CALL SYSTEM ("MakeNewActivities")
         OPEN (UNIT=JEXOPT,FILE='PPE_MoreActivities.txt',
     >         STATUS='OLD',ERR=195)
         GOTO 196
  195    CONTINUE
         JEXOPT=-1         
  196    CONTINUE
      ELSE
         JEXOPT=-1
      ENDIF
  200 CONTINUE
      RETURN
      END
