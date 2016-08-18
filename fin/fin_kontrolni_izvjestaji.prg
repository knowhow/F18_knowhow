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


FUNCTION fin_kontrolni_izvjestaji_meni()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   //AAdd( opc, "1. provjera integriteta tabela - ima u suban nema u nalog " )
   //AAdd( opcexe, {|| check_ima_u_suban_nema_u_nalog() } )

   AAdd( opc, "2. pregled datumskih grešaka u nalozima" )
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
      -- _broj // smanji globalni brojac za 1
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN .T.





FUNCTION fin_valid_provjeri_postoji_nalog( cIdFirma, cIdVn, cBrNal )

   IF find_nalog_by_broj_dokumenta( cIdFirma, cIdVn, cBrNal )

      error_bar( "fin_unos", " Dupli nalog " + cIdFirma + "-" + cIdvn + "-" + cBrNal )
      RETURN .F.
   ENDIF

   RETURN .T.
