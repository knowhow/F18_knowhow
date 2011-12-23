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


function mat_sifrarnik()
private izbor:=1
private opc:={}
private opcexe:={}

O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_ROBA
O_VALUTE
O_KARKON
O_SIFV
O_SIFK
O_TARIFA

AADD(opc, "1. partneri                            ")
AADD(opcexe, {|| p_firma() } )
AADD(opc, "2. konto        ")
AADD(opcexe, {|| p_konto() } )
AADD(opc, "3. vrste naloga  ")
AADD(opcexe, {|| p_vn() } )
AADD(opc, "4. tipovi dokumenata  ")
AADD(opcexe, {|| p_tipdok() } )
AADD(opc, "5. roba  ")
AADD(opcexe, {|| p_roba() } )
AADD(opc, "6. tarifa  ")
AADD(opcexe, {|| p_tarifa() } )
AADD(opc, "7. osobine konta  ")
AADD(opcexe, {|| p_karkon() } )
AADD(opc, "8. valute ")
AADD(opcexe, {|| p_valuta() } )
AADD(opc, "9. sifk - karakteristike ")
AADD(opcexe, {|| p_sifk() } )


Menu_sc("m_rpt")

return


function P_KarKon(cid,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID "        , {|| id }   , "id"    , {|| .t.}, {|| vpsifra(wId)} },;
          { "T.NC( /1/2/3/P)", {|| PADC(tip_nc,17)}, "tip_nc", {|| .t.}, {|| wtip_nc$" 123P"} },;
          { "T.PC( /1/2/3/P)", {|| PADC(tip_pc,17)}, "tip_pc", {|| .t.}, {|| wtip_pc$" 123P"} };
        }
Kol:={1,2,3}
return PostojiSifra(F_KARKON,1,10,55,"Osobine konta",@cid,dx,dy)



