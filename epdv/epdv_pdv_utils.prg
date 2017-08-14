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


FUNCTION save_pdv_obracun( dDatOd, dDatDo )

   LOCAL _rec

   select_o_epdv_r_pdv()

   set_global_vars_from_dbf()

   IF Pitanje( , "Želite li obračun pohraniti u bazu PDV prijava ?", " " ) == "D"


      select_o_epdv_pdv()

      SET ORDER TO TAG "period"
      SEEK DToS( dDatOd ) + DToS( dDatDo )
      IF !Found()
         APPEND BLANK
      ELSE
         IF lock == "D"
            MsgBeep( "Vec postoji obracun koji je zakljucan #" + ;
               "promjena NIJE snimljena !" )
            SELECT ( F_PDV )
            USE
            SELECT ( F_R_PDV )
            USE
            RETURN .F.
         ENDIF
      ENDIF

      IF Empty( pdv->datum_1 ) // datum kreiranja
         _datum_1 := Date()
      ENDIF

      // datum azuriranja
      _datum_2 := Date()

      _rec := get_hash_record_from_global_vars()

      update_rec_server_and_dbf( "epdv_pdv", _rec, 1, "FULL" )

      SELECT ( F_PDV )
      USE

   ENDIF

   RETURN .T.
