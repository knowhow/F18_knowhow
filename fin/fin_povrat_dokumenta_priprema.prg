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


MEMVAR m_x, m_y

FUNCTION fin_povrat_naloga( lStorno )

   LOCAL _rec
   LOCAL nRec
   LOCAL _del_rec, _ok := .T.
   LOCAL _field_ids, _where_block
   LOCAL _t_rec
   LOCAL _tbl
   LOCAL lBrisiKumulativ := .T.
   LOCAL lOk := .T.

   IF lStorno == NIL
      lStorno := .F.
   ENDIF

   O_SUBAN
   O_FIN_PRIPR
   O_ANAL
   O_SINT
   O_NALOG

   SELECT SUBAN
   SET ORDER TO TAG "4"

   cIdFirma         := gFirma
   cIdFirma2        := gFirma
   cIdVN := cIdVN2  := Space( 2 )
   cBrNal := cBrNal2 := Space( 8 )

   Box( "", iif( lStorno, 3, 1 ), iif( lStorno, 65, 35 ) )

   @ m_x + 1, m_y + 2 SAY "Nalog:"

   IF gNW == "D"
      @ m_x + 1, Col() + 1 SAY cIdFirma PICT "@!"
   ELSE
      @ m_x + 1, Col() + 1 GET cIdFirma PICT "@!"
   ENDIF

   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )

   IF lStorno

      @ m_x + 3, m_y + 2 SAY "Broj novog naloga (naloga storna):"

      IF gNW == "D"
         @ m_x + 3, Col() + 1 SAY cIdFirma2
      ELSE
         @ m_x + 3, Col() + 1 GET cIdFirma2
      ENDIF

      @ m_x + 3, Col() + 1 SAY "-" GET cIdVN2 PICT "@!"
      @ m_x + 3, Col() + 1 SAY "-" GET cBrNal2

   ENDIF

   READ
   ESC_BCR

   BoxC()

   IF Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + ;
         IIF( lStorno," stornirati", " povući u pripremu" ) + " (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   IF !lStorno
      lBrisiKumulativ := Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + ALLTRIM( cBrNal ) + " izbrisati iz baze ažuriranih dokumenata (D/N) ?", "D" ) == "D"
   ENDIF

   kopiraj_fin_nalog_u_tabelu_pripreme( cIdFirma, cIdVn, cBrNal, lStorno )

   IF !lBrisiKumulativ .OR. lStorno
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   IF !fin_nalog_brisi_iz_kumulativa( cIdFirma, cIdVn, cBrNal )
       MsgBeep( "Greška sa brisanjem naloga iz kumulativa !#Poništavam operaciju." )
   ENDIF

   my_close_all_dbf()

   RETURN .T.




STATIC FUNCTION fin_nalog_brisi_iz_kumulativa( cIdFirma, cIdVn, cBrNal )

   LOCAL _rec, cTbl
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL hParams := hb_hash()

   _rec := hb_Hash()
   _rec[ "idfirma" ] := cIdFirma
   _rec[ "idvn" ] := cIdVn
   _rec[ "brnal" ] := cBrNal

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban", "fin_nalog", "fin_sint", "fin_anal" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Operacija povrata poništena." )
      RETURN .F.
   ENDIF

   Box(, 5, 70 )

   cTbl := "fin_suban"
   @ m_x + 1, m_y + 2 SAY "delete " + cTbl
   SELECT suban
   lOk := delete_rec_server_and_dbf( cTbl, _rec, 2, "CONT" )

   IF lOk
      cTbl := "fin_anal"
      @ m_x + 2, m_y + 2 SAY "delete " + cTbl
      SELECT anal
      lOk := delete_rec_server_and_dbf( cTbl, _rec, 2, "CONT" )
   ENDIF

   IF lOk
      cTbl := "fin_sint"
      @ m_x + 3, m_y + 2 SAY "delete " + cTbl
      SELECT sint
      lOk := delete_rec_server_and_dbf( cTbl, _rec, 2, "CONT" )
   ENDIF

   IF lOk
      cTbl := "fin_nalog"
      @ m_x + 4, m_y + 2 SAY "delete " + cTbl
      SELECT nalog
      lOk := delete_rec_server_and_dbf( cTbl, _rec, 1, "CONT" )
   ENDIF

   BoxC()

   IF lOk
      lRet := .T.
      hParams[ "unlock" ] := { "fin_suban", "fin_nalog", "fin_sint", "fin_anal" }
      run_sql_query( "COMMIT", hParams )

      log_write( "F18_DOK_OPER: POVRAT_FIN: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
   ELSE
      run_sql_query( "ROLLBACK" )
      log_write( "F18_DOK_OPER: ERROR_POVRAT_FIN: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
   ENDIF

   RETURN lRet




STATIC FUNCTION kopiraj_fin_nalog_u_tabelu_pripreme( cIdFirma, cIdVn, cBrNal, lStorno )

   LOCAL _rec

   SELECT suban
   SET ORDER TO TAG "4"
   GO TOP
   SEEK cIdfirma + cIdvn + cBrNal

   DO WHILE !Eof() .AND. cIdFirma == field->IdFirma .AND. cIdVN == field->IdVN .AND. cBrNal == field->BrNal

      _rec := dbf_get_rec()

      SELECT fin_pripr

      IF lStorno
         _rec[ "idfirma" ]  := cIdFirma2
         _rec[ "idvn" ]     := cIdVn2
         _rec[ "brnal" ]    := cBrNal2
         _rec[ "iznosbhd" ] := -_rec[ "iznosbhd" ]
         _rec[ "iznosdem" ] := -_rec[ "iznosdem" ]
      ENDIF

      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT suban
      SKIP

   ENDDO

   RETURN
