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

#include "fin.ch"

FUNCTION povrat_fin_naloga( lStorno )

   LOCAL _rec
   LOCAL nRec
   LOCAL _del_rec, _ok := .T.
   LOCAL _field_ids, _where_block
   LOCAL _t_rec
   LOCAL _tbl
   LOCAL _brisi_nalog

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
         iif( lStorno," stornirati", " povuci u pripremu" ) + " (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   _brisi_nalog := .T.

   IF !lStorno
      _brisi_nalog := ( Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + " izbrisati iz baze ažuriranih dokumenata (D/N) ?", "D" ) == "D" )
   ENDIF

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

   MsgC()

   IF !_brisi_nalog
      my_close_all_dbf()
      RETURN
   ENDIF

   IF !lStorno

      _del_rec := hb_Hash()
      _del_rec[ "idfirma" ] := cIdFirma
      _del_rec[ "idvn" ]    := cIdVn
      _del_rec[ "brnal" ]   := cBrNal

      _ok := .T.

      IF !f18_lock_tables( { "fin_suban", "fin_nalog", "fin_sint", "fin_anal", "fin_suban" } )
         MsgBeep( "lockovanje FIN tabela neuspjesno !?" )
         RETURN .F.
      ENDIF

      Box(, 5, 70 )

      sql_table_update( nil, "BEGIN" )

      AltD()
      _tbl := "fin_suban"
      @ m_x + 1, m_y + 2 SAY "delete " + _tbl
      // algoritam 2  - nivo dokumenta
      SELECT suban
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _del_rec, 2, "CONT" )

      _tbl := "fin_anal"
      @ m_x + 2, m_y + 2 SAY "delete " + _tbl
      // algoritam 2  - nivo dokumenta
      SELECT anal
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _del_rec, 2, "CONT" )

      _tbl := "fin_sint"
      @ m_x + 3, m_y + 2 SAY "delete " + _tbl
      // algoritam 2  - nivo dokumenta
      SELECT sint
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _del_rec, 2, "CONT" )

      _tbl := "fin_nalog"
      @ m_x + 4, m_y + 2 SAY "delete " + _tbl
      // algoritam 1 - jedini algoritam za naloge
      SELECT nalog
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _del_rec, 1, "CONT" )

      IF _ok
         f18_free_tables( { "fin_suban", "fin_nalog", "fin_sint", "fin_anal", "fin_suban" } )
         sql_table_update( nil, "END" )
      ENDIF

      BoxC()


   ENDIF

   IF !_ok
      sql_table_update( nil, "ROLLBACK" )
      f18_free_tables( { "fin_suban", "fin_nalog", "fin_sint", "fin_anal", "fin_suban" } )

      MsgBeep( "Ajoooooooj del suban/anal/sint/nalog nije ok ?! " + cIdFirma + "-" + cIdVn + "-" + cBrNal )
   ELSE
      log_write( "F18_DOK_OPER: povrat finansijskog naloga u pripremu: " + cIdFirma + "-" + cIdVn + "-" + cBrNal, 2 )
   ENDIF

   my_close_all_dbf()

   RETURN




