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



FUNCTION fakt_ftxt_decode_memo()

   LOCAL hFaktParams := fakt_params()
   LOCAL aMemo := fakt_ftxt_decode( _txt )
   LOCAL _len := Len( aMemo )

   IF _len > 0
      _txt1 := aMemo[ 1 ]
   ENDIF

   IF _len >= 2
      cTxtIn := aMemo[ 2 ]
   ENDIF

   IF _len >= 9
      _brotp := aMemo[ 6 ]
      _datotp := CToD( aMemo[ 7 ] )
      _brnar := aMemo[ 8 ]
      _datpl := CToD( aMemo[ 9 ] )
   ENDIF

   IF _len >= 10 .AND. !Empty( aMemo[ 10 ] )
      _vezotpr := aMemo[ 10 ]
   ENDIF

   IF _len >= 11
      d2k1 := aMemo[ 11 ]
   ENDIF

   IF _len >= 12
      d2k2 := aMemo[ 12 ]
   ENDIF

   IF _len >= 13
      d2k3 := aMemo[ 13 ]
   ENDIF

   IF _len >= 14
      d2k4 := aMemo[ 14 ]
   ENDIF

   IF _len >= 15
      d2k5 := aMemo[ 15 ]
   ENDIF

   IF _len >= 16
      d2n1 := aMemo[ 16 ]
   ENDIF

   IF _len >= 17
      d2n2 := aMemo[ 17 ]
   ENDIF

   IF hFaktParams[ "destinacije" ] .AND. _len >= 18
      _destinacija := PadR( AllTrim( aMemo[ 18 ] ), 500 )
   ENDIF

   IF hFaktParams[ "fakt_dok_veze" ] .AND. _len >= 19
      _dokument_veza := PadR( AllTrim( aMemo[ 19 ] ), 500 )
   ENDIF

   IF hFaktParams[ "fakt_objekti" ] .AND. _len >= 20
      _objekti := PadR( aMemo[ 20 ], 10 )
   ENDIF

   RETURN .T.




FUNCTION fakt_ftxt_encode_2( aFaktTxtIn, cBrNar, cBrOtpr, dDatOtpr, dDatPl )

   LOCAL cFaktTxtNovi, nI

   // roba tip U
   cFaktTxtNovi := Chr( 16 ) + aFaktTxtIn[ 1 ] + Chr( 17 )
   // dodatni tekst fakture
   cFaktTxtNovi += Chr( 16 ) + aFaktTxtIn[ 2 ] + Chr( 17 )
   // naziv partnera
   cFaktTxtNovi += Chr( 16 ) + AllTrim( partn->naz ) + Chr( 17 )
   // partner 2 podaci
   cFaktTxtNovi += Chr( 16 ) + AllTrim( partn->adresa ) + ", Tel:" + AllTrim( partn->telefon ) + Chr( 17 )
   // partner 3 podaci
   cFaktTxtNovi += Chr( 16 ) + AllTrim( partn->ptt ) + " " + AllTrim( partn->mjesto ) + Chr( 17 )
   // broj otpremnice
   cFaktTxtNovi += Chr( 16 ) + cBrOtpr + Chr( 17 )
   // datum otpremnice
   cFaktTxtNovi += Chr( 16 ) + DToC( dDatOtpr ) + Chr( 17 )
   // broj narudzbenice
   cFaktTxtNovi += Chr( 16 ) + cBrNar + Chr( 17 )
   // datum placanja
   cFaktTxtNovi += Chr( 16 ) + DToC( dDatPl ) + Chr( 17 )

   IF Len( aFaktTxtIn ) > 9
      FOR nI := 10 TO Len( aFaktTxtIn )
         cFaktTxtNovi += Chr( 16 ) + aFaktTxtIn[ nI ] + Chr( 17 )
      NEXT
   ENDIF

   RETURN cFaktTxtNovi



FUNCTION fakt_ftxt_encode_3( cTxt1, cTxt2, _txt3a, _txt3b, _txt3c, ;
      _BrOtp, _BrNar, _DatOtp, _DatPl, cVezaOtpremnica, ;
      _dest, _m_dveza )

   RETURN Chr( 16 ) + Trim( cTxt1 ) + Chr( 17 ) + Chr( 16 ) + cTxt2 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrNar + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
      iif( Empty ( cVezaOtpremnica ), "", Chr( 16 ) + cVezaOtpremnica + Chr( 17 ) ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _dest ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _m_dveza ) + Chr( 17 )


FUNCTION fakt_ftxt_encode_4( cTxt1, cTxt2, _txt3a, _txt3b, _txt3c, _BrOtp, _DatOtp, ;
      _BrNar, _DatPl, _VezOtpr, d2k1, d2k2, d2k3, d2k4, d2k5, d2n1, d2n2 )

   RETURN Chr( 16 ) + Trim( cTxt1 ) + Chr( 17 ) + Chr( 16 ) + cTxt2 + Chr( 17 ) + ;
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




FUNCTION fakt_ftxt_sub_renumeracija_pripreme( cTxt2 )

   LOCAL cId := "  "
   LOCAL cUserName

   IF _IdTipDok $ "10#20" .AND. partner_is_ino( _IdPartner )
      fakt_ftxt_ino_klauzula()
      IF Empty( AllTrim( cTxt2 ) )
         cId := "IN"
      ENDIF
   ENDIF


   IF Empty( AllTrim( cTxt2 ) )
      cId := "KS"
   ENDIF


   IF ( nRbr == 1 .AND. Val( _podbr ) < 1 )

      Box(, 9, 75 )

      @ m_x + 1, m_Y + 1  SAY "Uzorak teksta (<c-W> za kraj unosa teksta):"  GET cId PICT "@!"
      READ

      IF LastKey() <> K_ESC .AND. !Empty( cId )

         p_fakt_ftxt( @cId )

         select_o_fakt_txt( cId )

         SELECT fakt_pripr

         cTxt2 := Trim( ftxt->naz )

         cUserName := f18_user_name()

         IF !Empty( cUserName ) .AND. cUserName <> "?user?"
            cTxt2 += " Dokument izradio: " + cUserName
         ENDIF

         SELECT fakt_pripr

         IF glDistrib .AND. _IdTipdok == "26"
            IF cId $ ";"
               _k2 := "OPOR"
            ELSE
               _k2 := ""
            ENDIF
         ENDIF

      ENDIF

      SetColor( f18_color_invert()  )

      PRIVATE fUMemu := .T.
      cTxt2 := MemoEdit( cTxt2, m_x + 3, m_y + 1, m_x + 9, m_y + 76 )

      fUMemu := NIL

      SetColor( f18_color_normal() )

      BoxC()

   ENDIF

   RETURN .T.





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



FUNCTION fakt_ftxt_add_text_by_id( cTxt, cIdFaktTxt, nCount, lAppend )

   LOCAL cTmp
   LOCAL cUserName

   IF lAppend == nil
      lAppend := .F.
   ENDIF
   IF nCount == nil
      nCount := 1
   ENDIF

   // prazan tekst - ne radi nista
   IF Empty( cIdFaktTxt )
      RETURN .F.
   ENDIF

   select_o_fakt_txt( cIdFaktTxt )
   SELECT fakt_pripr

   IF lAppend == .F.
      cTxt := Trim( ftxt->naz )
   ELSE

      cTmp := ""
      IF nCount > 1
         cTmp += NRED_DOS
      ENDIF
      cTmp += Trim( ftxt->naz )

      cTxt +=  cTmp
   ENDIF

   IF nCount == 1

      cUserName := f18_user_name()

      IF !Empty( cUserName ) .AND. cUserName <> "?user?"
         cTxt2 += " Dokument izradio: " + cUserName
      ENDIF

   ENDIF

   RETURN .T.


FUNCTION f18_user_name()

   RETURN AllTrim( GetFullUserName( GetUserID() ) )

FUNCTION fakt_ftxt_encode( cFTxtNaz, cTxt1, cTxt3a, cTxt3b, cTxt3c, cVezaUgovor, cDodTxt )

   RETURN Chr( 16 ) + cTxt1 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( ftxt->naz ) + Chr( 13 ) + Chr( 10 ) + ;
      cVezaUgovor + Chr( 13 ) + Chr( 10 ) + ;
      cDodTxt + Chr( 17 ) + Chr( 16 ) + ;
      _Txt3a + Chr( 17 ) + Chr( 16 ) + _Txt3b + Chr( 17 ) + ;
      Chr( 16 ) + _Txt3c + Chr( 17 )





FUNCTION fakt_ftxt_encode_5( cTxtIn )

   LOCAL _tmp
   LOCAL hFaktParams := fakt_params()
   LOCAL cTxt

altd()
   // odsjeci na kraju prazne linije
   cTxtIn := OdsjPLK( cTxtIn )

   IF ! "Racun formiran na osnovu" $ cTxtIn
      cTxtIn += Chr( 13 ) + Chr( 10 ) + _vezotpr
   ENDIF

   cTxt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 )
   cTxt += Chr( 16 ) + cTxtIn + Chr( 17 )
   cTxt += Chr( 16 ) + "" + Chr( 17 )
   cTxt += Chr( 16 ) + "" + Chr( 17 )
   cTxt += Chr( 16 ) + "" + Chr( 17 )

   // 6 - br otpr
   cTxt += Chr( 16 ) + _brotp + Chr( 17 )
   // 7 - dat otpr
   cTxt += Chr( 16 ) + DToC( _datotp ) + Chr( 17 )
   // 8 - br nar
   cTxt += Chr( 16 ) + _brnar + Chr( 17 )
   // 9 - dat nar
   cTxt += Chr( 16 ) + DToC( _datpl ) + Chr( 17 )
   // 10
   cTxt += Chr( 16 ) + _vezotpr + Chr( 17 )
   // 11
   cTxt += Chr( 16 ) + d2k1 + Chr( 17 )
   // 12
   cTxt += Chr( 16 ) + d2k2 + Chr( 17 )
   // 13
   cTxt += Chr( 16 ) + d2k3 + Chr( 17 )
   // 14
   cTxt += Chr( 16 ) + d2k4 + Chr( 17 )
   // 15
   cTxt += Chr( 16 ) + d2k5 + Chr( 17 )
   // 16
   cTxt += Chr( 16 ) + d2n1 + Chr( 17 )
   // 17
   cTxt += Chr( 16 ) + d2n2 + Chr( 17 )

   IF hFaktParams[ "destinacije" ]
      _tmp := _destinacija
   ELSE
      _tmp := ""
   ENDIF

   // 18 - Destinacija
   cTxt += Chr( 16 ) + AllTrim( _tmp ) + Chr( 17 )

   // 19 - vezni dokumenti
   IF hFaktParams[ "fakt_dok_veze" ]
      _tmp := _dokument_veza
   ELSE
      _tmp := ""
   ENDIF

   cTxt += Chr( 16 ) + AllTrim( _dokument_veza ) + Chr( 17 )

   // 20 - objekti
   IF hFaktParams[ "fakt_objekti" ]
      _tmp := _objekti
   ELSE
      _tmp := ""
   ENDIF

   cTxt += Chr( 16 ) + _tmp + Chr( 17 )

   RETURN cTxt


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
