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

STATIC s_lInCreAllDbfs := .F.

/*
   Kreiraj sve DBFCDX
*/

FUNCTION cre_all_dbfs( ver )

//   LOCAL _first_start := fetch_metric( "f18_first_start", my_user(), 0 )

   s_lInCreAllDbfs := .T.

/*
   IF _first_start == 0 // first_start, ako je 0 onda je to prvi ulazak u bazu...

      // napravi dodatnu provjeru radi postojecih instalacija...
      _local_files := Directory( my_home() + "*.dbf" )
      _local_files_count := Len( _local_files )

      IF _local_files_count == 0 .AND. is_in_main_thread()
         f18_set_active_modules() // odabir modula za glavni meni
      ENDIF

   ENDIF
*/

   log_write( "START: cre_all_dbfs", 5 )

   cre_params_dbf()
   cre_sif_konto( ver )

   fill_tbl_valute() // upisi default valute ako ne postoje
   db_cre_ugov( ver ) // kreiranje tabela ugovora

   cre_sif_roba( ver )
   cre_sif_partn( ver )
   cre_sif_adrese( ver )

   proizvoljni_izvjestaji_db_cre( ver )
   cre_fin_mat( ver )

   IF f18_use_module( "fin" )
      IF fetch_metric_error()
         error_bar( "sql", "fetch metric error" )
         RETURN .F.
      ENDIF
      cre_all_fin( ver )
   ENDIF

   IF fetch_metric_error()
      error_bar( "sql", "fetch metric error" )
      RETURN .F.
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


   IF f18_use_module( "epdv" )
      cre_all_epdv( ver )
   ENDIF

#ifdef F18_POS
   IF f18_use_module( "pos" )
      cre_all_pos( ver )
   ENDIF
#endif

#ifdef F18_RNAL
   IF f18_use_module( "rnal" )
      cre_all_rnal( ver )
   ENDIF
#endif

#ifdef F18_MAT
   IF f18_use_module( "mat" )
      cre_all_mat( ver )
   ENDIF
#endif

#ifdef F18_KADEV
   IF f18_use_module( "kadev" )
      cre_all_kadev( ver )
   ENDIF
#endif

/*
   IF _first_start == 0
      // setuj da je modul vec aktiviran...
      set_metric( "f18_first_start", my_user(), 1 )
   ENDIF
*/

   log_write( "END: cre_all_dbfs", 5 )

   s_lInCreAllDbfs := .F.

   RETURN .T.



FUNCTION in_cre_all_dbfs()

   RETURN s_lInCreAllDbfs





FUNCTION cre_params_dbf()

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

   RETURN .T.



FUNCTION cre_sif_adrese( ver )

   LOCAL _table_name, _alias, _created
   LOCAL aDbf

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
   CREATE_INDEX( "ID", "id+naz", _alias )
   AFTER_CREATE_INDEX

   RETURN .T.




FUNCTION create_gparams()

   LOCAL aDbf, cImeDbf

   info_bar( "dbf", "create gparams" )

   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 2, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj


   cImeDBf := f18_ime_dbf( "gparams" )

   IF !File( cImeDbf )
      DBCREATE2( cImeDbf, aDbf )
   ENDIF

   CREATE_INDEX( "ID", "fsec+fh+fvar+rbr", cImeDBF )
   info_bar( "dbf", "" )

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

FUNCTION dbCreate2( cImeDbf, struct_dbf, driver )

   LOCAL _ime_cdx

   cImeDbf := f18_ime_dbf( cImeDbf )
   _ime_cdx := ImeDbfCdx( cImeDbf )

   IF Right( _ime_cdx, 4 ) == "." + INDEXEXT
      FErase( _ime_cdx )
   ENDIF

   dbCreate( cImeDbf, struct_dbf, driver )

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
