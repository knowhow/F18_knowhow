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



FUNCTION pos_azuriraj_racun( cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost )

   LOCAL cDatum
   LOCAL nStavki
   LOCAL cDokument := ""
   LOCAL _rec
   LOCAL _cnt := 0
   LOCAL _kolicina := 0
   LOCAL _idroba, _idcijena, _cijena
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   PRIVATE nIznRn := 0

   otvori_pos_tabele_bez_semafora()

   IF !postoji_racun_za_azuriranje_u_pripremi( cIdPos, cRadRac )
      _msg := "Problem sa podacima tabele _POS, nema stavi !!!#Azuriranje nije moguce !"
      log_write( _msg, 2 )
      msgbeep( _msg )
      my_use_semaphore_on()
      RETURN lRet 
   ENDIF

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks" }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   SELECT pos_doks
   APPEND BLANK

   cDokument := cIdPos + "-" + VD_RN + "-" + cStalRac + " " + DTOC( gDatum ) 

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := cIdPos
   _rec[ "idvd" ] := VD_RN
   _rec[ "datum" ] := gDatum
   _rec[ "brdok" ] := cStalRac
   _rec[ "vrijeme" ] := cVrijeme
   _rec[ "idvrstep" ] := IIF( cNacPlac == NIL, gGotPlac, cNacPlac )
   _rec[ "idgost" ] := IIF( cIdGost == NIL, "", cIdGost )
   _rec[ "idradnik" ] := _pos->idradnik
   _rec[ "m1" ] := OBR_NIJE
   _rec[ "prebacen" ] := OBR_JEST
   _rec[ "smjena" ] := _pos->smjena

   lOk := update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   IF lOk

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

         lOk := update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT _pos
         SKIP

      ENDDO

   ENDIF

   IF lOk
      lRet := .T.
      f18_free_tables( { "pos_pos", "pos_doks" } )
      sql_table_update( nil, "END" )
      log_write( "F18_DOK_OPER, ažuriran računa " + cDokument, 2 )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
      log_write( "F18_DOK_OPER, greška sa ažuriranjem računa " + cDokument, 2 )
   ENDIF

   IF lOk
      brisi_pos_pripremu()
   ENDIF

   RETURN lRet


STATIC FUNCTION brisi_pos_pripremu()

   SELECT _pos
   my_dbf_zap()

   RETURN


STATIC FUNCTION otvori_pos_tabele_bez_semafora()

   my_use_semaphore_off()
   o_pos_tables()
   my_use_semaphore_on()

   RETURN


STATIC FUNCTION postoji_racun_za_azuriranje_u_pripremi( cIdPos, cBroj )

   LOCAL lRet := .T.

   SELECT _pos
   SET ORDER TO TAG "1"
   SEEK cIdPos + "42" + DToS( gDatum ) + cBroj

   IF !Found()
      lRet := .F.
   ENDIF

   RETURN lRet



