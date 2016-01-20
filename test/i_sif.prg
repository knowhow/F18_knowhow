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
#include "f18_ver.ch"

// --------------------------
// --------------------------
function i_dodaj_sifre()
local _omodul
// radi inicijalizacije varijabli definisimo neki programski modul

_omodul := TKalkMod():new(nil, "KALK", F18_VER, F18_VER_DATE , "test", "test")
_omodul:initdb()

goModul := _omodul

i_dodaj_sifru_rj()
i_dodaj_sifru_partner()
i_dodaj_sifre_roba()

return


/// --------------------------------------
/// --------------------------------------
function i_dodaj_sifru_rj()
local _tmp, _a_polja

test_var("ok", .f.)
test_var("rec_99", 0)

O_RJ
_kod := PADR("99", LEN(ID))
_naz := "RJ 99"

_a_polja := {_kod, "<ENTER>",  _naz, "<PGDN>"}

test_procedure_with_keystrokes({|| P_Rj()}, key_test_dodaj_id_u_sifarnik(_a_polja))

// rec_99 treba da sadrzi broj zapisa
COUNT FOR (ID == _kod ) TO _tmp
// setuj test var rec_99 sa _tmp 
test_var("rec_99", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("rec_99") == 1,  .t.)

return

/// --------------------------------------
/// --------------------------------------
function i_dodaj_sifru_partner()
local _tmp, _a_polja

test_var("ok", .f.)
test_var("rec_part_99", 0)

O_PARTN
_kod := REPLICATE("9", LEN(id))
_naz := "PARTN 99"

_a_polja := {_kod, "<ENTER>",  _naz, "<PGDN>"}

test_procedure_with_keystrokes({|| P_Firma()}, key_test_dodaj_id_u_sifarnik(_a_polja))


// rec_99 treba da sadrzi broj zapisa
COUNT FOR (ID == _kod ) TO _tmp
// setuj test var rec_99 sa _tmp 
test_var("rec_part_99", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("rec_part_99") == 1,  .t.)

return


/// --------------------------------------
/// --------------------------------------
function i_dodaj_sifre_roba()
local _tmp, _kod, _naz, _vpc, _a_polja

test_var("ok", .f.)
test_var("rec_roba_t1", 0)
test_var("rec_roba_t2", 0)

O_ROBA
_kod := PADR("TEST1", LEN(id))
_naz := "Naziv Test 1"
_vpc := "1"

_a_polja := {_kod, "<ENTER>2",  _naz, "<ENTER>", "kom", "<ENTER>2", _vpc, "<ENTER>11", "PDV17", "<PGDN>2"}


test_procedure_with_keystrokes({|| P_Roba()}, key_test_dodaj_id_u_sifarnik(_a_polja))

COUNT FOR (ID == _kod ) TO _tmp
test_var("rec_roba_t1", _tmp)


_kod := PADR("TEST2", LEN(id))
_naz := "Naziv Test 2"
_vpc := "2"

_a_polja := {_kod, "<ENTER>2",  _naz, "<ENTER>", "kg", "<ENTER>2", _vpc, "<ENTER>11", "PDV17", "<ENTER>", "<PGDN>2"}

test_procedure_with_keystrokes({|| P_Roba()}, key_test_dodaj_id_u_sifarnik(_a_polja))

COUNT FOR (ID == _kod ) TO _tmp
test_var("rec_roba_t2", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("rec_roba_t1") == 1 .and. test_var("rec_roba_t2") == 1,  .t.)

return


// rec_99 treba da sadrzi broj zapisa
COUNT FOR (ID == _kod ) TO _tmp
// setuj test var rec_99 sa _tmp 
test_var("rec_part_99", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("rec_part_99") == 1,  .t.)

return


// -------------------------------------------------
// -------------------------------------------------
static function key_test_dodaj_id_u_sifarnik(a_polja)
local _ret := hb_hash()
local _kod, _i, _j, _num
local _keys
local _a_new := { "WID" }
local _vars 

to_keystrokes(a_polja, @_a_new)

// id je uvijek prvo polje sifarnika
_kod := a_polja[1]


_keys := { ;
   { "DBEDIT", K_CTRL_PGUP, K_HOME, K_CTRL_F}, ;  // trazi
   { "CLOC", _kod, K_ENTER, K_ENTER }, ; // lociraj se na cLoc GET (u ctrl+F) pa ukucaj 99 i udari 2 x ENTER 
   { "DBEDIT", {|| log_write("nakon c-F tbl:" + ALIAS() + " id: " + field->id + " trazim: " + _kod, 3), delete_if_found_id(_kod) }} ,;
   { "DBEDIT", K_CTRL_PGUP, K_HOME, K_CTRL_N } ,;     // kada se vratis u tabelu dodaj novi zapis
   _a_new, ;     // unesi novi zapis
   { "DBEDIT", K_CTRL_PGUP, K_CTRL_F, K_CTRL_F }, ;  // idi na vrh tabele
   { "CLOC",  _kod, K_ENTER, K_ENTER }, ;  // ponovi trazenje 99
   { "DBEDIT", {|| ok_if_found_id(_kod)} },;
   { "DBEDIT", K_ESC } ;   // izadji sa ESC iz tabele
}

_ret["keys"] := _keys
return _ret


// --------------------------------------------------------
// izbrisi stavku u sifarniku ako vec postoji
// --------------------------------------------------------
static function delete_if_found_id(kod)

if field->id == kod
      // ako nadjes 99 zapis brisi ga
      delete_rec_server_and_dbf(ALIAS(), nil, 1, "FULL")
      log_write("izbrisao " + kod +  " zapis", 3)
else
      log_write("nema " + kod + " sifre " + kod, 3) 
endif

return .t.

// --------------------------------------------------------
// ako kod postoji, onda je test var ok = .t.
// --------------------------------------------------------
static function ok_if_found_id(kod)

if field->id == kod 
  test_var("ok", .t.)
else
  test_var("ok", .f.)
endif

return .t.


