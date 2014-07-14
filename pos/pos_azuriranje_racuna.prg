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

#include "pos.ch"

/*! \fn azur_pos_racun(cIdPos,cStalRac,cRadRac,cVrijeme,cNacPlac,cIdGost)
 *  \brief Azuriranje racuna ( _POS->POS, _POS->DOKS )
 *  \param cIdPos
 *  \param cStalRac    - prilikom azuriranja daje se broj cStalRac
 *  \param cRadRac     - racun iz _POS.DBF sa brojem cRadRac se prenosi u POS, DOKS
 *  \param cVrijeme
 *  \param cNacPlac
 *  \param cIdGost
 */

FUNCTION azur_pos_racun( cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost )

   LOCAL cDatum
   LOCAL nStavki
   LOCAL _rec, _append
   LOCAL _cnt := 0
   LOCAL _kolicina := 0
   LOCAL _idroba, _idcijena, _cijena
   PRIVATE nIznRn := 0

   _ok := .T.

   log_write( "F18_DOK_OPER: pos azuriranje racuna: " + cStalRac, 2 )

   my_use_semaphore_off()
   o_pos_tables()
   my_use_semaphore_on()

   IF !f18_lock_tables( { "pos_pos", "pos_doks" } )
      RETURN .F.
   ENDIF

   IF ( cNacPlac == NIL )
      cNacPlac := gGotPlac
   ENDIF

   IF ( cIdGost == NIL )
      cIdGost := ""
   ENDIF

   SELECT _pos
   SET ORDER TO TAG "1"
   SEEK cIdPos + "42" + DToS( gDatum ) + cRadRac

   IF !Found()
      _msg := "Problem sa podacima tabele _POS, nema stavi !!!#Azuriranje nije moguce !"
      log_write( _msg, 2 )
      msgbeep( _msg )
      my_use_semaphore_on()
      RETURN
   ENDIF

   // azuriraj racun u POS_DOKS
   SELECT pos_doks
   APPEND BLANK

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := cIdPos
   _rec[ "idvd" ] := VD_RN
   _rec[ "datum" ] := gDatum
   _rec[ "brdok" ] := cStalRac
   _rec[ "vrijeme" ] := cVrijeme
   _rec[ "idvrstep" ] := cNacPlac
   _rec[ "idgost" ] := cIdGost
   _rec[ "idradnik" ] := _pos->idradnik
   _rec[ "m1" ] := OBR_NIJE
   _rec[ "prebacen" ] := OBR_JEST
   _rec[ "smjena" ] := _pos->smjena

   sql_table_update( nil, "BEGIN" )

   update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   // azuriranje stavki u POS

   SELECT _pos
   cDatum := DToS( gDatum )

   DO WHILE !Eof() .AND. _POS->( IdPos + IdVd + DToS( Datum ) + BrDok ) == ( cIdPos + "42" + cDatum + cRadRac )

      nIznRn += ( _pos->kolicina * _pos->cijena )

      SELECT pos
      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idpos" ] := cIdPos
      _rec[ "idvd" ] := VD_RN
      _rec[ "datum" ] := gDatum
      _rec[ "brdok" ] := cStalRac
      _rec[ "rbr" ] := PadL( AllTrim( Str( ++_cnt ) ), 5 )
      _rec[ "m1" ] := OBR_JEST
      _rec[ "prebacen" ] := OBR_NIJE
      _rec[ "iddio" ] := _pos->iddio
      _rec[ "idodj" ] := _pos->idodj
      _rec[ "idcijena" ] := _pos->idcijena
      _rec[ "idradnik" ] := _pos->idradnik
      _rec[ "idroba" ] := _pos->idroba
      _rec[ "idtarifa" ] := _pos->idtarifa
      _rec[ "kolicina" ] := _pos->kolicina
      _rec[ "mu_i" ] := _pos->mu_i
      _rec[ "ncijena" ] := _pos->ncijena
      _rec[ "cijena" ] := _pos->cijena
      _rec[ "smjena" ] := _pos->smjena
      _rec[ "c_1" ] := _pos->c_1
      _rec[ "c_2" ] := _pos->c_2
      _rec[ "c_3" ] := _pos->c_3

      update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

      SELECT _pos
      SKIP

   ENDDO

   f18_free_tables( { "pos_pos", "pos_doks" } )
   sql_table_update( nil, "END" )

   // pobrisi _pos
   SELECT _pos
   my_dbf_zap()

   RETURN
