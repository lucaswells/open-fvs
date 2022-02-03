      SUBROUTINE TMSCHD 
      IMPLICIT NONE
C---------- 
C DFTM $Id: tmschd.f 2446 2018-07-09 22:54:33Z gedixon $
C---------- 
C     
C     THIS ROUTINE IS CALLED ONCE PER SIMULATION FROM DFTMIN AND  
C     SCHEDULES ALL OF THE NECESSARY OUTBREAK BEGINNING CYCLES.   
C     IF 'RANSCHED' OPTION IS SPECIFIED, THIS ROUTINE ALSO SCHEDULES    
C     THE TIMING OF REGIONAL OUTBREAKS.   
C     
C     N.L. CROOKSTON      MAY 1978 & JUNE 1981    INT -- MOSCOW   
C     
C     THE CONCEPT FOR THE 'RANSCHED' OPTION IS FROM A. R.   
C     STAGE. INT -- MOSCOW.   
C
C Revision History:
C   01-APR-2013 Lance R. David (FMSC)
C      A few variables defined locally were already defined
C      in a common block. Local declaration removed.
C
C----------
C
COMMONS     
C     
      INCLUDE 'PRGPRM.F77'
C
      INCLUDE 'CONTRL.F77'
C     
      INCLUDE 'TMCOM1.F77'
C     
COMMONS     
C     
C     INTERNAL VARIABLES
C     
C     SEL   = A UNIFORM RANDOM NUMBER (0-1)     
C     NYR   = THE NUMBER OF DRAWS MINUS 1 NECESSARY FOR THE 
C             EVENT TO OCCUR. 
C     NEXT  = THE YEAR OF THE NEXT OUTBREAK.    
C     
C     THE OUTBREAK YEARS ARE ASSIGNED TO A PREVIOUSLY SCHEDULED   
C     CYCLE IF THE RESOLUTION OF THE SYSTEM CAN BE MAINTAINED.    
C     
C     TMRES = A RESOLUTION FACTOR USED TO CALCULATE MOVE    
C     TMBASE= TUSSOCK MOTH MODEL TIME BASE...5 YEARS. 
C     MOVE  = THE MAX. NUMBER OF YEARS AN OUTBREAK WILL BE MOVED. 
C     MOVE  = IFIX ( FLOAT(TMBASE) * TMRES )    
C     IYI   = SUBSCRIPT OF ARRAY IY.
C     LAST  = THE LAST CYCLE YEAR.  
C     IDIFF = THE DIFFERENCE IN YEARS BETWEEN THE TIME THE NEXT   
C             OUTBREAK SHOULD OCCUR AND THE CLOSEST CYCLE YEAR    
C     MSCH  = COUNTER WHICH KEEPS TRACK OF THE MANUALLY SCHEDULED 
C             OUTBREAKS WHICH HAVE BEEN SPECIFIED BY DATE.  
C     NMSCH = THE NUMBER OF MANUALLY SCHEDULED OUTBREAKS SPECIFIED
C             BY DATE.  
C     ITMYR = VECTOR OF MANUALLY SCHEDULED TM-YRS (VIA DATE). ITMYR IS  
C             EQUIVALENT TO TMYRS; HOWEVER IN THE IBM VERSION ITMYR     
C             IS HALF-WORD.   
C     
      INTEGER I, I1, IBOUND, IDIFF, INVYR,
     &        IPAST, ISPOT, 
     &        ITMYR(41), IYI, IYLAST, KODE,
     &        LAST, MOVE, MSCH, NEXT, NMSCH, NYR,
     &        TMBASE

      REAL PRMS(1), SEL

      EQUIVALENCE (ITMYR(1), TMYRS(1))    

      DATA TMBASE / 5 /, MOVE / 2 / 


      IF (ITMSCH .NE. 1) GOTO 10    
      MSCH = 0    
      NMSCH = ITMYR(41) 
      ITMYR(41) = 0     
      IF (NMSCH .EQ. 0) RETURN
      CALL IQRSRT(ITMYR, NMSCH)     

   10 CONTINUE    
      INVYR = IY(1)     
      LAST = IY(NCYC + 1)     
      I1 = 1
      IPAST = TMPAST    

   30 CONTINUE    
      IYLAST = NCYC + 1 

C     
C     FIND THE DATE OF THE NEXT REGIONAL OUTBREAK     
C     
      IF (ITMSCH .NE. 1) GOTO 35    
      MSCH = MSCH + 1   
      IF (MSCH .GT. NMSCH) RETURN   
      NEXT = ITMYR(MSCH)
      ITMYR(MSCH) = 0   
      GOTO 65     

   35 CONTINUE    
      NYR = 0     

   40 CONTINUE    
      CALL TMRANN(SEL)  
      IF (SEL .LE. TMEVNT) GOTO 60  
      NYR = NYR + 1     
      IF (NYR .LT. 300) GOTO 40     

C     
C     THE EVENT PROBABILITY (TMEVNT) MAY BE TOO DAMN SMALL OR     
C     EQUAL TO ZERO.    
C     
      WRITE (JOSTND,50) TMEVNT
   50 FORMAT (//,'***** WARNING:  TUSSOCK MOTH EVENT PROBABILITY',     
     >        ' EQUALS:',E13.7,'.  NO OUTBREAKS SCHEDULED.')
      RETURN

   60 CONTINUE    
      NEXT = IPAST + TMWAIT + NYR   

   65 CONTINUE    
      IF (NEXT .GE. LAST - MOVE) RETURN   
      IF (NEXT .LT. INVYR) NEXT = INVYR   
      IPAST = NEXT

C     
C     FIND THE SUBSCRIPT OF THE IY WITH THE SMALLEST ABSOLUTE     
C     DISTANCE FROM NEXT.     
C     
      IYI = 0     
      IDIFF = 9999

      DO 70 I = I1, IYLAST    
        IF (IABS(IY(I) - NEXT) .GT. IABS(IDIFF)) GOTO 70    
        IDIFF = NEXT - IY(I)  
        IYI = I   
   70 CONTINUE    

      IF (IYI .GT. 0) GOTO 80 
      WRITE (JOSTND,75) 
   75 FORMAT ( //,'***** ERROR IN SUBROUTINE TMSCHD.')     
      STOP 200    

   80 CONTINUE    
      IF (IABS(IDIFF) .LE. MOVE) GOTO 160 
      IF (IYI .GE. 40) RETURN 
C     
C     A CYCLE NEEDS TO BE INSERTED. 
C     
      IF (IDIFF .LT. 0) GOTO 120    
      IBOUND = IDIFF    
      IF (IABS(IY(IYI + 1) - NEXT - TMBASE) .LE. MOVE)
     >    IBOUND = IY(IYI + 1) - TMBASE - IY(IYI)     
      GO TO 150   

  120 CONTINUE    
      IBOUND = IY(IYI) - IY(IYI-1) - TMBASE     
      IF (-IDIFF .GT. TMBASE+MOVE) IBOUND = IY(IYI) - IY(IYI-1) + IDIFF 
      IYI = IYI - 1     
  150 CONTINUE    

      CALL INSCYC(IYI, IBOUND, ISPOT, .FALSE., .TRUE., JOSTND, TMDEBU)  
      IF (ISPOT .LE. 0) RETURN
      IYI = ISPOT 

  160 CONTINUE    
C     
C     IF TM-YRS WERE MANUALLY SCHEDULED THEY ALREADY EXIST AS     
C     ACTIVITIES. 
C     
      IF (ITMSCH .EQ. 1) GOTO 30    
      CALL OPNEW (KODE, NEXT, 811, 0, PRMS)     
      IF (KODE .NE. 0) RETURN 
      I1 = IYI    
      GOTO 30     

      END   
