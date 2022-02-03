      SUBROUTINE CVIN (PASKEY,ARRAY,LNOTBK,LKECHO)
      IMPLICIT NONE
C----------
C COVR $Id: cvin.f 2443 2018-07-09 15:07:14Z gedixon $
C----------
C  PROCESSES OPTIONS AND WRITES OPTION TABLE FOR COVER ROUTINES.
C  CALLED FROM **INITRE**.
C----------
C FIELD       ** (OPTION NUMBER) KEYWORD **
C------------------------------------------
C             ** (1) END **
C----------
C             ** (2) CANOPY **
C
C       -- LCNOP -- LOGICAL FLAG FOR CANOPY OPTION
C 1     -- COVOPT -- FOLIAGE BIOMASS EQUATION OPTION.  PRESENTLY NOT
C                    USED, BECAUSE TREE AGE NOT CARRIED BY PROGNOSIS.
C----------
C             ** (3) SHRUBS **
C
C       -- LBROW -- LOGICAL FLAG FOR SHRUBS OPTION
C 1     -- SAGE -- TIME SINCE DISTURBANCE
C 2     -- IHTYPE -- HABITAT TYPE CODE FOR SHRUBS OPTION ONLY
C 3     -- IPHYS -- PHYSIOGRAPHIC POSITION CODE
C 4     -- IDIST -- TYPE OF DISTURBANCE CODE
C----------
C             ** (4) SHRBLAYR **
C
C       -- LCAL1 -- LOGICAL FLAG FOR CALIBRATION BY SHRUB LAYER
C       -- LCALIB -- LOGICAL FLAG FOR CALIBRATION
C       -- NKLASS -- NUMBER OF OBSERVED SHRUB LAYERS
C       -- SUMCVR -- TOTAL OBSERVED SHRUB COVER
C 1,3,5 -- AVGBHT(3) -- OBSERVED AVERAGE HEIGHT OF UP TO 3 SHRUB LAYERS
C 2,4,6 -- AVGBPC(3) -- OBSERVED AVERAGE COVER OF UP TO 3 SHRUB LAYERS
C----------
C             ** (5) SHRUBHT **
C
C       -- LCAL2 -- LOGICAL FLAG FOR CALIBRATION BY SPECIES
C       -- LCALIB -- LOGICAL FLAG FOR CALIBRATION
C 1-31  -- SHRBHT(31) -- OBSERVED HEIGHTS BY SPECIES
C----------
C             ** (6) SHRUBPC **
C
C       -- LCAL2 -- LOGICAL FLAG FOR CALIBRATION BY SPECIES
C       -- LCALIB -- LOGICAL FLAG FOR CALIBRATION
C 1-31  -- SHRBPC(31) -- OBSERVED COVER BY SPECIES
C----------
C             ** (8) NOCOVOUT **
C
C       -- LCOVER -- LOGICAL FLAG FOR TURNING OFF CANOPY COVER DISPLAY
C----------
C             ** (9) NOSHBOUT **
C
C       -- LSHRUB -- LOGICAL FLAG FOR TURNING OFF SHRUB COVER DISPLAY
C----------
C             ** (10) NOSUMOUT **
C
C       -- LCVSUM -- LOGICAL FLAG FOR TURNING OFF SUMMARY DISPLAY
C----------
C----------
C             ** (12) COVER **
C
C       -- IDT -- CYCLE OR DATE TO TURN ON COVER OPTIONS
C       -- JOSHRB -- LOGICAL UNIT NUMBER FOR COVER OUTPUT
C----------
C             ** (13) SHOWSHRB **
C
C       -- LSHOW -- LOGICAL FLAG FOR SHOWSHRB OPTION
C       -- NSHOW -- NUMBER OF SPECIES FOR DISPLAY
C 1-6   -- ISHOW(6)-- SUBSCRIPTS OF SPECIES FOR DISPLAY
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CVCOM.F77'
C
COMMONS
C----------
C  INTERNAL STORAGE
C----------
      LOGICAL DEBUG,LKECHO
      LOGICAL LNOTBK(7),LSORT
      REAL ARRAY(7),ARRAY2(8)
      INTEGER KNDEX(33)
      INTEGER KSIZE,ISIZE,KODE,NUMBER,I,J,K,IDT,KEY,IRTNCD
      REAL TEMPHT,TEMPPC
      CHARACTER*10 KARD(7)
      CHARACTER*8 TABLE(20),KEYWRD,PASKEY
      CHARACTER*4 SNAME(33),SHRBSP(8)
      DATA ISIZE/20/, KSIZE/33/
      DATA TABLE /'END','CANOPY','SHRUBS','SHRBLAYR','SHRUBHT',
     &           'SHRUBPC','DEBUG','NOCOVOUT','NOSHBOUT','NOSUMOUT',
     &           '        ','COVER','SHOWSHRB','CVNOHEAD',6*' ' /
      DATA SNAME /
     & 'ARUV','BERB','LIBO','PAMY','SPBE','VASC','CARX','LONI',
     & 'MEFE','PHMA','RIBE','ROSA','RUPA','SHCA','SYMP','VAME',
     & 'XETE','FERN','COMB','ACGL','ALSI','AMAL','CESA','CEVE',
     & 'COST','HODI','PREM','PRVI','SALX','SAMB','SORB',
     & '    ','-999'/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CVIN',4,0)
C----------
C  TURN ON SWITCH TO CALL DIAMETER DUBBING SUBROUTINE.
C----------
      IF (DEBUG) WRITE(JOSTND,4000)
 4000 FORMAT ('**CALLING CVIN')
      LDUBDG = .TRUE.
C----------
C     SORT SHRUB NAMES.
C----------
      CALL CH4SRT (KSIZE,SNAME,KNDEX,.TRUE.)
C----------
C  SET KEYWORD = PASSED KEYWORD, BRANCH TO FIND KEYWORD IN THE TABLE.
C----------
      KEYWRD = PASKEY
      GO TO 30
C----------
C  TO READ ANOTHER COVER KEYWORD, BRANCH BACK HERE.
C----------
   10 CONTINUE
      CALL KEYRDR (IREAD,JOSTND,DEBUG,KEYWRD,
     >             LNOTBK,ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)
C----------
C  RETURN KODES  0=NO ERROR; 1=COLUMN 1 BLANK; 2=EOF
C----------
      IF (KODE .EQ. 0) GO TO 30
      IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      CALL ERRGRO(.TRUE.,6)
      GO TO 10
   30 CONTINUE
C----------
C  CALL FNDKEY TO FIND KEYWORD IN THE TABLE
C----------
      CALL FNDKEY (NUMBER,KEYWRD,TABLE,ISIZE,KODE,DEBUG,JOSTND)
C----------
C  RETURN KODES  0=NO ERROR; 1=KEYWORD NOT FOUND.
C----------
      IF (KODE .EQ. 0) GO TO 40
      IF (KODE .EQ. 1) THEN
         CALL ERRGRO (.TRUE.,1)
         GO TO 10
      ENDIF
   40 CONTINUE
C----------
C  PROCESS OPTIONS.
C----------
      GO TO (1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,
     &       2000,2100,2200,2300,2400,2500,2600,2700,2800,2900), NUMBER
 1000 CONTINUE
C==========  OPTION NUMBER  1: END       ====================
      IF(LKECHO)WRITE(JOSTND,8090) KEYWRD
 8090 FORMAT (/,A8,'   END COVER OPTIONS')
      RETURN
C
 1100 CONTINUE
C========== OPTION NUMBER  2: CANOPY     ====================
      LCNOP = .TRUE.
      COVOPT = 2
      IF(LKECHO)WRITE(JOSTND,9000) KEYWRD
 9000 FORMAT (/,A8,'   CANOPY MODEL CALCULATIONS: TREE CROWN ',
     &               'WIDTH, CROWN SHAPE, AND FOLIAGE BIOMASS')
      IF (.NOT. LNOTBK(1)) GO TO 1150
      COVOPT = IFIX(ARRAY(1))
      IF(LKECHO)WRITE(JOSTND,9002)
 9002 FORMAT (T12,'FOLIAGE BIOMASS EQUATION REQUIRES TREE AGES')
 1150 CONTINUE
      GO TO 10
 1200 CONTINUE
C========== OPTION NUMBER  3: SHRUBS    ====================
      LBROW = .TRUE.
      SAGE = -1.0
      IF(LKECHO)WRITE(JOSTND,9004) KEYWRD
 9004 FORMAT (/,A8,'   SHRUB MODEL OPTIONS:  ')
      IF (.NOT. LNOTBK(1)) GO TO 1220
      SAGE = ARRAY(1)
      IF(LKECHO)WRITE(JOSTND,9104) SAGE
 9104 FORMAT (T12,'TIME SINCE DISTURBANCE = ', F5.1,' YEARS')
      GO TO 1230
 1220 CONTINUE
      IF ((IAGE.LE.0).AND.LKECHO)WRITE(JOSTND,9005)
 9005 FORMAT (T12,'WARNING: SHRUB MODELS REQUIRE TIME SINCE',
     &       ' DISTURBANCE ON THE SHRUBS CARD OR' / T12,'STAND AGE ',
     &       'ON THE STDINFO CARD.  INITIAL TIME SINCE DISTURBANCE ',
     &       'WILL BE SET TO 3 YEARS')
      IF ((IAGE.GT.0).AND.LKECHO)WRITE(JOSTND,9205) IAGE
 9205 FORMAT (T12,'TIME SINCE DISTURBANCE WILL BE SET TO STAND AGE=',
     &  I5,' YEARS')
 1230 CONTINUE
C
      IHTYPE = 0
      IF (.NOT. LNOTBK(2)) GO TO 1250
      IHTYPE = INT(ARRAY(2))
      IF(LKECHO)WRITE(JOSTND,9003) IHTYPE
 9003 FORMAT (T12,'HABITAT TYPE = ',I3,' SELECTED FOR PROCESSING ',
     &        'SHRUBS OPTIONS')
 1250 CONTINUE
C
      IPHYS = 2
      IF (.NOT. LNOTBK(3)) GO TO 1260
      IPHYS = INT(ARRAY(3))
      IF ((IPHYS.EQ.1).AND.LKECHO)WRITE(JOSTND,4001) IPHYS
 4001 FORMAT (T12,'PHYSIOGRAPHY TYPE = ',I3,' (BOTTOM)')
      IF ((IPHYS.EQ.2).AND.LKECHO)WRITE(JOSTND,4002) IPHYS
 4002 FORMAT (T12,'PHYSIOGRAPHY TYPE = ',I3,' (LOWER SLOPE)')
      IF ((IPHYS.EQ.3).AND.LKECHO)WRITE(JOSTND,4003) IPHYS
 4003 FORMAT (T12,'PHYSIOGRAPHY TYPE = ',I3,' (MIDSLOPE)')
      IF ((IPHYS.EQ.4).AND.LKECHO)WRITE(JOSTND,4004) IPHYS
 4004 FORMAT (T12,'PHYSIOGRAPHY TYPE = ',I3,' (UPPER SLOPE)')
      IF ((IPHYS.EQ.5).AND.LKECHO)WRITE(JOSTND,4005) IPHYS
 4005 FORMAT (T12,'PHYSIOGRAPHY TYPE = ',I3,' (RIDGE)')
 1260 CONTINUE
C
      IDIST = 1
      IF (.NOT. LNOTBK(4)) GO TO 1270
      IDIST = INT(ARRAY(4))
      IF ((IDIST.EQ.1).AND.LKECHO)WRITE(JOSTND,4011) IDIST
 4011 FORMAT (T12,'DISTURBANCE TYPE = ',I3,' (NONE)')
      IF ((IDIST.EQ.2).AND.LKECHO)WRITE(JOSTND,4012) IDIST
 4012 FORMAT (T12,'DISTURBANCE TYPE = ',I3,' (MECHANICAL)')
      IF ((IDIST.EQ.3).AND.LKECHO)WRITE(JOSTND,4013) IDIST
 4013 FORMAT (T12,'DISTURBANCE TYPE = ',I3,' (BURN)')
      IF ((IDIST.EQ.4).AND.LKECHO)WRITE(JOSTND,4014) IDIST
 4014 FORMAT (T12,'DISTURBANCE TYPE = ',I3,' (ROAD)')
 1270 CONTINUE
      GO TO 10
 1300 CONTINUE
C========== OPTION NUMBER  4: SHRBLAYR ====================
      IF(LKECHO)WRITE(JOSTND,9011) KEYWRD
 9011 FORMAT (/,A8,'   SHRUB MODEL CALIBRATION BY LAYER')
      LCAL1 = .TRUE.
      LCALIB = .TRUE.
      AVGBHT(1) = ARRAY(1)
      AVGBPC(1) = ARRAY(2)
      AVGBHT(2) = ARRAY(3)
      AVGBPC(2) = ARRAY(4)
      AVGBHT(3) = ARRAY(5)
      AVGBPC(3) = ARRAY(6)
C----------
C  COUNT THE NUMBER OF CLASSES INPUT, AND ADD UP TOTAL COVER.
C----------
      NKLASS = 0
      SUMCVR = 0.0
      DO 110 I=2,6,2
      IF (LNOTBK(I)) NKLASS=NKLASS+1
      SUMCVR = SUMCVR + ARRAY(I)
  110 CONTINUE
C----------
C  BUBBLE-SORT THE % COVER AND HEIGHT FIGURES BY DECREASING HEIGHT.
C----------
  120 CONTINUE
      LSORT = .FALSE.
      DO 130 I=1,2
      J = I + 1
      IF ( AVGBHT(I) .GE. AVGBHT(J) ) GO TO 130
      LSORT = .TRUE.
      TEMPHT = AVGBHT(I)
      TEMPPC = AVGBPC(I)
      AVGBHT(I) = AVGBHT(J)
      AVGBPC(I) = AVGBPC(J)
      AVGBHT(J) = TEMPHT
      AVGBPC(J) = TEMPPC
  130 CONTINUE
      IF ( LSORT ) GO TO 120
C----------
C  WRITE SORTED INPUT CALIBRATION VALUES.
C----------
      IF(LKECHO)WRITE(JOSTND,9012)
 9012 FORMAT (T12,'LAYER  HEIGHT  COVER'/
     &        T12,'-----  ------  -----')
      DO 140 I = 1,NKLASS
      IF(LKECHO)WRITE(JOSTND,9013) I,AVGBHT(I),AVGBPC(I)
 9013 FORMAT (T12,I3,F9.1,F8.1)
  140 CONTINUE
      GO TO 10
 1400 CONTINUE
C========== OPTION NUMBER  5: SHRUBHT  ====================
      IF(LKECHO)WRITE(JOSTND,9014) KEYWRD
 9014 FORMAT (/,A8,'   SHRUB MODEL CALIBRATION BY SPECIES',
     &        ' HEIGHT')
      LCAL2 = .TRUE.
      LCALIB = .TRUE.
      DO 210 K = 1,4
      READ (IREAD,8000,END=600) (SHRBSP(I),ARRAY2(I),I=1,8)
 8000 FORMAT (8(A4,F6.1))
C----------
C  WRITE INPUT VALUES.
C----------
      IF(LKECHO)WRITE(JOSTND,8099) (SHRBSP(I),ARRAY2(I),I=1,8)
 8099 FORMAT (T12,8(A4,F6.1))
      IRECNT = IRECNT + 1
C----------
C  CALL **CH4BSR** TO FIND THE SHRUB SPECIES ABBREVIATIONS.
C  "NUMBER" WILL RETURN THE SHRUB SPECIES INDEX NUMBER.
C----------
      DO 230 I=1,8
      CALL CH4BSR(KSIZE,SNAME,KNDEX,SHRBSP(I),NUMBER)
C----------
C  RETURN CODES:  0=NOT FOUND, >0=KEYWORD POSITION
C----------
      IF ( NUMBER.GT.0 ) GO TO 220
      CALL ERRGRO (.TRUE.,1)
      GO TO 230
  220 CONTINUE
C----------
C  '-999' ENCOUNTERED: END OF SHRUB DATA.
C----------
      IF (NUMBER .EQ. 33) GO TO 10
C----------
C  IF NO INFORMATION WAS INPUT FOR A GIVEN SHRUB SPECIES (THE
C  PARAMETER FIELD WAS BLANK & NUMBER=32) DO NOT ERASE THE DUMMY
C  VALUE OF -99999.0 WHICH WAS ASSIGNED TO SHRBHT(I) IN **CVINIT**.
C----------
      IF ( NUMBER .EQ. 32 ) GO TO 230
      SHRBHT(NUMBER) = ARRAY2(I)
  230 CONTINUE
  210 CONTINUE
 1500 CONTINUE
C========== OPTION NUMBER  6: SHRUBPC   ====================
      IF(LKECHO)WRITE(JOSTND,9022) KEYWRD
 9022 FORMAT (/,A8,'   SHRUB MODEL CALIBRATION BY SPECIES',
     &        ' PERCENT COVER')
      LCAL2 = .TRUE.
      LCALIB = .TRUE.
      DO 310 K = 1,4
      READ (IREAD,8000,END=600) (SHRBSP(I),ARRAY2(I),I=1,8)
C----------
C  WRITE INPUT VALUES.
C----------
      IF(LKECHO)WRITE(JOSTND,8099) (SHRBSP(I),ARRAY2(I),I=1,8)
      IRECNT = IRECNT + 1
C----------
C  CALL **CH4BSR** TO FIND THE SHRUB SPECIES ABBREVIATIONS.
C  "NUMBER" WILL RETURN THE SHRUB SPECIES INDEX NUMBER.
C----------
      DO 330 I=1,8
      CALL CH4BSR(KSIZE,SNAME,KNDEX,SHRBSP(I),NUMBER)
C----------
C  RETURN CODES:  0=NOT FOUND, >0=KEYWORD POSITION
C----------
      IF ( NUMBER.GT.0 ) GO TO 320
      CALL ERRGRO (.TRUE.,1)
      GO TO 330
  320 CONTINUE
C----------
C  '-999' ENCOUNTERED: END OF SHRUB DATA.
C----------
      IF (NUMBER .EQ. 33) GO TO 10
C----------
C  IF NO INFORMATION WAS INPUT FOR A GIVEN SHRUB SPECIES (THE
C  PARAMETER FIELD WAS BLANK & NUMBER=32) DO NOT ERASE THE DUMMY
C  VALUE OF -99999.0 WHICH WAS ASSIGNED TO SHRBPC(I) IN **CVINIT**.
C----------
      IF ( NUMBER .EQ. 32 ) GO TO 330
      SHRBPC(NUMBER) = ARRAY2(I)
  330 CONTINUE
  310 CONTINUE
C----------
C  ENTER HERE IF END-OF-FILE ENCOUNTERED WHILE READING
C  SHRUB CALIBRATION DATA.
C----------
  600 CONTINUE
      CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
 1600 CONTINUE
C========== OPTION NUMBER  7: DEBUG    ====================
      IF(LKECHO)WRITE(JOSTND,9027)
 9027 FORMAT(/,'DEBUG',6X,'IS NO LONGER PROCESSED AS A COVER OPTION;'/
     &        11X,'USE STANDARD PROGNOSIS DEBUG PROCEDURES.')
      GO TO 10
 1700 CONTINUE
C========== OPTION NUMBER  8: NOCOVOUT ====================
      LCOVER = .FALSE.
      IF(LKECHO)WRITE(JOSTND,9028) KEYWRD
 9028 FORMAT (/,A8,'   CANOPY COVER STATISTICS DISPLAY WILL NOT ',
     &               'BE WRITTEN')
      GO TO 10
 1800 CONTINUE
C========== OPTION NUMBER  9: NOSHBOUT===================
      LSHRUB = .FALSE.
      IF(LKECHO)WRITE(JOSTND,9030) KEYWRD
 9030 FORMAT (/,A8,'   SHRUB STATISTICS DISPLAY WILL NOT BE WRITTEN')
      GO TO 10
 1900 CONTINUE
C========== OPTION NUMBER 10: NOSUMOUT ====================
      LCVSUM = .FALSE.
      IF(LKECHO)WRITE(JOSTND,9032) KEYWRD
 9032 FORMAT (/,A8,'   CANOPY AND SHRUBS SUMMARY DISPLAY WILL NOT ',
     &               'BE WRITTEN')
      GO TO 10
 2000 CONTINUE
C========== OPTION NUMBER 11:          ====================
      GO TO 10
 2100 CONTINUE
C========== OPTION NUMBER 12: COVER    ====================
      IDT = 1
      IF (ARRAY(1) .GT. 0.0) IDT = IFIX(ARRAY(1))
      IF(LKECHO)WRITE(JOSTND,9035) KEYWRD,IDT
 9035 FORMAT (/,A8,'   COVER OPTIONS:  ',
     &  /T12,'DATE/CYCLE=',I5)
      CALL OPNEW (KODE,IDT,900,0,ARRAY)
      IF (KODE .GT. 0) GO TO 10
      IF (LNOTBK(2)) JOSHRB = IFIX(ARRAY(2))
      IF(LKECHO)WRITE(JOSTND,9036) JOSHRB
 9036 FORMAT (T12,'DATA SET REFERENCE NUMBER =',I3)
      GO TO 10
 2200 CONTINUE
C========== OPTION NUMBER 13: SHOWSHRB ====================
      IF(LKECHO)WRITE(JOSTND,9037) KEYWRD
 9037 FORMAT (/,A8,'   SELECT SHRUB SPECIES FOR OUTPUT')
      IRECNT = IRECNT + 1
      LSHOW = .TRUE.
      NSHOW = 0
      READ (IREAD,8001,END=600) (SHRBSP(I),I=1,6)
 8001 FORMAT (6(6X,A4))
C----------
C  CALL **CH4BSR** TO FIND THE SHRUB SPECIES ABBREVIATIONS.
C----------
      DO 430 I=1,6
      CALL CH4BSR(KSIZE,SNAME,KNDEX,SHRBSP(I),NUMBER)
      IF ( NUMBER.GT.0 ) GO TO 420
      CALL ERRGRO (.TRUE.,1)
      GO TO 430
  420 CONTINUE
      IF ( NUMBER .LT. 32 ) NSHOW = NSHOW + 1
      ISHOW(I) = NUMBER
  430 CONTINUE
C----------
C  WRITE INPUT VALUES.
C----------
      IF(LKECHO)WRITE(JOSTND,8091) (SHRBSP(I),I=1,NSHOW)
 8091 FORMAT (T12,6(6X,A4))
      GO TO 10
 2300 CONTINUE
C========== OPTION NUMBER 14: CVNOHEAD ====================
      IF (LNOTBK(1)) JCVNOH=IFIX(ARRAY(1))
      LCVNOH=.TRUE.
      IF(LKECHO)WRITE(JOSTND,2310) KEYWRD,JCVNOH
 2310 FORMAT (/,A8,'   WRITE COVER DATA WITHOUT A HEADING TO',
     >        ' DATA SET REFERENCE NUMBER ',I2)
      GOTO 10
 2400 CONTINUE
C========== OPTION NUMBER 15:          ====================
      GO TO 10
 2500 CONTINUE
C========== OPTION NUMBER 16:          ====================
      GO TO 10
 2600 CONTINUE
C========== OPTION NUMBER 17:          ====================
      GO TO 10
 2700 CONTINUE
C========== OPTION NUMBER 18:          ====================
      GO TO 10
 2800 CONTINUE
C========== OPTION NUMBER 19:          ====================
      GO TO 10
 2900 CONTINUE
C========== OPTION NUMBER 20:          ====================
      GO TO 10
C
      ENTRY CVKEY (KEY,PASKEY)
      PASKEY = TABLE(KEY)
      RETURN
      END
