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


#include "fmk.ch"


function set_roba_global_vars()

public gUVarPP
public glProvNazRobe := .f.
public gRobaBlock
public gPicCDem
public PicDem
public gPicProc
public gPicDEM
public gPickol
public gFPicCDem
public gFPicDem
public gFPicKol

public glAutoFillBK
public gDuzSifIni

public glPoreziLegacy
public glUgost
public gUgostVarijanta

// R - Obracun porez na RUC
// D - starija varijanta ???
// N - obicno robno knjigovodstvo

glPoreziLegacy := .t.
glUgost := .f.

//RMarza_DLimit - osnovica realizovana marza ili donji limit
//MpcSaPor - Maloprodajna cijena sa porezom
gUgostVarijanta := UPPER(IzFmkIni("UGOSTITELJSTVO","Varijanta","Rmarza_DLimit", KUMPATH))

gUVarPP := IzFMKINI("POREZI","PPUgostKaoPPU","N", KUMPATH)

glProvNazRobe := fetch_metric( "sifrarnik_roba_provjera_istih_naziva", nil, glProvNazRobe ) 

glAutoFillBK := (IzFmkIni("ROBA","AutoFillBarKod","N",SIFPATH)=="D")

gRobaBlock := nil

gPicCDEM := "999999.999"
gPicProc := "999999.99%"
gPicDEM := "9999999.99"
gPickol := "999999.999"
gFPicCDem := "0"
gFPicDem := "0"
gFPicKol := "0"
gDuzSifINI := "10"

return


