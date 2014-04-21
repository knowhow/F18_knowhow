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



#include "rnal.ch"

// --------------------------------------------------------
// meni exporta
// --------------------------------------------------------
FUNCTION m_export( nDoc_no, aDocList, lTemp, lWriteRel )

   LOCAL mX := m_x
   LOCAL mY := m_y
   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE izbor := 1

   AAdd( opc, "1. rnal -> GPS.opt (Lisec)         " )
   AAdd( opcexe, {|| exp_2_lisec( nDoc_no, lTemp, lWriteRel ), izbor := 0 } )
   AAdd( opc, "2. rnal -> FMK    " )
   AAdd( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList ), izbor := 0 } )
   AAdd( opc, "3. rnal -> FMK (zadnja otpremnica) " )
   AAdd( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList, .T. ), izbor := 0 } )

   Menu_SC( "export" )

   m_x := mX
   m_y := mY

   RETURN
