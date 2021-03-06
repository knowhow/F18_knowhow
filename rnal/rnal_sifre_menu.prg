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

FUNCTION m_sif()

   LOCAL opc := {}
   LOCAL opcexe := {}
   LOCAL Izbor := 1

   rnal_o_sif_tables()

   AAdd( opc, "1. naručioci                      " )
   AAdd( opcexe, {|| s_customers() } )
   AAdd( opc, "2. kontakti" )
   AAdd( opcexe, {|| s_contacts() } )
   AAdd( opc, "3. objekti" )
   AAdd( opcexe, {|| s_objects() } )
   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "5. artikli" )
   AAdd( opcexe, {|| s_articles() } )
   AAdd( opc, "6. elementi, grupe " )
   AAdd( opcexe, {|| s_e_groups() } )
   AAdd( opc, "7. elementi atributi grupe" )
   AAdd( opcexe, {|| s_e_gr_val() } )
   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "8. dodatne operacije" )
   AAdd( opcexe, {|| s_aops() } )
   AAdd( opc, "9. dodatne operacije, atributi" )
   AAdd( opcexe, {|| s_aops_att() } )
   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "A. export, relacije" )
   AAdd( opcexe, {|| p_relation() } )

   AAdd( opc, "B. RAL definicije" )
   AAdd( opcexe, {|| sif_ral() } )

   Izbor := 1

   f18_menu( "m_sif", .F., izbor, opc, opcexe )

   RETURN .T.
