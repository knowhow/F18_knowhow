#include "f18.ch"


// ----------------------------------------------
// napuni sifrarnik sifk  sa poljem za unos
// podatka o pripadnosti rejonu
// 1 - federacija
// 2 - rs
// 3 - distrikt brcko
// ---------------------------------------------
FUNCTION epdv_update_sif_partneri()

   LOCAL cId := "PARTN"
   LOCAL cNaz := "1-FED,2-RS 3-DB"
   LOCAL cOznaka := "REJO"
   LOCAL cSort := "09"

   LOCAL hRec

   IF !find_sifk_by_id_oznaka_naz_sort( cId,  cOznaka, cNaz, cSort )

      o_sifk( "XXXX" )
      APPEND BLANK
      ?E "fill_sifk_partn - not fonud", cOznaka, cNaz, cSort

      hRec := dbf_get_rec()
      hRec[ "id" ] := cId
      hRec[ "oznaka" ] := cOznaka
      hRec[ "naz" ] := cNaz
      hRec[ "sort" ] := cSort
      hRec[ "tip" ] := "C"
      hRec[ "duzina" ] := 1
      hRec[ "veza" ] := "1"

      IF !update_rec_server_and_dbf( "sifk", hRec, 1, "FULL" )
         delete_with_rlock()
      ENDIF
   ENDIF

   RETURN .T.
