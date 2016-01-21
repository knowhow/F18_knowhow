/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

/*
   Ostali finansijksi izvjestaji
 */
function fin_izvjestaji_ostali()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. pregled promjena na računu               ")
AADD(opcexe,{|| PrPromRn()})

if (IsRamaGlas())
	AADD(opc,"P. specifikacije za pogonsko knjigovodstvo")
	AADD(opcexe,{|| IzvjPogonK() })
endif

Menu_SC("ost")
return .f.


