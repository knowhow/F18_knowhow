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

#include "f18.ch"

/*
   Kreiraj sve DBFCDX
*/

FUNCTION cre_all_dbfs( ver )

   LOCAL _first_start := fetch_metric( "f18_first_start", my_user(), 0 )
   LOCAL _local_files, _local_files_count

   // first_start, ako je 0 onda je to prvi ulazak u bazu...
   IF _first_start = 0

      // napravi dodatnu provjeru radi postojecih instalacija...
      _local_files := Directory( my_home() + "*.dbf" )
      _local_files_count := Len( _local_files )

      // ovdje mozemo poduzeti neka pitanja...
      IF _local_files_count = 0
         // recimo mozemo birati module za glavni meni itd...
         f18_set_active_modules()
      ENDIF

   ENDIF

   log_write( "START cre_all_dbfs", 5 )

   cre_sifrarnici_1( ver )
   cre_roba( ver )
   cre_partn( ver )
   _kreiraj_adrese( ver )


   proizvoljni_izvjestaji_db_cre( ver )
   cre_fin_mat( ver )

   IF f18_use_module( "fin" )
      // glavni fin tabele
      cre_all_fin( ver )
   ENDIF

   IF f18_use_module( "kalk" )
      cre_all_kalk( ver )
   ENDIF

   IF f18_use_module( "fakt" )
      cre_all_fakt( ver )
   ENDIF

   IF f18_use_module( "ld" )
      cre_all_ld_sif( ver )
      cre_all_ld( ver )
   ENDIF


   IF f18_use_module( "os" )
      cre_all_os( ver )
   ENDIF


   IF f18_use_module( "virm" )
      cre_all_virm_sif( ver )
      cre_all_virm( ver )
   ENDIF

   IF f18_use_module( "kadev" )
      cre_all_kadev( ver )
   ENDIF

   IF f18_use_module( "epdv" )
      cre_all_epdv( ver )
   ENDIF

   IF f18_use_module( "pos" )
      cre_all_pos( ver )
   ENDIF

   IF f18_use_module( "rnal" )
      cre_all_rnal( ver )
   ENDIF

   IF f18_use_module( "mat" )
      cre_all_mat( ver )
   ENDIF

   IF _first_start = 0
      // setuj da je modul vec aktiviran...
      set_metric( "f18_first_start", my_user(), 1 )
   ENDIF

   log_write( "END crea_all_dbfs", 5 )

   RETURN .T.



FUNCTION CreSystemDb( ver )

   _kreiraj_params_tabele( ver )
   _kreiraj_adrese( ver )

   RETURN .T.



FUNCTION _kreiraj_params_tabele()

   LOCAL _table_name, _alias, aDBF

   CLOSE ALL

   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 2, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj

   _alias := "PARAMS"
   _table_name := "params"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "fsec+fh+fvar+rbr", _alias, .T. )

   _alias := "GPARAMS"
   _table_name := "gparams"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "fsec+fh+fvar+rbr", _alias, .T. )

   _alias := "KPARAMS"
   _table_name := "kparams"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "fsec+fh+fvar+rbr", _alias, .T. )

   RETURN NIL



FUNCTION _kreiraj_adrese( ver )

   LOCAL _table_name, _alias, _created

   _alias := "ADRES"
   _table_name := "adres"

   aDBF := {}
   AAdd( aDBf, { 'ID', 'C',  50,   0 } )
   AAdd( aDBf, { 'RJ', 'C',  30,   0 } )
   AAdd( aDBf, { 'KONTAKT', 'C',  30,   0 } )
   AAdd( aDBf, { 'NAZ', 'C',  15,   0 } )
   AAdd( aDBf, { 'TEL2', 'C',  15,   0 } )
   AAdd( aDBf, { 'TEL3', 'C',  15,   0 } )
   AAdd( aDBf, { 'MJESTO', 'C',  15,   0 } )
   AAdd( aDBf, { 'PTT', 'C',  6,   0 } )
   AAdd( aDBf, { 'ADRESA', 'C',  50,   0 } )
   AAdd( aDBf, { 'DRZAVA', 'C',  22,   0 } )
   AAdd( aDBf, { 'ziror', 'C',  30,   0 } )
   AAdd( aDBf, { 'zirod', 'C',  30,   0 } )
   AAdd( aDBf, { 'K7', 'C',  1,   0 } )
   AAdd( aDBf, { 'K8', 'C',  2,   0 } )
   AAdd( aDBf, { 'K9', 'C',  3,   0 } )

   IF_NOT_FILE_DBF_CREATE
   IF_C_RESET_SEMAPHORE

   CREATE_INDEX( "ID", "id+naz", _alias )

   RETURN .T.




FUNCTION CreGparam( nArea )

   LOCAL aDbf

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 2, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj

   IF ( nArea == -1 .OR. nArea == F_GPARAMS )

      cImeDBf := f18_ime_dbf( "gparams" )

      IF !File( cImeDbf )
         DBCREATE2( cImeDbf, aDbf )
      ENDIF

      CREATE_INDEX( "ID", "fsec+fh+fvar+rbr", cImeDBF )
   ENDIF

   RETURN .T.


FUNCTION KonvParams( cImeDBF )

   cImeDBF := f18_ime_dbf( cImeDBF )
   CLOSE  ALL
   IF File( cImeDBF ) // ako postoji
      USE ( cImeDbf )
      IF FieldPos( "VAR" ) <> 0  // stara varijanta parametara
         SAVE SCREEN TO cScr
         cls
         Modstru( cImeDbf, "C H C 1 0  FH  C 1 0", .T. )
         Modstru( cImeDbf, "C SEC C 1 0  FSEC C 1 0", .T. )
         Modstru( cImeDbf, "C VAR C 2 0 FVAR C 2 0", .T. )
         Modstru( cImeDbf, "C  V C 15 0  FV C 15 0", .T. )
         Modstru( cImeDbf, "A BRISANO C 1 0", .T. )  // dodaj polje "BRISANO"
         Inkey( 2 )
         RESTORE SCREEN FROM cScr
      ENDIF
   ENDIF
   CLOSE ALL

   RETURN .T.


FUNCTION dbf_ext_na_kraju( cIme )

   cIme := ToUnix( cIme )
   IF Right( cIme, 4 ) <> "." + DBFEXT
      cIme := cIme + "." + DBFEXT
   ENDIF

   RETURN cIme

/*
    aDbf := { ... struktura dbf .. }
    cTable := "konto"
    dbCreate2( cTable, aDbf )
*/

FUNCTION dbCreate2( ime_dbf, struct_dbf, driver )

   LOCAL _ime_cdx

   ime_dbf := f18_ime_dbf( ime_dbf )
   _ime_cdx := ImeDbfCdx( ime_dbf )

   IF Right( _ime_cdx, 4 ) == "." + INDEXEXT
      FErase( _ime_cdx )
   ENDIF

   dbCreate( ime_dbf, struct_dbf, driver )

   RETURN .T.


FUNCTION g_pos_pripr_fields()

   LOCAL aDbf

   // _POS, _PRIPR, PRIPRZ, PRIPRG, _POSP
   aDbf := {}
   AAdd ( aDbf, { "BRDOK",     "C",  6, 0 } )
   AAdd ( aDbf, { "CIJENA",    "N", 10, 3 } )
   AAdd ( aDbf, { "DATUM",     "D",  8, 0 } )
   AAdd ( aDbf, { "GT",        "C",  1, 0 } )
   AAdd ( aDbf, { "IDCIJENA",  "C",  1, 0 } )
   AAdd ( aDbf, { "IDDIO",     "C",  2, 0 } )
   AAdd ( aDbf, { "IDGOST",    "C",  8, 0 } )
   AAdd ( aDbf, { "IDODJ",     "C",  2, 0 } )
   AAdd ( aDbf, { "IDPOS",     "C",  2, 0 } )
   AAdd ( aDbf, { "IDRADNIK",  "C",  4, 0 } )
   AAdd ( aDbf, { "IDROBA",    "C", 10, 0 } )

   AAdd ( aDbf, { "IDTARIFA",  "C",  6, 0 } )
   AAdd ( aDbf, { "IDVD",      "C",  2, 0 } )
   AAdd ( aDbf, { "IDVRSTEP",  "C",  2, 0 } )
   AAdd ( aDbf, { "JMJ",       "C",  3, 0 } )

   // za inventuru, nivelaciju
   AAdd ( aDbf, { "KOL2",      "N", 18, 3 } )
   AAdd ( aDbf, { "KOLICINA",  "N", 18, 3 } )
   AAdd ( aDbf, { "M1",        "C",  1, 0 } )
   AAdd ( aDbf, { "MU_I",      "C",  1, 0 } )
   AAdd ( aDbf, { "NCIJENA",   "N", 10, 3 } )
   AAdd ( aDbf, { "PLACEN",    "C",  1, 0 } )
   AAdd ( aDbf, { "PREBACEN",  "C",  1, 0 } )
   AAdd ( aDbf, { "ROBANAZ",   "C", 40, 0 } )
   AAdd ( aDbf, { "SMJENA",    "C",  1, 0 } )
   AAdd ( aDbf, { "STO",       "C",  3, 0 } )
   AAdd ( aDbf, { "STO_BR",    "N",  3, 0 } )
   AAdd ( aDbf, { "ZAK_BR",    "N",  4, 0 } )
   AAdd ( aDbf, { "FISC_RN",   "N", 10, 0 } )

   AAdd ( aDbf, { "VRIJEME",   "C",  5, 0 } )

   AAdd( aDBf, { 'K1', 'C',   4,  0 } )
   // planika: dobavljac   - grupe artikala
   AAdd( aDBf, { 'K2', 'C',   4,  0 } )
   // planika: stavljaju se oznake za velicinu obuce
   // X - ne broji se parovno

   AAdd( aDBf, { 'K7', 'C',   1,  0 } )
   AAdd( aDBf, { 'K8', 'C',   2,  0 } )
   AAdd( aDBf, { 'K9', 'C',   3,  0 } )
   // planika: stavljaju se oznake za velicinu obuce
   // X - ne broji se parovno

   AAdd( aDBf, { 'N1', 'N',  12,  2 } )
   AAdd( aDBf, { 'N2', 'N',  12,  2 } )

   AAdd( aDBf, { 'BARKOD', 'C',  13,  0 } )
   AAdd( aDBf, { 'KATBR', 'C',  14,  0 } )

   AAdd( aDBf, { 'C_1', 'C',   6,  0 } )
   AAdd( aDBf, { 'C_2', 'C',  10,  0 } )
   AAdd( aDBf, { 'C_3', 'C',  50,  0 } )

   RETURN aDbf
