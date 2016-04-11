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



FUNCTION pos_azuriraj_racun( cIdPos, cBrojRacuna, cVrijeme, cNacPlac, cIdGost )

   LOCAL cDokument := ""
   LOCAL _rec
   LOCAL nCount := 0
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL hParams := hb_hash()

   hParams[ "tran_name" ] := "pos_rn_azur"

  o_pos_tables()

   IF !racun_se_moze_azurirati( cIdPos, VD_RN, gDatum, cBrojRacuna )
      RETURN lRet
   ENDIF

   SELECT _pos_pripr
   GO TOP

   run_sql_query( "BEGIN", hParams )
   IF !f18_lock_tables( { "pos_pos", "pos_doks" }, .T. )
      run_sql_query( "COMMIT", hParams )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   MsgO( "Ažuriranje stavki računa u toku ..." )

   IF SELECT( "pos_doks" ) == 0
     o_pos_doks()
   ELSE
     SELECT POS_DOKS
   ENDIF

   APPEND BLANK

   cDokument := ALLTRIM( cIdPos ) + "-" + VD_RN + "-" + ALLTRIM( cBrojRacuna ) + " " + DTOC( gDatum )

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := cIdPos
   _rec[ "idvd" ] := VD_RN
   _rec[ "datum" ] := gDatum
   _rec[ "brdok" ] := cBrojRacuna
   _rec[ "vrijeme" ] := cVrijeme
   _rec[ "idvrstep" ] := IIF( cNacPlac == NIL, gGotPlac, cNacPlac )
   _rec[ "idgost" ] := IIF( cIdGost == NIL, "", cIdGost )
   _rec[ "idradnik" ] := _pos_pripr->idradnik
   _rec[ "m1" ] := OBR_NIJE
   _rec[ "prebacen" ] := OBR_JEST
   _rec[ "smjena" ] := _pos_pripr->smjena

   lOk := update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   IF lOk

      SELECT _pos_pripr

      DO WHILE !Eof() .AND. _pos_pripr->( IdPos + IdVd + DToS( Datum ) + BrDok ) == ( cIdPos + "42" + DTOS( gDatum ) + "PRIPRE" )

         SELECT pos
         APPEND BLANK

         _rec := dbf_get_rec()

         _rec[ "idpos" ] := cIdPos
         _rec[ "idvd" ] := VD_RN
         _rec[ "datum" ] := gDatum
         _rec[ "brdok" ] := cBrojRacuna
         _rec[ "rbr" ] := PadL( AllTrim( Str( ++ nCount ) ), 5 )
         _rec[ "m1" ] := OBR_JEST
         _rec[ "prebacen" ] := OBR_NIJE
         _rec[ "iddio" ] := _pos_pripr->iddio
         _rec[ "idodj" ] := _pos_pripr->idodj
         _rec[ "idcijena" ] := _pos_pripr->idcijena
         _rec[ "idradnik" ] := _pos_pripr->idradnik
         _rec[ "idroba" ] := _pos_pripr->idroba
         _rec[ "idtarifa" ] := _pos_pripr->idtarifa
         _rec[ "kolicina" ] := _pos_pripr->kolicina
         _rec[ "mu_i" ] := _pos_pripr->mu_i
         _rec[ "ncijena" ] := _pos_pripr->ncijena
         _rec[ "cijena" ] := _pos_pripr->cijena
         _rec[ "smjena" ] := _pos_pripr->smjena
         _rec[ "c_1" ] := _pos_pripr->c_1
         _rec[ "c_2" ] := _pos_pripr->c_2
         _rec[ "c_3" ] := _pos_pripr->c_3

         lOk := update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT _pos_pripr
         SKIP

      ENDDO

   ENDIF

   MsgC()

   IF lOk
      lRet := .T.
      f18_unlock_tables( { "pos_pos", "pos_doks" } )
      run_sql_query( "COMMIT", hParams )
      log_write( "F18_DOK_OPER, ažuriran računa " + cDokument, 2 )
   ELSE
      run_sql_query( "ROLLBACK", hParams )
      log_write( "F18_DOK_OPER, greška sa ažuriranjem računa " + cDokument, 2 )
   ENDIF

   IF lOk
      brisi_pripremu_racuna()
   ENDIF

   priprema_set_order_to()

   RETURN lRet



STATIC FUNCTION brisi_pripremu_racuna()

   SELECT _pos_pripr
   my_dbf_zap()

   RETURN


STATIC FUNCTION priprema_set_order_to()

   SELECT _pos_pripr
   SET ORDER TO

   RETURN


STATIC FUNCTION racun_se_moze_azurirati( cIdPos, cIdVd, dDatum, cBroj )

   LOCAL lRet := .F.

   IF pos_dokument_postoji( cIdPos, cIdVd, dDatum, cBroj )
      MsgBeep( "Dokument već postoji ažuriran pod istim brojem !" )
      RETURN lRet
   ENDIF

   SELECT _pos_pripr

   IF RecCount() == 0
      MsgBeep( "Priprema računa je prazna, ažuriranje nije moguće !" )
      RETURN lRet
   ENDIF

   SELECT _pos_pripr
   SET ORDER TO TAG "2"
   GO TOP

   IF field->brdok <> "PRIPR" .AND. field->idpos <> cIdPos
      MsgBeep( "Pogrešne stavke računa !#Ažuriranje onemogućeno." )
      RETURN lRet
   ENDIF

   lRet := .T.

   RETURN lRet
