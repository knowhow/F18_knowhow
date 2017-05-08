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

STATIC __device_id
STATIC __device_params


FUNCTION fiskalni_izvjestaji_komande( lLowLevel, from_pos )

   LOCAL _dev_id := 0
   LOCAL _dev_drv
   LOCAL _m_x
   LOCAL _m_y


   LOCAL nIzbor := 1
   LOCAL aOpc := {}
   LOCAL aOpcExe := {}

   IF lLowLevel == NIL
      lLowLevel := .F.
   ENDIF

   IF from_pos == NIL
      from_pos := .F.
   ENDIF

   __device_id := odaberi_fiskalni_uredjaj( NIL, from_pos, .F. )

   IF __device_id == 0
      RETURN .F.
   ENDIF

   __device_params := get_fiscal_device_params( __device_id, my_user() )

   IF __device_params == NIL
      MsgBeep( "Fiskalni parametri nisu podešeni,#fiskalne funkcije nedostupne." )
      RETURN .F.
   ENDIF

   _dev_drv := __device_params[ "drv" ]

   DO CASE

   CASE _dev_drv == "FLINK"

      AAdd( aOpc, "------ izvještaji ---------------------------------" )
      AAdd( aOpcExe, {|| .F. } )
      AAdd( aOpc, "1. dnevni izvještaj  (Z-rep / X-rep)          " )
      AAdd( aOpcExe, {|| flink_dnevni_izvjestaj( AllTrim( flink_path() ), AllTrim( flink_name() ) ) } )
      AAdd( aOpc, "------ ostale komande --------------------" )
      AAdd( aOpcExe, {|| .F. } )
      AAdd( aOpc, "5. unos depozita u uređaj       " )
      AAdd( aOpcExe, {|| fl_polog( AllTrim( flink_path() ), AllTrim( flink_name() ) ) } )
      AAdd( aOpc, "6. poništi otvoren racun      " )
      AAdd( aOpcExe, {|| fl_reset( AllTrim( flink_path() ), AllTrim( flink_name() ) ) } )

   CASE _dev_drv == "FPRINT"

      IF !lLowLevel

         AAdd( aOpc, "------ izvjestaji ---------------------------------" )
         AAdd( opcexe, {|| NIL } )

         AAdd( aOpc, "1. dnevni izvještaj  (Z-rep / X-rep)          " )
         AAdd( aOpcExe, {|| fprint_daily_rpt( __device_params ) } )

         AAdd( aOpc, "2. periodični izvještaj" )
         AAdd( aOpcExe, {|| fprint_per_rpt( __device_params ) } )

         AAdd( aOpc, "3. pregled artikala " )
         AAdd( aOpcExe, {|| fprint_sold_plu( __device_params ) } )

      ENDIF

      AAdd( aOpc, "------ ostale komande --------------------" )
      AAdd( aOpcExe, {|| NIL } )

      AAdd( aOpc, "5. unos depozita u uredjaj       " )
      AAdd( aOpcExe, {|| fprint_polog( __device_params ) } )

      AAdd( aOpc, "6. štampanje duplikata       " )
      AAdd( aOpcExe, {|| fprint_dupliciraj_racun( __device_params ) } )

      AAdd( aOpc, "7. zatvori račun (cmd 56)       " )
      AAdd( aOpcExe, {|| fprint_rn_close( __device_params ) } )

      AAdd( aOpc, "8. zatvori nasilno račun (cmd 301) " )
      AAdd( aOpcExe, {|| fprint_komanda_301_zatvori_racun( __device_params ) } )

      IF !lLowLevel

         AAdd( aOpc, "9. proizvoljna komanda " )
         AAdd( aOpcExe, {|| fprint_manual_cmd( __device_params ) } )

         IF __device_params[ "type" ] == "P"

            AAdd( aOpc, "10. brisanje artikala iz uređaja (cmd 107)" )
            AAdd( aOpcExe, {|| fprint_delete_plu( __device_params, .F. ) } )
         ENDIF

         AAdd( aOpc, "11. reset PLU " )
         AAdd( aOpcExe, {|| auto_plu( .T., NIL, __device_params ) } )

         AAdd( aOpc, "12. non-fiscal racun - test" )
         AAdd( aOpcExe, {|| fprint_nf_txt( __device_params, "ČčĆćŽžĐđŠš" ) } )

         AAdd( aOpc, "13. test email" )
         AAdd( aOpcExe, {|| f18_email_test() } )

      ENDIF

   CASE _dev_drv == "HCP"

      IF !lLowLevel

         AAdd( aOpc, "------ izvještaji -----------------------" )
         AAdd( aOpcExe, {|| .F. } )
         AAdd( aOpc, "1. dnevni fiskalni izvještaj (Z rep.)    " )
         AAdd( aOpcExe, {|| hcp_z_rpt( __device_params ) } )
         AAdd( aOpc, "2. presjek stanja (X rep.)    " )
         AAdd( aOpcExe, {|| hcp_x_rpt( __device_params ) } )

         AAdd( aOpc, "3. periodični izvjestaj (Z rep.)    " )
         AAdd( aOpcExe, {|| hcp_s_rpt( __device_params ) } )

      ENDIF

      AAdd( aOpc, "------ ostale komande --------------------" )
      AAdd( aOpcExe, {|| .F. } )

      AAdd( aOpc, "5. kopija računa    " )
      AAdd( aOpcExe, {|| hcp_rn_copy( __device_params ) } )
      AAdd( aOpc, "6. unos depozita u uređaj    " )
      AAdd( aOpcExe, {|| hcp_polog( __device_params ) } )
      AAdd( aOpc, "7. pošalji cmd.ok    " )
      AAdd( aOpcExe, {|| hcp_create_cmd_ok( __device_params ) } )

      IF !lLowLevel

         AAdd( aOpc, "8. izbaci stanje računa    " )
         AAdd( aOpcExe, {|| hcp_fisc_no( __device_params ) } )
         AAdd( aOpc, "P. reset PLU " )
         AAdd( aOpcExe, {|| auto_plu( .T., NIL, __device_params ) } )

      ENDIF

   CASE _dev_drv == "TREMOL"

      IF !lLowLevel

         AAdd( aOpc, "------ izvještaji -----------------------" )
         AAdd( aOpcExe, {|| .F. } )

         AAdd( aOpc, "1. dnevni fiskalni izvještaj (Z rep.)    " )
         AAdd( aOpcExe, {|| tremol_z_rpt( __device_params ) } )

         AAdd( aOpc, "2. izvještaj po artiklima (Z rep.)    " )
         AAdd( aOpcExe, {|| tremol_z_item( __device_params ) } )

         AAdd( aOpc, "3. presjek stanja (X rep.)    " )
         AAdd( aOpcExe, {|| tremol_x_rpt( __device_params ) } )

         AAdd( aOpc, "4. izvještaj po artiklima (X rep.)    " )
         AAdd( aOpcExe, {|| tremol_x_item( __device_params ) } )

         AAdd( aOpc, "5. periodični izvjestaj (Z rep.)    " )
         AAdd( aOpcExe, {|| tremol_per_rpt( __device_params ) } )

      ENDIF

      AAdd( aOpc, "------ ostale komande --------------------" )
      AAdd( aOpcExe, {|| .F. } )

      AAdd( aOpc, "K. kopija računa    " )
      AAdd( aOpcExe, {|| tremol_rn_copy( __device_params ) } )

      IF !lLowLevel

         AAdd( aOpc, "R. reset artikala    " )
         AAdd( aOpcExe, {|| tremol_reset_plu( __device_params ) } )

      ENDIF

      AAdd( aOpc, "P. unos depozita u uređaj    " )
      AAdd( aOpcExe, {|| tremol_polog( __device_params ) } )

      IF !lLowLevel
         AAdd( aOpc, "R. reset PLU " )
         AAdd( aOpcExe, {|| auto_plu( .T., NIL, __device_params ) } )
      ENDIF


   CASE _dev_drv == "TRING"

      IF !lLowLevel

         AAdd( aOpc, "------ izvještaji ---------------------------------" )
         AAdd( aOpcExe, {|| .F. } )
         AAdd( aOpc, "1. dnevni izvještaj                               " )
         AAdd( aOpcExe, {|| tring_daily_rpt( __device_params ) } )
         AAdd( aOpc, "2. periodični izvjestaj" )
         AAdd( aOpcExe, {|| tring_per_rpt( __device_params ) } )
         AAdd( aOpc, "3. presjek stanja" )
         AAdd( aOpcExe, {|| tring_x_rpt( __device_params ) } )

      ENDIF

      AAdd( aOpc, "------ ostale komande --------------------" )
      AAdd( aOpcExe, {|| .F. } )
      AAdd( aOpc, "5. unos depozita u uređaj       " )
      AAdd( aOpcExe, {|| tring_polog( __device_params ) } )
      AAdd( aOpc, "6. štampanje duplikata       " )
      AAdd( aOpcExe, {|| tring_double( __device_params ) } )
      AAdd( aOpc, "7. zatvori (poništi) racun " )
      AAdd( aOpcExe, {|| tring_close_rn( __device_params ) } )

      IF !lLowLevel

         AAdd( aOpc, "8. inicijalizacija " )
         AAdd( aOpcExe, {|| tring_init( __device_params, "1", "" ) } )
         AAdd( aOpc, "S. reset zahtjeva na PU serveru " )
         AAdd( aOpcExe, {|| tring_reset( __device_params ) } )

         AAdd( aOpc, "R. reset PLU " )
         AAdd( aOpcExe, {|| auto_plu( .T., NIL, __device_params ) } )

      ENDIF

   ENDCASE

   _m_x := m_x
   _m_y := m_y


   f18_menu( "izvf", .F., nIzbor, aOpc, aOpcExe )

   m_x := _m_x
   m_y := _m_y

   RETURN .T.
