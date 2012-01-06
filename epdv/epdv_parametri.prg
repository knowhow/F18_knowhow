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


#include "epdv.ch"

// zaokruzenje iznos
static gZAO_IZN
// zaokruzenje cijena
static gZAO_CIJ
// zaokruzenje cijena
static gZAO_PDV

// picture iznos
static gPIC_IZN

// picture cijena
static gPIC_CIJ

// ulazni pdv koji se ne moze odbiti
// da li ulazi u statistiku krajnje potrosnje
// ako ulazi onda se stavlja polje u koje se dodaje
// " " - ne dodajes u statistiku
// "1" - federacija
// "2" - sprski republikanci 
// "3" - brcko district do las vegasa
static gUlPdvKp := "1"


// -----------------------------------
// -----------------------------------
function epdv_parametri()
ed_g_params()
return


// -------------------------------------
// set parametre pri pokretanju modula
// ------------------------------------
function epdv_set_params()

// procitaj globalne - kparams
read_epdv_gl_params()

// napuni sifrarnik tarifa
epdv_set_sif_tarifa()

// napuni sifk radi unosa partnera - rejon
epdv_set_sif_partneri()

return


// --------------------------------------
// --------------------------------------
function ed_g_params()

gPIC_IZN:= PADR(gPIC_IZN, 20)
gPIC_CIJ:= PADR(gPIC_CIJ, 20)

gUlPdvKp:= PADR(gUlPdvKp, 1)

nX:=1
Box(, 20, 70)

 set cursor on

 @ m_x + nX, m_y+2 SAY "1. Osnovni podaci ***"

 nX++
 
 @ m_x + nX , m_y+2 SAY "Firma:" GET gFirma
 @ m_x + nX , col() + 1 SAY "Naziv:" GET gNFirma

 nX ++

 @ m_x + nX, m_y+2 SAY "2. Zaokruzenje ***"
 nX++
 
 @ m_x + nX , m_y+2 SAY PADL("iznos ", 30)   GET gZAO_IZN PICT "9"
 nX++
 
 @ m_x + nX, m_y+2 SAY PADL("cijena ", 30)   GET gZAO_CIJ PICT "9"
 nX++
 
 @ m_x + nX, m_y+2 SAY PADL(" podaci na pdv prijavi ", 30)   GET gZAO_PDV PICT "9"
 nX ++

 @ m_x + nX, m_y+2 SAY "3. Prikaz ***"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" iznos ", 30)   GET gPIC_IZN
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" cijena ", 30)   GET gPIC_CIJ
 nX ++

 @ m_x + nX, m_y+2 SAY "4. Obracun ***"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" ul. pdv kr.potr-stat fed-1, rs-2, bd-3", 55)   GET gUlPdvKp ;
	VALID gUlPdvKp $ " 123"
 nX ++
 
 @ m_x + nX, m_y+2 SAY "5. Ostalo ***"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" konta dobavljaci:", 30) GET gL_kto_dob ;
 	PICT "@S30"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL("      konta kupci:", 30) GET gL_kto_kup ;
 	PICT "@S30"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL("ulazni pdv:", 30) GET gKt_updv ;
 	PICT "@S30"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL("izlazni pdv:", 30) GET gKt_ipdv ;
 	PICT "@S30"

 READ

BoxC()

gPIC_IZN := ALLTRIM(gPIC_IZN)
gPIC_CIJ := ALLTRIM(gPIC_CIJ)

if lastkey()<>K_ESC
	write_g_params()
endif

return


// --------------------------------------
// --------------------------------------
function read_epdv_gl_params()
gZAO_IZN := 2
gZAO_CIJ := 3
gZAO_PDV := 0
gPIC_IZN := "9999999.99"
gPIC_CIJ := "9999999.99"
gUlPdvKp := "1"
gFirma := SPACE(2)
gNFirma := SPACE(20)

gZAO_IZN := fetch_metric("epdv_zaokruzenje_iznosa", nil, gZAO_IZN)
gZAO_CIJ := fetch_metric("epdv_zaokruzenje_cijene", nil, gZAO_CIJ)
gZAO_PDV := fetch_metric("epdv_zaokruzenje_pdv", nil, gZAO_PDV)

gPIC_IZN := fetch_metric("epdv_picture_iznos", nil, gPIC_IZN)
gPIC_CIJ := fetch_metric("epdv_picture_cijena", nil, gPIC_CIJ)

gUlPDVKp := fetch_metric("epdv_ulazni_pdv_krajnja_potrosnja", nil, gUlPdvKp)

gL_kto_dob := fetch_metric("epdv_lista_konta_dobavljaca", nil, gL_kto_dob)
gL_kto_kup := fetch_metric("epdv_lista_konta_kupaca", nil, gL_kto_kup)
gkt_updv := fetch_metric("epdv_konto_ulazni_pdv", nil, gkt_updv)
gkt_ipdv := fetch_metric("epdv_konto_izlazni_pdv", nil, gkt_ipdv)

gNFirma := fetch_metric("epdv_firma_naziv", nil, gNFirma)
gFirma := fetch_metric("epdv_firma", nil, gFirma)

return


// ---------------------------
// ---------------------------
function write_g_params()

set_metric("epdv_zaokruzenje_iznosa", nil, gZAO_IZN)
set_metric("epdv_zaokruzenje_cijene", nil, gZAO_CIJ)
set_metric("epdv_zaokruzenje_pdv", nil, gZAO_PDV)

set_metric("epdv_picture_iznos", nil, gPIC_IZN)
set_metric("epdv_picture_cijena", nil, gPIC_CIJ)

set_metric("epdv_ulazni_pdv_krajnja_potrosnja", nil, gUlPdvKp)

set_metric("epdv_lista_konta_dobavljaca", nil, gL_kto_dob)
set_metric("epdv_lista_konta_kupaca", nil, gL_kto_kup)
set_metric("epdv_konto_ulazni_pdv", nil, gkt_updv)
set_metric("epdv_konto_izlazni_pdv", nil, gkt_ipdv)

set_metric("epdv_firma", nil, gFirma)
set_metric("epdv_firma_naziv", nil, gNFirma)

return


// ---------------------------------------------------------------
// ---------------------------------------------------------------
function read_pdv_pars(dPotDatum, cPotMjesto, cPotOb, cPdvPovrat)

dPotDatum := fetch_metric("epdv_prijava_datum", nil, dPotDatum)
dPotMjesto := fetch_metric("epdv_prijava_mjesto", nil, cPotMjesto)
cPotOb := fetch_metric("epdv_prijava_obveznik", nil, cPotOb)
cPdvPovrat := fetch_metric("epdv_prijava_povrat", nil, cPdvPovrat)

return

// ---------------------------------------------------------------
// ---------------------------------------------------------------
function save_pdv_pars(dPotDatum, cPotMjesto, cPotOb, cPdvPovrat)

set_metric("epdv_prijava_datum", nil, dPotDatum)
set_metric("epdv_prijava_mjesto", nil, cPotMjesto)
set_metric("epdv_prijava_obveznik", nil, cPotOb)
set_metric("epdv_prijava_povrat", nil, cPdvPovrat)

return

// SET - GET sekcija  za PIC i ZAO vrijednostai

// -------------------------------
// -------------------------------
function ZAO_IZN(xVal)

if xVal <> nil
	gZAO_IZN := xVal
endif

return gZAO_IZN

// -------------------------------
// -------------------------------
function ZAO_CIJ(xVal)

if xVal <> nil
	gZAO_CIJ := xVal
endif

return gZAO_CIJ

// -------------------------------
// -------------------------------
function ZAO_PDV(xVal)

if xVal <> nil
	gZAO_PDV := xVal
endif

return gZAO_PDV


// -------------------------------
// -------------------------------
function PIC_IZN(xVal)
if xVal <> nil
	gPIC_IZN := xVal
endif
return gPIC_IZN

// -------------------------------
// -------------------------------
function PIC_CIJ(xVal)
if xVal <> nil
	gPIC_CIJ := xVal
endif
return gPIC_CIJ


// -------------------------------
// -------------------------------
function gUlPdvKp(xVal)
if xVal <> nil
	gUlPdvKp := xVal
endif
return gUlPdvKp


