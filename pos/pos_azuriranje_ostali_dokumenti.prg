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



FUNCTION pos_azuriraj_zaduzenje( cBrDok, cIdVd )

   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL _rec
   LOCAL nCount := 0
   LOCAL cDokument := ""
   LOCAL hParams

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks", "roba" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   SELECT PRIPRZ
   GO TOP
   set_global_memvars_from_dbf()

   SELECT pos_doks
   APPEND BLANK

   _brdok := cBrDok
   _idvd := cIdVd

   cDokument := AllTrim( _idpos ) + "-" + _idvd + "-" + AllTrim( _brdok ) + " " + DToC( _datum )

   IF gBrojSto == "D"
      IF cIdVd <> VD_RN
         _zakljucen := "Z"
      ENDIF
   ENDIF

   _rec := get_dbf_global_memvars()

   lOk := update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   IF lOk

      SELECT PRIPRZ

      DO WHILE !Eof()

         SELECT PRIPRZ

         lOk := azuriraj_artikal_u_sifrarniku()

         IF !lOk
            EXIT
         ENDIF

         SELECT PRIPRZ

         set_global_memvars_from_dbf()

         SELECT pos
         APPEND BLANK

         _brdok := cBrDok
         _idvd := cIdVd
         _rbr := PadL( AllTrim( Str( ++nCount ) ), 5 )

         _rec := get_dbf_global_memvars()

         lOk := update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT priprz
         SKIP

      ENDDO

   ENDIF

   IF lOk
      lRet := .T.

      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "pos_pos", "pos_doks", "roba" }
      run_sql_query( "COMMIT", hParams )

      log_write( "F18_DOK_OPER, ažuriran pos dokument " + cDokument, 2 )
   ELSE
      run_sql_query( "ROLLBACK" )
      log_write( "F18_DOK_OPER, greška sa ažuriranjem pos dokumenta " + cDokument, 2 )
   ENDIF

   IF lOk
      brisi_tabelu_pripreme()
   ENDIF

   IF lOk .AND. fiscal_opt_active()
      setuj_plu_kodove_artikala_nakon_azuriranja()
   ENDIF

   SELECT PRIPRZ

   RETURN lRet



STATIC FUNCTION brisi_tabelu_pripreme()

   MsgO( "Brisanje tabele pripreme u toku ..." )

   SELECT priprz
   my_dbf_zap()

   MsgC()

   RETURN



STATIC FUNCTION setuj_plu_kodove_artikala_nakon_azuriranja()

   LOCAL nDeviceId
   LOCAL hDeviceParams

   nDeviceId := odaberi_fiskalni_uredjaj( NIL, .T., .F. )

   IF nDeviceId > 0
      hDeviceParams := get_fiscal_device_params( nDeviceId, my_user() )
      IF hDeviceParams[ "plu_type" ] == "P"
         gen_all_plu( .T. )
      ENDIF
   ENDIF

   RETURN .T.



FUNCTION pos_azuriraj_inventura_nivelacija()

   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL nTotalCount
   LOCAL nCount := 0
   LOCAL _rec, _t_rec
   LOCAL cTipDok, cDokument
   LOCAL hParams

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks" } )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   Box(, 3, 60 )

   nTotalCount := priprz->( RecCount() )

   SELECT ROBA
   SET ORDER TO TAG "ID"

   SELECT PRIPRZ
   GO TOP

   SELECT pos_doks
   APPEND BLANK

   _rec := dbf_get_rec()
   _rec[ "idpos" ] := priprz->idpos
   _rec[ "idvd" ] := priprz->idvd
   _rec[ "datum" ] := priprz->datum
   _rec[ "brdok" ] := priprz->brdok
   _rec[ "vrijeme" ] := priprz->vrijeme
   _rec[ "idvrstep" ] := priprz->idvrstep
   _rec[ "idgost" ] := priprz->idgost
   _rec[ "idradnik" ] := priprz->idradnik
   _rec[ "m1" ] := priprz->m1
   _rec[ "prebacen" ] := priprz->prebacen
   _rec[ "smjena" ] := priprz->smjena

   cTipDok := _rec[ "idvd" ]
   cDokument := AllTrim( _rec[ "idpos" ] ) + "-" + _rec[ "idvd" ] + "-" + AllTrim( _rec[ "brdok" ] ) + " " + DToC( _rec[ "datum" ] )

   @ m_x + 1, m_y + 2 SAY8 "    AŽURIRANJE DOKUMENTA U TOKU ..."
   @ m_x + 2, m_y + 2 SAY "Formiran dokument: " + cDokument +  " / zap: " + AllTrim( Str( nTotalCount ) )

   lOk := update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

   IF lOk

      SELECT PRIPRZ

      DO WHILE !Eof()

         _t_rec := RecNo()

         SELECT POS
         APPEND BLANK

         _rec := dbf_get_rec()
         _rec[ "idpos" ] := priprz->idpos
         _rec[ "idvd" ] := priprz->idvd
         _rec[ "datum" ] := priprz->datum
         _rec[ "brdok" ] := priprz->brdok
         _rec[ "m1" ] := priprz->m1
         _rec[ "prebacen" ] := priprz->prebacen
         _rec[ "iddio" ] := priprz->iddio
         _rec[ "idodj" ] := priprz->idodj
         _rec[ "idcijena" ] := priprz->idcijena
         _rec[ "idradnik" ] := priprz->idradnik
         _rec[ "idroba" ] := priprz->idroba
         _rec[ "idtarifa" ] := priprz->idtarifa
         _rec[ "kolicina" ] := priprz->kolicina
         _rec[ "kol2" ] := priprz->kol2
         _rec[ "mu_i" ] := priprz->mu_i
         _rec[ "ncijena" ] := priprz->ncijena
         _rec[ "cijena" ] := priprz->cijena
         _rec[ "smjena" ] := priprz->smjena
         _rec[ "c_1" ] := priprz->c_1
         _rec[ "c_2" ] := priprz->c_2
         _rec[ "c_3" ] := priprz->c_3
         _rec[ "rbr" ] := PadL( AllTrim( Str( ++nCount ) ), 5 )

         @ m_x + 3, m_y + 2 SAY "Stavka " + AllTrim( Str( nCount ) ) + " roba: " + _rec[ "idroba" ]

         lOk := update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT PRIPRZ

         IF cTipDok <> "IN"
            azuriraj_artikal_u_sifrarniku()
         ENDIF

         SELECT PRIPRZ
         GO ( _t_rec )
         SKIP

      ENDDO

   ENDIF

   BoxC()

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] := { "pos_pos", "pos_doks" }
      run_sql_query( "COMMIT", hParams )

      log_write( "F18_DOK_OPER, ažuriran pos dokument: " + cDokument, 2 )
   ELSE
      run_sql_query( "ROLLBACK" )
      log_write( "F18_DOK_OPER, greška sa ažuriranjem pos dokumenta: " + cDokument, 2 )
   ENDIF

   IF lOk
      brisi_tabelu_pripreme()
   ENDIF

   RETURN lRet




STATIC FUNCTION azuriraj_artikal_u_sifrarniku()

   LOCAL lOk := .T.
   LOCAL _rec
   LOCAL _field_mpc
   LOCAL _update := .F.

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   IF gSetMPCijena == "1"
      _field_mpc := "mpc"
   ELSE
      _field_mpc := "mpc" + AllTrim( gSetMPCijena )
   ENDIF

   SEEK priprz->idroba

   lNovi := .F.

   IF !Found()
      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := priprz->idroba
      _update := .T.
   ELSE
      _rec := dbf_get_rec()
   ENDIF

   _rec[ "naz" ] := priprz->robanaz
   _rec[ "jmj" ] := priprz->jmj

   IF !IsPDV()
      IF katops->idtarifa <> "PDV17"
         _rec[ _field_mpc ] := Round( priprz->cijena, 3 )
      ENDIF
   ELSE

      IF cIdVd == "NI"
         _rec[ _field_mpc ] := Round( priprz->ncijena, 3 )
      ELSE
         _rec[ _field_mpc ] := Round( priprz->cijena, 3 )
      ENDIF

   ENDIF

   _rec[ "idtarifa" ] := priprz->idtarifa
   _rec[ "k1" ] := priprz->k1
   _rec[ "k2" ] := priprz->k2
   _rec[ "k7" ] := priprz->k7
   _rec[ "k8" ] := priprz->k8
   _rec[ "k9" ] := priprz->k9
   _rec[ "n1" ] := priprz->n1
   _rec[ "n2" ] := priprz->n2
   _rec[ "barkod" ] := priprz->barkod

   lOk := update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

   RETURN lOk
