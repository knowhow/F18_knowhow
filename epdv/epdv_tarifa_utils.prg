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


#include "epdv.ch"


// ----------------------------
// napuni sifrarnik tarifa sa
FUNCTION epdv_set_sif_tarifa()

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   IF !f18_lock_tables( { "tarifa" } )
      RETURN .F.
   ENDIF

   sql_table_update( nil, "BEGIN" )

   // nabavka od pdv obveznika, standardna prodaja
   cPom := PadR( "PDV17", 6 )
   _append_tarifa( cPom, "PDV 17%", 17 )

   // zasticene cijene
   cPom := PadR( "PDV17Z", 6 )
   _append_tarifa( cPom, "PDV 17% ZASTICENA CIJENA", 17 )

   // stopa 0
   cPom := PadR( "PDV0", 6 )
   _append_tarifa( cPom, "PDV 0%", 0 )

   // nabavka od poljoprivrednika oporezivi dio 5%
   cPom := PadR ( "PDV7PO", 6 )
   _append_tarifa( cPom, "POLJOPR., OPOR. DIO PDV 17%", 17 )

   // nabavka od poljoprivrednika neopoprezivi dio 95%
   cPom := PadR( "PDV0PO", 6 )
   _append_tarifa( cPom, "POLJOPR., NEOPOR. DIO PDV 0%", 0 )

   // uvoz  oporezivo
   cPom := PadR( "PDV7UV", 6 )
   _append_tarifa( cPom, "UVOZ OPOREZIVO, PDV 17%", 17 )

   // uvoz neoporezivo
   cPom := PadR( "PDV0UV", 6 )
   _append_tarifa( cPom, "UVOZ NEOPOREZIVO, PDV 0%", 0 )

   // nabavka neposlovne svrhe - ne priznaje se ul. porez kao odbitak
   // isporuka neposlovne svrhe - izl. pdv standardno
   cPom := PadR( "PDV7NP", 6 )
   _append_tarifa( cPom, "NEPOSLOVNE SVRHE, NAB/ISP", 17 )

   // nabavka i prodaja avansne fakture
   cPom := PadR( "PDV7AV", 6 )
   _append_tarifa( cPom, "AVANSNE FAKTURE, PDV 17%", 17 )

   // nabavka i prodaja avansne fakture neoporezive
   cPom := PadR( "PDV0AV", 6 )
   _append_tarifa( cPom, "AVANSNE FAKTURE, PDV 0%", 0 )

   // isporuke, izvoz
   cPom := PadR( "PDV0IZ", 6 )
   _append_tarifa( cPom, "IZVOZ, PDV 0%", 0 )

   f18_free_tables( { "tarifa" } )
   sql_table_update( nil, "END" )

   RETURN


// ----------------------------------------------------------
// ubaci tarifu u sifranik
// ----------------------------------------------------------
STATIC FUNCTION _append_tarifa( tar_id, naziv, iznos )

   LOCAL _rec

   SELECT tarifa
   SET ORDER TO TAG "ID"
   GO TOP
   SEEK tar_id

   IF !Found()

      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := tar_id
      _rec[ "naz" ] := naziv
      _rec[ "opp" ] := iznos
      update_rec_server_and_dbf( "tarifa", _rec, 1, "CONT" )

   ENDIF

   RETURN
