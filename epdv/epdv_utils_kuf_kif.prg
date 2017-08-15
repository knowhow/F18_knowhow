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




FUNCTION epdv_otvori_kuf_tabele( lPriprema )

   IF lPriprema == nil
      lPriprema := .F.
   ENDIF

   select_o_tarifa()
   select_o_epdv_kuf()

   IF lPriprema == .T.

      select_o_epdv_p_kuf()

   ENDIF

   RETURN .T.


FUNCTION epdv_otvori_kif_tabele( lPriprema )

   IF lPriprema == nil
      lPriprema := .F.
   ENDIF

   // SELECT F_TARIFA
   // IF !Used()
   // o_tarifa()
   // ENDIF


   select_o_epdv_kif()


   IF lPriprema == .T.
      select_o_epdv_p_kif()
   ENDIF

   RETURN .T.



FUNCTION epdv_next_r_br( cTblName )

   LOCAL nLastBr

   PushWA()
   DO CASE
   CASE cTblName == "P_KUF"
      SELECT p_kuf
   CASE cTblName == "P_KIF"
      SELECT p_kif

   ENDCASE

   SET ORDER TO TAG "BR_DOK"
   GO BOTTOM
   nLastRbr := field->r_br
   PopWa()

   RETURN nLastRbr + 1




FUNCTION next_redni_broj_globalno( cTblName )

   LOCAL nLastRbr

   PushWA()
   DO CASE
   CASE cTblName == "KUF"
      SELECT kuf
   CASE cTblName == "KIF"
      SELECT kif

   ENDCASE

   SET ORDER TO TAG "G_R_BR"

   GO BOTTOM
   nLastRbr := field->g_r_br
   PopWa()

   RETURN nLastRbr + 1



FUNCTION next_br_dok( cTblName )

   LOCAL nLastBrDok

   PushWA()
   DO CASE
   CASE cTblName == "KUF"
      SELECT kuf
   CASE cTblName == "KIF"
      SELECT kif

   ENDCASE

   SET ORDER TO TAG "BR_DOK"

   GO BOTTOM
   nLastBrDok := field->br_dok
   PopWa()

   RETURN nLastBrdok + 1



FUNCTION epdv_renumeracija_g_r_br( cTblName )

   LOCAL nRbr, _rec
   LOCAL _table := "epdv_kuf"
   LOCAL hParams

   // TAG: datum : "dtos(datum)+src_br_2"

   my_close_all_dbf()

   DO CASE
   CASE cTblName == "KUF"
      select_o_epdv_kuf()
      _table := "epdv_kuf"
   CASE cTblName == "KIF"
      select_o_epdv_kuf()
      _table := "epdv_kif"
   ENDCASE

   nRbr := 1
   SET ORDER TO TAG "DATUM"

   GO TOP

   IF !FLock()
      MsgBeep( "Ne mogu zakljucati bazu " + cTblName + ;
         "## renumeracije nije izvrsena !" )
      my_close_all_dbf()
   ENDIF

   Box( , 2, 35 )


   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { _table } )
      run_sql_query( "ROLLBACK" )
      RETURN .F.
   ENDIF


   DO WHILE !Eof()

      @ m_x + 1, m_y + 2 SAY "Renumeracija: G_R_BR " + Str( nRbr, 4, 0 )

      _rec := dbf_get_rec()
      _rec[ "g_r_br" ] := nRbr
      update_rec_server_and_dbf( _table, _rec, 1, "CONT" )

      nRbr++

      SKIP

   ENDDO

   hParams := hb_Hash()
   hParams[ "unlock" ] :=  { _table }
   run_sql_query( "COMMIT", hParams )

   BoxC()

   my_close_all_dbf()

   RETURN .T.
