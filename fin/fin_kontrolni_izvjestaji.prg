/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2018 by bring.out d.o.o Sarajevo.
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

   //AAdd( opc, "2. pregled datumskih grešaka u nalozima" )
   //AAdd( opcexe, {|| daterr_rpt() } )

   AAdd( opc, "N. podešenje brojača naloga" )
   AAdd( opcexe, {|| fin_set_param_broj_dokumenta() } )

   AAdd( opc, "R. fmk pravila - rules " )
   AAdd( opcexe, {|| p_rules(,,, aRuleCols, bRuleBlock ) } )


   f18_menu_sa_priv_vars_opc_opcexe_izbor( "adm" )

   RETURN .T.




/*
// vraca naredni redni broj fin naloga
// ----------------------------------------------------------------
FUNCTION fin_nalog_sljedeci_redni_broj( cIdFirma, cIdVN, cBrNal )

   LOCAL _rbr := ""


   _rbr := fin_nalog_zadnji_redni_broj( cIdFirma, cIdVN, cBrNal )

   IF Empty( _rbr )
      RETURN _rbr
   ENDIF


   _rbr :=  _rbr  + 1

   RETURN _rbr


// ----------------------------------------------------------------
// vraca najveci redni broj stavke u nalogu
// ----------------------------------------------------------------
FUNCTION fin_nalog_zadnji_redni_broj( cIdFirma, cIdVN, cBrNal )

   LOCAL _qry, _qry_ret, _table
   LOCAL oRow
   LOCAL _last

   _qry := "SELECT MAX(rbr) AS last FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban " + ;
      " WHERE idfirma = " + sql_quote( cIdFirma ) + ;
      " AND idvn = " + sql_quote( cIdVN ) + ;
      " AND brnal = " + sql_quote( cBrNal )

   _table := run_sql_query( _qry )

   oRow := _table:GetRow( 1 )

   _last := oRow:FieldGet( oRow:FieldPos( "last" ) )

   IF ValType( _last ) == "L"
      _last := ""
   ENDIF

   RETURN _last

*/





FUNCTION fin_valid_provjeri_postoji_nalog( cIdFirma, cIdVn, cBrNal )

   IF find_nalog_by_broj_dokumenta( cIdFirma, cIdVn, cBrNal )
      error_bar( "fin_unos", " Dupli nalog " + cIdFirma + "-" + cIdvn + "-" + cBrNal )
      RETURN .F.
   ENDIF

   RETURN .T.
