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

THREAD STATIC __LD_FIELDS_COUNT := 60


FUNCTION cre_all_ld_sif( ver )

   LOCAL _table_name, _alias, _created
   LOCAL aDbf

   // KRED.DBF
   // ---------------------------------------------------------
   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   6,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  30,  0 } )
   AAdd( aDBf, { 'ZIRO', 'C',  20,  0 } )
   AAdd( aDBf, { 'ZIROD', 'C',  20,  0 } )
   AAdd( aDBf, { 'TELEFON', 'C',  20,  0 } )
   AAdd( aDBf, { 'MJESTO', 'C',  20,  0 } )
   AAdd( aDBf, { 'ADRESA', 'C',  30,  0 } )
   AAdd( aDBf, { 'PTT', 'C',   5,  0 } )
   AAdd( aDBf, { 'FIL', 'C',  30,  0 } )


/*
   _alias := "KRED"
   _table_name := "kred"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   AFTER_CREATE_INDEX
*/

   _alias := "_KRED"
   _table_name := "_kred"
   IF_NOT_FILE_DBF_CREATE

   /*
   // POR.DBF
   // ------------------------------------------------------------

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'IZNOS', 'N',   5,  2 } )
   AAdd( aDBf, { 'DLIMIT', 'N',  12,  2 } )
   AAdd( aDBf, { 'POOPST', 'C',   1,  0 } )
   AAdd( aDBf, { 'POR_TIP', 'C',   1,  0 } )
   // stepenasti porez
   AAdd( aDBf, { 'ALGORITAM', 'C',   1,  0 } )
   AAdd( aDBf, { 'S_STO_1', 'N',   5,  2 } )
   AAdd( aDBf, { 'S_IZN_1', 'N',  12,  2 } )
   AAdd( aDBf, { 'S_STO_2', 'N',   5,  2 } )
   AAdd( aDBf, { 'S_IZN_2', 'N',  12,  2 } )
   AAdd( aDBf, { 'S_STO_3', 'N',   5,  2 } )
   AAdd( aDBf, { 'S_IZN_3', 'N',  12,  2 } )
   AAdd( aDBf, { 'S_STO_4', 'N',   5,  2 } )
   AAdd( aDBf, { 'S_IZN_4', 'N',  12,  2 } )
   AAdd( aDBf, { 'S_STO_5', 'N',   5,  2 } )
   AAdd( aDBf, { 'S_IZN_5', 'N',  12,  2 } )

   _alias := "POR"
   _table_name := "por"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX

   // -----------------------------------------------------------
   // DOPR.DBF
   // -----------------------------------------------------------

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'IZNOS', 'N',   5,  2 } )
   AAdd( aDBf, { 'IdKBenef', 'C',   1,  0 } )
   AAdd( aDBf, { 'DLIMIT', 'N',  12,  2 } )
   AAdd( aDBf, { 'POOPST', 'C',   1,  0 } )
   AAdd( aDBf, { 'DOP_TIP', 'C',   1,  0 } )
   AAdd( aDBf, { 'TIPRADA', 'C',   1,  0 } )

   _alias := "DOPR"
   _table_name := "dopr"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "1", "id+naz+tiprada", _alias )
   AFTER_CREATE_INDEX



   // -------------------------------------------------------
   // STRSPR.DBF
   // -------------------------------------------------------

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   3,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'NAZ2', 'C',   6,  0 } )

   _alias := "STRSPR"
   _table_name := "strspr"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX


   // --------------------------------------------------------
   // KBENEF.DBF
   // --------------------------------------------------------

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   1,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',   8,  0 } )
   AAdd( aDBf, { 'IZNOS', 'N',   5,  2 } )

   _alias := "KBENEF"
   _table_name := "kbenef"

   IF_NOT_FILE_DBF_CREATE


   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX


   // --------------------------------------------------------
   // VPOSLA.DBF
   // --------------------------------------------------------

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'IDKBENEF', 'C',   1,  0 } )

   _alias := "VPOSLA"
   _table_name := "vposla"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX


   // ---------------------------------------------------------
   // TIPPR.DBF
   // ---------------------------------------------------------

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'Aktivan', 'C',   1,  0 } )
   AAdd( aDBf, { 'Fiksan', 'C',   1,  0 } )
   AAdd( aDBf, { 'UFS', 'C',   1,  0 } )
   AAdd( aDBf, { 'UNeto', 'C',   1,  0 } )
   AAdd( aDBf, { 'Koef1', 'N',   5,  2 } )
   AAdd( aDBf, { 'Formula', 'C', 200,  0 } )
   AAdd( aDBf, { 'OPIS', 'C',   8,  0 } )
   AAdd( aDBf, { 'TPR_TIP', 'C',   1,  0 } )

   _alias := "TIPPR"
   _table_name := "tippr"

   IF_NOT_FILE_DBF_CREATE


   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX

   _alias := "TIPPR2"
   _table_name := "tippr2"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX
  */

   RETURN .T.


FUNCTION cre_all_ld( ver )

   LOCAL aDbf, hIndexes, cKey
   LOCAL _alias, _table_name
   LOCAL _created
   LOCAL _tmp

   // RADN
   // -----------------------

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   6,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  20,  0 } )
   AAdd( aDBf, { 'IMEROD', 'C',  15,  0 } )
   AAdd( aDBf, { 'IME', 'C',  15,  0 } )
   AAdd( aDBf, { 'BRBOD', 'N',  11,  2 } )
   AAdd( aDBf, { 'KMINRAD', 'N',   7,  2 } )
   AAdd( aDBf, { 'KLO', 'N',   5,  2 } )
   AAdd( aDBf, { 'SP_KOEF', 'N',   5,  2 } )
   AAdd( aDBf, { 'TIPRADA', 'C',   1,  0 } )
   AAdd( aDBf, { 'IDVPOSLA', 'C',   2,  0 } )
   AAdd( aDBf, { 'OSNBOL', 'N',  11,  4 } )
   AAdd( aDBf, { 'IDSTRSPR', 'C',   3,  0 } )
   AAdd( aDBf, { 'IDOPSST', 'C',   4,  0 } )
   AAdd( aDBf, { 'IDOPSRAD', 'C',   4,  0 } )
   AAdd( aDBf, { 'POL', 'C',   1,  0 } )
   AAdd( aDBf, { 'MATBR', 'C',  13,  0 } )
   AAdd( aDBf, { 'DATOD', 'D',   8,  0 } )
   AAdd( aDBf, { 'brknjiz', 'C',  12,   0 } )
   AAdd( aDBf, { 'brtekr', 'C',  40,   0 } )
   AAdd( aDBf, { 'Isplata', 'C',   2,   0 } )
   AAdd( aDBf, { 'IdBanka', 'C',   6,   0 } )
   AAdd( aDBf, { 'K1', 'C',   1,  0 } )
   AAdd( aDBf, { 'K2', 'C',   1,  0 } )
   AAdd( aDBf, { 'K3', 'C',   2,  0 } )
   AAdd( aDBf, { 'K4', 'C',   2,  0 } )
   AAdd( aDBf, { 'RMJESTO', 'C',  30,  0 } )
   AAdd( aDBf, { 'POROL', 'N',   5,  2 } )
   AAdd( aDBf, { 'IDRJ', 'C',   2,  0 } )
   AAdd( aDBf, { 'STREETNAME', 'C',  40,  0 } )
   AAdd( aDBf, { 'STREETNUM', 'C',   6,  0 } )
   AAdd( aDBf, { 'HIREDFROM', 'D',   8,  0 } )
   AAdd( aDBf, { 'HIREDTO', 'D',   8,  0 } )
   AAdd( aDBf, { 'BEN_SRMJ', 'C',  20,  0 } )
   AAdd( aDBf, { 'AKTIVAN', 'C',   1,  0 } )
   AAdd( aDBf, { 'N1', 'N',  12,  2 } )
   AAdd( aDBf, { 'N2', 'N',  12,  2 } )
   AAdd( aDBf, { 'N3', 'N',  12,  2 } )
   AAdd( aDBf, { 'S1', 'C',  10,  0 } )
   AAdd( aDBf, { 'S2', 'C',  10,  0 } )
   AAdd( aDBf, { 'S3', 'C',  10,  0 } )
   AAdd( aDBf, { 'S4', 'C',  10,  0 } )
   AAdd( aDBf, { 'S5', 'C',  10,  0 } )
   AAdd( aDBf, { 'S6', 'C',  10,  0 } )
   AAdd( aDBf, { 'S7', 'C',  10,  0 } )
   AAdd( aDBf, { 'S8', 'C',  10,  0 } )
   AAdd( aDBf, { 'S9', 'C',  10,  0 } )
   AAdd( aDBf, { 'OPOR', 'C',   1,  0 } )
   AAdd( aDBf, { 'TROSK', 'C',   1,  0 } )
   AAdd( aDBf, { 'ST_INVALID', 'I',   1,  0 } )
   AAdd( aDBf, { 'VR_INVALID', 'I',   1,  0 } )

/*
   _alias := "RADN"
   _table_name := "ld_radn"

   IF_NOT_FILE_DBF_CREATE
   // 1.0.0
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 010002
      modstru( { "*" + _table_name, "A ST_INVALID I 1 0", "A VR_INVALID I 1 0" } )
   ENDIF
   CREATE_INDEX( "1", "id", _alias )
   CREATE_INDEX( "2", "naz", _alias )
   AFTER_CREATE_INDEX
*/

   // -------------------------------------
   // _RADN
   // -------------------------------------
   _alias := "_RADN"
   _table_name := "_ld_radn"
   IF_NOT_FILE_DBF_CREATE

   // 1.0.0
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 010002
      modstru( { "*" + _table_name, "A ST_INVALID I 1 0", "A VR_INVALID I 1 0" } )
   ENDIF

   /*
   // LD_RJ

   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  35,  0 } )
   AAdd( aDBf, { 'TIPRADA', 'C',   1,  0 } )
   AAdd( aDBf, { 'OPOR', 'C',   1,  0 } )

   _alias := "LD_RJ"
   _table_name := "ld_rj"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "ID", "id", _alias )
   AFTER_CREATE_INDEX
   */


   // RADKR.DBF
   // -----------------------------------------------
   aDbf := {}
   AAdd( aDBf, { 'IDRadn', 'C',   6,  0 } )
   AAdd( aDBf, { 'Mjesec', 'N',   2,  0 } )
   AAdd( aDBf, { 'Godina', 'N',   4,  0 } )
   AAdd( aDBf, { 'IdKred', 'C',   6,  0 } )
   AAdd( aDBf, { 'Iznos', 'N',  12,  2 } )
   AAdd( aDBf, { 'Placeno', 'N',  12,  2 } )
   AAdd( aDBf, { 'NaOsnovu', 'C',  20,  0 } )

/*
   _alias := "RADKR"
   _table_name := "ld_radkr"
   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "1", "str(godina)+str(mjesec)+idradn+idkred+naosnovu", _alias )
   CREATE_INDEX( "2", "idradn+idkred+naosnovu+str(godina)+str(mjesec)", _alias )
   CREATE_INDEX( "3", "idkred+naosnovu+idradn+str(godina)+str(mjesec)", _alias )
   CREATE_INDEX( "4", "str(godina)+str(mjesec)+idradn+naosnovu", _alias )

   AFTER_CREATE_INDEX
*/

   // --------------------------------------------------
   // _RADKR.DBF
   // --------------------------------------------------
   _alias := "_RADKR"
   _table_name := "_ld_radkr"
   IF_NOT_FILE_DBF_CREATE


   // ---------------------------------------------------
   // LD

   aDbf := a_dbf_ld_ld()
   hIndexes := h_ld_ld_indexes()

/*
   _alias := "LD"
   _table_name := "ld_ld"

   IF_NOT_FILE_DBF_CREATE
   FOR EACH cKey IN hIndexes:Keys
      CREATE_INDEX( cKey, hIndexes[ cKey ], _alias )
   NEXT
   AFTER_CREATE_INDEX
*/

   // --------------------------------------
   // LD_LDSM
   // --------------------------------------
   _alias := "LDSM"
   _table_name := "ld_ldsm"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "1", "Obr+str(godina)+str(mjesec)+idradn+idrj", _alias )
   CREATE_INDEX( "RADN", "idradn", _alias )
   kreiraj_tabelu_ld__ld( aDbf )


/*
   // PAROBR.DBF
   // --------------------------------------------
   aDBf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'GODINA', 'C',   4,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  10,  0 } )
   AAdd( aDBf, { 'IDRJ', 'C',   2,  0 } )
   AAdd( aDBf, { 'VrBod', 'N',  15,  5 } )
   AAdd( aDBf, { 'K1', 'N',  11,  6 } )
   AAdd( aDBf, { 'K2', 'N',  11,  6 } )
   AAdd( aDBf, { 'K3', 'N',   9,  5 } )
   AAdd( aDBf, { 'K4', 'N',   6,  3 } )
   AAdd( aDBf, { 'K5', 'N',  12,  6 } )
   AAdd( aDBf, { 'K6', 'N',  12,  6 } )
   AAdd( aDBf, { 'K7', 'N',  11,  6 } )
   AAdd( aDBf, { 'K8', 'N',  11,  6 } )
   AAdd( aDBf, { 'OBR', 'C',   1,  0 } )
   AAdd( aDBf, { 'PROSLD', 'N',  12,  2 } )
   AAdd( aDBf, { 'M_BR_SAT', 'N',  12,  2 } )
   AAdd( aDBf, { 'M_NET_SAT', 'N',  12,  2 } )

   _alias := "PAROBR"
   _table_name := "ld_parobr"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "ID", "id + godina + obr", _alias )
   AFTER_CREATE_INDEX
*/

/*
   // OBRACUNI.DBF
   // ---------------------------------------

   aDbf := {}

   AAdd( aDBf, { 'RJ', 'C', 2, 0 } )
   AAdd( aDBf, { 'GODINA', 'N', 4, 0 } )
   AAdd( aDBf, { 'MJESEC', 'N', 2, 0 } )
   AAdd( aDBf, { 'STATUS', 'C', 1, 0 } )
   AAdd( aDBf, { 'OBR', 'C', 1, 0 } )
   AAdd( aDBf, { 'K1', 'C', 4, 0 } )
   AAdd( aDBf, { 'K2', 'C', 10, 0 } )
   AAdd( aDBf, { 'MJ_ISPL', 'N', 2, 0 } )
   AAdd( aDBf, { 'DAT_ISPL', 'D', 8, 0 } )
   AAdd( aDBf, { 'ISPL_ZA', 'C', 50, 0 } )
   AAdd( aDBf, { 'VR_ISPL', 'C', 50, 0 } )

   _alias := "OBRACUNI"
   _table_name := "ld_obracuni"

   IF_NOT_FILE_DBF_CREATE
   CREATE_INDEX( "RJ", "rj+STR(godina)+STR(mjesec)+status+obr", _alias )
   AFTER_CREATE_INDEX
*/

   /*
   // PK_RADN
   // -----------------------------------------------------------

   aDbf := {}
   AAdd( aDBf, { 'idradn', 'C',   6,  0 } )
   AAdd( aDBf, { 'zahtjev', 'N',   4,  0 } )
   AAdd( aDBf, { 'datum', 'D',   8,  0 } )

   // 1. podaci o radniku
   // -----------------------------------------------------
   // prezime
   AAdd( aDBf, { 'r_prez', 'C',   20,  0 } )
   // ime
   AAdd( aDBf, { 'r_ime', 'C',   20,  0 } )
   // ime oca
   AAdd( aDBf, { 'r_imeoca', 'C',   20,  0 } )
   // jmb
   AAdd( aDBf, { 'r_jmb', 'C',   13,  0 } )
   // adresa prebivalista
   AAdd( aDBf, { 'r_adr', 'C',   30,  0 } )
   // opcina prebivalista
   AAdd( aDBf, { 'r_opc', 'C',   30,  0 } )
   // opcina prebivalista "kod"
   AAdd( aDBf, { 'r_opckod', 'C',   10,  0 } )
   // datum rodjenja
   AAdd( aDBf, { 'r_drodj', 'D',    8,  0 } )
   // telefon
   AAdd( aDBf, { 'r_tel', 'N',   12,  0 } )

   // 2. podaci o poslodavcu
   // -----------------------------------------------------
   // naziv poslodavca
   AAdd( aDBf, { 'p_naziv', 'C',  100,  0 } )
   // jib poslodavca
   AAdd( aDBf, { 'p_jib', 'C',   13,  0 } )
   // zaposlen TRUE/FALSE
   AAdd( aDBf, { 'p_zap', 'C',    1,  0 } )

   // 3. podaci o licnim odbicima
   // -----------------------------------------------------
   // osnovni licni odbitak
   AAdd( aDBf, { 'lo_osn', 'N',  10,  3 } )
   // licni odbitak za bracnog druga
   AAdd( aDBf, { 'lo_brdr', 'N',  10,  3 } )
   // licni odbitak za izdrzavanu djecu
   AAdd( aDBf, { 'lo_izdj', 'N',  10,  3 } )
   // licni odbitak za clanove porodice
   AAdd( aDBf, { 'lo_clp', 'N',  10,  3 } )
   // licni odbitak za clanove porodice sa invaliditeom
   AAdd( aDBf, { 'lo_clpi', 'N',  10,  3 } )
   // ukupni faktor licnog odbitka
   AAdd( aDBf, { 'lo_ufakt', 'N',  10,  3 } )

   _alias := "PK_RADN"
   _table_name := "ld_pk_radn"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idradn", _alias )
   CREATE_INDEX( "2", "STR(zahtjev)", _alias )
   AFTER_CREATE_INDEX


   // ---------------------------------------------------
   // PK_DATA
   // ---------------------------------------------------

   aDbf := {}

   // id radnik
   AAdd( aDBf, { 'idradn', 'C',   6,  0 } )
   // identifikator podatka (1) bracni drug
   // (2) djeca
   // (3) clanovi porodice ....
   AAdd( aDBf, { 'ident', 'C',   1,  0 } )
   // redni broj
   AAdd( aDBf, { 'rbr', 'N',   2,  0 } )
   // ime i prezime
   AAdd( aDBf, { 'ime_pr', 'C',   50,  0 } )
   // jmb
   AAdd( aDBf, { 'jmb', 'C',   13,  0 } )
   // srodstvo naziv
   AAdd( aDBf, { 'sr_naz', 'C',   30,  0 } )
   // kod srodstva
   AAdd( aDBf, { 'sr_kod', 'N',   2,  0 } )
   // prihod vlastiti
   AAdd( aDBf, { 'prihod', 'N',    10,  2 } )
   // udio u izdrzavanju
   AAdd( aDBf, { 'udio', 'N',    3,  0 } )
   // koeficijent odbitka
   AAdd( aDBf, { 'koef', 'N',    10,  3 } )

   _alias := "PK_DATA"
   _table_name := "ld_pk_data"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idradn+ident+STR(rbr)", _alias )
   AFTER_CREATE_INDEX
*/


   // -------------------------------------
   // RADSAT.DBF
   // -------------------------------------

/*
   _alias := "RADSAT"
   _table_name := "ld_radsat"

   aDbf := {}
   AAdd( aDBf, { 'IDRADN', 'C',  6,  0 } )
   AAdd( aDBf, { 'SATI', 'N', 10, 0 } )
   AAdd( aDBf, { 'STATUS', 'C',  2, 0 } )

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "IDRADN", "idradn", _alias )
   AFTER_CREATE_INDEX
*/

   /*
   // RADSIHT
   // ------------------------------------------
   aDbf := {}
   AAdd( aDBf, { 'Godina', 'N',   4,  0 } )
   AAdd( aDBf, { 'Mjesec', 'N',   2,  0 } )
   AAdd( aDBf, { 'Dan', 'N',   2,  0 } )
   AAdd( aDBf, { 'DanDio', 'C',   1,  0 } )
   AAdd( aDBf, { 'IDRJ', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDRADN', 'C',   6,  0 } )
   AAdd( aDBf, { 'IDKONTO', 'C',   7,  0 } )
   AAdd( aDBf, { 'OPIS', 'C',  50,  0 } )
   AAdd( aDBf, { 'IDTipPR', 'C',   2,  0 } )
   AAdd( aDBf, { 'BRBOD', 'N',  11,  2 } )
   AAdd( aDBf, { 'IdNorSiht', 'C',   4,  0 } )
   AAdd( aDBf, { 'Izvrseno', 'N',  14,  3 } )
   AAdd( aDBf, { 'Bodova', 'N',  14,  2 } )

   _alias := "RADSIHT"
   _table_name := "ld_radsiht"

   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 010002
      ferase_cdx( _table_name )
   ENDIF

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "str(godina,4,0)+str(mjesec,2,0)+idradn+idrj+str(dan)+dandio+idtippr", _alias  )
   CREATE_INDEX( "2", "idkonto+str(godina,4,0)+str(mjesec,2,0)+idradn", _alias )
   CREATE_INDEX( "3", "idnorsiht+str(godina,4,0)+str(mjesec,2,0)+idradn", _alias )
   CREATE_INDEX( "4", "idradn+str(godina,4,0)+str(mjesec,2,0)+idkonto", _alias )
   AFTER_CREATE_INDEX

   // HACK: 2i indeks sortime pravi probleme
   // CREATE_INDEX( "2i", "idkonto+SORTIME(idradn)+str(godina)+str(mjesec)", _alias )
*/

   // ------------------------------------------------------------
   // NORSIHT - norme u sihtarici
   // - koristi se vjerovatno samo kod rada u normi
   // ------------------------------------------------------------
   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   4,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  30,  0 } )
   AAdd( aDBf, { 'JMJ', 'C',   3,  0 } )
   AAdd( aDBf, { 'Iznos', 'N',   8,  2 } )
   AAdd( aDBf, { 'N1', 'N',   6,  2 } )
   AAdd( aDBf, { 'K1', 'C',   1,  0 } )
   AAdd( aDBf, { 'K2', 'C',   2,  0 } )

   _alias := "NORSIHT"
   _table_name := "ld_norsiht"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )
   AFTER_CREATE_INDEX

   // ---------------------------------------------------------------
   // TPRSIHT   - tipovi primanja koji odradjuju sihtaricu
   // ---------------------------------------------------------------
   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   2,  0 } )
   AAdd( aDBf, { 'NAZ', 'C',  30,  0 } )
   AAdd( aDBf, { 'K1', 'C',   1,  0 } )
   // K1="F" - po formuli
   // " " - direktno se unose bodovi
   AAdd( aDBf, { 'K2', 'C',   2,  0 } )
   AAdd( aDBf, { 'K3', 'C',   3,  0 } )
   AAdd( aDBf, { 'FF', 'C',  30,  0 } )

   _alias := "TPRSIHT"
   _table_name := "ld_tprsiht"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )
   AFTER_CREATE_INDEX

   RETURN .T.


STATIC FUNCTION kreiraj_tabelu_ld__ld( aDbf )

   LOCAL _alias, _table_name

   _alias := "_LD"
   _table_name := "_ld_ld"

   prosiri_numericka_polja_tabele( @aDbf )

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "1", "idradn + idrj", _alias )

   RETURN .T.


STATIC FUNCTION prosiri_numericka_polja_tabele( aDbf )

   LOCAL i
   LOCAL nProsiri := 4

   FOR i := 1 TO Len( aDbf )
      IF aDbf[ i, 2 ] == "N" .AND. !( Upper( AllTrim( aDbf[ i, 1 ] ) ) $ "GODINA#MJESEC" )
         aDbf[ i, 3 ] += nProsiri
      ENDIF
   NEXT

   RETURN .T.


FUNCTION a_dbf_ld_ld()

   LOCAL aDbf, nI, _field_sati, _field_iznos

   aDBf := {}
   AAdd( aDBf, { 'Godina', 'N',   4,  0 } )
   AAdd( aDBf, { 'IDRJ', 'C',   2,  0 } )
   AAdd( aDBf, { 'IDRADN', 'C',   6,  0 } )
   AAdd( aDBf, { 'Mjesec', 'N',   2,  0 } )
   AAdd( aDBf, { 'BRBOD', 'N',  11,  2 } )
   AAdd( aDBf, { 'IdStrSpr', 'C',   3,  0 } )
   AAdd( aDBf, { 'IdVPosla', 'C',   2,  0 } )
   AAdd( aDBf, { 'KMinRad', 'N',   7,  2 } )

   // generisanje kolona iznos/sati
   FOR nI := 1 TO __LD_FIELDS_COUNT

      _field_sati := "S" + PadL( AllTrim( Str( nI ) ), 2, "0" )
      _field_iznos := "I" + PadL( AllTrim( Str( nI ) ), 2, "0" )

      AAdd( aDBf, { _field_sati, 'N',   6,  2 } )
      AAdd( aDBf, { _field_iznos, 'N',  12,  2 } )

   NEXT

   AAdd( aDBf, { 'USATI', 'N',   8,  1 } )
   AAdd( aDBf, { 'UNETO', 'N',  13,  2 } )
   AAdd( aDBf, { 'UODBICI', 'N',  13,  2 } )
   AAdd( aDBf, { 'UIZNOS', 'N',  13,  2 } )
   AAdd( aDBf, { 'UNETO2', 'N',  13,  2 } )
   AAdd( aDBf, { 'UBRUTO', 'N',  13,  2 } )
   AAdd( aDBf, { 'UPOREZ', 'N',  13,  2 } )
   AAdd( aDBf, { 'UPOR_ST', 'N',  10,  2 } )
   AAdd( aDBf, { 'UDOPR', 'N',  13,  2 } )
   AAdd( aDBf, { 'UDOP_ST', 'N',  10,  2 } )
   AAdd( aDBf, { 'NAKN_OPOR', 'N',  13,  2 } )
   AAdd( aDBf, { 'NAKN_NEOP', 'N',  13,  2 } )
   AAdd( aDBf, { 'ULICODB', 'N',  13,  2 } )
   AAdd( aDBf, { 'TIPRADA', 'C',   1,  2 } )
   AAdd( aDBf, { 'OPOR', 'C',   1,  2 } )
   AAdd( aDBf, { 'TROSK', 'C',   1,  2 } )
   AAdd( aDBf, { 'VAROBR', 'C',   1,  0 } )
   AAdd( aDBf, { 'V_ISPL', 'C',   2,  0 } )
   AAdd( aDBf, { 'OBR', 'C',   1,  0 } )
   AAdd( aDBf, { 'RADSAT', 'N',  10,  0 } )

   RETURN aDbf


FUNCTION h_ld_ld_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "str(godina,4,0)+idrj+str(mjesec,2,0)+obr+idradn"
   hIndexes[ "2" ] := "str(godina,4,0)+str(mjesec,2,0)+obr+idradn+idrj"
   hIndexes[ "3" ] := "str(godina,4,0)+idrj+idradn"
   hIndexes[ "4" ] := "str(godina,4,0)+idradn+str(mjesec,2,0)+obr"

   // U (ukupno) indeksi ne sadrze polje obr
   hIndexes[ "1U" ] := "str(godina,4,0)+idrj+str(mjesec,2,0)+idradn"
   hIndexes[ "2U" ] := "str(godina,4,0)+str(mjesec,2,0)+idradn+idrj"

   hIndexes[ "RADN" ] := "idradn"

   RETURN hIndexes


FUNCTION h_ld_radkr_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "str(godina,4,0)+str(mjesec,2,0)+idradn+idkred+naosnovu"
   hIndexes[ "2" ] := "idradn+idkred+naosnovu+str(godina,4,0)+str(mjesec,2,0)"
   hIndexes[ "3" ] := "idkred+naosnovu+idradn+str(godina,4,0)+str(mjesec,2,0)"
   hIndexes[ "4" ] := "str(godina,4,0)+str(mjesec,2,0)+idradn+naosnovu"

   RETURN hIndexes
