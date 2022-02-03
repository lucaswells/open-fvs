      SUBROUTINE FMSCUT (MXVOL,NR,NC,SSNG,DSNG,CTCRWN,TKCRWN)
      IMPLICIT NONE
C----------
C FIRE-BASE $Id: fmscut.f 2359 2018-05-18 17:35:04Z lancedavid $
C----------
C     SINGLE-STAND VERSION
C
C     PART OF THE FIRE MODEL EXTENSION.
C     THIS ROUTINE ADDS THE MATERIAL THAT WAS LEFT BEHIND AFTER CUTS.
C     THIS MUST BE DONE *BEFORE* CUTS REMOVES THE TREE RECORDS,
C     BECAUSE IT RELIES ON GETTING THE INFORMATION ABOUT THE DBH, HT AND
C     SPECIES OF EACH RECORD.
C
C     CALLED FROM -- CUTS
C     CALLS FMSSEE
C           CWD3
C           FMSADD
C           FMCBIO
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'

      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'FMCOM.F77'
      INCLUDE 'FMFCOM.F77'
      INCLUDE 'FMPROP.F77'
C
C
COMMONS
C
C  Local Variable Definitions:
C
      INTEGER I, ISZ, IDC, NR, NC, J, K
      REAL    MXVOL(NR,NC), SSNG(MAXTRE), DSNG(MAXTRE)
      REAL    CTCRWN(MAXTRE), TKCRWN(MAXTRE)
      REAL    X, Y, Z, LVSNBM, TKCRBM, XNEG1
      REAL    ABIO, MBIO, RBIO, HRVTRE, LVCRWN
      LOGICAL DEBUG, LMERCH,LMRCH2
      REAL RDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = MXVOL(1,1)
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK (DEBUG,'FMSCUT',6,ICYC)
      IF (DEBUG) WRITE(JOSTND,7) ICYC, LFMON
    7 FORMAT(' ENTERING FMSCUT CYCLE = ',I2,' LFMON=',L2)

C     CHECK TO SEE IF THE FIRE MODEL IS ACTIVE

      IF (.NOT. LFMON) RETURN
C
C     Add standing snags created by **CUTS** to the list of new snags
C     ADD CROWN MATERIAL FROM **CUTS** TO DEBRIS POOLS
C     ADD DOWNED SNAGS TO DEBRIS POOLS VIA CWD3
C
      LVSNBM = 0.0
      TKCRBM = 0.0
      LVCRWN = 0.0     
      LMERCH = .FALSE.
      IF (LVWEST) LMERCH = .TRUE.

      DO I= 1,ITRN

C       SET THE HARVEST YEAR IF THERE IS ANY MATERIAL TO ADD TO THE
C       DEBRIS POOLS (CROWNS OR DOWNED SNAGS)

        IF (CTCRWN(I) .GT. 0.0 .OR. DSNG(I) .GT. 0.0)
     &    HARVYR = IY(ICYC)

        CALL FMSSEE (I,ISP(I),DBH(I),HT(I),SSNG(I),0,DEBUG,JOSTND)

        IDC = DKRCLS(ISP(I))
        X = CTCRWN(I) * P2T
        Y = TKCRWN(I) * P2T

C           (NOTE: When calculating LVCRWN, we want only those crowns
C               that are on harvested trees that left the stand. Therefore,
C               we must remove the trees that were left as downed snags.)
        Z = (CTCRWN(I) - DSNG(I)) * P2T

        CWD(1,10,2,IDC) = CWD(1,10,2,IDC) + (CROWNW(I,0) * X)
        TKCRBM = TKCRBM + (CROWNW(I,0) * Y)
        LVCRWN = LVCRWN + (CROWNW(I,0) * Z)

        DO ISZ = 1,5
          CWD(1,ISZ,2,IDC) = CWD(1,ISZ,2,IDC) + (CROWNW(I,ISZ) * X)
          TKCRBM = TKCRBM + CROWNW(I,ISZ) * Y
          LVCRWN = LVCRWN + (CROWNW(I,ISZ) * Z)
        ENDDO
        CALL CWD3(ISP(I),DBH(I),DSNG(I),HT(I))
C
C       CALCULATE VOLUME AND BIOMASS OF CUT MATERIAL NOW IN
C       THE SNAG (SSNG) OR DOWNED SNAG (DSNG) POOLS; IN
C       PREPARATION FOR SUBTRACTING FROM THE HARVESTED VOLUME
C
        XNEG1= -1.0
        LMRCH2 = .FALSE.

        CALL FMSVL2(ISP(I),DBH(I),HT(I),XNEG1,X,LMRCH2,DEBUG,JOSTND)
        LVSNBM = LVSNBM +
     >    (X * V2T(ISP(I)) * (SSNG(I) + DSNG(I)))

C       CALCULATE THE BIOMASS EQUATIONS FOR REMOVED TREES
C       OR DOWN TREES.
C       (TREES LEFT STANDING AS SNAGS ARE CAPTURED BY FMSADD)

        HRVTRE = (WK3(I) - SSNG(I) - DSNG(I))

        CALL FMCBIO(DBH(I), ISP(I), ABIO, MBIO, RBIO)
        BIOROOT = BIOROOT + RBIO * (WK3(I) - SSNG(I))

C       BIOMASS REMOVED IS ABOVEGROUND BIOMASS (USUSALLY MORE THAN
C       THE HARVESTED BIOMASS, WHICH IS BASED ON MERCH)

        BIOREM(1) = BIOREM(1) + ABIO * HRVTRE

C       DETERMINE THE VOLUME OF ROUNDWOOD AND PULPWOOD.
C       VALUES BELOW BREAKPOINT (POTENTIALLY ALTERED BY THE USER)
C       ARE FOR PULPWOOD, VALUES ABOVE ARE FOR ROUNDWOOD.
C       SAVE THE VALUES BY HW/SW. RW/PW, YEAR
C       EASTERN FVS VARIANTS USE "TOTAL" VOLUME AS COMMERCIALLY
C       USEFUL, SO LMERCH IS .FALSE.; WESTERN VARIANTS USE
C       "MERCH" VOLUME AS USEFUL, SO LMERCH IS .TRUE.
C       REPORTED USING MBIO WHEN JENKINS EQUATIONS ARE IN USE

        IF (ICMETH .EQ. 0) THEN  ! FFE-CALCULATION METHOD
          X = 0.0
          IF (HRVTRE .GT. 0.0) THEN
            XNEG1= -1.0
            CALL FMSVL2(ISP(I),DBH(I),HT(I),XNEG1,X,LMERCH,DEBUG,JOSTND)
            X = X * V2T(ISP(I)) * HRVTRE
          ENDIF
        ELSE                     ! JENKINS CALCULATION METHOD
          X = MBIO * HRVTRE
        ENDIF

        K = 1
        IF (BIOGRP(ISP(I)) .GT. 5) K = 2
        J = 1
        IF (DBH(I) .GT. CDBRK(K))  J = 2
        FATE(J, K, ICYC) = FATE(J, K, ICYC) + X

      ENDDO

C     ADD NEW SNAG LIST ELEMENTS FROM **CUTS** TO SNAG LIST

      CALL FMSADD (IY(ICYC),2)

C     COMPUTE TOTAL VOLUME REMOVED THROUGH HARVEST AND CONVERT TO
C     TOTAL WEIGHT REMOVED

      TONRMH = 0.0
      DO I= 1,ITRN
        X = 0.
        XNEG1= -1.0
        LMERCH = .FALSE.
        CALL FMSVL2(ISP(I),DBH(I),HT(I),XNEG1,X,LMERCH,DEBUG,JOSTND)
        X = X * V2T(ISP(I)) * WK3(I)
        TONRMH = TONRMH + X
      ENDDO
C
C     ADJUST REMOVED TONS BY SUBTRACTING SNAGS THAT HAVE BEEN
C     LEFT BEHIND IN THE STAND AND ADDING CROWNS THAT HAVE BEEN
C     TAKEN FROM THE STAND
C
      TONRMH = TONRMH - LVSNBM + TKCRBM

C     IN THE JENKINS CASE, SUBTRACT THE CROWNS LEFT IN THE STAND
C     FROM THE TOTAL AMOUNT OF BIOMASS REMOVED FROM THE STAND.
C     NOTE THAT IN THIS CASE SINCE THE TOTAL BIOMASS AND THE CROWN BIOMASS
C     ARE CALCULATED FROM DIFFERENT SOURCES, THE AMOUNT REMOVED COULD
C     BE NEGATIVE, SO WE SET IT TO 0.
      BIOREM(1) = BIOREM(1) - LVCRWN
      IF (BIOREM(1) .LT. 0.0) BIOREM(1) = 0.0

      BIOREM(1) = MAX(BIOREM(1),0.)

      IF (DEBUG) WRITE(JOSTND,10) TONRMH
   10 FORMAT(' FMSCUT, TONRMH= ',F12.3)

      RETURN
      END
