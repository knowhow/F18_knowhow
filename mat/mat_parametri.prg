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


#include "mat.ch"



function m_params()
local cK1:=cK2:=cK3:=cK4:="N"
O_PARAMS
// select 99; use (PRIVPATH+"params") index (PRIVPATH+"parai1")
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("k1",@cK1)
RPar("k2",@cK2)
RPar("k3",@cK3)
RPar("k4",@cK4)
RPar("po",@gPotpis)
RPar("ci",@gCijena)

gNalPr:=padr(gNalPr,20)
gDirPor:=padr(gDirPor,25)

Box(,21,74)
 set cursor on
 @ m_x+1,m_y+2 SAY "Firma:" GET gFirma
 @ m_x+1,col()+2 SAY "Naziv:" get gNFirma
 @ m_x+1,col()+2 SAY "Bazna valuta (Domaca/Pomocna)" GET gBaznaV  valid gbaznav $ "DP"  pict "!@"
 @ m_x+3,m_y+2 SAY "Polje K1  D/N" GET cK1 valid cK1 $ "DN" pict "@!"
 @ m_x+4,m_y+2 SAY "Polje K2  D/N" GET cK2 valid cK2 $ "DN" pict "@!"
 @ m_x+5,m_y+2 SAY "Polje K3  D/N" GET cK3 valid cK3 $ "DN" pict "@!"
 @ m_x+6,m_y+2 SAY "Polje K4  D/N" GET cK4 valid cK4 $ "DN" pict "@!"
 @ m_x+8,m_y+2 SAY "Privatni direktorij PORMP (KALK):" get gDirPor
 @ m_x+9,m_y+2 SAY "Potpis na kraju naloga D/N:" GET gPotpis valid gPotpis $ "DN"
 @ m_x+10,m_y+2 SAY "Nalozi realizac. prodavnice:" GET gNalPr
 @ m_x+11,m_y+2 SAY "Preuzimanje cijene iz sifr.(bez/nc/vpc/mpc/prosj.) ( /1/2/3/P):" GET gCijena valid gcijena $ " 123P"
 @ m_x+13,m_y+2 SAY "Zadati datum naloga D/N:" GET gDatNal valid gDatNal $ "DN" pict "@!"
 @ m_x+14,m_y+2 SAY "Koristiti polja partnera, lice zaduzuje D/N" GET gKupZad valid gKupZad $ "DN" pict "@!"
 @ m_x+15,m_y+2 SAY "Novi korisnicki interfejs D-da / N-ne / R-RUDNIK(bez cijena)" GET gNW valid gNW $ "DNR" pict "@!"
 @ m_x+16,m_y+2 SAY "Prikaz dvovalutno D/N" GET g2Valute valid g2Valute $ "DN" pict "@!"
 @ m_x+17,m_y+2 SAY "Pict "+ValPomocna()+":"  get gpicdem
 @ m_x+18,m_y+2 SAY "Pict "+ValDomaca()+":"  get gpicdin
 @ m_x+19,m_y+2 SAY "Pict KOL :"  get gpickol
 @ m_x+20,m_y+2 SAY "Sa sifrom je vezan konto D/N" GET gKonto valid gKonto $ "DN" pict "@!"
 @ m_x+21,m_y+2 SAY "Sekretarski sistem (D/N) ?"  GET gSekS valid gSekS $ "DN" pict "@!"
 read
BoxC()
gNalPr:=trim(gNalPr)
gDirPor:=trim(gDirPor)
if lastkey()<>K_ESC
 WPar("k1",cK1)
 WPar("k2",cK2)
 WPar("k3",cK3)
 WPar("k4",cK4)
 WPar("po",gPotpis)
 WPar("np",gNalPr)
 WPar("dp",gDirPor)
 WPar("fi",gFirma)
 Wpar("fn",gNFirma)
 Wpar("Bv",gBaznaV)
 Wpar("dn",gDatNal)
 Wpar("nw",gNW)
 Wpar("ss",gSeks)
 Wpar("2v",g2Valute)
 WPar("kd",gKupZad)
 WPar("ci",@gCijena)
 WPar("ko",@gKonto)
 WPar("pe",@gpicdem)
 WPar("pd",@gpicdin)
 WPar("pk",@gpickol)
 select params; use
endif
closeret
return





