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


#include "os.ch"


function os_sifrarnici()

local Izb:=1
local lPartner:=.f.

private opc[9]

gMeniSif:=.t.  // pritiskom na enter se nece napustiti tabela sifrarnika

opc[1]:="1. stalna sredstva            "
opc[2]:="2. koeficijenti amortizacije"
opc[3]:="3. koeficijenti revalorizecije"
opc[4]:="4. radne jedinice"
opc[5]:="---------------"
opc[6]:="6. konta"
opc[7]:="7. grupacije-k1"
opc[8]:="8. partneri"
opc[9]:="9. "+IF(gDrugaVal<>"D","-------","valute")

IF gDrugaVal=="D"
  O_VALUTE
ENDIF

O_KONTO
O_OS
O_AMORT
O_REVAL
O_RJ
O_K1

if os_fld_partn_exist()
  lPartner:=.t.
  O_PARTN
  O_SIFK
  O_SIFV
else
  opc[8]:="8. -------"
endif

do while .t.

  h[1]:=""
  h[2]:=""
  h[3]:=""
  h[5]:=""
  Izb:=Menu("sios",opc,Izb,.f.)
     do case
        case Izb==0
           exit
        case Izb==1
           P_OS()
        case Izb==2
           P_Amort()
        case Izb==3
           P_Reval()
        case Izb==4
           P_RJ()
        case Izb==5
        case Izb==6
           P_Konto()
        case Izb==7
           P_K1()
        case Izb==8 .and. lPartner
           P_Firma()
        case Izb==9 .and. gDrugaVal=="D"
           P_Valuta()
     endcase
enddo

gMeniSif:=.f.
closeret
return



function P_OS(cId, dx, dy)
local lNovi := .t.
private ImeKol
private Kol

ImeKol:={ { PADR("Inv.Broj",15),{|| id },     "id"   , {|| .t.}, {|| vpsifra(wId) .and. os_promjena_id_zabrana(lNovi)} },;
          { PADR("Naziv",30),{|| naz},     "naz"      },;
          { PADR("Kolicina",8),{|| kolicina},    "kolicina"     },;
          { PADR("jmj",3),{|| jmj},    "jmj"     },;
          { PADR("Datum",8),{|| Datum},    "datum"     },;
          { PADR("RJ",2),    {|| idRj},    "idRj"  , {|| .t.}, {|| P_Rj(@wIdRj)}   },;
          { PADR("Konto",7), {|| idkonto},    "idkonto", {|| .t.}, {|| P_Konto(@wIdKonto)}     },;
          { PADR("StAm",8),  {|| IdAm},  "IdAm", {|| .t.}, {|| P_Amort(@wIdAm)} },;
          { PADR("StRev",5), {|| IdRev+" "},  "IdRev",{|| .t.}, {|| P_Reval(@wIdRev)}   },;
          { PADR("NabVr",15),{|| nabvr},  "nabvr" , {|| .t.}, {|| os_validate_vrijednost(wnabvr,wotpvr)} },;
          { PADR("OtpVr",15),{|| otpvr},  "otpvr", {|| .t.},  {|| os_validate_vrijednost(wnabvr,wotpvr)}  };
        }

//          { PADR("DatOtp",8),{|| DatOtp},    "datOtp"     },;

if os->(fieldpos("K1"))<>0
  AADD (ImeKol,{ padc("K1",4 ), {|| k1}, "k1" , {|| .t.}, {|| P_k1(@wK1)} })
  AADD (ImeKol,{ padc("K2",2 ), {|| k2}, "k2"   })
  AADD (ImeKol,{ padc("K3",2 ), {|| k3}, "k3"   })
  AADD (ImeKol,{ padc("Opis",2 ), {|| opis}, "opis"   })
endif

if os_fld_partn_exist()
  AADD (ImeKol,{ "Dobavljac", {|| idPartner}, "idPartner" , {|| .t.}, {|| P_Firma(@wIdPartner)}   })
endif

if os->(fieldpos("BrSoba"))<>0
  AADD (ImeKol,{ padc("BrSoba",6 ), {|| brsoba}, "brsoba"   })
endif

private Kol:={}

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

return PostojiSifra(F_OS, 1, 10, 60, "Lista stalnih sredstava", @cId, dx, dy, {|Ch| os_sif_key_handler(Ch, @lNovi)})



function os_validate_vrijednost(wNabVr, wOtpVr)
@ m_x+11,m_y+50 say wNabvr-wOtpvr
return .t.



function os_sif_key_handler(Ch, lNovi)
lNovi := .t.

do case
    case (Ch==K_CTRL_T)
	SELECT (F_PROMJ)
 	lUsedPromj:=.t.
 	IF !USED()
   		lUsedPromj:=.f.
   		O_PROMJ
 	ENDIF
 	select promj
 	seek os->id
 	if found()
   		Beep(1)
   		Msg("Sredstvo se ne moze brisati - prvo izbrisi promjene !")
 	else
   		select os
   		if Pitanje(,"Sigurno zelite izbrisati ovo sredstvo ?","N")=="D"
    			delete
   		endif
 	endif
 	IF !lUsedPromj
   		select promj
		use
 	ENDIF
 	select os

 	return 7  
	// kao de_refresh, ali se zavrsava izvrsenje f-ja iz ELIB-a
    
    case (Ch == K_F2)
    	// ispravka stavke
	lNovi := .f.
	
	
endcase

return DE_CONT



function os_promjena_id_zabrana(lNovi)
if !lNovi .and. wId <> id
	Beep(1)
   	Msg("Promjenu inventurnog broja ne vrsiti ovdje !")
   	return .f.
endif
return .t.


function P_AMORT(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("Id",8),{|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Naziv",25),{|| naz},     "naz"      },;
          { PADR("Iznos",7),{|| iznos},    "iznos"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_AMORT,1,10,60,"Lista koeficijenata amortizacije",@cId,dx,dy)



function P_REVAL(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("Id",4),{|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Naziv",10),{|| naz},     "naz"      },;
          { PADR("I1",7),{|| i1},    "i1"     },;
          { PADR("I2",7),{|| i2},    "i2"     },;
          { PADR("I3",7),{|| i3},    "i3"     },;
          { PADR("I4",7),{|| i4},    "i4"     },;
          { PADR("I5",7),{|| i5},    "i5"     },;
          { PADR("I6",7),{|| i6},    "i6"     },;
          { PADR("I7",7),{|| i7},    "i7"     },;
          { PADR("I8",7),{|| i8},    "i8"     },;
          { PADR("I9",7),{|| i9},    "i9"     },;
          { PADR("I10",7),{|| i10},    "i10"     },;
          { PADR("I11",7),{|| i11},    "i11"     },;
          { PADR("I12",7),{|| i12},    "i12"     };
        }
Kol:={1,2,3,4,5,6,7,8,9,10,11,12,13,14}
return PostojiSifra(F_REVAL,1,10,60,"Lista koeficijenata revalorizacije",@cId,dx,dy)



static function vpsifra(wid)
local nrec:=recno(),nRet
seek wid
if found() .and. Ch==K_CTRL_N
  Beep(3)
  nRet:=.f.
else
  nRet:=.t.
endif
go nrec
return nRet



function os_fld_partn_exist()
return (os->(fieldpos("idPartner")<>0))


