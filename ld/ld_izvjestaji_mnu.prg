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


#include "ld.ch"

// ----------------------------------------------------
// osnovna funkcija za poziv izvjestaja - menij
// ----------------------------------------------------
function ld_izvjestaji()
local _opc:={}
local _opcexe:={}
local _Izbor:=1
local _priv_pr := f18_privgranted( "ld_pregled_podataka" )

if !_priv_pr
    MsgBeep( F18_SECUR_WARRNING )
    return .t.
endif

AADD( _opc,"1. kartice                                           ")
AADD( _opcexe,{|| MnuIzvK() })
AADD( _opc,"2. rekapitulacije")
AADD( _opcexe,{|| MnuIzvR() })
AADD( _opc,"3. pregledi")
AADD( _opcexe,{|| MnuIzvP() })
AADD( _opc,"4. specifikacije")
AADD( _opcexe,{|| MnuIzvS() })

if gVarObracun == "2"
    AADD( _opc,"5. specifikacije specijalni tipovi rada")
    AADD( _opcexe,{|| m_spec_o() })
endif

AADD( _opc,"6. ostali izvjestaji")
AADD( _opcexe,{|| MnuIzvO() })

if gVarObracun == "2"
    
    AADD( _opc,"-----------------------------------------")
    AADD( _opcexe,{|| nil})
    AADD( _opc,"J. prijave doprinosa (JS-3400)")
    AADD( _opcexe,{|| r_js3400_obrazac() })
    AADD( _opc,"O. obracunski listovi (obrasci OLP i GIP)")
    AADD( _opcexe,{|| r_obr_list() })
    AADD( _opc,"P. akontacije poreza (obrasci ASD i AUG)")
    AADD( _opcexe,{|| r_ak_list() })
    AADD( _opc,"M. mjesecni obrazac MIP-1023")
    AADD( _opcexe,{|| r_mip_obr() })
    AADD( _opc,"E. poreska kartica : export")
    AADD( _opcexe,{|| pk_export() })

endif

f18_menu( "izvj", .f., _izbor, _opc, _opcexe )

return

// ----------------------------------------
// izvjestaji kartice
// ----------------------------------------
static function MnuIzvK()
local _opc:={}
local _opcexe:={}
local _Izbor:=1

AADD( _opc,"1. kartice plate                      ")
AADD( _opcexe,{|| KartPl()})
AADD( _opc,"2. kartica plate za period (za m4)")
AADD( _opcexe,{|| UKartPl()})

f18_menu( "kart", .f., _izbor, _opc, _opcexe )
return



// -----------------------------------------
// menij - izvjestaji specifikacije 2
// -----------------------------------------
static function m_spec_o()
local _opc:={}
local _opcexe:={}
local _Izbor:=1

AADD( _opc,"1. specifikacija za samostalne poduzetnike     ")
AADD( _opcexe,{|| SpecPlS()})
AADD( _opc,"2. specifikacija ostale samostalne djelatnosti")
AADD( _opcexe,{|| SpecPlU()})

f18_menu( "spec2", .f., _izbor, _opc, _opcexe )

return


// -----------------------------------------
// menij - izvjestaji specifikacije
// -----------------------------------------
static function MnuIzvS()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. specifikacija uz isplatu plata                 ")
if gVarObracun == "2"
    AADD(opcexe,{|| SpecPl2()})
else
    AADD(opcexe,{|| Specif()})
endif

AADD(opc,"2. specifikacija po opštinama i RJ")
AADD(opcexe,{|| Specif2()})
AADD(opc,"3. specifikacija po rasponima primanja")
AADD(opcexe,{|| SpecifRasp()})
AADD(opc,"4. specifikacija primanja po mjesecima")
AADD(opcexe,{|| SpecifPoMjes()})
AADD(opc,"5. specif.novcanica potrebnih za isplatu plata")
AADD(opcexe,{|| SpecNovcanica()})
AADD(opc,"6. spec. prosječnog neta po stručnoj spremi")
AADD(opcexe,{|| Specif3()})
AADD(opc,"7. specifikacija primanja po RJ")
AADD(opcexe,{|| SpecPrimRj()})

Menu_SC("spec")
return

// -------------------------------------
// menij - pregledi
// -------------------------------------
static function MnuIzvP()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. pregled plata                                  ")
AADD(opcexe,{|| PregPl()})
AADD(opc,"1a. pregled plata za vise mjeseci  ")
AADD(opcexe,{|| ppl_vise() })
AADD(opc,"2. pregled odredjenog primanja")
AADD(opcexe,{|| PregPrim()})
AADD(opc,"3. platni spisak")
AADD(opcexe,{|| PlatSp()})
AADD(opc,"4. platni spisak tekuci racun")
AADD(opcexe,{|| PlatSpTR("1")})
AADD(opc,"5. platni spisak stedna knj  ")
AADD(opcexe,{|| PlatSpTR("2")})
AADD(opc,"6. pregled primanja za period")
AADD(opcexe,{|| PregPrimPer()})
AADD(opc,"7. pregled obracunatih doprinosa")
AADD(opcexe,{|| IzObDop()})
AADD(opc,"8. isplata jednog tipa primanja na tekuci racun")
AADD(opcexe,{|| IsplataTR("1")})


Menu_SC("preg")
return


// --------------------------------------------
// menij ostali izvjestaji
// --------------------------------------------
static function MnuIzvO()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. lista radnika sa netom po opst.stanovanja  ")
AADD(opcexe,{|| SpRadOpSt()})

if (IsRamaGlas())
    AADD(opc,"2. pregled plata po radnim nalozima    ")
    AADD(opcexe,{|| PlatePoRNalozima()})
endif

AADD(opc,"S. pregled utroska po sihtaricama")
AADD(opcexe,{|| r_sh_print()})

AADD(opc,"T. lista radnika za isplatu toplog obroka")
AADD(opcexe,{|| to_list()})


Menu_SC("ost")
return


static function MnuIzvR()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. rekapitulacija                         ")
if gVarObracun == "2"
    AADD(opcexe,{|| Rekap2(.f.)})
else
    AADD(opcexe,{|| Rekap(.f.)})
endif
AADD(opc,"2. rekapitulacija za sve rj")
if gVarObracun == "2"
    AADD(opcexe,{|| Rekap2(.t.)})
else
    AADD(opcexe,{|| Rekap(.t.)})
endif
AADD(opc,"3. rekapitulacija po koeficijentima")
AADD(opcexe,{|| RekapBod()})
AADD(opc,"4. rekapitulacija neto primanja")
AADD(opcexe,{|| RekNeto()})
AADD(opc,"5. rekapitulacija tekucih racuna")
AADD(opcexe,{|| RekTekRac()})

Menu_SC("rekap")
return




