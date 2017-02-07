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



FUNCTION fin_povrat_naloga( lStorno )

   LOCAL hRec
   LOCAL nRec
   LOCAL _delhRec, _ok := .T.
   LOCAL _field_ids, _where_block
   LOCAL _thRec
   LOCAL _tbl
   LOCAL lBrisiKumulativ := .T.
   LOCAL lOk := .T.

   IF lStorno == NIL
      lStorno := .F.
   ENDIF


   o_fin_pripr()

   cIdFirma         := self_organizacija_id()
   cIdFirma2        := self_organizacija_id()
   cIdVN := cIdVN2  := Space( 2 )
   cBrNal := cBrNal2 := Space( 8 )

   Box( "", iif( lStorno, 3, 1 ), iif( lStorno, 65, 35 ) )

   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Nalog:"

   IF gNW == "D"
      @ form_x_koord() + 1, Col() + 1 SAY cIdFirma PICT "@!"
   ELSE
      @ form_x_koord() + 1, Col() + 1 GET cIdFirma PICT "@!"
   ENDIF

   @ form_x_koord() + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ form_x_koord() + 1, Col() + 1 SAY "-" GET cBrNal VALID fin_fix_broj_naloga( @cBrNal )

   IF lStorno

      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Broj novog naloga (naloga storna):"

      IF gNW == "D"
         @ form_x_koord() + 3, Col() + 1 SAY cIdFirma2
      ELSE
         @ form_x_koord() + 3, Col() + 1 GET cIdFirma2
      ENDIF

      @ form_x_koord() + 3, Col() + 1 SAY "-" GET cIdVN2 PICT "@!"
      @ form_x_koord() + 3, Col() + 1 SAY "-" GET cBrNal2

   ENDIF

   READ
   ESC_BCR

   BoxC()

   IF Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + iif( lStorno, " stornirati", " povući u pripremu" ) + " (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
   find_anal_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
   find_sint_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
   find_nalog_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )


   IF !lStorno
      lBrisiKumulativ := Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + AllTrim( cBrNal ) + " izbrisati iz baze ažuriranih dokumenata (D/N) ?", "D" ) == "D"
   ENDIF

   MsgO( "fin -> fin_pripr  ..." )
   fin_kopiraj_nalog_u_tabelu_pripreme( cIdFirma, cIdVn, cBrNal, lStorno )
   MsgC()

   IF !lBrisiKumulativ .OR. lStorno
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   IF !fin_nalog_brisi_iz_kumulativa( cIdFirma, cIdVn, cBrNal )
      MsgBeep( "Greška sa brisanjem FIN naloga iz kumulativa !#Poništavam operaciju." )
   ENDIF

   my_close_all_dbf()

   RETURN .T.



FUNCTION fin_nalog_brisi_iz_kumulativa( cIdFirma, cIdVn, cBrNal )

   LOCAL hRec, cTbl
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL hParams := hb_Hash()

   hRec := hb_Hash()
   hRec[ "idfirma" ] := cIdFirma
   hRec[ "idvn" ] := cIdVn
   hRec[ "brnal" ] := cBrNal

   run_sql_query( "BEGIN" )

/*
   IF !f18_lock_tables( { "fin_suban", "fin_nalog", "fin_sint", "fin_anal" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Operacija povrata poništena." )
      RETURN .F.
   ENDIF
*/

   Box(, 5, 70 )

altd()
   fin_brisanje_markera_otvorenih_stavki_vezanih_za_nalog( cIdFirma, cIdVn, cBrNal )

   cTbl := "fin_suban"
   @ form_x_koord() + 1, form_y_koord() + 2 SAY "delete " + cTbl
   select_o_suban()
   lOk := delete_rec_server_and_dbf( cTbl, hRec, 2, "CONT" )

   IF lOk
      cTbl := "fin_anal"
      @ form_x_koord() + 2, form_y_koord() + 2 SAY "delete " + cTbl
      select_o_anal()
      lOk := delete_rec_server_and_dbf( cTbl, hRec, 2, "CONT" )
   ENDIF

   IF lOk
      cTbl := "fin_sint"
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "delete " + cTbl
      select_o_sint()
      lOk := delete_rec_server_and_dbf( cTbl, hRec, 2, "CONT" )
   ENDIF

   IF lOk
      cTbl := "fin_nalog"
      @ form_x_koord() + 4, form_y_koord() + 2 SAY "delete " + cTbl
      select_o_nalog()
      lOk := delete_rec_server_and_dbf( cTbl, hRec, 1, "CONT" )
   ENDIF

   BoxC()

   IF lOk
      lRet := .T.
      //hParams[ "unlock" ] := { "fin_suban", "fin_nalog", "fin_sint", "fin_anal" }
      run_sql_query( "COMMIT", hParams )

      log_write( "F18_DOK_OPER: POVRAT_FIN: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
   ELSE
      run_sql_query( "ROLLBACK" )
      log_write( "F18_DOK_OPER: ERROR_POVRAT_FIN: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
   ENDIF

   RETURN lRet




STATIC FUNCTION fin_kopiraj_nalog_u_tabelu_pripreme( cIdFirma, cIdVn, cBrNal, lStorno )

   LOCAL hRec

/*
   SELECT suban
   SET ORDER TO TAG "4"
   GO TOP
   SEEK cIdfirma + cIdvn + cBrNal
*/

   // ranije pozvana fja find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )


   SELECT SUBAN
   GO TOP
   DO WHILE !Eof() .AND. cIdFirma == field->IdFirma .AND. cIdVN == field->IdVN .AND. cBrNal == field->BrNal // suban.brnal char(8) na serveru

      hRec := dbf_get_rec()

      SELECT fin_pripr

      IF lStorno
         hRec[ "idfirma" ]  := cIdFirma2
         hRec[ "idvn" ]     := cIdVn2
         hRec[ "brnal" ]    := cBrNal2
         hRec[ "iznosbhd" ] := -hRec[ "iznosbhd" ]
         hRec[ "iznosdem" ] := -hRec[ "iznosdem" ]
      ENDIF

      APPEND BLANK

      dbf_update_rec( hRec )

      SELECT suban
      SKIP

   ENDDO

   RETURN .T.
