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
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TMatMod FROM TAppMod
    method New
    method setGVars
    method mMenu
    method mMenuStandard
    method initdb
END CLASS

// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self


// -----------------------------------------------
// -----------------------------------------------
method initdb()
::oDatabase:=TDbMat():new()
return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenu()

set_hot_keys()

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard()
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. unos/ispravka dokumenata                       ")
AADD(opcexe, {|| mat_knjizenje_naloga()})
AADD(opc, "2. izvještaji")
AADD(opcexe, {|| mat_izvjestaji()})
AADD(opc, "3. kontrola zbira datoteka")
AADD(opcexe, {|| mat_kzb()})
AADD(opc, "4. štampa datoteke naloga")
AADD(opcexe, {|| mat_dnevnik_naloga()})
AADD(opc, "5. štampa proknjizenih naloga")
AADD(opcexe, {|| mat_stampa_naloga()})
AADD(opc, "6. inventura")
AADD(opcexe, {|| mat_inventura() } )
AADD(opc, "F. prenos fakt->mat")
AADD(opcexe, {|| mat_prenos_fakmat()})
AADD(opc, "G. generacija dokumenta pocetnog stanja")
AADD(opcexe, {|| mat_prenos_podataka()})
AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| mat_sifrarnik()})
AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "P. povrat naloga u pripremu")
AADD(opcexe, {|| mat_povrat_naloga()})
AADD(opc, "9. administracija baze podataka")
AADD(opcexe, {|| mat_admin_menu()})
AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "X. parametri")
AADD(opcexe, {|| mat_parametri()})

Menu_SC("gmat", .t. )

return




// -----------------------------------------------
// -----------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

public gModul
public gTema
public gGlBaza

public gDirPor := ""
public gNalPr := "41#42"
public gCijena := "2"
public gKonto := "D"
public KursLis := "1"
public gpicdem := "9999999.99"
public gpicdin := "999999999.99"
public gPicKol := "999999.999"
public g2Valute := "N"
public gPotpis := "N"
public gDatNal := "D"
public gKupZad := "D"
public gSekS := "N"

public cZabrana := "Opcija nedostupna za ovaj nivo !!!"

// read server params...
gDirPor := fetch_metric( "mat_dir_kalk", my_user(), gDirPor  )
g2Valute := fetch_metric( "mat_dvovalutni_rpt", NIL, g2Valute )
gNalPr := fetch_metric( "mat_real_prod", NIL, gNalPr )
gCijena := fetch_metric( "mat_tip_cijene", NIL, gCijena )
gPicDem := ALLTRIM( fetch_metric( "mat_pict_dem", NIL, gPicDem ) )
gPicDin := ALLTRIM( fetch_metric( "mat_pict_din", NIL, gPicDin ) )
gPicKol := ALLTRIM( fetch_metric( "mat_pict_kol", NIL, gPicKol ) )
gDatNal := fetch_metric( "mat_datum_naloga", NIL, gDatNal )
gSekS := fetch_metric( "mat_sekretarski_sistem", NIL, gSekS )
gKupZad := fetch_metric( "mat_polje_partner", NIL, gKupZad )
gKonto := fetch_metric( "mat_vezni_konto", NIL, gKonto )
gPotpis := fetch_metric( "mat_rpt_potpis", my_user(), gPotpis )

gModul := "MAT"
gTema := "OSN_MENI"
gGlBaza := "SUBAN.DBF"


return



