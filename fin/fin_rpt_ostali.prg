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

#include "fin.ch"

/*! \file fmk/fin/rpt/1g/ostalo.prg
 *  \brief Ostali izvjestaji
 */

/*! \fn Ostalo()
 *  \brief Menij ostalih izvjestaja
 */
 
function Ostalo()

private Izbor:=1
private opc:={}
private opcexe:={}
//private picBHD:=FormPicL(gPicBHD,16)
//private picDEM:=FormPicL(gPicDEM,12)

AADD(opc,"1. pregled promjena na racunu               ")
AADD(opcexe,{|| PrPromRn()})

if IzFMKIni("FIN","Bilansi_Jerry","N",KUMPATH)=="D"
	lBilansi:=.t.
  	AADD(opc,"2. bilans stanja")
	AADD(opcexe,{|| if (lBilansi,BilansS(),nil)})
  	AADD(opc,"3. bilans uspjeha")
	AADD(opcexe,{|| if (lBilansi,BilansU(),nil)})
else
  	lBilansi:=.f.
  	AADD(opc,"2. ---------------------")
	AADD(opcexe,{|| nil})
  	AADD(opc,"3. ---------------------")
	AADD(opcexe,{|| nil})
endif

if (IsRamaGlas())
	AADD(opc,"4. specifikacije za pogonsko knjigovodstvo")
	AADD(opcexe,{|| IzvjPogonK() })
endif

Menu_SC("ost")
return .f.


