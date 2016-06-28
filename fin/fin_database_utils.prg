/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION fin_admin_opcije_menu()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. provjera integriteta tabela - ima u suban nema u nalog " )
   AAdd( opcexe, {|| ImaUSubanNemaUNalog() } )

   AAdd( opc, "2. pregled datumskih gresaka u nalozima" )
   AAdd( opcexe, {|| daterr_rpt() } )

#ifdef F18_FMK
   AAdd( opc, "4. kontrola podataka nakon importa iz FMK" )
   AAdd( opcexe, {|| fmk_provjera_za_migraciju_f18() } )
#endif

   AAdd( opc, "------------------------------------------------------" )
   AAdd( opcexe, {|| NIL } )

   AAdd( opc, "B. podešenje brojača naloga" )
   AAdd( opcexe, {|| fin_set_param_broj_dokumenta() } )

   AAdd( opc, "------------------------------------------------------" )
   AAdd( opcexe, {|| NIL } )
   AAdd( opc, "R. fmk pravila - rules " )
   AAdd( opcexe, {|| p_rules(,,, aRuleCols, bRuleBlock ) } )


   Menu_SC( "adm" )

   RETURN .T.




// ----------------------------------------------------------------
// vraca naredni redni broj fin naloga
// ----------------------------------------------------------------
FUNCTION fin_dok_get_next_rbr( idfirma, idvn, brnal )

   LOCAL _rbr := ""

   // vrati mi zadnji redni broj sa dokumenta
   _rbr := fin_dok_get_last_rbr( idfirma, idvn, brnal )

   IF Empty( _rbr )
      RETURN _rbr
   ENDIF


   _rbr :=  _rbr  + 1

   RETURN _rbr


// ----------------------------------------------------------------
// vraca najveci redni broj stavke u nalogu
// ----------------------------------------------------------------
FUNCTION fin_dok_get_last_rbr( idfirma, idvn, brnal )

   LOCAL _qry, _qry_ret, _table
   LOCAL oRow
   LOCAL _last

   _qry := "SELECT MAX(rbr) AS last FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban " + ;
      " WHERE idfirma = " + sql_quote( idfirma ) + ;
      " AND idvn = " + sql_quote( idvn ) + ;
      " AND brnal = " + sql_quote( brnal )

   _table := run_sql_query( _qry )

   oRow := _table:GetRow( 1 )

   _last := oRow:FieldGet( oRow:FieldPos( "last" ) )

   IF ValType( _last ) == "L"
      _last := ""
   ENDIF

   RETURN _last


// ------------------------------------------------
// vraca prazan broj naloga
// ------------------------------------------------
FUNCTION fin_prazan_broj_naloga()
   RETURN PadR( "0", 8, "0" )


// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
FUNCTION fin_reset_broj_dokumenta( firma, tip_dokumenta, broj_dokumenta )

   LOCAL _param
   LOCAL _broj := 0

   // param: fin/10/10
   _param := "fin" + "/" + firma + "/" + tip_dokumenta
   _broj := fetch_metric( _param, nil, _broj )

   IF Val( broj_dokumenta ) == _broj
      -- _broj
      // smanji globalni brojac za 1
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN



// ------------------------------------------------------------------
// fin, uzimanje novog broja za fin dokument
// ------------------------------------------------------------------
FUNCTION fin_novi_broj_dokumenta( firma, tip_dokumenta )

   LOCAL _broj := 0
   LOCAL _broj_nalog := 0
   LOCAL _len_broj := 8
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL _t_area := Select()

   // obratiti paznju na gBrojacFinNaloga... 1 ili 2
   // 1 - idfirma + idvn + brnal
   // 2 - idfirma + brnal

   // param: fin/10/10
   _param := "fin" + "/" + firma + "/" + tip_dokumenta

   IF gBrojacFinNaloga == "2"
      _param := "fin" + "/" + firma
   ENDIF

   _broj := fetch_metric( _param, nil, _broj )

   // konsultuj i doks uporedo
   IF gBrojacFinNaloga == "2" // Brojac naloga: 1 - (firma,vn,brnal), 2 - (firma,brnal)
      find_nalog_by_broj_dokumenta( firma, tip_dokumenta, NIL, "idfirma,brnal" )
   ELSE
      find_nalog_by_broj_dokumenta( firma, tip_dokumenta )

   ENDIF
   GO BOTTOM

   IF field->idfirma == firma .AND. IIF( gBrojacFinNaloga == "1", field->idvn == tip_dokumenta, .T. )
      _broj_nalog := Val( field->brnal )
   ELSE
      _broj_nalog := 0
   ENDIF

   // uzmi sta je vece, nalog broj ili globalni brojac
   _broj := Max( _broj, _broj_nalog )

   // uvecaj broj
   ++ _broj

   // ovo ce napraviti string prave duzine...
   _ret := PadL( AllTrim( Str( _broj ) ), _len_broj, "0" )

   // upisi ga u globalni parametar
   set_metric( _param, nil, _broj )

   SELECT ( _t_area )

   RETURN _ret





// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
FUNCTION fin_set_broj_dokumenta()

   LOCAL _broj_dokumenta
   LOCAL _t_rec, _rec
   LOCAL _firma, _td, _null_brdok
   LOCAL _len_broj := 8

   PushWA()

   SELECT fin_pripr
   GO TOP

   _null_brdok := fin_prazan_broj_naloga()

   IF field->brnal <> _null_brdok
      // nemam sta raditi, broj je vec setovan
      PopWa()
      RETURN .F.
   ENDIF

   _firma := field->idfirma
   _td := field->idvn

   // daj mi novi broj dokumenta
   _broj_dokumenta := fin_novi_broj_dokumenta( _firma, _td )

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      IF field->idfirma == _firma .AND. field->idvn == _td .AND. field->brnal == _null_brdok
         _rec := dbf_get_rec()
         _rec[ "brnal" ] := _broj_dokumenta
         dbf_update_rec( _rec )
      ENDIF

      GO ( _t_rec )

   ENDDO

   PopWa()

   RETURN .T.





// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
FUNCTION fin_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _firma := gFirma
   LOCAL _tip_dok := "10"

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Nalog:" GET _firma

   IF gBrojacFinNaloga == "1"
      @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok
   ENDIF

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   // param: fin/10/10
   IF gBrojacFinNaloga == "1"
      _param := "fin" + "/" + _firma + "/" + _tip_dok
   ELSE
      _param := "fin" + "/" + _firma
   ENDIF

   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj naloga:" GET _broj PICT "99999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      // snimi broj u globalni brojac
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN .T.



   /*  Dupli(cIdFirma,cIdVn,cBrNal)
    *  brief Provjera duplog naloga
    *  param cIdFirma
    *  param cIdVn
    *  param cBrNal
    */

FUNCTION fin_valid_provjeri_postoji_nalog( cIdFirma, cIdVn, cBrNal )

   IF find_nalog_by_broj_dokumenta( cIdFirma, cIdVn, cBrNal )

      error_bar( "fin_unos", " Dupli nalog " + cIdFirma + "-" + cIdvn + "-" + cBrNal )
      RETURN .F.
   ENDIF

   RETURN .T.
