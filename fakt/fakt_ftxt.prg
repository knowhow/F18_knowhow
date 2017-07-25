#include "f18.ch"

MEMVAR Kol, ImeKol

FUNCTION p_fakt_ftxt( cId, dx, dy )

   LOCAL xRet
   LOCAL nDbfArea := Select()
   LOCAL nBottom
   LOCAL nTop
   LOCAL nLeft
   LOCAL nRight
   LOCAL nBoxHeight := f18_max_rows() - 20
   LOCAL nBoxWidth := f18_max_cols() - 3
   LOCAL i
   PRIVATE ImeKol
   PRIVATE Kol

   PushWA()

   IF cId != NIL .AND. !Empty( cId )
      select_o_fakt_txt( "XXXXXXX" ) // cId je zadan, otvoriti samo dummy tabelu sa 0 zapisa
   ELSE
      select_o_fakt_txt()
   ENDIF

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { PadR( "ID", 2 ),   {|| id },     "id", {|| .T. }, {|| validacija_postoji_sifra( wid ) }    } )
   // add_mcode( @ImeKol )
   // AAdd( ImeKol, { "Naziv",  {|| naz },  "naz", {|| .T. }, {|| wNaz := StrTran( wnaz, "##", hb_eol() ), .T. }, NIL, "@S50" } )
   AAdd( ImeKol, { "Naziv",  {|| naz },  "naz", {|| fakt_ftxt_naz_tarabiraj( @wNaz ) }, {|| .T. }, NIL, "@S50" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   nBottom := 15
   nTop := 3
   nLeft := 1
   nRight := f18_max_cols() - 3

   box_crno_na_zuto( nTop, nLeft, nBottom, nRight, "PREGLED TEKSTA" )

   @ nBottom, 0 SAY ""

   xRet := p_sifra( F_FTXT, 1, nBoxHeight, nBoxWidth, "Faktura - tekst na kraju fakture", @cId, , , {|| fakt_ftxt_keyboard_handler( nTop, nLeft, 8, nRight ) } )

   Prozor0()

   SELECT ( nDbfArea )
   PopWa()

   RETURN xRet


FUNCTION fakt_ftxt_naz_tarabiraj( cNaz )

   cNaz := StrTran( cNaz, NRED_DOS, "##" )
   cNaz := StrTran( cNaz, hb_eol(), "##" )

   RETURN .T.


/*
 *     Prikazuje uzorak teksta
 */

FUNCTION fakt_ftxt_keyboard_handler( nTopPos, nLeftPos, nBottomPos, nTxtLenght )

   LOCAL nI := 0
   LOCAL aFtxt := {}

   @ nTopPos, 6 SAY "uzorak teksta id: " + field->id

   aFtxt := decode_string_to_array( field->naz, nTxtLenght - 1 - nLeftPos, "##" )

   FOR nI := 1 TO nBottomPos
      IF nI > Len( aFtxt )
         @ nTopPos + nI, nLeftPos + 1 SAY Space( nTxtLenght - 1 - nLeftPos )
      ELSE
         @ nTopPos + nI, nLeftPos + 1 SAY PadR( aFtxt[ nI ], nTxtLenght - 1 - nLeftPos )
      ENDIF
   NEXT

   RETURN DE_REFRESH



/*
    *  "prvi red" + hb_eol() + "drugi red" => { "prvi red", "drugi red" }
    *  param cTxt   - tekst
    *  param nKol   - broj kolona
*/

FUNCTION decode_string_to_array( cTxt, nKol, cSeparator )

   LOCAL aVrati := {}, lNastavi := .T., cPom := "", aPom := {}, nI := 0
   LOCAL nPoz := 0

   IF cSeparator == NIL
      cSeparator := NRED_DOS
   ENDIF

   cTxt := Trim( cTxt )
   DO WHILE lNastavi
      nPoz := At( NRED_DOS, cTxt )
      IF nPoz > 0
         cPom := Left( cTxt, nPoz - 1 )
         IF nPoz - 1 > nKol
            cPom := Trim( LomiGa( cPom, 1, 5, nKol ) )
            FOR  nI := 1  TO  Int( ( Len( cPom ) - 1 ) / nKol ) + 1
               AAdd( aVrati, SubStr( cPom, ( nI - 1 ) * nKol + 1, nKol ) )
            NEXT
         ELSE
            AAdd( aVrati, cPom )
         ENDIF
         cTxt := SubStr( cTxt, nPoz + 2 )
      ELSEIF !Empty( cTxt )
         cPom := Trim( cTxt )
         IF Len( cPom ) > nKol
            cPom := Trim( LomiGa( cPom, 1, 5, nKol ) )
            FOR  nI := 1  TO  Int( ( Len( cPom ) - 1 ) / nKol ) + 1
               AAdd( aVrati, SubStr( cPom, ( nI - 1 ) * nKol + 1, nKol ) )
            NEXT
         ELSE
            AAdd( aVrati, cPom )
         ENDIF
         lNastavi := .F.
      ELSE
         lNastavi := .F.
      ENDIF
   ENDDO

   RETURN aVrati


// =========================================================

/*
 *   Ispravka teksta ispod fakture (poziv iz menija)
 *   param: lSilent
 *   param: bFunc
 */

FUNCTION fakt_ispravka_ftxt( lSilent, bFunc )

   LOCAL cListaTxt := ""
   LOCAL aMemo

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   // lDoks2 := .T.

   IF !lSilent
      Scatter()
   ENDIF

   _BrOtp := Space( 50 )
   _DatOtp := CToD( "" )
   _BrNar := Space( 50 )
   _DatPl := CToD( "" )
   _VezOtpr := ""
   _txt1 := _txt2 := _txt3a := _txt3b := _txt3c := ""
   // txt1  -  naziv robe,usluge
   nRbr := RbrUNum( RBr )

   // IF lDoks2
   d2k1 := Space( 15 )
   d2k2 := Space( 15 )
   d2k3 := Space( 15 )
   d2k4 := Space( 20 )
   d2k5 := Space( 20 )
   d2n1 := Space( 12 )
   d2n2 := Space( 12 )
   // ENDIF

   aMemo := fakt_ftxt_decode( _txt )
   IF Len( aMemo ) > 0
      _txt1 := aMemo[ 1 ]
   ENDIF
   IF Len( aMemo ) >= 2
      _txt2 := aMemo[ 2 ]
   ENDIF
   IF Len( aMemo ) >= 5
      _txt3a := aMemo[ 3 ]; _txt3b := aMemo[ 4 ]; _txt3c := aMemo[ 5 ]
   ENDIF

   IF Len( aMemo ) >= 9
      _BrOtp := aMemo[ 6 ]; _DatOtp := CToD( aMemo[ 7 ] ); _BrNar := amemo[ 8 ]; _DatPl := CToD( aMemo[ 9 ] )
   ENDIF
   IF Len ( aMemo ) >= 10 .AND. !Empty( aMemo[ 10 ] )
      _VezOtpr := aMemo[ 10 ]
   ENDIF

   // IF lDoks2
   IF Len ( aMemo ) >= 11
      d2k1 := aMemo[ 11 ]
   ENDIF
   IF Len ( aMemo ) >= 12
      d2k2 := aMemo[ 12 ]
   ENDIF
   IF Len ( aMemo ) >= 13
      d2k3 := aMemo[ 13 ]
   ENDIF
   IF Len ( aMemo ) >= 14
      d2k4 := aMemo[ 14 ]
   ENDIF
   IF Len ( aMemo ) >= 15
      d2k5 := aMemo[ 15 ]
   ENDIF
   IF Len ( aMemo ) >= 16
      d2n1 := aMemo[ 16 ]
   ENDIF
   IF Len ( aMemo ) >= 17
      d2n2 := aMemo[ 17 ]
   ENDIF
   // ENDIF

   IF !lSilent
      cListaTxt := g_txt_tipdok( _idtipdok )
      fakt_unos_set_ftxt2( cListaTxt, nRbr )
   ENDIF

   IF bFunc <> nil
      Eval( bFunc )
   ENDIF

   _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrNar + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
      iif ( Empty ( _VezOtpr ), Chr( 16 ) + "" + Chr( 17 ), Chr( 16 ) + _VezOtpr + Chr( 17 ) ) + ;
      Chr( 16 ) + d2k1 + Chr( 17 ) + ;
      Chr( 16 ) + d2k2 + Chr( 17 ) + ;
      Chr( 16 ) + d2k3 + Chr( 17 ) + ;
      Chr( 16 ) + d2k4 + Chr( 17 ) + ;
      Chr( 16 ) + d2k5 + Chr( 17 ) + ;
      Chr( 16 ) + d2n1 + Chr( 17 ) + ;
      Chr( 16 ) + d2n2 + Chr( 17 )

   IF !lSilent
      my_rlock()
      Gather()
      my_unlock()
   ENDIF

   RETURN .T.



// -------------------------------------------------
// uzorak teksta na kraju fakture
// verzija sa listom...
// -------------------------------------------------
FUNCTION fakt_unos_set_ftxt2( cList, nRedBr )

   LOCAL cId := "  "
   LOCAL cU_txt
   LOCAL aList := {}
   LOCAL i
   LOCAL nCount := 1

   IF cList == nil
      cList := ""
   ENDIF

   cList := AllTrim( cList )

   IF !Empty( cList )
      IF Empty( _txt2 )
         IF Pitanje(, "Dokument sadrži txt listu, koristiti je ?", "D" ) == "N"
            cList := ""
         ENDIF
         aList := TokToNiz( cList, ";" )
      ENDIF
   ENDIF

   IF _IdTipDok $ "10#20" .AND. partner_is_ino( _IdPartner )
      fakt_ftxt_ino_klauzula()
      IF Empty( AllTrim( _txt2 ) )
         cId := "IN"
         AAdd( aList, cId )
      ENDIF
   ENDIF

   IF !Empty( cList )
      FOR i := 1 TO Len( aList )
         cU_txt := aList[ i ]
         fakt_a_to_public_var_txt2( cU_txt, nCount, .T. )
         cId := "MX"
         ++nCount
      NEXT
   ENDIF

   IF ( nRedBr == 1 .AND. Val( _podbr ) < 1 )
      fakt_unos_ftxt_box( @cId, nCount )
   ENDIF

   RETURN .T.



FUNCTION fakt_unos_ftxt_box( cId, nCount )

   LOCAL lRet := .T.
   LOCAL GetList := {}

   Box(, 11, 75 )

   DO WHILE .T.

      @ m_x + 1, m_y + 1 SAY8 "Odaberi uzorak teksta iz šifarnika:"  GET cId PICT "@!"
      @ m_x + 11, m_y + 1 SAY8 "<c+W> dodaj novi ili snimi i izađi <ESC> poništi"

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      IF LastKey() <> K_ESC .AND. !Empty( cId )
         IF cId <> "MX"
            p_fakt_ftxt( @cId )
            fakt_a_to_public_var_txt2( cId, nCount, .T. )
            ++nCount
            cId := "  "
         ENDIF
      ENDIF

      SetColor( f18_color_invert() )

      PRIVATE fUMemu := .T.

      _txt2 := MemoEdit( _txt2, m_x + 3, m_y + 1, m_x + 9, m_y + 76 )

      fUMemu := NIL
      SetColor( f18_color_normal() )

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      IF LastKey() == K_CTRL_W
         IF Pitanje(, "Nastaviti sa unosom teksta ? (D/N)", "N" ) == "N"
            lRet := .F.
            EXIT
         ENDIF
      ENDIF

   ENDDO
   BoxC()

   RETURN lRet



FUNCTION fakt_ftxt_ino_klauzula()

   LOCAL _rec

   PushWA()

   IF !select_o_fakt_txt( "IN" )

      APPEND BLANK
      _rec := dbf_get_rec()

      _rec[ "id" ] := "IN"
      _rec[ "naz" ] := "Porezno oslobadjanje na osnovu (nulta stopa) na osnovu clana 27. stav 1. tacka 1. ZPDV - izvoz dobara iz BIH"

      update_rec_server_and_dbf( "ftxt", _rec, 1, "FULL" )

   ENDIF

   PopWa()

   RETURN .T.




FUNCTION fakt_a_to_public_var_txt( cVal, lEmpty )

   LOCAL nTArr

   nTArr := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF
   // ako je prazno nemoj dodavati
   IF !lEmpty .AND. Empty( cVal )
      RETURN .F.
   ENDIF
   _txt += Chr( 16 ) + cVal + Chr( 17 )

   SELECT ( nTArr )

   RETURN .T.



FUNCTION fakt_a_to_public_var_txt2( cId_txt, nCount, lAppend )

   LOCAL cTmp
   LOCAL _user_name

   IF lAppend == nil
      lAppend := .F.
   ENDIF
   IF nCount == nil
      nCount := 1
   ENDIF

   // prazan tekst - ne radi nista
   IF Empty( cId_Txt )
      RETURN .F.
   ENDIF

   select_o_fakt_txt( cId_txt )
   SELECT fakt_pripr

   IF lAppend == .F.
      _txt2 := Trim( ftxt->naz )
   ELSE
      cTmp := ""

      IF nCount > 1
         cTmp += NRED_DOS
      ENDIF

      cTmp += Trim( ftxt->naz )

      _txt2 := _txt2 + cTmp
   ENDIF

   IF nCount == 1
      _user_name := AllTrim( GetFullUserName( GetUserID() ) )
      IF !Empty( _user_name ) .AND. _user_name <> "?user?"
         _txt2 += " Dokument izradio: " + _user_name
      ENDIF
   ENDIF

   RETURN .T.



FUNCTION fakt_ftxt_encode( cFTxtNaz, cTxt1, cTxt3a, cTxt3b, cTxt3c, cVezaUgovor, cDodTxt )

   RETURN Chr( 16 ) + _txt1 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( ftxt->naz ) + Chr( 13 ) + Chr( 10 ) + ;
      cVezaUgovor + Chr( 13 ) + Chr( 10 ) + ;
      cDodTxt + Chr( 17 ) + Chr( 16 ) + ;
      _Txt3a + Chr( 17 ) + Chr( 16 ) + _Txt3b + Chr( 17 ) + ;
      Chr( 16 ) + _Txt3c + Chr( 17 )




FUNCTION fakt_ftxt_decode( cTxt )

   // Struktura cTxt-a je: Chr(16) txt1 Chr(17)  Chr(16) txt2 Chr(17) ...
   LOCAL aMemo := {}
   LOCAL i, cPom, fPoc, _len

   fPoc := .F.
   cPom := ""

   FOR i := 1 TO Len( cTxt )

      IF  SubStr( cTxt, i, 1 ) == Chr( 16 )
         fPoc := .T.
      ELSEIF  SubStr( cTxt, i, 1 ) == Chr( 17 )
         fPoc := .F.
         AAdd( aMemo, cPom )
         cPom := ""
      ELSEIF fPoc
         cPom := cPom + SubStr( cTxt, i, 1 )
      ENDIF
   NEXT

   _len := Len( aMemo )

   // uvijek neka vrati polje od 20 elemenata

   FOR i := 1 TO ( 20 - _len )
      AAdd( aMemo, "" )
   NEXT

   RETURN aMemo
