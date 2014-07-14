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



FUNCTION pos_azuriraj_dokument( cBrDok, cIdVd )

   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL _rec
   LOCAL nCount := 0
   LOCAL cDokument := ""

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks", "roba" }, .T. )
      sql_table_update( nil, "END" )
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

   cDokument := _idpos + "-" + _idvd + "-" + _brdok + " " + DTOC( _datum )

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

         lOk := azur_sif_roba_row()

         IF !lOk
            EXIT
         ENDIF

         SELECT PRIPRZ

         set_global_memvars_from_dbf()

         SELECT pos
         APPEND BLANK

         _brdok := cBrDok
         _idvd := cIdVd
         _rbr := PadL( AllTrim( Str( ++ nCount ) ), 5 )

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
       f18_free_tables( { "pos_pos", "pos_doks", "roba" } )
       sql_table_update( nil, "END" )
       log_write( "F18_DOK_OPER, ažuriran pos dokument " + cDokument, 2 )
   ELSE
       sql_table_update( nil, "ROLLBACK" )
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
      
   SELECT priprz
   my_dbf_pack()
 
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

   RETURN


