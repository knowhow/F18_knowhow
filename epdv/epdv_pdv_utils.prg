#include "f18.ch"


FUNCTION epdv_pdv_prijava_snimi_obracun( dDatOd, dDatDo )

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
            MsgBeep( "Vec postoji obracun koji je zakljucan #promjena NIJE snimljena !" )
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


      _datum_2 := Date()   // datum azuriranja

      _rec := get_hash_record_from_global_vars()
      update_rec_server_and_dbf( "epdv_pdv", _rec, 1, "FULL" )

      SELECT ( F_PDV )
      USE

   ENDIF

   RETURN .T.
