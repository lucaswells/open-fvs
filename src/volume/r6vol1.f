C----------
C VOLUME $Id: r6vol1.f 2944 2020-02-03 22:59:12Z lancedavid $
C----------
      SUBROUTINE R6VOL1(IAPZ,DBHOB,FCLASS,XLOGS,LOGDIA,LOGVOL,INTBF)
C== last modified  08-13-2003
C ENTER WITH COMPUTED DIBS FOR 1 TO 20 LOGS IN A TREE.
C RETURN WITH GROSS BD-FT AND CU-FT VOLUME FOR EACH LOG.
C USE SCRIBNER DIAMETER-LENGTH FACTORS FOR COMPUTING BD-FT SCALE.
C MINIMUM LOG DIB = 2 INCHES.
C MAXIMUM LOG DIB = 120 INCHES.
C EASTSIDE:
C   XLOGS = NUMBER OF 16-FT LOGS TO NEAREST HALF
C   COMPUTE 16-FT SCALE FOR WHOLE LOGS.
C   COMPUTE 8-FT SCALE FOR ANY HALF LOG AT THE TOP.
C   A SINGLE HALF LOG IN THE TREE IS NOT PERMITTED.
C WESTSIDE:
C   XLOGS = NUMBER OF 16-FT LOGS
C   COMPUTE 16-FT EQUIVALENTS OF 32-FT SCALE FOR ALL WHOLE LOGS.
C   COMPUTE STRAIGHT 16-FT SCALE FOR ANY HALF LOG IN THE TREE.

      REAL LOGDIA(21,3),LOGVOL(7,20),XLOGS,DBHOB
      REAL X,BOTV16,TOPV16,R,F,INTBF(20),bfint
      INTEGER IFTR(132),FCLASS,IAPZ,LOGS,I,KD,KBOT,KTOP
      INTEGER IBOT16,ITOP16,K,IV32,ITOPGV,IBOTGV,IG
 
C     ***** SCRIBNER DIAMETER-LENGTH FACTORS *****
C IFTR(1-5)     APPLY TO ALL LOG LENGTHS WITH DIB (1-5)
C IFTR(6-17)    APPLY ONLY TO 16-FT LOGS WITH DIB (6-11 )
C IFTR(12-17)   APPLY ONLY TO 32-FT LOGS WITH DIB (6-11)
C IFTR(18-126)  APPLY TO ALL LOG LENGTHS WITH DIB (12-120)
C IFTR(127-132) APPLY ONLY TO  8-FT LOGS WITH DIB (6-11)

      DATA IFTR /0,143,390,676,1070,1249,1608,1854,2410,3542,4167,
     > 1570,1800,2200,2900,3815,4499,4900,6043,7140,8880,10000,
     > 11528,13290,14990,17499,18990,20880,23510,25218,28677,
     > 31249,34220,36376,38040,41060,44376,45975,48990,50000,
     > 54688,57660,64319,66731,70000,75240,79480,83910,87190,
     > 92501,94990,99075,103501,107970,112292,116990,121650,
     > 126525,131510,136510,141610,146912,152210,157710,163288,
     > 168990,174850,180749,186623,193170,199120,205685,211810,
     > 218501,225685,232499,239317,246615,254040,261525,269040,
     > 276630,284260,292501,300655,308970,317360,325790,334217,
     > 343290,350785,359120,368380,376610,385135,393380,402499,
     > 410834,419166,428380,437499,446565,455010,464150,473430,
     > 482490,491700,501700,511700,521700,531700,541700,552499,
     > 562501,573350,583350,594150,604170,615010,625890,636660,
     > 648380,660000,671700,683330,695011,1160,1400,1501,2084,
     > 3126,3749/



C     ***** CLEAR PREVIOUS TREE *****
      DO I=1,20
        INTBF(I) = 0
        LOGVOL(1,I) = 0
        LOGVOL(4,I) = 0
      ENDDO

         X = 0.0

      LOGS = INT(AINT(XLOGS))
      IF(IAPZ.EQ.1) GO TO 40

C     ***** (WESTSIDE) 32-FT LOG SCALE *****
      DO 20 I=1,LOGS,2
      KD = INT(LOGDIA(I,1))
      KBOT = KD+6
      IF (KD.LE.11) KBOT=KD
      KD = INT(LOGDIA(I+1,1))
      KTOP = KD+6
      IF (KD.LE.11) KTOP=KD

C     ***** GET 16-FT SCALE FOR BOTH HALFS OF LOG *****
      IBOT16 = (IFTR(KBOT) * 16 + 500) / 1000
      BOTV16 = IBOT16
      IF (LOGDIA(I+1,1).EQ.0.0) GO TO 30
      ITOP16 = (IFTR(KTOP) * 16 + 500) / 1000
      TOPV16 = ITOP16
      R = TOPV16 / (TOPV16 + BOTV16)

C     ***** GET 32-FT SCALE FOR ENTIRE LOG *****
      KD = INT(LOGDIA(I+1,1))
      K = KTOP
      IF (KD.GE.6.AND.KD.LE.11) K=KD+6
      IV32 = (IFTR(K) * 32 + 500) / 1000
      IV32 = IV32

C  INTERNATIONAL BDFT
      CALL INTL14(LOGDIA(I+1,1),32.0,BFINT)
      INTBF(I) = BFINT

C     ***** PROPORTIONATE 32-FT SCALE BY LOG HALFS *****
      ITOPGV = INT(REAL(IV32) * R + 0.5)
      IBOTGV = IV32 - ITOPGV
      LOGVOL(1,I+1) = ITOPGV
      LOGVOL(1,I) = IBOTGV
   20 CONTINUE
      GO TO 60
                    
C     ***** SINGLE 16-FT LOG (TOP OR BUTT OF TREE) *****
   30 IBOTGV = INT(BOTV16)
      LOGVOL(1,I) = IBOTGV

C  INTERNATIONAL BDFT
      CALL INTL14(LOGDIA(I,1),16.0,BFINT)
      INTBF(I) = BFINT

      GO TO 60

C     ***** (EASTSIDE) 16-FT LOG SCALE *****
   40 DO 50 I=1,LOGS
      KD = INT(LOGDIA(I,1))
      K = KD+6
      IF (KD.LE.11) K=KD
      IG = (IFTR(K) * 16 + 500) / 1000

C  INTERNATIONAL BDFT
      CALL INTL14(LOGDIA(I,1),16.0,BFINT)
      INTBF(I) = BFINT

      LOGVOL(1,I) = IG
   50 CONTINUE

      X = XLOGS - LOGS
      IF (X.EQ.0.0) GO TO 60
      KD = INT(LOGDIA(LOGS+1,1))
      IF (KD.LT.6) K=KD+0
      IF (KD.GE.6) K=KD+121
      IF (KD.GE.12) K=KD+6
      IG = (IFTR(K) * 8 + 500) / 1000

C  INTERNATIONAL BDFT
      CALL INTL14(LOGDIA(I,1),8.0,BFINT)
      INTBF(I) = BFINT

      LOGVOL(1,LOGS+1) = IG

C     ***** (BOTH SIDES) CUBIC-FOOT VOLUME *****
   60 F = 0.005454154

C     ***** BUTTLOG VOLUME *****
      LOGVOL(4,1) = 0.06239*DBHOB**2*(FCLASS/100.0)**2 + 
     >                                               0.025624*DBHOB**2

C     ***** EASTSIDE HALF LOG AT TOP *****
      IF (X.EQ.0) GO TO 70
      LOGVOL(4,LOGS+1) = (LOGDIA(LOGS+1,1)**2*F + 
     >                                    LOGDIA(LOGS,1)**2*F)/2.0*8.0

C     ***** REMAINING LOGS *****
   70 DO I=2,LOGS
        LOGVOL(4,I) = (LOGDIA(I,1)**2 * F  +  
     >                              LOGDIA(I-1,1)**2 * F) / 2.0 * 16.0
      ENDDO
      RETURN
      END
