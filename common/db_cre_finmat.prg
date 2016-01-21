/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// --------------------------------------------------------
// kreiranje tabele fin_mat
// --------------------------------------------------------
FUNCTION cre_fin_mat( ver )

   LOCAL aDbf
   LOCAL _table_name
   LOCAL _alias
   LOCAL _created

   aDbf := {}
   AAdd( aDBf, { "IDFIRMA", "C",   2,  0 } )
   AAdd( aDBf, { "IDKONTO", "C",   7,  0 } )
   AAdd( aDBf, { "IDKONTO2", "C",   7,  0 } )
   AAdd( aDBf, { "IDTARIFA", "C",   6,  0 } )
   AAdd( aDBf, { "IDPARTNER", "C",   6,  0 } )
   AAdd( aDBf, { 'IDZADUZ', 'C',   6,  0 } )
   AAdd( aDBf, { 'IDZADUZ2', 'C',   6,  0 } )
   AAdd( aDBf, { "IDVD", "C",   2,  0 } )
   AAdd( aDBf, { "BRDOK", "C",   8,  0 } )
   AAdd( aDBf, { "DATDOK", "D",   8,  0 } )
   AAdd( aDBf, { "BRFAKTP", "C",  10,  0 } )
   AAdd( aDBf, { "DATFAKTP", "D",   8,  0 } )
   AAdd( aDBf, { "DATKURS", "D",   8,  0 } )
   AAdd( aDBf, { 'RABAT', 'N',  20,  8 } )
   AAdd( aDBf, { 'PREVOZ', 'N',  20,  8 } )
   AAdd( aDBf, { 'CARDAZ', 'N',  20,  8 } )
   AAdd( aDBf, { 'BANKTR', 'N',  20,  8 } )
   AAdd( aDBf, { 'SPEDTR', 'N',  20,  8 } )
   AAdd( aDBf, { 'ZAVTR', 'N',  20,  8 } )
   AAdd( aDBf, { 'VPVSAP', 'N',  20,  8 } )
   AAdd( aDBf, { 'PRUCMP', 'N',  20,  8 } )
   AAdd( aDBf, { 'PORPOT', 'N',  20,  8 } )
   AAdd( aDBf, { "FV", "N",  20,  8 } )
   AAdd( aDBf, { "GKV", "N",  20,  8 } )
   AAdd( aDBf, { "GKV2", "N",  20,  8 } )
   AAdd( aDBf, { "TR1", "N",  20,  8 } )
   AAdd( aDBf, { "TR2", "N",  20,  8 } )
   AAdd( aDBf, { "TR3", "N",  20,  8 } )
   AAdd( aDBf, { "TR4", "N",  20,  8 } )
   AAdd( aDBf, { "TR5", "N",  20,  8 } )
   AAdd( aDBf, { "TR6", "N",  20,  8 } )
   AAdd( aDBf, { "NV", "N",  20,  8 } )
   AAdd( aDBf, { "RABATV", "N",  20,  8 } )
   AAdd( aDBf, { "POREZV", "N",  20,  8 } )
   AAdd( aDBf, { "MARZA", "N",  20,  8 } )
   AAdd( aDBf, { "VPV", "N",  20,  8 } )
   AAdd( aDBf, { "MPV", "N",  20,  8 } )
   AAdd( aDBf, { "MARZA2", "N",  20,  8 } )
   AAdd( aDBf, { "POREZ", "N",  20,  8 } )
   AAdd( aDBf, { "POREZ2", "N",  20,  8 } )
   AAdd( aDBf, { "POREZ3", "N",  20,  8 } )
   AAdd( aDBf, { "MPVSAPP", "N",  20,  8 } )
   AAdd( aDBf, { "IDROBA", "C",  10,  0 } )
   AAdd( aDBf, { "KOLICINA", "N",  19,  7 } )
   AAdd( aDBf, { "GKol", "N",  19,  7 } )
   AAdd( aDBf, { "GKol2", "N",  19,  7 } )
   AAdd( aDBf, { "PORVT", "N",  20,  8 } )
   AAdd( aDBf, { "UPOREZV", "N",  20,  8 } )
   AAdd( aDBf, { "K1", "C",   1,  0 } )
   AAdd( aDBf, { "K2", "C",   1,  0 } )

   _alias := "FINMAT"
   _table_name := "finmat"

   IF_NOT_FILE_DBF_CREATE

   // 0.9.1
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 0901
      modstru( { "*" + _table_name, "A K1 C 1 0", "A K2 C 1 0" } )
   ENDIF

   CREATE_INDEX( "1", "idFirma+IdVD+BRDok", _alias )

   RETURN
