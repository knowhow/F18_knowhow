/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"



FUNCTION epdv_otvori_kuf_tabele( lPriprema )

   IF lPriprema == nil
      lPriprema := .F.
   ENDIF

   SELECT F_TARIFA
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT F_PARTN
   IF !Used()
      O_PARTN
   ENDIF

   SELECT F_KUF
   IF !Used()
      O_KUF
   ENDIF

   IF lPriprema == .T.
      SELECT ( F_P_KUF )

      IF !Used()
         O_P_KUF
      ENDIF
   ENDIF

   RETURN


FUNCTION epdv_otvori_kif_tabele( lPriprema )

   IF lPriprema == nil
      lPriprema := .F.
   ENDIF

   SELECT F_TARIFA
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT F_PARTN
   IF !Used()
      O_PARTN
   ENDIF

   SELECT F_KIF
   IF !Used()
      O_KIF
   ENDIF

   IF lPriprema == .T.
      SELECT ( F_P_KIF )

      IF !Used()
         O_P_KIF
      ENDIF
   ENDIF

   RETURN



// ------------------------
// ------------------------
FUNCTION next_r_br( cTblName )

   PushWa()
   DO CASE
   CASE cTblName == "P_KUF"
      SELECT p_kuf
   CASE cTblName == "P_KIF"
      SELECT p_kif
	
   ENDCASE

   SET ORDER TO TAG "BR_DOK"
   GO BOTTOM
   nLastRbr := r_br
   PopWa()

   RETURN nLastRbr + 1


// ------------------------
// ------------------------
FUNCTION next_g_r_br( cTblName )

   PushWa()
   DO CASE
   CASE cTblName == "KUF"
      SELECT kuf
   CASE cTblName == "KIF"
      SELECT kif
	
   ENDCASE

   SET ORDER TO TAG "G_R_BR"

   GO BOTTOM
   nLastRbr := g_r_br
   PopWa()

   RETURN nLastRbr + 1


// -----------------------------
// -----------------------------
FUNCTION next_br_dok( cTblName )

   LOCAL nLastBrDok

   PushWa()
   DO CASE
   CASE cTblName == "KUF"
      SELECT kuf
   CASE cTblName == "KIF"
      SELECT kif
	
   ENDCASE

   SET ORDER TO TAG "BR_DOK"

   GO BOTTOM
   nLastBrDok := br_dok
   PopWa()

   RETURN nLastBrdok + 1


// ------------------------
// ------------------------
FUNCTION rn_g_r_br( cTblName )

   LOCAL nRbr, _rec
   LOCAL _table := "epdv_kuf"

   // TAG: datum : "dtos(datum)+src_br_2"

   my_close_all_dbf()

   DO CASE
   CASE cTblName == "KUF"
      O_KUF
      _table := "epdv_kuf"
   CASE cTblName == "KIF"
      O_KIF
      _table := "epdv_kif"
   ENDCASE

   nRbr := 1
   SET ORDER TO TAG "DATUM"

   GO TOP

   IF !FLock()
      MsgBeep( "Ne mogu zakljucati bazu " + cTblName + ;
         "## renumeracije nije izvrsena !" )
      my_close_all_dbf()
   endif

   Box( , 2, 35 )

   f18_lock_tables( { _table } )
   sql_table_update( nil, "BEGIN" )

   DO WHILE !Eof()

      @ m_x + 1, m_y + 2 SAY "Renumeracija: G_R_BR " + Str( nRbr, 4, 0 )

      _rec := dbf_get_rec()
      _rec[ "g_r_br" ] := nRbr
      update_rec_server_and_dbf( _table, _rec, 1, "CONT" )

      nRbr ++
	
      SKIP

   ENDDO

   f18_free_tables( { _table } )
   sql_table_update( nil, "END" )

   BoxC()

   my_close_all_dbf()

   RETURN
