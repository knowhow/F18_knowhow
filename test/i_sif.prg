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

#include "fmk.ch"
#include "f18_ver.ch"

static __keystrokes := {}
static __test_vars

// jedan poziv test_keystroke treba samo jednu sekvencu poslati 
static __keystroke_step 


// --------------------------------------
// --------------------------------------
static function test_var(key, value)

if __test_vars == NIL
 __test_vars := hb_hash()
endif

if value != NIL
  __test_vars[key] := value
endif

return __test_vars[key]



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





// --------------------------------------------
// --------------------------------------------
function test_procedure_with_keystrokes( b_proc, h_keystrokes)
local _task, _var_key, _key_test, _key_tests := {}
local _tmp
local _i := 1
local _cnt := 0


// key sekvenca koju treba izvrsiti
AADD(_key_tests, h_keystrokes)

for each _key_test IN _key_tests 

   __keystrokes := _key_test["keys"]
   __keystroke_step := 1

   CLEAR TYPEAHEAD
   SET CONFIRM ON
   _task := HB_IDLEADD( {|| SetPos(MAXROW()-2, MAXCOL()-10),  DispOut(_cnt++), test_keystrokes()} )

   EVAL(b_proc)

   log_write("uklanjam idleadd task", 3)
   HB_IDLEDEL(_task)

   CLEAR TYPEAHEAD

  _i++
next


return


 
// -------------------------------------------------
// -------------------------------------------------
static function key_test_dodaj_id_u_sifarnik(a_polja)
local _ret := hb_hash()
local _kod, _i, _j, _num
local _keys
local _a_new := { "WID" }
local _vars 


// id je uvijek prvo polje sifarnika
_kod := a_polja[1]

AADD(_a_new, _kod)

for _i := 2 to LEN(a_polja)
   DO CASE
     CASE LEFT(a_polja[_i], 7) == "<ENTER>"
        // <ENTER5> => 5 x enter
        _num := SUBSTR(a_polja[_i], 8)
        if _num == ""
           _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(_a_new, K_ENTER)
        next
 
     CASE LEFT(a_polja[_i], 6) == "<PGDN>"
        _num := SUBSTR(a_polja[_i], 7)
        // <PGDN> => 1 x enter
        if _num == ""
             _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(_a_new, K_PGDN)
        next 

     OTHERWISE
       AADD(_a_new, a_polja[_i]) 
  END CASE
next

_keys := { ;
   { "DBEDIT", K_CTRL_PGUP, K_HOME, K_CTRL_F}, ;  // trazi
   { "CLOC", _kod, K_ENTER, K_ENTER }, ; // lociraj se na cLoc GET (u ctrl+F) pa ukucaj 99 i udari 2 x ENTER 
   { "DBEDIT", {|| log_write("step " + ALLTRIM(STR(__keystroke_step)) + ", nakon c-F tbl:" + ALIAS() + " id: " + field->id + " trazim: " + _kod, 3), delete_if_found_id(_kod) }} ,;
   { "DBEDIT", K_CTRL_PGUP, K_HOME, K_CTRL_N } ,;     // kada se vratis u tabelu dodaj novi zapis
   _a_new, ;     // unesi novi zapis
   { "DBEDIT", K_CTRL_PGUP, K_CTRL_F, K_CTRL_F }, ;  // idi na vrh tabele
   { "CLOC",  _kod, K_ENTER, K_ENTER }, ;  // ponovi trazenje 99
   { "DBEDIT", {|| ok_if_found_id(_kod)} },;
   { "DBEDIT", K_ESC } ;   // izadji sa ESC iz tabele
}



_vars := hb_hash()
// od varijable ok ocekuje se ova vrijednost na kraju price
_vars["ok"] := .t.

_ret["keys"] := _keys
_ret["vars"] := _vars
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


// --------------------------------------
// --------------------------------------
function test_keystrokes()
local _var_name
local _i, _j, _expected_var_name
local _buffer

log_write("START test_keystrokes: " + ALLTRIM(STR(__keystroke_step)), 3)

for _i := 1 to LEN(__keystrokes)

    // ovo ne kontam
    if (__keystroke_step) <> _i
         loop
    endif 
    
    _expected_var_name := __keystrokes[_i, 1]

    if VALTYPE(_expected_var_name) == "B"
             // npr. { {|| !eof()},  {|| delete_with_rlock()},  {|| log_write("ne treba nista brisati", 2)} }
          
             // izvrsi trazeni izraz
             _ret := EVAL(_expected_var_name)
             if _ret 
                _bl2 := __keystrokes[_i, 2]
            else

                _bl2 := __keystrokes[_i, 3]
             endif

             if (VALTYPE(_bl2) == "B")
                     EVAL(_bl2)

             elseif (VALTYPE(_bl2) == "A")

                    // moze biti array tipki
                    _buffer := {}
                    for _j := 1 TO LEN(_bl2)
                        AADD(_buffer, _bl2[_j])
                    next
                    put_to_keyboard_buffer(_buffer)

              else
                  Alert(" bl 2 mora biti B ili A")   
              endif
 
           
             __keystroke_step ++
             loop
     endif

     if VALTYPE(_expected_var_name) == "C"

           _expected_var_name := UPPER(_expected_var_name)

           if _expected_var_name == "DBEDIT" .and. PROCNAME(3) == "OBJDBEDIT"
               // nalazimo se u objdbeditu
               // to i zelimo
               log_write("obj_dbedit step: " + pp(_i), 3)
           else  
               _var_name := READVAR()
               log_write("READVAR: " + _var_name + " expected_var_name: " + _expected_var_name, 3)

               if (_var_name != _expected_var_name)
                        // ako tekuca get varijabla nije identicna ocekivanoj, ne salji keytroke
                        loop
               endif
           endif
      endif

     _buffer := {}
     for _j := 2 TO LEN(__keystrokes[_i])
           AADD(_buffer, __keystrokes[_i, _j])
     next
     log_write("test step " + pp(_i) + "buffer " + pp(_buffer), 3 )
     put_to_keyboard_buffer(_buffer)

     // sada idemo na sljedeci korak
     __keystroke_step ++


next


return .t.


static function put_to_keyboard_buffer(buffer)
local _i

for _i := 1 to LEN(buffer)

   if VALTYPE(buffer[_i]) == "C" .or.  VALTYPE(buffer[_i]) == "N"
        HB_KEYPUT(buffer[_i])

   elseif VALTYPE(buffer[_i]) == "B"
        // ako je kodni blok izvrsi ga
        EVAL(buffer[_i])
   else
        Alert("buffer tip: "  + VALTYPE(buffer[_i]) + " ?!")
   endif

next

return .t.
