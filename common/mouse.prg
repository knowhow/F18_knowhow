FUNCTION MINRECT( nTop, nLeft, nBott, nRight)
LOCAL lInside := .F.
 
IF MROW() >= nTop .AND. MROW() <= nBott
     IF MCOL() >= nLeft .AND. MCOL() <= nRight
        lInside := .T.
    ENDIF
ENDIF

RETURN( lInside )

