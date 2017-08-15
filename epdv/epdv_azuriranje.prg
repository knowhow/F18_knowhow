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


FUNCTION epdv_azur_kif()
   RETURN epdv_azur_kuf_kif( "KIF" )

FUNCTION epdv_azur_kuf()
   RETURN epdv_azur_kuf_kif( "KUF" )


FUNCTION pov_kuf( nBrDok )
   RETURN epdv_povrat_kuf_kif( "KUF", nBrDok )

FUNCTION pov_kif( nBrDok )
   RETURN epdv_povrat_kuf_kif( "KIF", nBrDok )


FUNCTION epdv_azur_kuf_kif( cTbl )

   LOCAL nPArea, nKArea, nCount
   LOCAL hRec
   LOCAL nNextGRbr := 0
   LOCAL nLastBrDok := 0
   LOCAL nNextBrDok := 0
   LOCAL nBrDok := 0

   IF cTbl == "KUF"
      epdv_otvori_kuf_tabele( .T. )
      nPArea := F_P_KUF
      nKArea := F_KUF
   ELSE
      epdv_otvori_kif_tabele( .T. )
      nPArea := F_P_KIF
      nKArea := F_KIF
   ENDIF

   Box(, 2, 60 )

   nCount := 0

   SELECT ( nPArea )
   IF RECCOUNT2() == 0
      RETURN 0
   ENDIF

   nNextGRbr := next_redni_broj_globalno( cTbl )

   SELECT ( nPArea )
   GO TOP

   IF ( field->br_dok == 0 )
      nNextBrDok := next_br_dok( cTbl )
      nBrdok := nNextBrDok
   ELSE
      nBrDok := field->br_dok
   ENDIF

   IF kuf_kif_azur_sql( cTbl, nNextGRbr, nBrDok )

      SELECT ( nPArea )
      GO TOP

      DO WHILE !Eof()

         set_global_memvars_from_dbf()

         _datum_2 := Date()
         _g_r_br := nNextGRbr

         _br_dok := nBrDok
         nLastBrDok := _br_dok

         ++nCount
         @ m_x + 1, m_y + 2 SAY PadR( "Dodajem P_KIF -> KUF " + Transform( nCount, "9999" ), 40 )
         @ m_x + 2, m_y + 2 SAY PadR( "   " + cTbl + " G.R.BR: " + Transform( nNextGRbr, "99999" ), 40 )

         nNextGRbr++

         SELECT ( nKArea )
         APPEND BLANK

         hRec := get_hash_record_from_global_vars()
         dbf_update_rec( hRec )

         SELECT ( nPArea )
         SKIP
      ENDDO

   ELSE

      MsgBeep( "Neuspješno ažuriranje epdv/sql !" )
      RETURN .F.

   ENDIF

   SELECT ( nKArea )
   USE

   @ m_x + 1, m_y + 2 SAY8 PadR( "Brišem pripremu ...", 40 )

   SELECT ( nPArea )
   my_dbf_zap()

   USE

   IF ( cTbl == "KUF" )
      epdv_otvori_kuf_tabele( .T. )
   ELSE
      epdv_otvori_kif_tabele( .T. )
   ENDIF

   BoxC()

   MsgBeep( "Ažuriran je " + cTbl + " dokument " + Str( nNextBrDok, 6, 0 ) )

   RETURN nLastBrDok



FUNCTION kuf_kif_azur_sql( cTable, nNextRbrGlobalno, nNextBrDok )

   LOCAL lOk := .T.
   LOCAL hRec := hb_Hash()
   LOCAL _tbl_epdv
   LOCAL nI
   LOCAL _tmp_id
   LOCAL _ids := {}
   LOCAL __area
   LOCAL hParams

   IF cTable == "KIF"
      __area := F_P_KIF
   ELSEIF cTable == "KUF"
      __area := F_P_KUF
   ENDIF

   _tbl_epdv := "epdv_" + Lower( cTable )

   info_bar( "epdv", "sql " + _tbl_epdv )

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { _tbl_epdv } )
      run_sql_query( "ROLLBACK" )
      RETURN .F.
   ENDIF

   lOk := .T.

   IF lOk = .T.

      SELECT ( __area )
      GO TOP
      DO WHILE !Eof()

         hRec := dbf_get_rec()
         hRec[ "datum_2" ] := Date()
         hRec[ "br_dok" ] := nNextBrDok
         hRec[ "g_r_br" ] := nNextRbrGlobalno

         IF cTable == "KIF"
            hRec[ "src_pm" ] := field->src_pm
         ENDIF

         _tmp_id := "#2" + PadL( AllTrim( Str( hRec[ "br_dok" ], 6 ) ), 6 )

         IF !sql_table_update( _tbl_epdv, "ins", hRec )
            lOk := .F.
            EXIT
         ENDIF

         SKIP

      ENDDO

   ENDIF

   IF !lOk
      run_sql_query( "ROLLBACK" )
   ELSE
      AAdd( _ids, _tmp_id )
      push_ids_to_semaphore( _tbl_epdv, _ids )

      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { _tbl_epdv }
      run_sql_query( "COMMIT", hParams )
   ENDIF

   RETURN lOk



FUNCTION epdv_povrat_kuf_kif( cTbl, nBrDok )

   LOCAL _del_rec, _ok
   LOCAL hRec
   LOCAL _p_area
   LOCAL _k_area
   LOCAL _cnt
   LOCAL _table

   IF ( cTbl == "KUF" )
      epdv_otvori_kuf_tabele( .T. )
      _p_area := F_P_KUF
      _k_area := F_KUF
      _table := "epdv_kuf"
   ELSE
      epdv_otvori_kif_tabele( .T. )
      _p_area := F_P_KIF
      _k_area := F_KIF
      _table := "epdv_kif"
   ENDIF

   _cnt := 0

   SELECT ( _k_area )
   SET ORDER TO TAG "BR_DOK"
   SEEK Str( nBrdok, 6, 0 )


   IF !Found()
      SELECT ( _p_area )
      RETURN 0
   ENDIF

   SELECT ( _p_area )
   IF RECCOUNT2() > 0
      MsgBeep( "U pripremi postoji dokument#Ne može se izvršiti povrat#operacija prekinuta !" )
      RETURN -1
   ENDIF

   Box(, 2, 60 )
   SELECT ( _k_area )

   DO WHILE !Eof() .AND. ( br_dok == nBrDok )

      ++_cnt
      @ m_x + 1, m_y + 2 SAY PadR( "P_" + cTbl +  " -> " + cTbl + " :" + Transform( _cnt, "9999" ), 40 )

      SELECT ( _k_area )
      hRec := dbf_get_rec()

      SELECT ( _p_area )
      APPEND BLANK
      dbf_update_rec( hRec )

      SELECT ( _k_area )
      SKIP
   ENDDO

   IF ( cTbl == "KUF" )
      epdv_otvori_kuf_tabele( .T. )
   ELSE
      epdv_otvori_kif_tabele( .T. )
   ENDIF

   SELECT ( _k_area )
   SET ORDER TO TAG "BR_DOK"
   SEEK Str( nBrdok, 6, 0 )

   _del_rec := dbf_get_rec()

   _ok := .T.

   MsgO( "del " + cTbl )

   _ok := delete_rec_server_and_dbf( _table, _del_rec, 2, "FULL" )

   MsgC()

   IF !_ok
      MsgBeep( "Operacija brisanja dokumenta nije uspješna, dokument: " + AllTrim( Str( nBrDok ) ) )
   ENDIF

   SELECT ( _k_area )
   USE

   IF ( cTbl == "KUF" )
      epdv_otvori_kuf_tabele( .T. )
   ELSE
      epdv_otvori_kif_tabele( .T. )
   ENDIF

   BoxC()

   IF _ok
      MsgBeep( "Izvršen je povrat dokumenta " + Str( nBrDok, 6, 0 ) + " u pripremu" )
   ENDIF

   RETURN nBrDok



FUNCTION epdv_renumeracija_rbr( cTbl, lShow )

   LOCAL hRec, nRbr

   IF lShow == nil
      lShow := .T.
   ENDIF

   IF cTbl == "P_KUF"
      select_o_epdv_p_kuf()

   ELSEIF cTbl == "P_KIF"
      select_o_epdv_p_kif()

   ENDIF

   SET ORDER TO TAG "datum"
   GO TOP
   nRbr := 1

   DO WHILE !Eof()
      hRec := dbf_get_rec()
      hRec[ "r_br" ] := nRbr
      dbf_update_rec( hRec )
      ++nRbr
      SKIP
   ENDDO

   IF lShow
      MsgBeep( "Renumeracija pripreme završena" )
   ENDIF

   RETURN .T.


FUNCTION renm_g_rbr( cTbl, lShow )

   LOCAL nRbr, hRec
   LOCAL nLRbr

   IF lShow == nil
      lShow := .T.
   ENDIF

   IF cTbl == "KUF"
      select_o_epdv_kuf()

   ELSEIF cTbl == "P_KIF"
      select_o_epdv_kif()

   ENDIF

   SET ORDER TO TAG "l_datum"

   SEEK "DZ"
   SKIP -1
   IF lock == "D"
      nLRbr := g_r_br
   ELSE
      nLRbr := 0
   ENDIF

   PRIVATE cFilter := "!(lock == 'D')"

   SET FILTER TO &cFilter
   GO TOP

   Box(, 3, 60 )
   nRbr := nLRbr
   DO WHILE !Eof()

      ++nRbr
      @ m_x + 1, m_y + 2 SAY cTbl + ":" + Str( nRbr, 8, 0 )
      hRec := dbf_get_rec()
      hRec[ "g_r_br" ] := nRbr
      dbf_update_rec( hRec )

      ++nRbr
      SKIP
   ENDDO
   BoxC()

   USE

   IF lShow
      MsgBeep( cTbl + " : G.Rbr renumeracija izvršena" )
   ENDIF

   RETURN .T.
