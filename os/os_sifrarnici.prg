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


#include "f18.ch"


static function _o_sif_tables()

O_VALUTE
O_KONTO

o_os_sii()

O_AMORT
O_REVAL
O_RJ
O_K1
O_PARTN
O_SIFK
O_SIFV

return



function os_sifrarnici()
local _izbor := 1
local _opc := {}
local _opcexe := {}
local _opis
    
_opis := "osnovna sredstva"

if gOsSii == "S"
    _opis := "sitan inventar"
endif

AADD( _opc, PADR( "1. " + _opis, 40 ) )
AADD( _opcexe, {|| p_os() })

AADD( _opc, "2. koeficijenti amortizacije"  )
AADD( _opcexe, {|| p_amort() })
AADD( _opc, "3. koeficijenti revalorizacije" )
AADD( _opcexe, {|| p_reval() })
AADD( _opc, "4. radne jedinice" )
AADD( _opcexe, {|| p_rj() })
AADD( _opc, "---------------------------" )
AADD( _opcexe, {|| nil })
AADD( _opc, "6. konta" )
AADD( _opcexe, {|| p_konto() })
AADD( _opc, "7. grupacije K1" )
AADD( _opcexe, {|| p_k1() })
AADD( _opc, "8. partneri" )
AADD( _opcexe, {|| p_partneri() })
AADD( _opc, "9. valute" )
AADD( _opcexe, {|| p_valuta() })

_o_sif_tables()

f18_menu("sifre", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return



function P_OS(cId, dx, dy)
local lNovi := .t.
local _n_area := F_OS 
private ImeKol
private Kol

if gOsSii == "S"
    _n_area := F_SII
endif

ImeKol:={ { PADR("Inv.Broj",15),{|| id },     "id"   , {|| .t.}, {|| vpsifra(wId) .and. os_promjena_id_zabrana(lNovi)} },;
          { PADR("Naziv",30),{|| naz},     "naz"      },;
          { PADR("Kolicina",8),{|| kolicina},    "kolicina"     },;
          { PADR("jmj",3),{|| jmj},    "jmj"     },;
          { PADR("Datum",8),{|| Datum},    "datum"     },;
          { PADR("RJ",2),    {|| idRj},    "idRj"  , {|| .t.}, {|| P_Rj(@wIdRj)}   },;
          { PADR("Konto",7), {|| idkonto},    "idkonto", {|| .t.}, {|| P_Konto(@wIdKonto)}     },;
          { PADR("StAm",8),  {|| IdAm},  "IdAm", {|| .t.}, {|| P_Amort(@wIdAm)} },;
          { PADR("StRev",5), {|| IdRev+" "},  "IdRev",{|| .t.}, {|| P_Reval(@wIdRev)}   },;
          { PADR("NabVr",15),{|| nabvr},  "nabvr" , {|| .t.}, {|| os_validate_vrijednost( wnabvr, wotpvr )} },;
          { PADR("OtpVr",15),{|| otpvr},  "otpvr", {|| .t.},  {|| os_validate_vrijednost( wnabvr, wotpvr )}  };
        }

if os_postoji_polje("K1")
    AADD (ImeKol,{ padc("K1",4 ), {|| k1}, "k1" , {|| .t.}, {|| P_K1( @wK1 ) } })
    AADD (ImeKol,{ padc("K2",2 ), {|| k2}, "k2"   })
    AADD (ImeKol,{ padc("K3",2 ), {|| k3}, "k3"   })
    AADD (ImeKol,{ padc("Opis",2 ), {|| opis}, "opis"   })
endif

if os_fld_partn_exist()
    AADD (ImeKol,{ "Dobavljac", {|| idPartner}, "idPartner" , {|| .t.}, {|| P_Firma(@wIdPartner)}   })
endif

if os_postoji_polje("brsoba")
    AADD (ImeKol,{ padc("BrSoba",6 ), {|| brsoba}, "brsoba"   })
endif

private Kol:={}

for i:=1 to LEN(ImeKol)
    AADD(Kol, i)
next

return PostojiSifra( _n_area, 1, MAXROWS()-15, MAXCOLS()-15, "Lista stalnih sredstava", @cId, dx, dy, {|Ch| os_sif_key_handler(Ch, @lNovi)})




function os_validate_vrijednost( wNabVr, wOtpVr )
@ m_x + 11, m_y + 50 say ( wNabvr - wOtpvr )
return .t.



function os_sif_key_handler( Ch, lNovi )
local _n_area := F_PROMJ
local _rec
local _sr_id 
lNovi := .t.

if gOsSii == "S"
    _n_area := F_SII_PROMJ
endif

_sr_id := field->id

do case

    case (Ch==K_CTRL_T)
        
        SELECT ( _n_area )
        lUsedPromj:=.t.

        IF !USED()
            lUsedPromj:=.f.
            o_os_sii_promj()
        ENDIF

        select_promj()

        seek _sr_id

        if FOUND()
            Beep(1)
            Msg("Sredstvo se ne moze brisati - prvo izbrisi promjene !")
        else
            select_os_sii()
            if Pitanje(,"Sigurno zelite izbrisati ovo sredstvo ?","N")=="D"
                _rec := dbf_get_rec()
                delete_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )
            endif
        endif
        IF !lUsedPromj
            select_promj()
            use
        ENDIF
        select_os_sii()

        return 7  
        // kao de_refresh, ali se zavrsava izvrsenje f-ja iz ELIB-a
    
    case (Ch == K_F2)
        // ispravka stavke
        lNovi := .f.
    
endcase

return DE_CONT



function os_promjena_id_zabrana(lNovi)

if !lNovi .and. wId <> field->id
    Beep(1)
    Msg("Promjenu inventurnog broja ne vrsiti ovdje !")
    return .f.
endif

return .t.


function P_AMORT( cId, dx, dy )
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("Id",8),{|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Naziv",25),{|| naz},     "naz"      },;
          { PADR("Iznos",7),{|| iznos},    "iznos"     };
        }
Kol:={1,2,3}
return PostojiSifra(F_AMORT,1, MAXROWS()-15,MAXCOLS()-15,"Lista koeficijenata amortizacije",@cId,dx,dy)



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
return PostojiSifra(F_REVAL,1,MAXROWS()-15,MAXCOLS()-15,"Lista koeficijenata revalorizacije",@cId,dx,dy)



static function vpsifra( wid )
local _t_rec := RECNO()
local _ret

seek wId

if FOUND() .and. Ch == K_CTRL_N
    Beep(3)
    _ret := .f.
else
    _ret := .t.
endif
go _t_rec
return _ret



// --------------------------------------------------------------
// provjerava postojanje polja idpartner u os/sii tabelama
// --------------------------------------------------------------
function os_fld_partn_exist()
return os_postoji_polje("idpartner")


