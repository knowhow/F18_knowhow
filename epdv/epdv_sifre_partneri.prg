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

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ---------------------------------
// ---------------------------------
function p_part(cId, dx, dy)
*{
local cN2Fin
local i
local cRet

PushWa()

PRIVATE ImeKol
PRIVATE Kol

SELECT (F_PARTN)

if !used()
	O_PARTN
endif

ImeKol:={}

AADD(ImeKol, { PADR("ID",6),   {|| id },  "id" , {|| .t.}, {|| vpsifra(wid)}    })
AADD(ImeKol, { PADR("Naziv",25),  {|| naz},  "naz"} )

cN2Fin:=IzFMkIni('FIN','PartnerNaziv2','N')

if cN2Fin=="D"
 AADD(ImeKol, { PADR("Naziv2",25), {|| naz2},     "naz2"      } )
endif

AADD(ImeKol, { PADR("PTT",5),     {|| PTT},     "ptt"      } )
AADD(ImeKol, { PADR("Mjesto",16), {|| MJESTO},  "mjesto"   } )
AADD(ImeKol, { PADR("Adresa",24), {|| ADRESA},  "adresa"   } )

AADD(ImeKol, { PADR("Ziro R ",22),{|| ZIROR},   "ziror"  ,{|| .t.},{|| .t. }  } )

Kol:={}

if IzFMkIni('SifPartn','DZIROR','N')=="D"
 if partn->(fieldpos("DZIROR"))<>0
   AADD (ImeKol,{ padr("Dev ZR",22 ), {|| DZIROR}, "Dziror" })
 endif
endif


if IzFMKINI('SifPartn','Telefon','D')=="D"
 AADD(Imekol,{ PADR("Telefon",12),  {|| TELEFON}, "telefon"  } )
endif

if IzFMKINI('SifPartn','Fax','D')=="D"
if partn->(fieldpos("FAX"))<>0
  AADD (ImeKol,{ padr("Fax",12 ), {|| fax}, "fax" })
endif
endif

if IzFMKINI('SifPartn','MOBTEL','D')=="D"
if partn->(fieldpos("MOBTEL"))<>0
  AADD (ImeKol,{ padr("MobTel",20 ), {|| mobtel}, "mobtel" })
endif
endif

if partn->(fieldpos("ID2"))<>0
  AADD (ImeKol,{ padr("Id2",6 ), {|| id2}, "id2" })
endif

if partn->(fieldpos("IdOps"))<>0
  AADD (ImeKol,{ padr("Opstina",6 ), {|| idOps}, "idOps" })
endif

FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

select (F_SIFK)
if !used()
  O_SIFK
endif

select (F_SIFV)
if !useD()
  O_SIFV
endif

select sifk
set order to tag "ID"
seek "PARTN"

do while !eof() .and. ID="PARTN"

 AADD (ImeKol, {  IzSifKNaz("PARTN",SIFK->Oznaka) })
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('PARTN','" + sifk->oznaka + "')) }" ) )
 AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 if sifk->edkolona > 0
   for ii:=4 to 9
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
   AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 else
   for ii:=4 to 10
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
 endif

 // postavi picture za brojeve
 if sifk->Tip="N"
   if decimal > 0
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina - sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   else
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   endif
 endif

 AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )

 skip
enddo

private gTBDir:="N"
cRet :=PostojiSifra(F_PARTN,1,10,60, "Lista Partnera", @cId, dx, dy, ;
        {|Ch| k_handler(Ch)},,,,, {"ID"})


PopWa()

return cRet



// ---------------------------------- 
// ---------------------------------- 
static function k_handler(Ch)
*{
LOCAL cSif:=PARTN->id, cSif2:=""

if Ch==K_CTRL_T .and. gSKSif=="D"
 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=PARTN->id
 PopWA()

endif

RETURN DE_CONT
*}

