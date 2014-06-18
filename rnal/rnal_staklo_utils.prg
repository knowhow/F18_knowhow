/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "rnal.ch"

// --------------------------------
// pretvara mm u inch-e
// --------------------------------
FUNCTION to_inch( nVal )

   LOCAL nConv := nVal

   IF nVal <> 0
      nConv := ROUND2( ( nVal / 25.4 ), 2 )
   ENDIF

   RETURN nConv


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
FUNCTION c_ukvadrat( nKol, nDim1, nDim2 )

   LOCAL xRet

   xRet := ( nDim1 / 1000 ) * ( nDim2 / 1000 )
   xRet := nKol * xRet

   RETURN xRet



// -----------------------------------------------------
// kalkulise duzinske metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
FUNCTION c_duzinski( nKol, nDim1, nDim2, nDim3, nDim4 )

   LOCAL xRet

   IF nDim3 == NIL .AND. nDim4 == nil
      xRet := ( ( ( nDim1 / 1000 )  * 2 ) + ( ( nDim2 / 1000 ) * 2 ) )
   ELSE
      xRet := ( ( nDim1 / 1000 ) + ( nDim2 / 1000 ) + ;
         ( nDim3 / 1000 ) + ( nDim4 / 1000 ) )
   ENDIF

   xRet := nKol * xRet

   RETURN xRet


// ------------------------------------------
// pretvara iznos u cent. u milimetr.
// ------------------------------------------
FUNCTION cm_2_mm( nVal )
   RETURN nVal * 10


// ------------------------------------------
// pretvara iznos iz mm u cm
// ------------------------------------------
FUNCTION mm_2_cm( nVal )
   RETURN nVal / 10


// ------------------------------------------
// pretvara mm u metre
// ------------------------------------------
FUNCTION mm_2_m( nVal )
   RETURN nVal / 1000


// ------------------------------------------
// pretvara m u mm
// ------------------------------------------
FUNCTION m_2_mm( nVal )
   RETURN nVal * 1000


// --------------------------------------------
// uklanjanje jokera iz stringa
// --------------------------------------------
FUNCTION rem_jokers( cVal )

   cVal := StrTran( cVal, "#G_CONFIG#", "" )
   cVal := StrTran( cVal, "#HOLE_CONFIG#", "" )
   cVal := StrTran( cVal, "#STAMP_CONFIG#", "" )
   cVal := StrTran( cVal, "#PREP_CONFIG#", "" )
   cVal := StrTran( cVal, "#RAL_CONFIG#", "" )

   RETURN



// ---------------------------------------------------
// ispisuje box sa slikom stakla i odabirom
// obrade na stranicama
// ---------------------------------------------------
FUNCTION glass_config( nWidth, nHeigh, ;
      cV1, cV2, cV3, cV4, ;
      nR1, nR2, nR3, nR4 )

   LOCAL nBoxX := 17
   LOCAL nBoxY := 56

   LOCAL nGLen := 40
   LOCAL nGLeft := 8
   LOCAL nGTop := 4
   LOCAL nGBott := 15
   LOCAL cColSch := "GR+/G+"

   PRIVATE GetList := {}

   cV1 := "N"
   cV2 := cV1
   cV3 := cV1
   cV4 := cV1

   cD1 := "N"
   cD2 := cD1
   cD3 := cD1
   cD4 := cD1

   nR1 := 0
   nR2 := nR1
   nR3 := nR1
   nR4 := nR1

   Box(, nBoxX, nBoxY )

   nStX := m_x + 2
   nStY := m_y + 2

   @ m_x + 1, m_y + 2 SAY "##glass_config##  select operations..."

   _show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh )
	
   // top
   @ m_x + nGTop - 1, m_y + ( nBoxY / 2 ) - 1 SAY "d1 ?" GET cV1 ;
      PICT "@!" VALID cV1 $ "DN"
	
   // left
   @ m_x + ( nBoxX / 2 ) + 1, m_y + ( nGLeft - 6 ) SAY "d2 ?" GET cV2 ;
      PICT "@!" VALID cV2 $ "DN"
	
   // right
   @ m_x + ( nBoxX / 2 ) + 1, m_y + ( nGLeft + nGLen + 3 ) SAY "d3 ?" GET cV3;
      PICT "@!" VALID cV3 $ "DN"
	
   // bottom
   @ m_x + nGBott + 1, m_y + ( nBoxY / 2 ) - 1 SAY "d4 ?" GET cV4 ;
      PICT "@!" VALID cV4 $ "DN"
	
	
   // procitaj prvo stranice
   READ
	
	
   IF pitanje(, "Definisati radijuse ?", "N" ) == "D"

      // pobrisi prethodno
      @ nStX, nStY CLEAR TO nStX + nBoxX - 3, nStY + nBoxY - 2


      _show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh )
		
      // top left
      @ m_x + nGTop - 1, m_y + ( nGLeft - 4 ) SAY "r1 ?" GET cD1 ;
         PICT "@!" VALID cD1 $ "DN"
	
      @ m_x + nGTop - 1, Col() + 1 GET nR1 PICT "99999" ;
         WHEN cD1 == "D" VALID val_radius( nR1, nWidth, nHeigh )
	
      // top right
      @ m_x + nGTop - 1, m_y + ( nGLen + 3 ) SAY "r2 ?" GET cD2 ;
         PICT "@!" VALID cD2 $ "DN"
	
      @ m_x + nGTop - 1, Col() + 1 GET nR2 PICT "99999" ;
         WHEN cD2 == "D" VALID val_radius( nR2, nWidth, nHeigh )
	
      // bott. left
      @ m_x + nGBott + 1, m_y + ( nGLeft - 4 ) SAY "r3 ?" GET cD3;
         PICT "@!" VALID cD3 $ "DN"
	
      @ m_x + nGBott + 1, Col() + 1 GET nR3 PICT "99999" ;
         WHEN cD3 == "D" VALID val_radius( nR3, nWidth, nHeigh )
	
      // bott. right
      @ m_x + nGBott + 1, m_y + ( nGLen + 3 ) SAY "r4 ?" GET cD4 ;
         PICT "@!" VALID cD4 $ "DN"

      @ m_x + nGBott + 1, Col() + 1 GET nR4 PICT "99999" ;
         WHEN cD4 == "D" VALID val_radius( nR4, nWidth, nHeigh )

      READ
	
      // zatim procitaj radijuse
	
   ENDIF
	
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   RETURN .T.



// ---------------------------------------------------
// staklo sa prepustom - konfigurator
// nove dimenzije stakla
// ---------------------------------------------------
FUNCTION prepust_config( cJoker, nWidth, nHeigh, ;
      nD1, nD2, nD3, nD4 )

   LOCAL nBoxX := 17
   LOCAL nBoxY := 66

   LOCAL nGLen := 38
   LOCAL nGLeft := 13
   LOCAL nGTop := 4
   LOCAL nGBott := 15
   LOCAL cColSch := "GR+/G+"

   PRIVATE GetList := {}

   nD1 := nWidth
   nD2 := nHeigh
   nD3 := nD2
   nD4 := nD1

   Box(, nBoxX, nBoxY )

   nStX := m_x + 2
   nStY := m_y + 2

   @ m_x + 1, m_y + 2 SAY "##glass_config## konfigurisanje prepusta..."

   _show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh )
	
   // top
   @ m_x + nGTop - 1, m_y + ( nBoxY / 2 ) - 1 SAY "A:" GET nD1 ;
      PICT pic_dim()
	
   // left
   @ m_x + ( nBoxX / 2 ) + 1, m_y + ( nGLeft - 10 ) SAY "B:" GET nD2 ;
      PICT pic_dim()
	
   // right
   @ m_x + ( nBoxX / 2 ) + 1, m_y + ( nGLeft + nGLen + 3 ) SAY "C:" GET nD3;
      PICT pic_dim()
	
   // bottom
   @ m_x + nGBott + 1, m_y + ( nBoxY / 2 ) - 1 SAY "D:" GET nD4 ;
      PICT pic_dim()
	
   READ
	
   BoxC()

   IF LastKey() == K_ESC
      RETURN ""
   ENDIF

   // ako su identicne mjere kao i original staklo
   // izadji
   IF ( nD1 = nWidth .AND. nD4 = nWidth ) .AND. ;
         ( nD2 = nHeigh .AND. nD3 = nHeigh )
      RETURN ""
   ENDIF

   cTmp := ""

   // dim. 1
   IF nD1 > 0
      cTmp += "A=" + AllTrim( Str( nD1, 12, 2 ) ) + "#"
   ENDIF
   // dim. 2
   IF nD2 > 0
      cTmp += "B=" + AllTrim( Str( nD2, 12, 2 ) ) + "#"
   ENDIF
   // dim. 3
   IF nD3 > 0
      cTmp += "C=" + AllTrim( Str( nD3, 12, 2 ) ) + "#"
   ENDIF
   // dim. 4
   IF nD4 > 0
      cTmp += "D=" + AllTrim( Str( nD4, 12, 2 ) ) + "#"
   ENDIF

   IF !Empty( cTmp )
      cTmp := "#" + cTmp
   ENDIF

   // formiraj gotov string
   // <A_PREP>:#D1=2#D2=5#
   // dim1 = 2mm
   // dim2 = 5mm itd...

   IF !Empty( cTmp )
      cRet := cJoker + ":" + cTmp
   ENDIF

   RETURN cRet


// --------------------------------------
// konfigurator busenja
// cJoker - joker operacije
// --------------------------------------
FUNCTION hole_config( cJoker )

   LOCAL nBoxX := 12
   LOCAL nBoxY := 65
   LOCAL nX := 1
   LOCAL cRet := ""
   LOCAL nHole1 := 0
   LOCAL nHole2 := 0
   LOCAL nHole3 := 0
   LOCAL nHole4 := 0
   LOCAL nHole5 := 0
   LOCAL nHole6 := 0
   LOCAL nHole7 := 0
   LOCAL nHole8 := 0
   LOCAL nHole9 := 0
   LOCAL nHole10 := 0
   LOCAL cTmp := ""
   LOCAL GetList := {}

   // generisi box za definisanje rupa...
   Box(, nBoxX, nBoxY )
	
   @ m_x + nX, m_y + 2 SAY "#HOLE_CONFIG#"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Rupa 1 (fi):" GET nHole1 PICT "999"

   nX += 1
	
   @ m_x + nX, m_y + 2 SAY "Rupa 2 (fi):" GET nHole2 PICT "999"
	
   nX += 1
	
   @ m_x + nX, m_y + 2 SAY "Rupa 3 (fi):" GET nHole3 PICT "999"
	
   nX += 1
	
   @ m_x + nX, m_y + 2 SAY "Rupa 4 (fi):" GET nHole4 PICT "999"
	
   nX += 1
	
   @ m_x + nX, m_y + 2 SAY "Rupa 5 (fi):" GET nHole5 PICT "999"
	
   READ

   IF pitanje(, "Da li postoji jos rupa ?", "N" ) == "D"
	
      nX += 1
	
      @ m_x + nX, m_y + 2 SAY "Rupa 6 (fi):" GET nHole6 PICT "999"
		
      nX += 1
	
      @ m_x + nX, m_y + 2 SAY "Rupa 7 (fi):" GET nHole7 PICT "999"

      nX += 1
	
      @ m_x + nX, m_y + 2 SAY "Rupa 8 (fi):" GET nHole8 PICT "999"
		
      nX += 1
	
      @ m_x + nX, m_y + 2 SAY "Rupa 9 (fi):" GET nHole9 PICT "999"
		
      nX += 1
	
      @ m_x + nX, m_y + 2 SAY "Rupa 10 (fi):" GET nHole10 PICT "999"

      READ

   ENDIF
   BoxC()

   cTmp := ""

   // rupa 1
   IF nHole1 <> 0
      cTmp += "H1=" + AllTrim( Str( nHole1 ) ) + "#"
   ENDIF

   // rupa 2
   IF nHole2 <> 0
      cTmp += "H2=" + AllTrim( Str( nHole2 ) ) + "#"
   ENDIF

   // rupa 3
   IF nHole3 <> 0
      cTmp += "H3=" + AllTrim( Str( nHole3 ) ) + "#"
   ENDIF

   // rupa 4
   IF nHole4 <> 0
      cTmp += "H4=" + AllTrim( Str( nHole4 ) ) + "#"
   ENDIF

   // rupa 5
   IF nHole5 <> 0
      cTmp += "H5=" + AllTrim( Str( nHole5 ) ) + "#"
   ENDIF

   // rupa 6
   IF nHole6 <> 0
      cTmp += "H6=" + AllTrim( Str( nHole6 ) ) + "#"
   ENDIF

   // rupa 7
   IF nHole7 <> 0
      cTmp += "H7=" + AllTrim( Str( nHole7 ) ) + "#"
   ENDIF

   // rupa 8
   IF nHole8 <> 0
      cTmp += "H8=" + AllTrim( Str( nHole8 ) ) + "#"
   ENDIF

   // rupa 9
   IF nHole9 <> 0
      cTmp += "H9=" + AllTrim( Str( nHole9 ) ) + "#"
   ENDIF

   // rupa 10
   IF nHole10 <> 0
      cTmp += "H10=" + AllTrim( Str( nHole10 ) ) + "#"
   ENDIF


   IF !Empty( cTmp )
      cTmp := "#" + cTmp
   ENDIF

   // formiraj gotov string
   // <A_BU_HOLE>:#H1=2#H2=5#
   // hole1 = 2mm
   // hole2 = 5mm

   IF !Empty( cTmp )
      cRet := cJoker + ":" + cTmp
   ENDIF

   RETURN cRet



// --------------------------------------------------
// vraæa u stringu ispis rupa i dimenzija rupa
// --------------------------------------------------
FUNCTION hole_read( cValue )

   LOCAL cRet := ""
   LOCAL aTmp
   LOCAL cTmp
   LOCAL aTmp2
   LOCAL i
   LOCAL aHole

   // "<A_BU>:#H1=24#H2=55#"
   aTmp := TokToNiz( cValue, ":" )

   IF aTmp[ 1 ] <> "<A_BU>"
      // ovo nije busenje
      RETURN cRet
   ENDIF

   cTmp := AllTrim( aTmp[ 2 ] )

   aTmp2 := TokToNiz( cTmp, "#" )

   // i sada imamo rupe ...
   // H1=24, H2=55

   FOR i := 1 TO Len( aTmp2 )
	
      aHole := {}
      aHole := TokToNiz( aTmp2[ i ], "=" )

      cHoleTick := AllTrim( aHole[ 2 ] )
	
      cRet += "fi=" + cHoleTick + " mm, "
   NEXT

   RETURN cRet

// --------------------------------------------------
// vraca u stringu ispis dimenzija prepust stakla
// --------------------------------------------------
FUNCTION prep_read( cValue, nW, nH )

   LOCAL cRet := ""
   LOCAL aTmp
   LOCAL cTmp
   LOCAL aTmp2
   LOCAL i
   LOCAL aPrep

   // "<A_PREP>:#A=24#B=55#"
   aTmp := TokToNiz( cValue, ":" )

   IF aTmp[ 1 ] <> "<A_PREP>"
      // ovo nije prepust
      RETURN cRet
   ENDIF

   cTmp := AllTrim( aTmp[ 2 ] )

   aTmp2 := TokToNiz( cTmp, "#" )

   // i sada imamo dimenzije ...
   // A=24, B=55, C=...

   FOR i := 1 TO Len( aTmp2 )
	
      aPrep := {}
      aPrep := TokToNiz( aTmp2[ i ], "=" )

      cPrepPos := AllTrim( aPrep[ 1 ] )
      cPrepDim := AllTrim( aPrep[ 2 ] )
	
      IF cPrepPos == "A"
         nW := Val( cPrepDim )
      ENDIF

      IF cPrepPos == "B"
         nH := Val( cPrepDim )
      ENDIF

      cRet += aTmp2[ i ] + " mm, "
   NEXT

   RETURN cRet


// ---------------------------------------------
// procitaj vrijednosti...
// ---------------------------------------------
FUNCTION get_prep_dim( cVal, nW, nH )
   RETURN prep_read( cVal, @nW, @nH )


// ---------------------------------------------------
// konfigurator pozicije peèata
// ---------------------------------------------------
FUNCTION stamp_config( cJoker, nWidth, nHeigh )

   LOCAL nBoxX := 17
   LOCAL nBoxY := 56
   LOCAL cReturn := ""
   LOCAL cTmp := ""
   LOCAL nGLen := 40
   LOCAL nGLeft := 8
   LOCAL nGTop := 6
   LOCAL nGBott := 15
   LOCAL cColSch := "GR+/G+"

   PRIVATE GetList := {}

   // varijable
   cStampInfo := "P"
   cStampSch := "N"
   nX1 := nY1 := 0
   nX2 := nY2 := 0
   nX3 := nY3 := 0
   nX4 := nY4 := 0

   Box(, nBoxX, nBoxY )

   DO WHILE .T.

      nStX := m_x + 2
      nStY := m_y + 2

      @ m_x + 1, m_y + 2 SAY "##stamp_position##  select position..."

      @ m_x + 2, m_y + 2 SAY "vrsta pecata [P]ositiv / [N]egativ:" GET cStampInfo VALID cStampInfo $ "PN" PICT "@!"
	
      @ m_x + 3, m_y + 2 SAY "pogledati shemu u prilogu (D/N)?" GET cStampSch VALID cStampSch $ "DN" PICT "@!"

      READ
	
      IF cStampSch == "N"
	
         _show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh )
	
         // x1
         @ m_x + nGTop - 1, m_y + nGLeft GET nX1 PICT "999" ;
            VALID val_stamp( nX1, nWidth, nHeigh )
         @ m_x + nGTop - 1, Col() SAY "mm"
	
         // x2
         @ m_x + nGTop - 1, Col() + nGLen - 8 GET nX2 PICT "999" ;
            VALID val_stamp( nX2, nWidth, nHeigh )
         @ m_x + nGTop - 1, Col() SAY "mm"
	
         // y1
         @ m_x + nGTop + 1, m_y + 2 GET nY1 PICT "999" ;
            VALID val_stamp( nY1, nWidth, nHeigh )
         @ m_x + nGTop + 1, Col() SAY "mm"
	
         // y2
         @ m_x + nGTop + 1, Col() + ( nGLen  + 4 ) GET nY2 PICT "999" ;
            VALID val_stamp( nY2, nWidth, nHeigh )
         @ m_x + nGTop + 1, Col() SAY "mm"
	
         // y3
         @ m_x + nGBott - 2, m_y + 2 GET nY3 PICT "999" ;
            VALID val_stamp( nY3, nWidth, nHeigh )
         @ m_x + nGBott - 2, Col() SAY "mm"
	
         // y4
         @ m_x + nGBott - 2, Col() + ( nGLen + 4 ) GET nY4 PICT "999" ;
            VALID val_stamp( nY4, nWidth, nHeigh )
         @ m_x + nGBott - 2, Col() SAY "mm"
	
         // x3
         @ m_x + nGBott + 1, m_y + nGLeft GET nX3 PICT "999" ;
            VALID val_stamp( nX3, nWidth, nHeigh )
         @ m_x + nGBott + 1, Col() SAY "mm"
	
         // x4
         @ m_x + nGBott + 1, Col() + ( nGLen - 8 ) GET nX4 PICT "999" ;
            VALID val_stamp( nX4, nWidth, nHeigh )
         @ m_x + nGBott + 1, Col() SAY "mm"

	
         READ
	
	
         // mora biti unesena pozicija
         IF ( nX1 + nX2 + nX3 + nX4 + nY1 + nY2 + nY3 + nY4 ) <> 0
            EXIT
         ENDIF

      ELSE
         EXIT
      ENDIF
	
	
   ENDDO
   BoxC()

   IF LastKey() == K_ESC
      RETURN cReturn
   ENDIF

   cTmp := ""

   IF nX1 <> 0
      cTmp += "X1=" + AllTrim( Str( nX1 ) ) + "#"
   ENDIF
   IF nY1 <> 0
      cTmp += "Y1=" + AllTrim( Str( nY1 ) ) + "#"
   ENDIF
   IF nX2 <> 0
      cTmp += "X2=" + AllTrim( Str( nX2 ) ) + "#"
   ENDIF
   IF nY2 <> 0
      cTmp += "Y2=" + AllTrim( Str( nY2 ) ) + "#"
   ENDIF
   IF nX3 <> 0
      cTmp += "X3=" + AllTrim( Str( nX3 ) ) + "#"
   ENDIF
   IF nY3 <> 0
      cTmp += "Y3=" + AllTrim( Str( nY3 ) ) + "#"
   ENDIF
   IF nX4 <> 0
      cTmp += "X4=" + AllTrim( Str( nX4 ) ) + "#"
   ENDIF
   IF nY4 <> 0
      cTmp += "Y4=" + AllTrim( Str( nY4 ) ) + "#"
   ENDIF

   IF !Empty( cTmp ) .OR. cStampSch == "D"
	
      // ako je pogledaj shemu
      IF cStampSch == "D"
		
         cTmp := cStampSch
		
      ENDIF
	
      // primjer stringa koji se dobije:
      // STAMP:P#X1=20#Y1=25#
	
      cReturn := "STAMP" + ":" + cStampInfo + "#" + cTmp

   ENDIF

   RETURN cReturn



// -----------------------------------------------
// citanje pozicije pecata za nalog
// -----------------------------------------------
FUNCTION stamp_read( cStampStr )

   LOCAL cRet := ""
   LOCAL i
   LOCAL aTmp
   LOCAL aTmp2
   LOCAL aTmp3

   IF Empty( cStampStr )
      RETURN cRet
   ENDIF

   // string                   1          2
   // ex: "<A_K>:P#X1=20#Y1=25" => {<A_K>} {P#X1=20#Y1=25}
   aTmp := TokToNiz( cStampStr, ":" )

   IF aTmp[ 1 ] <> "STAMP"

      RETURN cRet

   ENDIF


   // ex: "P#X1=20#Y1=25" =>  {P} {X1=20} {Y1=25}
   aTmp2 := TokToNiz( aTmp[ 2 ], "#" )

   cRet := "pozicija pecata: "


   // pozitiv ili negativ
   IF aTmp2[ 1 ] == "P"
      cRet += "pozitiv, "
   ELSEIF aTmp2[ 1 ] == "N"
      cRet += "negativ, "
   ENDIF

   IF aTmp2[ 2 ] == "D"

      // ako je pozicija pecata, pogledati shemu
      // ex: "P#D" => {P} {D}

      cRet += " (pogledaj shemu u prilogu ) "
      RETURN cRet
	
   ENDIF



   // x koordinata
   aTmp3 := TokToNiz( aTmp2[ 2 ], "=" )

   // dodaj na ispis
   cRet += _stamp_pos( aTmp3[ 1 ] )
   cRet += " "
   cRet += AllTrim( aTmp3[ 2 ] )
   cRet += " mm - "

   // y koordinata
   aTmp3 := TokToNiz( aTmp2[ 3 ], "=" )

   // dodaj na ispis i y koordinatu
   cRet += _stamp_pos( aTmp3[ 1 ] )
   cRet += " "
   cRet += AllTrim( aTmp3[ 2 ] )
   cRet += " mm"

   RETURN cRet


// ----------------------------------------
// pozicija peèata stranice
// ----------------------------------------
STATIC FUNCTION _stamp_pos( cVar )

   LOCAL cRet := ""

   DO CASE
   CASE cVar $ "X1#X2"
      cRet := "gore"
   CASE cVar $ "X3#X4"
      cRet := "dole"
   CASE cVar $ "Y1#Y3"
      cRet := "lijevo"
   CASE cVar $ "Y2#Y4"
      cRet := "desno"
   ENDCASE

   RETURN cRet



// -------------------------
// validacija pecata
// osnovu dimenzija A i B
// stakla
// -------------------------
FUNCTION val_stamp( nDim, nA, nB )

   LOCAL lRet := .T.

   // trenutno nas nista ne interesuje....

   RETURN lRet




// -------------------------
// validacija radijusa na
// osnovu dimenzija A i B
// stakla
// -------------------------
FUNCTION val_radius( nRadius, nA, nB )

   LOCAL lRet := .T.

   IF nRadius > ( nA / 2 ) .OR. nRadius > ( nB / 2 )
      lRet := .F.
   ENDIF

   IF lRet == .F.
      msgbeep( "Radijus ne moze biti veci od pola duzine stranice !" )
   ENDIF

   RETURN lRet


// ----------------------------------------
// prikazuje sliku stakla unutar box-a
// nLenght - duzina stakla
// nTop - vrh stakla
// nBottom - dno stakla
// nLeft - lijeva strana
// cColSch - kolor shema
// ----------------------------------------
STATIC FUNCTION _show_glass( nLenght, nTop, nBottom, nLeft, cColSch, ;
      nWidth, nHeigh )

   LOCAL i
   LOCAL nTmp
   LOCAL nDimPos := nBottom - nTop

   // gornja strana
   @ m_x + nTop, m_y + nLeft SAY Chr( 218 ) ;
      COLOR cColSch
   @ m_x + nTop, m_y + nLeft + 1 SAY Replicate( Chr( 196 ), nLenght ) ;
      COLOR cColSch
   @ m_x + nTop, m_y + ( nLeft + 1 + nLenght ) SAY Chr( 191 ) ;
      COLOR cColSch

   nTmp := nTop + 1

   // popuna
   FOR i := nTmp TO nBottom
      @ m_x + i, m_y + nLeft SAY Chr( 179 ) + ;
         Replicate( Chr( 176 ), nLenght ) + Chr( 179 ) COLOR cColSch
   NEXT

   // donja strana
   @ m_x + nBottom, m_y + nLeft SAY Chr( 192 ) ;
      COLOR cColSch
   @ m_x + nBottom, m_y + nLeft + 1 SAY Replicate( Chr( 196 ), nLenght ) ;
      COLOR cColSch
   @ m_x + nBottom, m_y + nLeft + 1 + nLenght SAY Chr( 217 ) ;
      COLOR cColSch

   // ispisi dimenzije stakla
   @ m_x + nDimPos - 1, m_y + 20 SAY "glass dimensions:"
   @ m_x + nDimPos, m_y + 20 SAY AllTrim( Str( nWidth, 12, 2 ) ) + ;
      " x " + ;
      AllTrim( Str( nHeigh, 12, 2 ) ) + " mm"

   RETURN


// ---------------------------------
// glass tickness
// ---------------------------------
FUNCTION glass_tick( cTick )

   LOCAL nGlTick := 0
   LOCAL aTmp := {}
   LOCAL cTmp := ""
   LOCAL i

   // ovo je slucaj za LAMI staklo...
   IF "." $ cTick

      // ex: "33.1"
      aTmp := TokToNiz( cTick, "." )
      // ex: "33"
      cTmp := aTmp[ 1 ]

      FOR i := 1 TO Len( cTmp )
         nGlTick += Val ( SubStr( cTmp, i, 1 ) )
      NEXT

      // ex: "33" -> 6
   ELSE
      // klasicno staklo...
      nGlTick := Val( AllTrim( cTick ) )
   ENDIF

   RETURN nGlTick



// ---------------------------------------------
// da li se radi o rama-term staklu
// ---------------------------------------------
FUNCTION is_ramaterm( cArticle )

   LOCAL lRet := .F.

   IF "_A" $ cArticle
      lRet := .T.
   ENDIF

   RETURN lRet
