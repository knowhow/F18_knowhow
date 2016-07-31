/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

MEMVAR m_x, m_y, GetList
/*
   kalk_set_brkalk_za_idvd( "11", @cBrKalk )
*/

FUNCTION kalk_set_brkalk_za_idvd( cIdVd, cBrKalk )

   IF gBrojacKalkulacija == "D"

      find_kalk_doks_za_tip( gFirma, "11" )
      GO BOTTOM
      IF field->idvd <> cIdVd
         cBrKalk := Space( 8 )
      ELSE
         cBrKalk := field->brdok
      ENDIF
      cBrKalk := UBrojDok( Val( Left( cBrKalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )

   ENDIF

   RETURN cBrKalk



/*
  sljedeci broj kalkulacije
*/

FUNCTION kalk_sljedeci_brdok( cTipKalk, cIdFirma, cSufiks )

   LOCAL cBrKalk := Space( 8 )

   IF cSufiks == nil
      cSufiks := Space( 3 )
   ENDIF


   IF glBrojacPoKontima
         /*
            SELECT kalk_doks
            SET ORDER TO TAG "1S" // "IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)"
            SEEK cIdFirma + cTipKalk + cSufiks + "X"
         */
      find_kalk_doks_za_tip_sufix( cIdFirma, cTipKalk, cSufiks )
   ELSE
      find_kalk_doks_za_tip( cIdFirma, cTipKalk )
         /*
            SELECT kalk
            SET ORDER TO TAG "1"
            SEEK cIdFirma + cTipKalk + "X"
         */
   ENDIF

   // SKIP -1
   GO BOTTOM // zzadnji u nizu

   IF cTipKalk <> field->idVD .OR. glBrojacPoKontima .AND. Right( field->brDok, 3 ) <> cSufiks
      cBrKalk := Space( gLenBrKalk ) + cSufiks
   ELSE
      cBrKalk := field->brDok
   ENDIF

   IF cTipKalk == "16" .AND. glEvidOtpis
      cBrKalk := StrTran( cBrKalk, "-X", "  " )
   ENDIF

   IF AllTrim( cBrKalk ) >= "99999"
      cBrKalk := PadR( novasifra( AllTrim( cBrKalk ) ), 5 ) + Right( cBrKalk, 3 )
   ELSE
      cBrKalk := UBrojDok( Val( Left( cBrKalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   RETURN cBrKalk




   /*
    uvecava broj kalkulacije sa stepenom uvecanja nUvecaj
   */

FUNCTION kalk_get_next_kalk_doc_uvecaj( cIdFirma, cIdTipDok, nUvecaj )

   LOCAL xx
   LOCAL i
   LOCAL lIdiDalje

   IF nUvecaj == nil
      nUvecaj := 1
   ENDIF

   lIdiDalje := .F.

   find_kalk_doks_by_broj_dokumenta( cIdFirma, cIdTipDok )
   GO BOTTOM

   DO WHILE .T.
      FOR i := 2 TO Len( AllTrim( field->brDok ) )
         IF !IsNumeric( SubStr( AllTrim( field->brDok ), i, 1 ) )
            lIdiDalje := .F.
            SKIP -1
            LOOP
         ELSE
            lIdiDalje := .T.
         ENDIF
      NEXT

      IF lIdiDalje := .T.
         cResult := field->brDok
         EXIT
      ENDIF

   ENDDO

   xx := 1

   FOR xx := 1 TO nUvecaj
      cResult := PadR( novasifra( AllTrim( cResult ) ), 5 ) + ;
         Right( cResult, 3 )
   NEXT

   RETURN cResult



// ------------------------------------------------
// vraca prazan broj dokumenta
// ------------------------------------------------
FUNCTION kalk_prazan_broj_dokumenta()
   RETURN PadR( "0", 5, "0" )


// ------------------------------------------------------------
// resetuje brojac dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
FUNCTION kalk_reset_broj_dokumenta( firma, tip_dokumenta, broj_dokumenta, konto )

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _sufix := ""

   IF konto == NIL
      konto := ""
   ENDIF

   IF glBrojacPoKontima
      _sufix := kalk_sufix_brdok( konto )
   ENDIF

   // param: kalk/10/10
   _param := "kalk" + "/" + firma + "/" + tip_dokumenta + iif( !Empty( _sufix ), "_" + _sufix, "" )
   _broj := fetch_metric( _param, nil, _broj )

   IF Val( broj_dokumenta ) == _broj
      -- _broj
      // smanji globalni brojac za 1
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN .T.


// ------------------------------------------------------------------
// kalk, uzimanje novog broja za kalk dokument
// ------------------------------------------------------------------
FUNCTION kalk_novi_broj_dokumenta( firma, tip_dokumenta, konto )

   LOCAL _broj := 0
   LOCAL _broj_dok := 0
   LOCAL _len_broj := 5
   LOCAL _len_brdok, _len_sufix
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL _t_area := Select()
   LOCAL _sufix := ""

   // ova funkcija se brine i za sufiks
   IF konto == NIL
      konto := ""
   ENDIF


   IF glBrojacPoKontima // moramo pronaci sufiks
      _sufix := kalk_sufix_brdok( konto )
   ENDIF

   // param: kalk/10/10
   _param := "kalk" + "/" + firma + "/" + tip_dokumenta + iif( !Empty( _sufix ), "_" + _sufix, "" )
   _broj := fetch_metric( _param, nil, _broj )

   // konsultuj i doks uporedo
   find_kalk_doks_za_tip_sufix(  firma, tip_dokumenta, _sufix )

   // IF glBrojacPoKontima
   // SET ORDER TO TAG "1S"
   // ELSE
   // SET ORDER TO TAG "1"
   // ENDIF
   // GO TOP
   // SEEK firma + tip_dokumenta + _sufix + "X"
   // SKIP -1
   GO BOTTOM

   IF field->idfirma == firma .AND. field->idvd == tip_dokumenta .AND. ;
         iif( glBrojacPoKontima, Right( AllTrim( field->brdok ), Len( _sufix ) ) == _sufix, .T. )

      IF glBrojacPoKontima .AND. ( _sufix $ field->brdok )
         _len_brdok := Len( AllTrim( field->brdok ) )
         _len_sufix := Len( _sufix )
         // odrezi sufiks ako postoji
         _broj_dok := Val( Left( AllTrim( field->brdok ), _len_brdok - _len_sufix ) )
      ELSE
         _broj_dok := Val( field->brdok )
      ENDIF

   ELSE
      _broj_dok := 0
   ENDIF

   _broj := Max( _broj, _broj_dok ) // uzmi sta je vece, dokument broj ili globalni brojac

   // uvecaj broj
   ++ _broj

   // ovo ce napraviti string prave duzine...
   // dodaj i sufiks na kraju ako treba
   _ret := PadL( AllTrim( Str( _broj ) ), _len_broj, "0" ) + _sufix

   // upisi ga u globalni parametar
   set_metric( _param, nil, _broj )

   SELECT ( _t_area )

   RETURN _ret



// ---------------------------------------------
// odredjuje sufiks broja dokumenta
// ---------------------------------------------
FUNCTION kalk_sufix_brdok( cIdKonto )

   LOCAL nArr := Select()
   LOCAL cSufiks := Space( 3 )

   SELECT koncij
   SEEK cIdKonto

   IF Found()
      IF FieldPos( "sufiks" ) <> 0
         cSufiks := field->sufiks
      ENDIF
   ENDIF
   SELECT ( nArr )

   RETURN cSufiks



// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
FUNCTION kalk_set_broj_dokumenta()

   LOCAL _broj_dokumenta
   LOCAL _t_rec, _rec
   LOCAL _firma, _td, _null_brdok
   LOCAL _konto := ""

   PushWA()

   SELECT kalk_pripr
   GO TOP

   _null_brdok := kalk_prazan_broj_dokumenta()

   IF field->brdok <> _null_brdok
      // nemam sta raditi, broj je vec setovan
      PopWa()
      RETURN .F.
   ENDIF

   _firma := field->idfirma
   _td := field->idvd
   _konto := field->idkonto

   // daj mi novi broj dokumenta
   _broj_dokumenta := kalk_novi_broj_dokumenta( _firma, _td, _konto )

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      IF field->idfirma == _firma .AND. field->idvd == _td .AND. field->brdok == _null_brdok
         _rec := dbf_get_rec()
         _rec[ "brdok" ] := _broj_dokumenta
         dbf_update_rec( _rec )
      ENDIF

      GO ( _t_rec )

   ENDDO

   PopWa()

   RETURN .T.



// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
FUNCTION kalk_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _firma := gFirma
   LOCAL _tip_dok := "10"
   LOCAL _sufix := ""
   LOCAL _konto := PadR( "1330", 7 )

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Dokument:" GET _firma
   @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok

   IF glBrojacPoKontima
      @ m_x + 1, Col() + 1 SAY " konto:" GET _konto
   ENDIF

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   IF glBrojacPoKontima
      _sufix := kalk_sufix_brdok( _konto )
   ENDIF

   // param: kalk/10/10
   _param := "kalk" + "/" + firma + "/" + tip_dokumenta + iif( !Empty( _sufix ), "_" + _sufix, "" )
   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "99999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      // snimi broj u globalni brojac
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN .T.



FUNCTION get_kalk_brdok( _idfirma, _idvd, _idkonto, _idkonto2 )

   LOCAL _brdok, cSufiks

   IF glBrojacPoKontima

      Box( "#Glavni konto", 3, 70 )
      IF _idvd $ "10#16#18#IM#"
         @ m_x + 2, m_y + 2 SAY8 "Magacinski konto zadužuje" GET _idKonto VALID P_Konto( @_idKonto ) PICT "@!"
         READ

         cSufiks := kalk_sufix_brdok( _idKonto )
      ELSE
         @ m_x + 2, m_y + 2 SAY8 "Magacinski konto razdužuje" GET _idKonto2 VALID P_Konto( @_idKonto2 ) PICT "@!"
         READ
         cSufiks := kalk_sufix_brdok( _idKonto2 )
      ENDIF
      BoxC()

      _brDok := kalk_sljedeci_brdok( _idvd, _idfirma, cSufiks )

   ELSE

      _brDok := kalk_sljedeci_brdok( _idvd, _idfirma )

   ENDIF

   RETURN _brdok
