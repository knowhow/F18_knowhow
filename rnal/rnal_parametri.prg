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
// parametri zaokruzenja, formata prikaza
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


nX += 2

@ m_x + nX, m_y + 2 SAY PADL("****** export FMK parametri", nLeft)

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("FAKT kumulativ:", 20) GET gFaKumDir PICT "@S45"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("FAKT privatni:", 20) GET gFaPrivDir PICT "@S45"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("POS kumulativ:", 20) GET gPoKumDir PICT "@S45"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("POS privatni:", 20) GET gPoPrivDir PICT "@S45"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("****** ostali parametri", nLeft)

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

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("F1", @gFNaziv)
RPar("F2", @gFAdresa)
RPar("F3", @gFIdBroj)
RPar("F4", @gFTelefon)
RPar("F5", @gFEmail)
RPar("F8", @gFPrRed1)
RPar("F9", @gFPrRed2)
RPar("B1", @gFBanka1)
RPar("B2", @gFBanka2)
RPar("B3", @gFBanka3)
RPar("B4", @gFBanka4)
RPar("B5", @gFBanka5)

close
return


// --------------------------------
// upisi parametre firme
// --------------------------------
function write_fi_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("F1", gFNaziv)
WPar("F2", gFAdresa)
WPar("F3", gFIdBroj)
WPar("F4", gFTelefon)
WPar("F5", gFEmail)
WPar("F8", gFPrRed1)
WPar("F9", gFPrRed2)
WPar("B1", gFBanka1)
WPar("B2", gFBanka2)
WPar("B3", gFBanka3)
WPar("B4", gFBanka4)
WPar("B5", gFBanka5)

close

return


// --------------------------------------
// citaj paramtre izgleda dokumenta
// --------------------------------------
function read_doc_params()

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("D1", @gDg_margina)
RPar("D2", @gDl_margina)
RPar("D3", @gDd_redovi)

close
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

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="7"
private cHistory:=" "
private aHistory:={}

RPar("e1", @gGlassJoker)
RPar("e2", @gFrameJoker)

RPar("g1", @gGlLamiJoker)

RPar("a1", @gAopKaljenje)
RPar("a2", @gAopBrusenje)

RPar("P7", @gDefGlType)
RPar("P8", @gDefGlTick)


close
return


// --------------------------------------
// citaj paramtre izgleda dokumenta
// --------------------------------------
function read_ex_params()

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="E"
private cHistory:=" "
private aHistory:={}

RPar("od", @gExpOutDir)
RPar("ao", @gExpAlwOvWrite)
RPar("ad", @gAddToDim)
RPar("pd", @gFaPrivDir)
RPar("kd", @gFaKumDir)
RPar("tp", @gPoPrivDir)
RPar("tk", @gPoKumDir)

close
return



// --------------------------------------
// citaj parametre ostale
// --------------------------------------
function read_ost_params()

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("a1", @gFnd_reset )

RPar("a3", @gMaxWidth )
RPar("a4", @gMaxHeigh )

RPar("a5", @gDefNVM)

RPar("to", @gInsTimeOut)

RPar("g1", @gGnMin)
RPar("g2", @gGnMax)
RPar("g3", @gGnStep)

close
return


// ----------------------------------
// upisi parametre izgleda dokumenta
// ----------------------------------
function write_doc_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("D1", gDg_margina)
WPar("D2", gDl_margina)
WPar("D3", gDd_redovi)

close

return


// ---------------------------------------
// upisi parametre elemenata i atributa
// ---------------------------------------
function write_elat_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="7"
private cHistory:=" "
private aHistory:={}

WPar("e1", gGlassJoker)
WPar("e2", gFrameJoker)

WPar("g1", gGlLamiJoker)

WPar("a1", gAopKaljenje)
WPar("a2", gAopBrusenje)

WPar("P7", gDefGlType)
WPar("P8", gDefGlTick)

close

return



// ----------------------------------
// upisi parametre exporta
// ----------------------------------
function write_ex_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="E"
private cHistory:=" "
private aHistory:={}

WPar("od", gExpOutDir)
WPar("ao", gExpAlwOvWrite)
WPar("ad", gAddToDim)
WPar("pd", gFaPrivDir)
WPar("kd", gFaKumDir)
WPar("tp", gPoPrivDir)
WPar("tk", gPoKumDir)

close

return



// ----------------------------------
// upisi parametre ostalo
// ----------------------------------
function write_ost_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("a1", gFnd_reset )

WPar("a3", gMaxWidth )
WPar("a4", gMaxHeigh )

WPar("a5", gDefNVM )

WPar("to", gInsTimeOut )

WPar("g1", gGnMin )
WPar("g2", gGnMax )
WPar("g3", gGnStep )

close

return


// --------------------------------------
// citaj podatke zaokruzenja...
// --------------------------------------
function read_zf_params()

gPIC_VAL := "9999.99"
gPIC_DIM := "9999.99"
gPIC_QTTY := "99999"

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("P1", @gPIC_VAL)
RPar("P2", @gPIC_DIM)
RPar("P3", @gPIC_QTTY)

close
return


// ------------------------------------
// upisi paramtre zaokruzenja
// ------------------------------------
function write_zf_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("P1", gPIC_VAL)
WPar("P2", gPIC_DIM)
WPar("P3", gPIC_QTTY)

close

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


