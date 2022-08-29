!> @file
!> @brief Contains MODULE W3UQCKMD.
!> 
!> @author H. L. Tolman  @date 27-May-2014
!>

#include "w3macros.h"
!/ ------------------------------------------------------------------- /
!>
!> @brief Portable ULTIMATE QUICKEST schemes.
!>
!> @author H. L. Tolman  @date 27-May-2014
!>
      MODULE W3UQCKMD
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |           H. L. Tolman            |
!/                  |                        FORTRAN 90 |
!/                  | Last update :         27-May-2014 |
!/                  +-----------------------------------+
!/
!/    08-Feb-2001 : Origination of module. Routines     ( version 2.08 )
!/                  taken out of w3pro2md.ftn
!/    13-Nov-2001 : Version with obstacles added.       ( version 2.14 )
!/    16-Oct-2002 : Fix par list W3QCK3.                ( version 3.00 )
!/    05-Mar-2008 : Added NEC sxf90 compiler directives.
!/                  (Chris Bunney, UK Met Office)       ( version 3.13 )
!/    29-May-2009 : Preparing distribution version.     ( version 3.14 )
!/    30-Oct-2009 : Fixed a couple of doc lines.        ( version 3.14 )
!/                  (T. J. Campbell, NRL)
!/    27-May-2014 : Added OMPH switches in W3QCK3.      ( version 5.02 )
!/
!/    Copyright 2009-2014 National Weather Service (NWS),
!/       National Oceanic and Atmospheric Administration.  All rights
!/       reserved.  WAVEWATCH III is a trademark of the NWS. 
!/       No unauthorized use without permission.
!/
!  1. Purpose :
!
!     Portable ULTIMATE QUICKEST schemes.
!
!  2. Variables and types :
!
!     None.
!
!  3. Subroutines and functions :
!
!      Name      Type  Scope    Description
!     ----------------------------------------------------------------
!      W3QCK1    Subr. Public   Original ULTIMATE QUICKEST scheme.
!      W3QCK2    Subr. Public   UQ scheme for irregular grid.
!      W3QCK3    Subr. Public   Original ULTIMATE QUICKEST with obst.
!     ----------------------------------------------------------------
!
!  4. Subroutines and functions used :
!
!      Name      Type  Module   Description
!     ----------------------------------------------------------------
!      STRACE    Subr. W3SERVMD Subroutine tracing.
!     ----------------------------------------------------------------
!
!  5. Remarks :
!
!     - STRACE and !/S irrelevant for running code. The module is 
!       therefore fully portable to any other model.
!
!  6. Switches :
!
!       !/OMPH  Ading OMP directves for hybrid paralellization.
!
!       !/S     Enable subroutine tracing.
!       !/Tn    Enable test output.
!
!  7. Source code :
!
!/ ------------------------------------------------------------------- /
#ifdef W3_S
      USE W3SERVMD, ONLY: STRACE
#endif
!/
      CONTAINS
!/ ------------------------------------------------------------------- /
!>
!> @brief Preform one-dimensional propagation in a two-dimensional space
!>  with irregular boundaries and regular grid.
!>
!> @details ULTIMATE QUICKEST scheme (see manual).
!>        
!>  Note that the check on monotonous behavior of QCN is performed
!>  using weights CFAC, to avoid the need for IF statements.
!>
!>  Called by:  W3KTP2   Propagation in spectral space.
!>
!>  This routine can be used independently from WAVEWATCH III.
!>
!>        
!> @param[in]    MX  Field dimensions, if grid is 'closed' or circular, MX is the closed dimension.
!> @param[in]    MY  Field dimension (See MX)
!> @param[in]    NX  Part of field actually used
!> @param[in]    NY  Part of field actually used
!> @param[in]    INC     Increment in 1-D array corresponding to increment in 2-D space.
!> @param[in]    MAPACT  List of active grid points.
!> @param[in]    NACT    Size of MAPACT.
!> @param[in]    MAPBOU  Map with boundary information (See W3MAP2).
!> @param[in]    NB0     Counter in MAPBOU
!> @param[in]    NB1     Counter in MAPBOU
!> @param[in]    NB2     Counter in MAPBOU
!> @param[in]    NDSE    Error output unit number.
!> @param[in]    NDST    Test output unit number.
!> @param[inout] CFLL    Local Courant numbers (MY,  MX+1)
!> @param[inout] Q       Propagated quantity   (MY,0:MX+2)
!> @param[in]    CLOSE   Flag for closed 'X' dimension.
!>
!> @author  H. L. Tolman  @date 30-Oct-2009
!>        
      SUBROUTINE W3QCK1 (MX, MY, NX, NY, CFLL, Q, CLOSE, INC,         &
                         MAPACT, NACT, MAPBOU, NB0, NB1, NB2,         &
                         NDSE, NDST )
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |           H. L. Tolman            |
!/                  |                        FORTRAN 90 |
!/                  | Last update :         30-Oct-2009 |
!/                  +-----------------------------------+
!/
!/    11-Mar-1997 : Final FORTRAN 77                    ( version 1.18 )
!/    15-Dec-1999 : Upgrade to FORTRAN 90               ( version 2.00 )
!/    15-Feb-2001 : Unit numbers added to par list.     ( version 2.08 )
!/    05-Mar-2008 : Added NEC sxf90 compiler directives.
!/                  (Chris Bunney, UK Met Office)       ( version 3.13 )
!/    30-Oct-2009 : Fixed "Called by" doc line.         ( version 3.14 )
!/                  (T. J. Campbell, NRL)
!/
!  1. Purpose :
!
!     Preform one-dimensional propagation in a two-dimensional space
!     with irregular boundaries and regular grid.
!
!  2. Method :
!
!     ULTIMATE QUICKEST scheme (see manual).
!
!     Note that the check on monotonous behavior of QCN is performed
!     using weights CFAC, to avoid the need for IF statements.
!
!  3. Parameters :
!
!     Parameter list
!     ----------------------------------------------------------------
!       MX,MY   Int.   I   Field dimensions, if grid is 'closed' or
!                          circular, MX is the closed dimension.
!       NX,NY   Int.   I   Part of field actually used.
!       CFLL    R.A.   I   Local Courant numbers.         (MY,  MX+1)
!       Q       R.A.  I/O  Propagated quantity.           (MY,0:MX+2)
!       CLOSE   Log.   I   Flag for closed 'X' dimension'
!       INC     Int.   I   Increment in 1-D array corresponding to
!                          increment in 2-D space.
!       MAPACT  I.A.   I   List of active grid points.
!       NACT    Int.   I   Size of MAPACT.
!       MAPBOU  I.A.   I   Map with boundary information (see W3MAP2).
!       NBn     Int.   I   Counters in MAPBOU.
!       NDSE    Int.   I   Error output unit number.
!       NDST    Int.   I   Test output unit number.
!     ----------------------------------------------------------------
!           - CFLL amd Q need only bee filled in the (MY,MX) range,
!             extension is used internally for closure.
!           - CFLL and Q are defined as 1-D arrays internally.
!
!  4. Subroutines used :
!
!       STRACE   Service routine.
!
!  5. Called by :
!
!       W3KTP2   Propagation in spectral space
!
!  6. Error messages :
!
!     None.
!
!  7. Remarks :
!
!     - This routine can be used independently from WAVEWATCH III.
!
!  8. Structure :
!
!     ------------------------------------------------------
!       1. Initialize aux. array FLA.
!       2. Fluxes for central points (3rd order + limiter).
!       3. Fluxes boundary point above (1st order).
!       4. Fluxes boundary point below (1st order).
!       5. Closure of 'X' if required
!       6. Propagate.
!     ------------------------------------------------------
!
!  9. Switches :
!
!     !/S   Enable subroutine tracing.
!     !/T   Enable test output.
!     !/T0  Test output input/output fields.
!     !/T1  Test output fluxes.
!     !/T2  Test output integration.
!
! 10. Source code :
!
!/ ------------------------------------------------------------------- /
      IMPLICIT NONE
!/
!/ ------------------------------------------------------------------- /
!/ Parameter list
!/
      INTEGER, INTENT(IN)     :: MX, MY, NX, NY, INC, MAPACT(MY*MX),  &
                                 NACT, MAPBOU(MY*MX), NB0, NB1, NB2,  &
                                 NDSE, NDST
      REAL, INTENT(INOUT)     :: CFLL(MY*(MX+1)), Q(1-MY:MY*(MX+2))
      LOGICAL, INTENT(IN)     :: CLOSE
!/
!/ ------------------------------------------------------------------- /
!/ Local parameters
!/
      INTEGER                 :: IXY, IP, IXYC, IXYU, IXYD, IY, IX,   &
                                 IAD00, IAD02, IADN0, IADN1, IADN2
#ifdef W3_S
      INTEGER, SAVE           :: IENT = 0
#endif
#ifdef W3_T1
      INTEGER                 :: IX2, IY2
#endif
      REAL                    :: CFL, QB, DQ, DQNZ, QCN, QBN, QBR, CFAC
      REAL                    :: FLA(1-MY:MY*MX)
#ifdef W3_T0
      REAL                    :: QMAX
#endif
#ifdef W3_T1
      REAL                    :: QBO, QN
#endif
#ifdef W3_T2
      REAL                    :: QOLD
#endif
!/
!/ ------------------------------------------------------------------- /
!/
#ifdef W3_S
      CALL STRACE (IENT, 'W3QCK1')
#endif
!
#ifdef W3_T
      WRITE (NDST,9000) MX, MY, NX, NY, CLOSE, INC, NB0, NB1, NB2
#endif
!
#ifdef W3_T0
      QMAX   = 0.
      DO IY=1, NY
        DO IX=1, NX
          QMAX   = MAX ( QMAX , Q(IY+(IX-1)*MY) )
          END DO
        END DO
      QMAX   = MAX ( 0.01*QMAX , 1.E-10 )
#endif
!
#ifdef W3_T0
      WRITE (NDST,9001) 'CFLL'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(100.*CFLL(IY+(IX-1)*MY)),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'MAPACT'
      WRITE (NDST,9003) (MAPACT(IXY),IXY=1,NACT)
#endif
!
! 1.  Initialize aux. array FLA and closure ------------------------- *
!
      FLA = 0.
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9005)
#endif
          IAD00  = -MY
          IAD02  =  MY
          IADN0  = IAD00 + MY*NX
          IADN1  =         MY*NX
          IADN2  = IAD02 + MY*NX
          DO IY=1, NY
            Q   (IY+IAD00) = Q   (IY+IADN0)
            Q   (IY+IADN1) = Q   (   IY   )
            Q   (IY+IADN2) = Q   (IY+IAD02)
            CFLL(IY+IADN1) = CFLL(   IY   )
            END DO
        END IF
!
! 2.  Fluxes for central points ------------------------------------- *
!     ( 3rd order + limiter )
!
#ifdef W3_T1
      WRITE (NDST,9010)
      WRITE (NDST,9011) NB0, 'CENTRAL'
#endif
!
      DO IP=1, NB0
!
        IXY    = MAPBOU(IP)
        CFL    = 0.5 * ( CFLL(IXY) + CFLL(IXY+INC) )
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        QB     = 0.5 * ( (1.-CFL)*Q(IXY+INC) + (1.+CFL)*Q(IXY) )      &
            - (1.-CFL**2)/6. * (Q(IXYC-INC)-2.*Q(IXYC)+Q(IXYC+INC))
!
        IXYU   = IXYC - INC * INT ( SIGN (1.1,CFL) )
        IXYD   = 2*IXYC - IXYU
        DQ     = Q(IXYD) - Q(IXYU)
        DQNZ   = SIGN ( MAX(1.E-15,ABS(DQ)) , DQ )
        QCN    = ( Q(IXYC) - Q(IXYU) ) / DQNZ
        QCN    = MIN ( 1.1, MAX ( -0.1 , QCN ) )
!
#ifdef W3_T1
        QBO    = QB
#endif
        QBN    = MAX ( (QB-Q(IXYU))/DQNZ , QCN )
        QBN    = MIN ( QBN , 1. , QCN/MAX(1.E-10,ABS(CFL)) )
        QBR    = Q(IXYU) + QBN*DQ
        CFAC   = REAL ( INT( 2. * ABS(QCN-0.5) ) )
        QB     = (1.-CFAC)*QBR + CFAC*Q(IXYC)
!
        FLA(IXY) = CFL * QB
!
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( QB, QBO, Q(IXY-INC), Q(   IXY   ),         &
                                Q(IXY+INC), Q(IXY+2*INC) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9012) IP, IX, IY, IX2, IY2,               &
                              CFL, CFLL(IXY), CFLL(IXY+INC),      &
                   QBO*QN, QB*QN, Q(IXY-INC)*QN, Q(   IXY   )*QN, &
                                  Q(IXY+INC)*QN, Q(IXY+2*INC)*QN
          END IF
#endif
!
        END DO
!
! 3.  Fluxes for points with boundary above ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB1-NB0, 'BOUNDARY ABOVE'
#endif
!
      DO IP=NB0+1, NB1
        IXY    = MAPBOU(IP)
        CFL    = CFLL(IXY)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        FLA(IXY) = CFL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9013) IP, IX, IY, IX2, IY2, CFL,          &
                   CFLL(IXY), Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!
! 4.  Fluxes for points with boundary below ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB2-NB1, 'BOUNDARY BELOW'
#endif
!
      DO IP=NB1+1, NB2
        IXY    = MAPBOU(IP)
        CFL    = CFLL(IXY+INC)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        FLA(IXY) = CFL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9014) IP, IX, IY, IX2, IY2, CFL,         &
               CFLL(IXY+INC), Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!
! 5.  Global closure ----------------------------------------------- *
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9015)
#endif
          DO IY=1, NY
            FLA (IY+IAD00) = FLA (IY+IADN0)
            END DO
        END IF
!
! 6.  Propagation -------------------------------------------------- *
!
#ifdef W3_T2
      WRITE (NDST,9020)
#endif
      DO IP=1, NACT
        IXY    = MAPACT(IP)
#ifdef W3_T2
        QOLD   = Q(IXY)
#endif
        Q(IXY) = MAX ( 0. , Q(IXY) + FLA(IXY-INC) - FLA(IXY) )
#ifdef W3_T2
        IF ( QOLD + Q(IXY) .GT. 1.E-10 )                          &
             WRITE (NDST,9021) IP, IXY, QOLD, Q(IXY),             &
                               FLA(IXY-INC), FLA(IXY)
#endif
        END DO
!
#ifdef W3_T0
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
#endif
!
      RETURN
!
! Formats
!
#ifdef W3_T
 9000 FORMAT ( ' TEST W3QCK1 : ARRAY DIMENSIONS  :',2I6/           &
               '               USED              :',2I6/           &
               '               CLOSE, INC        :',L6,I6/         &
               '               NB0, NB1, NB2     :',3I6)
#endif
#ifdef W3_T0
 9001 FORMAT ( ' TEST W3QCK1 : DUMP ARRAY ',A,' :')
 9002 FORMAT ( 1X,43I3)
 9003 FORMAT ( 1X,21I6)
#endif
#ifdef W3_T
 9005 FORMAT (' TEST W3QCK1 : GLOBAL CLOSURE (1)')
#endif
!
#ifdef W3_T1
 9010 FORMAT (' TEST W3QCK1 : IP, 2x(IX,IY), CFL (b,i,i+1), ',    &
              ' Q (b,b,i-1,i,i+1,i+2)')
 9011 FORMAT (' TEST W3QCK1 :',I6,' POINTS OF TYPE ',A)
 9012 FORMAT (10X,I6,4I4,1X,3F6.2,1X,F7.2,F6.2,1X,4F6.2)
 9013 FORMAT (10X,I6,4I4,1X,F6.2,F6.2,'  --- ',1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
 9014 FORMAT (10X,I6,4I4,1X,F6.2,'  --- ',F6.2,1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
#endif
#ifdef W3_T
 9015 FORMAT (' TEST W3QCK1 : GLOBAL CLOSURE (2)')
#endif
!
#ifdef W3_T2
 9020 FORMAT (' TEST W3QCK1 : IP, IXY, 2Q, 2FL')
 9021 FORMAT ('            ',2I6,2(1X,2E11.3))
#endif
!/
!/ End of W3QCK1 ----------------------------------------------------- /
!/
      END SUBROUTINE W3QCK1
!/ ------------------------------------------------------------------- /
!>
!> @brief Like W3QCK1 with variable grid spacing.
!>
!> @details VELO amd Q need only bee filled in the (MY,MX) range,
!>  extension is used internally for closure.
!>  VELO and Q are defined as 1-D arrays internally.
!>        
!>  Called by:  W3KTP2   Propagation in spectral space.
!>
!>  This routine can be used independently from WAVEWATCH III.
!>
!>      
!> @param[in]    MX      Field dimensions, if grid is 'closed' or circular, MX is the closed dimension.
!> @param[in]    MY      Field dimension (See MX).
!> @param[in]    NX      Part of field actually used.
!> @param[in]    NY      Part of field actually used.
!> @param[in]    MAPACT  List of active grid points.
!> @param[in]    NACT    Size of MAPACT.
!> @param[in]    MAPBOU  Map with boundary information (See W3MAP2).
!> @param[in]    NB0     Counter in MAPBOU.
!> @param[in]    NB1     Counter in MAPBOU.
!> @param[in]    NB2     Counter in MAPBOU.
!> @param[inout] VELO    Local velocities          (MY,  MX+1).
!> @param[in]    DT      Time step.
!> @param[inout] DX1     Band width at points      (MY,  MX+1).
!> @param[inout] DX2     Band width between points (MY,0:MX+1)
!> @param[in]    NDSE    Error output unit number.
!> @param[in]    NDST    Test output unit number.
!> @param[inout] Q       Propagated quantity       (MY,0:MX+2).
!> @param[in]    CLOSE   Flag for closed 'X' dimension.
!> @param[in]    INC     Increment in 1-D array corresponding to
!>                       increment in 2-D space.      
!>
!> @author  H. L. Tolman  @date 30-Oct-2009
!>        
      SUBROUTINE W3QCK2 (MX, MY, NX, NY, VELO, DT, DX1, DX2, Q, CLOSE,&
                        INC,  MAPACT, NACT, MAPBOU, NB0, NB1, NB2,    &
                        NDSE, NDST )
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |           H. L. Tolman            |
!/                  |                        FORTRAN 90 |
!/                  | Last update :         30-Oct-2009 |
!/                  +-----------------------------------+
!/
!/    07-Sep-1997 : Final FORTRAN 77                    ( version 1.18 )
!/    16-Dec-1999 : Upgrade to FORTRAN 90               ( version 2.00 )
!/    14-Feb-2001 : Unit numbers added to par list.     ( version 2.08 )
!/    05-Mar-2008 : Added NEC sxf90 compiler directives.
!/                  (Chris Bunney, UK Met Office)       ( version 3.13 )
!/    30-Oct-2009 : Fixed "Called by" doc line.         ( version 3.14 )
!/                  (T. J. Campbell, NRL)
!/
!  1. Purpose :
!
!     Like W3QCK1 with variable grid spacing.
!
!  3. Parameters :
!
!     Parameter list
!     ----------------------------------------------------------------
!       MX,MY   Int.   I   Field dimensions, if grid is 'closed' or
!                          circular, MX is the closed dimension.
!       NX,NY   Int.   I   Part of field actually used.
!       VELO    R.A.   I   Local velocities.              (MY,  MX+1)
!       DT      Real   I   Time step.
!       DX1     R.A.  I/O  Band width at points.          (MY,  MX+1)
!       DX2     R.A.  I/O  Band width between points.     (MY,0:MX+1)
!                          (local counter and counter+INC)
!       Q       R.A.  I/O  Propagated quantity.           (MY,0:MX+2)
!       CLOSE   Log.   I   Flag for closed 'X' dimension'
!       INC     Int.   I   Increment in 1-D array corresponding to
!                          increment in 2-D space.
!       MAPACT  I.A.   I   List of active grid points.
!       NACT    Int.   I   Size of MAPACT.
!       MAPBOU  I.A.   I   Map with boundary information (see W3MAP2).
!       NBn     Int.   I   Counters in MAPBOU.
!       NDSE    Int.   I   Error output unit number.
!       NDST    Int.   I   Test output unit number.
!     ----------------------------------------------------------------
!           - VELO amd Q need only bee filled in the (MY,MX) range,
!             extension is used internally for closure.
!           - VELO and Q are defined as 1-D arrays internally.
!
!  4. Subroutines used :
!
!       STRACE   Service routine.
!
!  5. Called by :
!
!       W3KTP2   Propagation in spectral space
!
!  6. Error messages :
!
!     None.
!
!  7. Remarks :
!
!     - This routine can be used independently from WAVEWATCH III.
!
!  8. Structure :
!
!     ------------------------------------------------------
!       1. Initialize aux. array FLA.
!       2. Fluxes for central points (3rd order + limiter).
!       3. Fluxes boundary point above (1st order).
!       4. Fluxes boundary point below (1st order).
!       5. Closure of 'X' if required
!       6. Propagate.
!     ------------------------------------------------------
!
!  9. Switches :
!
!     !/S   Enable subroutine tracing.
!     !/T   Enable test output.
!     !/T0  Test output input/output fields.
!     !/T1  Test output fluxes.
!     !/T2  Test output integration.
!
! 10. Source code :
!
!/ ------------------------------------------------------------------- /
      IMPLICIT NONE
!/
!/ ------------------------------------------------------------------- /
!/ Parameter list
!/
      INTEGER, INTENT(IN)     :: MX, MY, NX, NY, INC, MAPACT(MY*MX),  &
                                 NACT, MAPBOU(MY*MX), NB0, NB1, NB2,  &
                                 NDSE, NDST
      REAL, INTENT(IN)        :: DT
      REAL, INTENT(INOUT)     :: VELO(MY*(MX+1)), DX1(MY*(MX+1)),     &
                                 DX2(1-MY:MY*(MX+1)), Q(1-MY:MY*(MX+2))
      LOGICAL, INTENT(IN)     :: CLOSE
!/
!/ ------------------------------------------------------------------- /
!/ Local parameters
!/
      INTEGER                 :: IXY, IP, IXYC, IXYU, IXYD, IY, IX,   &
                                 IAD00, IAD02, IADN0, IADN1, IADN2
#ifdef W3_S
      INTEGER, SAVE           :: IENT
#endif
#ifdef W3_T1
      INTEGER                 :: IX2, IY2
#endif
      REAL                    :: CFL, VEL, QB, DQ, DQNZ, QCN, QBN,    &
                                 QBR, CFAC, FLA(1-MY:MY*MX)
#ifdef W3_T0
      REAL                    :: QMAX
#endif
#ifdef W3_T1
      REAL                    :: QBO, QN, XCFL
#endif
#ifdef W3_T2
      REAL                    :: QOLD
#endif
!/
!/ ------------------------------------------------------------------- /
!/
#ifdef W3_S
      CALL STRACE (IENT, 'W3QCK2')
#endif
!
#ifdef W3_T
      WRITE (NDST,9000) MX, MY, NX, NY, DT, CLOSE, INC, NB0, NB1, NB2
#endif
!
#ifdef W3_T0
      QMAX   = 0.
      DO IY=1, NY
        DO IX=1, NX
          QMAX   = MAX ( QMAX , Q(IY+(IX-1)*MY) )
          END DO
        END DO
      QMAX   = MAX ( 0.01*QMAX , 1.E-10 )
#endif
!
#ifdef W3_T0
      WRITE (NDST,9001) 'VELO'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(100.*VELO(IY+(IX-1)*MY)           &
                                  *DT/DX1(IY+(IX-1)*MY)),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'MAPACT'
      WRITE (NDST,9003) (MAPACT(IXY),IXY=1,NACT)
#endif
!
! 1.  Initialize aux. array FLA and closure ------------------------- *
!
      FLA = 0.
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9005)
#endif
          IAD00  = -MY
          IAD02  =  MY
          IADN0  = IAD00 + MY*NX
          IADN1  =         MY*NX
          IADN2  = IAD02 + MY*NX
          DO IY=1, NY
            Q   (IY+IAD00) = Q   (IY+IADN0)
            Q   (IY+IADN1) = Q   (   IY   )
            Q   (IY+IADN2) = Q   (IY+IAD02)
            VELO(IY+IADN1) = VELO(   IY   )
            DX1 (IY+IADN1) = DX1 (   IY   )
            DX2 (IY+IAD00) = DX1 (IY+IADN0)
            DX2 (IY+IADN1) = DX1 (   IY   )
            END DO
        END IF
!
! 2.  Fluxes for central points ------------------------------------- *
!     ( 3rd order + limiter )
!
#ifdef W3_T1
      WRITE (NDST,9010)
      WRITE (NDST,9011) NB0, 'CENTRAL'
#endif
!
      DO IP=1, NB0
!
        IXY    = MAPBOU(IP)
        VEL    = 0.5 * ( VELO(IXY) + VELO(IXY+INC) )
        CFL    = DT *  VEL / DX2(IXY)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        QB     = 0.5 * ( (1.-CFL)*Q(IXY+INC) + (1.+CFL)*Q(IXY) )      &
                    - DX2(IXY)**2 / DX1(IXYC) * (1.-CFL**2) / 6.      &
                        * ( (Q(IXYC+INC)-Q(IXYC))/DX2(IXYC)           &
                          - (Q(IXYC)-Q(IXYC-INC))/DX2(IXYC-INC) )
!
        IXYU   = IXYC - INC * INT ( SIGN (1.1,CFL) )
        IXYD   = 2*IXYC - IXYU
        DQ     = Q(IXYD) - Q(IXYU)
        DQNZ   = SIGN ( MAX(1.E-15,ABS(DQ)) , DQ )
        QCN    = ( Q(IXYC) - Q(IXYU) ) / DQNZ
        QCN    = MIN ( 1.1, MAX ( -0.1 , QCN ) )
!
#ifdef W3_T1
        QBO    = QB
#endif
        QBN    = MAX ( (QB-Q(IXYU))/DQNZ , QCN )
        QBN    = MIN ( QBN , 1. , QCN/MAX(1.E-10,ABS(CFL)) )
        QBR    = Q(IXYU) + QBN*DQ
        CFAC   = REAL ( INT( 2. * ABS(QCN-0.5) ) )
        QB     = (1.-CFAC)*QBR + CFAC*Q(IXYC)
!
        FLA(IXY) = VEL * QB
!
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( QB, QBO, Q(IXY-INC), Q(   IXY   ),         &
                                Q(IXY+INC), Q(IXY+2*INC) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9012) IP, IX, IY, IX2, IY2,               &
                      CFL, DT*VELO(IXY)/DX1(IXY),                 &
                           DT*VELO(IXY+INC)/DX1(IXY+INC),         &
                  QBO*QN, QB*QN, Q(IXY-INC)*QN, Q(   IXY   )*QN,  &
                                 Q(IXY+INC)*QN, Q(IXY+2*INC)*QN
          END IF
#endif
!
        END DO
!
! 3.  Fluxes for points with boundary above ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB1-NB0, 'BOUNDARY ABOVE'
#endif
!
      DO IP=NB0+1, NB1
        IXY    = MAPBOU(IP)
        VEL    = VELO(IXY)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,VEL) ) )
        FLA(IXY) = VEL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9013) IP, IX, IY, IX2, IY2, XCFL,             &
                              DT*VELO(IXY)/DX2(IXY),                  &
                              Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!
! 4.  Fluxes for points with boundary below ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB2-NB1, 'BOUNDARY BELOW'
#endif
!
      DO IP=NB1+1, NB2
        IXY    = MAPBOU(IP)
        VEL    = VELO(IXY+INC)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,VEL) ) )
        FLA(IXY) = VEL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9014) IP, IX, IY, IX2, IY2, XCFL,         &
                              DT*VELO(IXY+INC)/DX2(IXY),          &
                              Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!
! 5.  Global closure ----------------------------------------------- *
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9015)
#endif
          DO IY=1, NY
            FLA (IY+IAD00) = FLA (IY+IADN0)
            END DO
        END IF
!
! 6.  Propagation -------------------------------------------------- *
!
#ifdef W3_T2
      WRITE (NDST,9020)
#endif
      DO IP=1, NACT
        IXY    = MAPACT(IP)
#ifdef W3_T2
        QOLD   = Q(IXY)
#endif
        Q(IXY) = MAX ( 0. , Q(IXY) + DT/DX1(IXY) *                    &
                              (FLA(IXY-INC)-FLA(IXY)) )
#ifdef W3_T2
        IF ( QOLD + Q(IXY) .GT. 1.E-10 )                          &
             WRITE (NDST,9021) IP, IXY, QOLD, Q(IXY),             &
                               DT*FLA(IXY-INC)/DX1(IXY),          &
                               DT*FLA(IXY)/DX1(IXY)
#endif
        END DO
!
#ifdef W3_T0
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
#endif
!
      RETURN
!
! Formats
!
#ifdef W3_T
 9000 FORMAT ( ' TEST W3QCK2 : ARRAY DIMENSIONS  :',2I6/           &
               '               USED              :',2I6/           &
               '               TIME STEP         :',F8.1/          &
               '               CLOSE, INC        :',L6,I6/         &
               '               NB0, NB1, NB2     :',3I6)
#endif
#ifdef W3_T0
 9001 FORMAT ( ' TEST W3QCK2 : DUMP ARRAY ',A,' :')
 9002 FORMAT ( 1X,43I3)
 9003 FORMAT ( 1X,21I6)
#endif
#ifdef W3_T
 9005 FORMAT (' TEST W3QCK2 : GLOBAL CLOSURE (1)')
#endif
!
#ifdef W3_T1
 9010 FORMAT (' TEST W3QCK2 : IP, 2x(IX,IY), CFL (b,i,i+1), ',    &
              ' Q (b,b,i-1,i,i+1,i+2)')
 9011 FORMAT (' TEST W3QCK2 :',I6,' POINTS OF TYPE ',A)
 9012 FORMAT (10X,I6,4I4,1X,3F6.2,1X,F7.2,F6.2,1X,4F6.2)
 9013 FORMAT (10X,I6,4I4,1X,F6.2,F6.2,'  --- ',1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
 9014 FORMAT (10X,I6,4I4,1X,F6.2,'  --- ',F6.2,1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
#endif
#ifdef W3_T
 9015 FORMAT (' TEST W3QCK2 : GLOBAL CLOSURE (2)')
#endif
!
#ifdef W3_T2
 9020 FORMAT (' TEST W3QCK2 : IP, IXY, 2Q, 2FL')
 9021 FORMAT ('            ',2I6,2(1X,2E11.3))
#endif
!/
!/ End of W3QCK2 ----------------------------------------------------- /
!/
      END SUBROUTINE W3QCK2
!/ ------------------------------------------------------------------- /
!>
!> @brief Like W3QCK1 with cell transparencies added. 
!>
!> @details CFLL amd Q need only bee filled in the (MY,MX) range,
!>  extension is used internally for closure.
!>  CFLL and Q are defined as 1-D arrays internally.      
!>        
!>  Called by:  W3XYP2   Propagation in physical space.
!>
!>  This routine can be used independently from WAVEWATCH III.
!>
!>      
!> @param[in]    MX    Field dimensions, if grid is 'closed' or circular, MX is the closed dimension.
!> @param[in]    MY    Field dimension (See MX)
!> @param[in]    NX    Part of field actually used
!> @param[in]    NY    Part of field actually used
!> @param[inout] CFLL  Local Courant numbers      (MY,  MX+1).
!> @param[in]    TRANS
!> @param[in]    INC     Increment in 1-D array corresponding to increment in 2-D space.
!> @param[in]    MAPACT  List of active grid points.
!> @param[in]    NACT    Size of MAPACT.
!> @param[in]    MAPBOU  Map with boundary information (See W3MAP2).
!> @param[in]    NB0     Counter in MAPBOU
!> @param[in]    NB1     Counter in MAPBOU
!> @param[in]    NB2     Counter in MAPBOU
!> @param[in]    NDSE    Error output unit number.
!> @param[in]    NDST    Test output unit number.
!> @param[inout] Q       Propagated quantity       (MY,0:MX+2)
!> @param[in]    CLOSE   Flag for closed 'X' dimension.
!>
!> @author  H. L. Tolman  @date 30-Oct-2009
!>      
      SUBROUTINE W3QCK3 (MX, MY, NX, NY, CFLL, TRANS, Q, CLOSE,       &
                         INC, MAPACT, NACT, MAPBOU, NB0, NB1, NB2,    &
                         NDSE, NDST )
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |           H. L. Tolman            |
!/                  |                        FORTRAN 90 |
!/                  | Last update :         27-May-2014 |
!/                  +-----------------------------------+
!/
!/    13_nov-2001 : Origination.                        ( version 2.14 )
!/    16-Oct-2002 : Fix INTENT for TRANS.               ( version 3.00 )
!/    05-Mar-2008 : Added NEC sxf90 compiler directives.
!/                  (Chris Bunney, UK Met Office)       ( version 3.13 )
!/    27-May-2014 : Added OMPH switches in W3QCK3.      ( version 5.02 )
!/
!  1. Purpose :
!
!     Like W3QCK1 with cell transparencies added.
!
!  2. Method :
!
!  3. Parameters :
!
!     Parameter list
!     ----------------------------------------------------------------
!       MX,MY   Int.   I   Field dimensions, if grid is 'closed' or
!                          circular, MX is the closed dimension.
!       NX,NY   Int.   I   Part of field actually used.
!       CFLL    R.A.   I   Local Courant numbers.         (MY,  MX+1)
!       Q       R.A.  I/O  Propagated quantity.           (MY,0:MX+2)
!       CLOSE   Log.   I   Flag for closed 'X' dimension'
!       INC     Int.   I   Increment in 1-D array corresponding to
!                          increment in 2-D space.
!       MAPACT  I.A.   I   List of active grid points.
!       NACT    Int.   I   Size of MAPACT.
!       MAPBOU  I.A.   I   Map with boundary information (see W3MAP2).
!       NBn     Int.   I   Counters in MAPBOU.
!       NDSE    Int.   I   Error output unit number.
!       NDST    Int.   I   Test output unit number.
!     ----------------------------------------------------------------
!           - CFLL amd Q need only bee filled in the (MY,MX) range,
!             extension is used internally for closure.
!           - CFLL and Q are defined as 1-D arrays internally.
!
!  4. Subroutines used :
!
!       STRACE   Service routine.
!
!  5. Called by :
!
!       W3XYP2   Propagation in physical space
!
!  6. Error messages :
!
!     None.
!
!  7. Remarks :
!
!     - This routine can be used independently from WAVEWATCH III.
!
!  8. Structure :
!
!     ------------------------------------------------------
!       1. Initialize aux. array FLA.
!       2. Fluxes for central points (3rd order + limiter).
!       3. Fluxes boundary point above (1st order).
!       4. Fluxes boundary point below (1st order).
!       5. Closure of 'X' if required
!       6. Propagate.
!     ------------------------------------------------------
!
!  9. Switches :
!
!     !/OMPH  Ading OMP directves for hybrid paralellization.
!
!     !/S   Enable subroutine tracing.
!     !/T   Enable test output.
!     !/T0  Test output input/output fields.
!     !/T1  Test output fluxes.
!     !/T2  Test output integration.
!
! 10. Source code :
!
!/ ------------------------------------------------------------------- /
      IMPLICIT NONE
!/
!/ ------------------------------------------------------------------- /
!/ Parameter list
!/
      INTEGER, INTENT(IN)     :: MX, MY, NX, NY, INC, MAPACT(MY*MX),  &
                                 NACT, MAPBOU(MY*MX), NB0, NB1, NB2,  &
                                 NDSE, NDST
      REAL, INTENT(IN)        :: TRANS(MY*MX,-1:1)
      REAL, INTENT(INOUT)     :: CFLL(MY*(MX+1)), Q(1-MY:MY*(MX+2))
      LOGICAL, INTENT(IN)     :: CLOSE
!/
!/ ------------------------------------------------------------------- /
!/ Local parameters
!/
      INTEGER                 :: IXY, IP, IXYC, IXYU, IXYD, IY, IX,   &
                                 IAD00, IAD02, IADN0, IADN1, IADN2,   &
                                 JN, JP
#ifdef W3_S
      INTEGER, SAVE           :: IENT = 0
#endif
#ifdef W3_T1
      INTEGER                 :: IX2, IY2
#endif
      REAL                    :: CFL, QB, DQ, DQNZ, QCN, QBN, QBR, CFAC
      REAL                    :: FLA(1-MY:MY*MX)
#ifdef W3_T0
      REAL                    :: QMAX
#endif
#ifdef W3_T1
      REAL                    :: QBO, QN
#endif
#ifdef W3_T2
      REAL                    :: QOLD
#endif
!/
!/ ------------------------------------------------------------------- /
!/
#ifdef W3_S
      CALL STRACE (IENT, 'W3QCK3')
#endif
!
#ifdef W3_T
      WRITE (NDST,9000) MX, MY, NX, NY, CLOSE, INC, NB0, NB1, NB2
#endif
!
#ifdef W3_T0
      QMAX   = 0.
      DO IY=1, NY
        DO IX=1, NX
          QMAX   = MAX ( QMAX , Q(IY+(IX-1)*MY) )
          END DO
        END DO
      QMAX   = MAX ( 0.01*QMAX , 1.E-10 )
#endif
!
#ifdef W3_T0
      WRITE (NDST,9001) 'CFLL'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(100.*CFLL(IY+(IX-1)*MY)),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
      WRITE (NDST,9001) 'MAPACT'
      WRITE (NDST,9003) (MAPACT(IXY),IXY=1,NACT)
#endif
!
! 1.  Initialize aux. array FLA and closure ------------------------- *
!
      FLA = 0.
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9005)
#endif
          IAD00  = -MY
          IAD02  =  MY
          IADN0  = IAD00 + MY*NX
          IADN1  =         MY*NX
          IADN2  = IAD02 + MY*NX
!
#ifdef W3_OMPH
!$OMP PARALLEL DO PRIVATE (IY)
#endif
!
          DO IY=1, NY
            Q   (IY+IAD00) = Q   (IY+IADN0) ! 1 ghost column to left
            Q   (IY+IADN1) = Q   (   IY   ) ! 1st ghost column to right
            Q   (IY+IADN2) = Q   (IY+IAD02) ! 2nd ghost column to right
            CFLL(IY+IADN1) = CFLL(   IY   ) ! as for Q above, 1st to rt
            END DO
!
#ifdef W3_OMPH
!$OMP END PARALLEL DO
#endif
!
        END IF
!
! 2.  Fluxes for central points ------------------------------------- *
!     ( 3rd order + limiter )
!
#ifdef W3_T1
      WRITE (NDST,9010)
      WRITE (NDST,9011) NB0, 'CENTRAL'
#endif
!
#ifdef W3_OMPH
!$OMP PARALLEL DO PRIVATE (IP, IXY, CFL, IXYC, QB, IXYU, IXYD, &
#ifdef W3_T1
!$OMP                      QBO, QN, IX, IY, IX2, IY2,              &
#endif
!$OMP&                     DQ, DQNZ, QCN, QBN, QBR, CFAC )
#endif
!
      DO IP=1, NB0
!
        IXY    = MAPBOU(IP)
        CFL    = 0.5 * ( CFLL(IXY) + CFLL(IXY+INC) )
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        QB     = 0.5 * ( (1.-CFL)*Q(IXY+INC) + (1.+CFL)*Q(IXY) )      &
            - (1.-CFL**2)/6. * (Q(IXYC-INC)-2.*Q(IXYC)+Q(IXYC+INC))
!
        IXYU   = IXYC - INC * INT ( SIGN (1.1,CFL) )
        IXYD   = 2*IXYC - IXYU
        DQ     = Q(IXYD) - Q(IXYU)
        DQNZ   = SIGN ( MAX(1.E-15,ABS(DQ)) , DQ )
        QCN    = ( Q(IXYC) - Q(IXYU) ) / DQNZ
        QCN    = MIN ( 1.1, MAX ( -0.1 , QCN ) )
!
#ifdef W3_T1
        QBO    = QB
#endif
        QBN    = MAX ( (QB-Q(IXYU))/DQNZ , QCN )
        QBN    = MIN ( QBN , 1. , QCN/MAX(1.E-10,ABS(CFL)) )
        QBR    = Q(IXYU) + QBN*DQ
        CFAC   = REAL ( INT( 2. * ABS(QCN-0.5) ) )
        QB     = (1.-CFAC)*QBR + CFAC*Q(IXYC)
!
        FLA(IXY) = CFL * QB
!
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( QB, QBO, Q(IXY-INC), Q(   IXY   ),         &
                                Q(IXY+INC), Q(IXY+2*INC) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9012) IP, IX, IY, IX2, IY2,               &
                              CFL, CFLL(IXY), CFLL(IXY+INC),      &
                  QBO*QN, QB*QN, Q(IXY-INC)*QN, Q(   IXY   )*QN,  &
                                 Q(IXY+INC)*QN, Q(IXY+2*INC)*QN
          END IF
#endif
!
        END DO
!
#ifdef W3_OMPH
!$OMP END PARALLEL DO
#endif
!
! 3.  Fluxes for points with boundary above ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB1-NB0, 'BOUNDARY ABOVE'
#endif
!
!!!/OMPH/!$OMP PARALLEL DO PRIVATE (IP, IXY, CFL, IXYC)
!!!
      DO IP=NB0+1, NB1
        IXY    = MAPBOU(IP)
        CFL    = CFLL(IXY)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        FLA(IXY) = CFL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9013) IP, IX, IY, IX2, IY2, CFL,          &
                   CFLL(IXY), Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!!!
!!!/OMPH/!$OMP END PARALLEL DO
!
! 4.  Fluxes for points with boundary below ------------------------- *
!     ( 1st order without limiter )
!
#ifdef W3_T1
      WRITE (NDST,9011) NB2-NB1, 'BOUNDARY BELOW'
#endif
!
!!!/OMPH/!$OMP PARALLEL DO PRIVATE (IP, IXY, CFL, IXYC)
!!!
      DO IP=NB1+1, NB2
        IXY    = MAPBOU(IP)
        CFL    = CFLL(IXY+INC)
        IXYC   = IXY - INC * INT( MIN ( 0. , SIGN(1.1,CFL) ) )
        FLA(IXY) = CFL * Q(IXYC)
#ifdef W3_T1
        IY     = MOD ( IXY , MY )
        IX     = 1 + IXY/MY
        IY2    = MOD ( IXY+INC , MY )
        IX2    = 1 + (IXY+INC)/MY
        QN     = MAX ( Q(IXY+INC), Q(IXY) )
        IF ( QN .GT. 1.E-10 ) THEN
            QN     = 1. /QN
            WRITE (NDST,9014) IP, IX, IY, IX2, IY2, CFL, CFLL(IXY+INC), &
                              Q(IXYC)*QN, Q(IXY)*QN, Q(IXY+INC)*QN
          END IF
#endif
        END DO
!
!!!/OMPH/!$OMP END PARALLEL DO
!
! 5.  Global closure ----------------------------------------------- *
!
      IF ( CLOSE ) THEN
#ifdef W3_T
          WRITE (NDST,9015)
#endif
          DO IY=1, NY
            FLA (IY+IAD00) = FLA (IY+IADN0)
            END DO
        END IF
!
! 6.  Propagation -------------------------------------------------- *
!
#ifdef W3_T2
      WRITE (NDST,9020)
#endif
#ifdef W3_OMPH
!$OMP PARALLEL DO PRIVATE (IP, IXY, JN, JP )
#endif
!
      DO IP=1, NACT
!
        IXY    = MAPACT(IP)
        IF ( FLA(IXY-INC) .GT. 0. ) THEN
            JN    = -1
          ELSE
            JN    =  0
          END IF
        IF ( FLA(IXY    ) .LT. 0. ) THEN
            JP    =  1
          ELSE
            JP    =  0
          END IF
!
#ifdef W3_T2
        QOLD   = Q(IXY)
#endif
        Q(IXY) = MAX ( 0. , Q(IXY) + TRANS(IXY,JN) * FLA(IXY-INC)     &
                                   - TRANS(IXY,JP) * FLA(IXY) )

#ifdef W3_T2
        IF ( QOLD + Q(IXY) .GT. 1.E-10 )                          &
             WRITE (NDST,9021) IP, IXY, QOLD, Q(IXY),             &
                               FLA(IXY-INC), FLA(IXY)
#endif
        END DO
!
#ifdef W3_OMPH
!$OMP END PARALLEL DO
#endif
!
#ifdef W3_T0
      WRITE (NDST,9001) 'Q'
      DO IY=NY,1,-1
        WRITE (NDST,9002) (NINT(Q(IY+(IX-1)*MY)/QMAX),IX=1,NX)
        END DO
#endif
!
      RETURN
!
! Formats
!
#ifdef W3_T
 9000 FORMAT ( ' TEST W3QCK3 : ARRAY DIMENSIONS  :',2I6/           &
               '               USED              :',2I6/           &
               '               CLOSE, INC        :',L6,I6/         &
               '               NB0, NB1, NB2     :',3I6)
#endif
#ifdef W3_T0
 9001 FORMAT ( ' TEST W3QCK3 : DUMP ARRAY ',A,' :')
 9002 FORMAT ( 1X,43I3)
 9003 FORMAT ( 1X,21I6)
#endif
#ifdef W3_T
 9005 FORMAT (' TEST W3QCK3 : GLOBAL CLOSURE (1)')
#endif
!
#ifdef W3_T1
 9010 FORMAT (' TEST W3QCK3 : IP, 2x(IX,IY), CFL (b,i,i+1), ',    &
              ' Q (b,b,i-1,i,i+1,i+2)')
 9011 FORMAT (' TEST W3QCK3 :',I6,' POINTS OF TYPE ',A)
 9012 FORMAT (10X,I6,4I4,1X,3F6.2,1X,F7.2,F6.2,1X,4F6.2)
 9013 FORMAT (10X,I6,4I4,1X,F6.2,F6.2,'  --- ',1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
 9014 FORMAT (10X,I6,4I4,1X,F6.2,'  --- ',F6.2,1X,F7.2,1X,'  --- ',&
              2F6.2,'  --- ')
#endif
#ifdef W3_T
 9015 FORMAT (' TEST W3QCK3 : GLOBAL CLOSURE (2)')
#endif
!
#ifdef W3_T2
 9020 FORMAT (' TEST W3QCK3 : IP, IXY, 2Q, 2FL')
 9021 FORMAT ('            ',2I6,2(1X,2E11.3))
#endif
!/
!/ End of W3QCK3 ----------------------------------------------------- /
!/
      END SUBROUTINE W3QCK3
!/
!/ End of module W3UQCKMD -------------------------------------------- /
!/
      END MODULE W3UQCKMD