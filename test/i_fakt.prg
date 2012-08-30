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


function i_fakt()

i_zaglavlje_fakture()
i_povrat_fakture()
i_napravi_fakturu()


// -------------------------------------
// -------------------------------------
function i_zaglavlje_fakture()

return

/// --------------------------------------
/// --------------------------------------
function i_povrat_fakture()
local _tmp, _a_polja, _stavka_dok

test_var("ok", .f.)
test_var("fakt_pov", 0)

_stavka_dok := {"99", "<ENTER>", "10", "<ENTER>", "77777", "<ENTER>"}
test_procedure_with_keystrokes({|| povrat_fakt_dokumenta()},  test_keystrokes_povrat_faktura(_stavka_dok))

close all
O_FAKT
// rec_99 treba da sadrzi broj zapisa
COUNT FOR (IdFirma == "99" .and. IdTipDok == "10" .and. brdok == PADR("77777", 8) ) TO _tmp
// setuj test var rec_99 sa _tmp 
test_var("fakt_pov", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("fakt_pov") == 0,  .t.)
 

return



/// --------------------------------------
/// --------------------------------------
function i_napravi_fakturu()
local _tmp, _a_polja, _stavka_h, _stavka_1, _stavka_2, _stavka_2b

test_var("ok", .f.)
test_var("fakt_77", 0)

_stavka_h := {"99", "<ENTER>2", "31.12.12", "<ENTER>", "77777", "<ENTER>", "999999", "<ENTER>3", "G", "<ENTER>", "KM", "<ENTER>", ;
              "N",  "<ENTER>" } // avansni racun N

_stavka_1 := {"1", "<ENTER>", ;
             "TEST1", "<ENTER>", ;
             "serbr-1","<ENTER>", ;
             "10.00", "<ENTER>", ; // 10 kom
             "1.00",  "<ENTER>", ; // 1 cijena (ovaj je cijena i u sifarniku)
             "<ENTER>2", ;      // rabat, %rabat nista
             "<ESC>", ;          // text opis nista
             "<ENTER>"}

_stavka_2 := { ;
             "2", "<ENTER>",;
             "TEST2", "<ENTER>"}

_stavka_2b:={ ;
             "serbr-2", "<ENTER>", ;
             "20.00", "<ENTER>",   ; // 10 kom
             "2.00",  "<ENTER>",   ; // 1 cijena (ovaj je cijena i u sifarniku)
             "<ENTER>2", ;      // rabat, %rabat nista
             "<ENTER>",  ;
             "<ESC>" }



test_procedure_with_keystrokes({|| fakt_unos_dokumenta()},  test_keystrokes_faktura(_stavka_h, _stavka_1, _stavka_2, _stavka_2b))

close all
O_FAKT
// rec_99 treba da sadrzi broj zapisa
COUNT FOR (IdFirma == "99" .and. IdTipDok == "10" .and. brdok == PADR("77777", 8) ) TO _tmp
// setuj test var rec_99 sa _tmp 
test_var("fakt_99", _tmp)

TEST_LINE( test_var("ok"),  .t.)
TEST_LINE( test_var("fakt_77") == 1,  .t.)

return


// -------------------------------------------------
// -------------------------------------------------
static function test_keystrokes_povrat_faktura(a_polja_dokument)
local _ret := hb_hash()
local _kod, _i, _j, _num
local _keys

// pocinje se od unosa firme, ovo je READVAR()
local _a_new := { "_FIRMA" }

to_keystrokes(a_polja_dokument, @_a_new)

_keys := { ;
   _a_new ,;
   { "#FAKT_POV_DOK", "D", K_ENTER } ,; // povrat Dokumenta
   { "#FAKT_POV_KUM", "D", K_ENTER } ; // vrati iz kumulativa
}


_ret["keys"] := _keys

return _ret


// -------------------------------------------------
// -------------------------------------------------
static function test_keystrokes_faktura(a_polja_stavka_h, a_polja_stavka_1, a_polja_stavka_2, a_polja_stavka_2b)
local _ret := hb_hash()
local _kod, _i, _j, _num
local _keys

// pocinje se od unosa firme, ovo je READVAR()
local _a_new_h := { "_IDFIRMA" }
local _a_new_1 := { "NRBR" }

// druga stavka pocinje od rednog broja
local _a_new_2 := { "NRBR" }
local _a_new_2b := { "_SERBR" }
local _vars 

to_keystrokes(a_polja_stavka_h, @_a_new_h)
to_keystrokes(a_polja_stavka_1, @_a_new_1)
to_keystrokes(a_polja_stavka_2, @_a_new_2)
to_keystrokes(a_polja_stavka_2b, @_a_new_2b)

//AADD(_a_new_1, K_ESC)

_keys := { ;
   {"DBEDIT",  K_CTRL_F9}, ;
   {"CODGOVOR", "D", K_ENTER},;
   {"DBEDIT", K_CTRL_N }, ;
    _a_new_h, ;
    _a_new_1, ;
    _a_new_2, ;
    _a_new_2b, ;
   {"DBEDIT", K_ALT_A} ,;
   {"#FAKT_AZUR", "D", K_ENTER },; 
   {"#ST_FISK_PRN", "N", K_ENTER },;  // azrirati D, fiskalni N
   {"DBEDIT", K_ESC} ;
}

_ret["keys"] := _keys

return _ret


