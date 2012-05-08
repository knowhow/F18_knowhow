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


#include "rnal.ch"

// picture iznos
static gPIC_VAL
// picture dimenzije
static gPIC_DIM
// picture kolicina
static gPIC_QTTY


// -----------------------------------------
// set parametara pri pokretanju modula
// -----------------------------------------
function rnal_set_params()

read_fi_params()
read_zf_params()
read_doc_params()
read_ex_params()
read_ost_params()
read_elat_params()

return


// --------------------------------------
// parametri zaokruzenja
// --------------------------------------
function ed_zf_params()
local cDimPict := "99999.99"

gPIC_VAL:= PADR(gPIC_VAL, 20)
gPIC_DIM:= PADR(gPIC_DIM, 20)
gPIC_QTTY:= PADR(gPIC_QTTY, 20)

nX:=1
Box(, 15, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "1. Prikazi ***"
nX ++

@ m_x + nX, m_y+2 SAY PADL(" kolicina ", 30)   GET gPIC_QTTY
nX ++

@ m_x + nX, m_y+2 SAY PADL(" dimenzija ", 30)   GET gPIC_DIM
nX ++

@ m_x + nX, m_y+2 SAY PADL(" iznos ", 30)   GET gPIC_VAL


read

BoxC()

gPIC_QTTY := ALLTRIM(gPIC_QTTY)
gPIC_DIM := ALLTRIM(gPIC_DIM)
gPIC_VAL := ALLTRIM(gPIC_VAL)

if lastkey()<>K_ESC
	write_zf_params()
endif

return


// --------------------------------------
// parametri firme
// --------------------------------------
function ed_fi_params()
local nLeft := 35

nX:=1
Box(, 20, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "1. Opci podaci ***"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Puni naziv firme:", nLeft) GET gFNaziv PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Adresa firme:", nLeft) GET gFAdresa PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Id broj:", nLeft) GET gFIdBroj

nX += 2

@ m_x + nX, m_y+2 SAY "2. Dodatni podaci ***"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Telefoni:", nLeft) GET gFTelefon PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("email/web:", nLeft) GET gFEmail PICT "@S30"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Banka 1:", nLeft) GET gFBanka1 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 2:", nLeft) GET gFBanka2 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 3:", nLeft) GET gFBanka3 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 4:", nLeft) GET gFBanka4 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 5:", nLeft) GET gFBanka5 PICT "@S30"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Dodatni red 1:", nLeft) GET gFPrRed1 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Dodatni red 2:", nLeft) GET gFPrRed2 PICT "@S30"


read

BoxC()

if lastkey()<>K_ESC
	write_fi_params()
endif

return



// --------------------------------------
// parametri exporta
// --------------------------------------
function ed_ex_params()
local nX := 1
local nLeft := 40

Box(, 20, 70)

set cursor on

@ m_x + nX, m_y + 2 SAY PADL("****** export GPS.opt Lisec parametri", nLeft)

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Izlazni direktorij:", 20) GET gExpOutDir PICT "@S45"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Uvijek overwrite export fajla (D/N)?", 45) GET gExpAlwOvWrite PICT "@!" VALID gExpAlwOvWrite $ "DN"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Dodaj (mm) na bruseno staklo:", 45) GET gAddToDim PICT "9999.99" 

read

BoxC()

if lastkey()<>K_ESC
	write_ex_params()
endif

return



// --------------------------------------
// parametri izgleda dokumenta
// --------------------------------------
function ed_doc_params()

nX:=2
Box(, 10, 70)

set cursor on

@ m_x + nX, m_y+2 SAY PADL("Dodati redovi po listu:",35) GET gDd_redovi PICT "99"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Lijeva margina:",35) GET gDl_margina PICT "99"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Gornja margina:",35) GET gDg_margina PICT "99"

read

BoxC()

if lastkey()<>K_ESC
	write_doc_params()
endif

return



// --------------------------------------
// parametri elementi atributi
// --------------------------------------
function ed_elat_params()

nX:=1

Box(, 18, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "***** Parametri atributa i elemenata"

nX += 2

@ m_x + nX, m_y+2 SAY "oznaka (staklo)         :" GET gGlassJoker VALID !EMPTY(gGlassJoker)

nX ++

@ m_x + nX, m_y+2 SAY "oznaka (distancer)      :" GET gFrameJoker VALID !EMPTY(gFrameJoker)

nX ++

@ m_x + nX, m_y+2 SAY "oznaka (debljina stakla):" GET gDefGlTick VALID !EMPTY(gDefGlTick)

nX ++

@ m_x + nX, m_y+2 SAY "oznaka (tip stakla)     :" GET gDefGlType VALID !EMPTY(gDefGlType)

nX += 2

@ m_x + nX, m_y+2 SAY "***** Specificni parametri operacija"

nX += 2

@ m_x + nX, m_y+2 SAY "oznaka (brusenje)     :" GET gAopBrusenje VALID !EMPTY(gAopBrusenje)

nX ++

@ m_x + nX, m_y+2 SAY "oznaka (kaljenje)     :" GET gAopKaljenje VALID !EMPTY(gAopKaljenje)

nX += 2

@ m_x + nX, m_y+2 SAY "***** Specificni parametri za pojedinu vrstu stakla"

nX += 2

@ m_x + nX, m_y+2 SAY "oznaka stakla / LAMI:" GET gGlLamiJoker VALID !EMPTY(gGlLamiJoker)

read

BoxC()

if lastkey()<>K_ESC
	write_elat_params()
endif

return




// --------------------------------------
// parametri ostali
// --------------------------------------
function ed_ost_params()
local nLeft := 50
local nX := 1

Box(, 15, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "1. Pretraga artikla *******"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Resetuj vrijednosti u tabeli pretrage (0/1)", nLeft) GET gFnd_reset PICT "9"

nX += 1

@ m_x + nX, m_y+2 SAY PADL("Timeout kod azuriranja dokumenata", nLeft) GET gInsTimeOut PICT "99999"


nX += 2

@ m_x + nX, m_y+2 SAY "2. Limiti unosa *******"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("maksimalna sirina (mm)", nLeft - 10) GET gMaxWidth PICT "99999.99"

nX += 1

@ m_x + nX, m_y+2 SAY PADL("maksimalna visina (mm)", nLeft - 10) GET gMaxHeigh PICT "99999.99"

nX += 2

@ m_x + nX, m_y+2 SAY "3. Default vrijednosti ********"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Nadmorska visina (nv.m)", nLeft - 10) GET gDefNVM PICT "99999.99"

nX += 1

@ m_x + nX, m_y+2 SAY PADL("Koristiti GN zaokruzenja ?", nLeft - 20) GET gGnUse ;
	PICT "@!" VALID gGnUse $ "DN"
nX += 1

@ m_x + nX, m_y+2 SAY PADL("GN zaok. (min)", nLeft - 20) GET gGnMin ;
	PICT "99999"
@ m_x + nX, col()+1 SAY "(max)" GET gGnMax PICT "99999"
@ m_x + nX, col()+1 SAY "korak" GET gGnStep PICT "9999"

read

BoxC()

if lastkey()<>K_ESC
	write_ost_params()
endif

return



// --------------------------------------
// citaj paramtre firme
// --------------------------------------
function read_fi_params()

gFNaziv := fetch_metric( "org_naziv", nil, gFNaziv )
gFAdresa := fetch_metric( "org_adresa", nil, gFAdresa )
gFIdBroj := fetch_metric( "org_pdv_broj", nil, gFIdBroj )
    
gFBanka1 := fetch_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
gFBanka2 := fetch_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
gFBanka3 := fetch_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
gFBanka4 := fetch_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
gFBanka5 := fetch_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
    
gFTelefon := fetch_metric( "fakt_zagl_telefon", nil, gFTelefon )
gFEmail := set_metric( "fakt_zagl_email", nil, gFEmail )

gFPrRed1 := fetch_metric( "fakt_zagl_dtxt_1", nil, gFPrRed1 )
gFPrRed2 := fetch_metric( "fakt_zagl_dtxt_2", nil, gFPrRed2 )

return


// --------------------------------
// upisi parametre firme
// --------------------------------
function write_fi_params()

set_metric( "org_naziv", nil, gFNaziv )
set_metric( "org_adresa", nil, gFAdresa )
set_metric( "org_pdv_broj", nil, gFIdBroj )
    
set_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
set_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
set_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
set_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
set_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
    
set_metric( "fakt_zagl_telefon", nil, gFTelefon )
set_metric( "fakt_zagl_email", nil, gFEmail )

set_metric( "fakt_zagl_dtxt_1", nil, gFPrRed1 )
set_metric( "fakt_zagl_dtxt_2", nil, gFPrRed2 )

return


// --------------------------------------
// citaj paramtre izgleda dokumenta
// --------------------------------------
function read_doc_params()
gDg_margina := fetch_metric( "rnal_stampa_desna_margina", nil, gDg_margina )
gDl_margina := fetch_metric( "rnal_stampa_lijeva_margina", nil, gDl_margina )
gDd_redovi := fetch_metric( "rnal_stampa_dodatni_redovi", nil, gDd_redovi )
return


// ----------------------------------
// upisi parametre izgleda dokumenta
// ----------------------------------
function write_doc_params()
set_metric( "rnal_stampa_desna_margina", nil, gDg_margina )
set_metric( "rnal_stampa_lijeva_margina", nil, gDl_margina )
set_metric( "rnal_stampa_dodatni_redovi", nil, gDd_redovi )
return




// --------------------------------------
// citaj paramtre elemenata i atributa
// --------------------------------------
function read_elat_params()

gDefGlType := PADR("<GL_TYPE>", 30)
gDefGlTick := PADR("<GL_TICK>", 30)

gGlassJoker := PADR( "G" , 20 )
gFrameJoker := PADR( "F" , 20 )

gGlLamiJoker := PADR( "LA", 20 )

gAopKaljenje := PADR( "<A_KA>", 20 )
gAopBrusenje := PADR( "<A_BR>", 20 )

gGlassJoker := fetch_metric( "rnal_staklo_joker", nil, gGlassJoker )
gFrameJoker := fetch_metric( "rnal_dist_joker", nil, gFrameJoker )
gGlLamiJoker := fetch_metric( "rnal_lami_staklo_joker", nil, gGlLamiJoker )

gAopKaljenje := fetch_metric( "rnal_aop_kaljenje", nil, gAopKaljenje )
gAopBrusenje := fetch_metric( "rnal_aop_brusenje", nil, gAopBrusenje )

gDefGlType := fetch_metric( "rnal_def_gl_type", nil, gDefGlType )
gDefGlTick := fetch_metric( "rnal_def_gl_tick", nil, gDefGlTick )

return



// ---------------------------------------
// upisi parametre elemenata i atributa
// ---------------------------------------
function write_elat_params()

set_metric( "rnal_staklo_joker", nil, gGlassJoker )
set_metric( "rnal_dist_joker", nil, gFrameJoker )
set_metric( "rnal_lami_staklo_joker", nil, gGlLamiJoker )

set_metric( "rnal_aop_kaljenje", nil, gAopKaljenje )
set_metric( "rnal_aop_brusenje", nil, gAopBrusenje )

set_metric( "rnal_def_gl_type", nil, gDefGlType )
set_metric( "rnal_def_gl_tick", nil, gDefGlTick )

return




// --------------------------------------
// citaj paramtre izgleda dokumenta
// --------------------------------------
function read_ex_params()

gExpOutDir := fetch_metric( "rnal_export_lokacija", my_user(), gExpOutDir )
gExpAlwOvWrite := fetch_metric( "rnal_export_overwrite_file", my_user(), gExpAlwOvWrite )
gAddToDim := fetch_metric( "rnal_dodatak_na_dimenzije", nil, gAddToDim )

return



// ----------------------------------
// upisi parametre exporta
// ----------------------------------
function write_ex_params()

set_metric( "rnal_export_lokacija", my_user(), gExpOutDir )
set_metric( "rnal_export_overwrite_file", my_user(), gExpAlwOvWrite )
set_metric( "rnal_dodatak_na_dimenzije", nil, gAddToDim )

return



// --------------------------------------
// citaj parametre ostale
// --------------------------------------
function read_ost_params()

gFnd_reset := fetch_metric( "rnal_reset_kod_pretrage", my_user(), gFnd_reset )

gMaxWidth := fetch_metric( "rnal_maksimalna_sirina_stakla", nil, gMaxWidth )
gMaxHeigh := fetch_metric("rnal_maksimalna_visina_stakla", nil, gMaxHeigh )

gDefNVM := fetch_metric("rnal_default_nadmorska_visina", nil, gDefNVM )

gInsTimeOut := fetch_metric("rnal_ins_timeout", nil, gInsTimeOut )

gGnUse := fetch_metric( "rnal_gn_tabela", nil, gGnUse )
gGnMin := fetch_metric( "rnal_gn_min", nil, gGnMin )
gGnMax := fetch_metric( "rnal_gn_max", nil, gGnMax )
gGnStep := fetch_metric("rnal_gn_step", nil, gGnStep )

return


// ----------------------------------
// upisi parametre ostalo
// ----------------------------------
function write_ost_params()

set_metric( "rnal_reset_kod_pretrage", my_user(), gFnd_reset )
set_metric( "rnal_maksimalna_sirina_stakla", nil, gMaxWidth )
set_metric("rnal_maksimalna_visina_stakla", nil, gMaxHeigh )
set_metric("rnal_default_nadmorska_visina", nil, gDefNVM )
set_metric("rnal_ins_timeout", nil, gInsTimeOut )
set_metric( "rnal_gn_tabela", nil, gGnUse )
set_metric( "rnal_gn_min", nil, gGnMin )
set_metric( "rnal_gn_max", nil, gGnMax )
set_metric("rnal_gn_step", nil, gGnStep )

return


// --------------------------------------
// citaj podatke zaokruzenja...
// --------------------------------------
function read_zf_params()

gPIC_VAL := "9999.99"
gPIC_DIM := "9999.99"
gPIC_QTTY := "99999"

gPic_val := fetch_metric("rnal_pict_val", nil, gPIC_VAL)
gPic_dim := fetch_metric("rnal_pict_dim", nil, gPIC_DIM)
gPic_qtty := fetch_metric("rnal_pict_qtty", nil, gPIC_QTTY)

return


// ------------------------------------
// upisi paramtre zaokruzenja
// ------------------------------------
function write_zf_params()

set_metric("rnal_pict_val", nil, gPIC_VAL)
set_metric("rnal_pict_dim", nil, gPIC_DIM)
set_metric("rnal_pict_qtty", nil, gPIC_QTTY)

return



// maximalna dimenzija
function max_heigh()
return gMaxHeigh

// maximalna dimenzija
function max_width()
return gMaxWidth



// -------------------------------
// -------------------------------
function PIC_VAL(xVal)
if xVal <> nil
	gPIC_VAL := xVal
endif
return gPIC_VAL

// -------------------------------
// -------------------------------
function PIC_DIM(xVal)
if xVal <> nil
	gPIC_DIM := xVal
endif
return gPIC_DIM


// -------------------------------
// -------------------------------
function PIC_QTTY(xVal)
if xVal <> nil
	gPIC_QTTY := xVal
endif
return gPIC_QTTY


