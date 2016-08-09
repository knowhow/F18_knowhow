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


FUNCTION fiskalni_izvjestaji_komande( low_level, from_pos )

   LOCAL _dev_id := 0
   LOCAL _dev_drv
   LOCAL _m_x
   LOCAL _m_y

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   IF low_level == NIL
      low_level := .F.
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

      AAdd( opc, "------ izvještaji ---------------------------------" )
      AAdd( opcexe, {|| .F. } )
      AAdd( opc, "1. dnevni izvještaj  (Z-rep / X-rep)          " )
      AAdd( opcexe, {|| fl_daily( AllTrim( flink_path() ), AllTrim( gFC_name ), nDevice ) } )
      AAdd( opc, "------ ostale komande --------------------" )
      AAdd( opcexe, {|| .F. } )
      AAdd( opc, "5. unos depozita u uređaj       " )
      AAdd( opcexe, {|| fl_polog( AllTrim( flink_path() ), AllTrim( gFC_name ) ) } )
      AAdd( opc, "6. poništi otvoren racun      " )
      AAdd( opcexe, {|| fl_reset( AllTrim( flink_path() ), AllTrim( gFC_name ) ) } )

   CASE _dev_drv == "FPRINT"

      IF !low_level

         AAdd( opc, "------ izvjestaji ---------------------------------" )
         AAdd( opcexe, {|| nil } )

         AAdd( opc, "1. dnevni izvještaj  (Z-rep / X-rep)          " )
         AAdd( opcexe, {|| fprint_daily_rpt( __device_params ) } )

         AAdd( opc, "2. periodični izvještaj" )
         AAdd( opcexe, {|| fprint_per_rpt( __device_params ) } )

         AAdd( opc, "3. pregled artikala " )
         AAdd( opcexe, {|| fprint_sold_plu( __device_params ) } )

      ENDIF

      AAdd( opc, "------ ostale komande --------------------" )
      AAdd( opcexe, {|| nil } )

      AAdd( opc, "5. unos depozita u uredjaj       " )
      AAdd( opcexe, {|| fprint_polog( __device_params ) } )

      AAdd( opc, "6. štampanje duplikata       " )
      AAdd( opcexe, {|| fprint_double( __device_params ) } )

      AAdd( opc, "7. zatvori račun (cmd 56)       " )
      AAdd( opcexe, {|| fprint_rn_close( __device_params ) } )

      AAdd( opc, "8. zatvori nasilno račun (cmd 301) " )
      AAdd( opcexe, {|| fprint_komanda_301_zatvori_racun( __device_params ) } )

      IF !low_level

         AAdd( opc, "9. proizvoljna komanda " )
         AAdd( opcexe, {|| fprint_manual_cmd( __device_params ) } )

         IF __device_params[ "type" ] == "P"

            AAdd( opc, "10. brisanje artikala iz uređaja (cmd 107)" )
            AAdd( opcexe, {|| fprint_delete_plu( __device_params, .F. ) } )
         ENDIF

         AAdd( opc, "11. reset PLU " )
         AAdd( opcexe, {|| auto_plu( .T., nil, __device_params ) } )

         AAdd( opc, "12. non-fiscal racun - test" )
         AAdd( opcexe, {|| fprint_nf_txt( __device_params, "ČčĆćŽžĐđŠš" ) } )

         AAdd( opc, "13. test email" )
         AAdd( opcexe, {|| f18_email_test() } )

      ENDIF

   CASE _dev_drv == "HCP"

      IF !low_level

         AAdd( opc, "------ izvještaji -----------------------" )
         AAdd( opcexe, {|| .F. } )
         AAdd( opc, "1. dnevni fiskalni izvještaj (Z rep.)    " )
         AAdd( opcexe, {|| hcp_z_rpt( __device_params ) } )
         AAdd( opc, "2. presjek stanja (X rep.)    " )
         AAdd( opcexe, {|| hcp_x_rpt( __device_params ) } )

         AAdd( opc, "3. periodični izvjestaj (Z rep.)    " )
         AAdd( opcexe, {|| hcp_s_rpt( __device_params ) } )

      ENDIF

      AAdd( opc, "------ ostale komande --------------------" )
      AAdd( opcexe, {|| .F. } )

      AAdd( opc, "5. kopija računa    " )
      AAdd( opcexe, {|| hcp_rn_copy( __device_params ) } )
      AAdd( opc, "6. unos depozita u uređaj    " )
      AAdd( opcexe, {|| hcp_polog( __device_params ) } )
      AAdd( opc, "7. pošalji cmd.ok    " )
      AAdd( opcexe, {|| hcp_create_cmd_ok( __device_params ) } )

      IF !low_level

         AAdd( opc, "8. izbaci stanje računa    " )
         AAdd( opcexe, {|| hcp_fisc_no( __device_params ) } )
         AAdd( opc, "P. reset PLU " )
         AAdd( opcexe, {|| auto_plu( .T., nil, __device_params ) } )

      ENDIF

   CASE _dev_drv == "TREMOL"

      IF !low_level

         AAdd( opc, "------ izvještaji -----------------------" )
         AAdd( opcexe, {|| .F. } )

         AAdd( opc, "1. dnevni fiskalni izvještaj (Z rep.)    " )
         AAdd( opcexe, {|| tremol_z_rpt( __device_params ) } )

         AAdd( opc, "2. izvještaj po artiklima (Z rep.)    " )
         AAdd( opcexe, {|| tremol_z_item( __device_params ) } )

         AAdd( opc, "3. presjek stanja (X rep.)    " )
         AAdd( opcexe, {|| tremol_x_rpt( __device_params ) } )

         AAdd( opc, "4. izvještaj po artiklima (X rep.)    " )
         AAdd( opcexe, {|| tremol_x_item( __device_params ) } )

         AAdd( opc, "5. periodični izvjestaj (Z rep.)    " )
         AAdd( opcexe, {|| tremol_per_rpt( __device_params ) } )

      ENDIF

      AAdd( opc, "------ ostale komande --------------------" )
      AAdd( opcexe, {|| .F. } )

      AAdd( opc, "K. kopija računa    " )
      AAdd( opcexe, {|| tremol_rn_copy( __device_params ) } )

      IF !low_level

         AAdd( opc, "R. reset artikala    " )
         AAdd( opcexe, {|| tremol_reset_plu( __device_params ) } )

      ENDIF

      AAdd( opc, "P. unos depozita u uređaj    " )
      AAdd( opcexe, {|| tremol_polog( __device_params ) } )

      IF !low_level
         AAdd( opc, "R. reset PLU " )
         AAdd( opcexe, {|| auto_plu( .T., nil, __device_params ) } )
      ENDIF


   CASE _dev_drv == "TRING"

      IF !low_level

         AAdd( opc, "------ izvještaji ---------------------------------" )
         AAdd( opcexe, {|| .F. } )
         AAdd( opc, "1. dnevni izvještaj                               " )
         AAdd( opcexe, {|| tring_daily_rpt( __device_params ) } )
         AAdd( opc, "2. periodični izvjestaj" )
         AAdd( opcexe, {|| tring_per_rpt( __device_params ) } )
         AAdd( opc, "3. presjek stanja" )
         AAdd( opcexe, {|| tring_x_rpt( __device_params ) } )

      ENDIF

      AAdd( opc, "------ ostale komande --------------------" )
      AAdd( opcexe, {|| .F. } )
      AAdd( opc, "5. unos depozita u uređaj       " )
      AAdd( opcexe, {|| tring_polog( __device_params ) } )
      AAdd( opc, "6. štampanje duplikata       " )
      AAdd( opcexe, {|| tring_double( __device_params ) } )
      AAdd( opc, "7. zatvori (poništi) racun " )
      AAdd( opcexe, {|| tring_close_rn( __device_params ) } )

      IF !low_level

         AAdd( opc, "8. inicijalizacija " )
         AAdd( opcexe, {|| tring_init( __device_params, "1", "" ) } )
         AAdd( opc, "S. reset zahtjeva na PU serveru " )
         AAdd( opcexe, {|| tring_reset( __device_params ) } )

         AAdd( opc, "R. reset PLU " )
         AAdd( opcexe, {|| auto_plu( .T., nil, __device_params ) } )

      ENDIF

   ENDCASE

   _m_x := m_x
   _m_y := m_y

   Menu_SC( "izvf" )

   m_x := _m_x
   m_y := _m_y

   RETURN
