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

// -----------------------------------------
// parametri - firma
// -----------------------------------------
function ld_set_firma()
local _godina := fetch_metric( "ld_godina", my_user(), gGodina )
local _rj := fetch_metric( "ld_rj", my_user(), gRj )
local _mjesec := fetch_metric( "ld_mjesec", my_user(), gMjesec )
local _v_obr := fetch_metric( "ld_vise_obracuna", NIL, lViseObr )
local _obracun := fetch_metric( "ld_obracun", my_user(), gObracun )

private GetList:={}

Box(, 4,60)
    
    @ m_x+1,m_y+2 SAY "Radna jedinica:" GET _rj valid P_LD_Rj(@_rj) pict "@!"
    @ m_x+2,m_y+2 SAY "Mjesec        :" GET _mjesec pict "99"
    @ m_x+3,m_y+2 SAY "Godina        :" GET _godina pict "9999"
    
    if _v_obr == .t.
        @ m_x+4,m_y+2 SAY "Obracun       " GET _obracun WHEN HelpObr( .f., _obracun ) VALID ValObr( .f., _obracun )
    endif
    
    read

    ClvBox()

BoxC()

if (LastKey()<>K_ESC)

    set_metric( "ld_godina", my_user(), _godina )
    gGodina := _godina

    set_metric( "ld_mjesec", my_user(), _mjesec )
    gMjesec := _mjesec

    set_metric( "ld_rj", my_user(), _rj )
    gRJ := _rj

    set_metric( "ld_obracun", my_user(), _obracun )
    gObracun := _obracun

    if gZastitaObracuna == "D"
        IspisiStatusObracuna( gRj, gGodina, gMjesec )
    endif

endif

return



// -----------------------------------------
// parametri - formati prikaza
// -----------------------------------------
function ld_set_forma()
private GetList:={}

gPicI := PADR( gPicI, 15 )
gPicS := PADR( gPicS, 15 )

Box(,5,60)
    @ m_x+1,m_y+2 SAY "Zaokruzenje primanja          :" GET gZaok pict "99"
    @ m_x+2,m_y+2 SAY "Zaokruzenje poreza i doprinosa:" GET gZaok2 pict "99"
    @ m_x+3,m_y+2 SAY "Valuta                        :" GET gValuta pict "XXX"
    @ m_x+4,m_y+2 SAY "Prikaz iznosa                 :" GET gPicI
    @ m_x+5,m_y+2 SAY "Prikaz sati                   :" GET gPicS
    read
BoxC()

if ( LastKey() <> K_ESC )
    set_metric( "ld_pic_iznos", NIL, ALLTRIM( gPicI ) )
    set_metric( "ld_pic_sati", NIL, ALLTRIM( gPicS ) )
    set_metric( "ld_valuta", NIL, gValuta )
    set_metric( "ld_zaok_por_dopr", NIL, gZaok2 )
    set_metric( "ld_zaok_prim", NIL, gZaok )
endif

return



// -----------------------------------------
// parametri - formule
// -----------------------------------------
function ld_set_formule()
private GetList:={}

Box(,19,77)
    gFURaz:=PADR(gFURaz,100)
        gFUPrim:=PADR(gFUPrim,100)
        gFUSati:=PADR(gFUSati,100)
        gFURSati:=PADR(gFURSati,100)
    gBFForm:=PADR(gBFForm,100)
        @ m_x+1,m_y+2 SAY "Formula za ukupna primanja:" GET gFUPrim  pict "@!S30"
        @ m_x+2,m_y+2 SAY "Formula za ukupno sati    :" GET gFUSati  pict "@!S30"
        @ m_x+3,m_y+2 SAY "Formula za godisnji       :" GET gFUGod pict "@!S30"
        @ m_x+5,m_y+2 SAY "Formula za uk.prim.-razno :" GET gFURaz pict "@!S30"
        @ m_x+6,m_y+2 SAY "Formula za uk.sati -razno :" GET gFURSati pict "@!S30"
        @ m_x+8,m_y+2 SAY "God. promjena koef.min.rada - ZENE:" GET gMRZ   pict "9999.99"
        @ m_x+9,m_y+2 SAY "God. promjena koef.min.rada - MUSK:" GET gMRM   pict "9999.99"
        @ m_x+11,m_y+2 SAY "% prosjecne plate kao donji limit neta za obracun poreza i doprinosa" GET gPDLimit pict "999.99"
        
    @ m_x+13,m_y+2 SAY "Osnovni licni odbitak" GET gOsnLOdb VALID gOsnLOdb > 0 PICT "9999.99"
    
    @ m_x+15,m_y+2 SAY "  Trosak - ugovor o djelu (%):" GET gUgTrosk PICT "999.99"
    
    @ m_x+16,m_y+2 SAY "Trosak - autorski honorar (%):" GET gAhTrosk PICT "999.99"
    
    @ m_x+18,m_y+2 SAY "Kod benef.gledaj formulu:" GET gBFForm pict "@!S30"
        read
BoxC()

if (LastKey()<>K_ESC)
    Wpar("gd", gFUGod)
        WPar("m1", @gMRM)
        WPar("m2", @gMRZ)
        WPar("dl", @gPDLimit)
        set_metric( "ld_formula_ukupni_sati", nil, gFURsati )
        Wpar("uS", @gFUSati)
    Wpar("uB", @gBFForm)
        Wpar("up", gFUPrim)
        Wpar("ur", gFURaz)
        Wpar("lo", gOsnLOdb)
        Wpar("t1", gUgTrosk)
        Wpar("t2", gAhTrosk)
endif

return


// -----------------------------------------
// parametri nacin obracuna
// -----------------------------------------
function ld_set_obracun()
local nX := 1
local _radni_sati := fetch_metric("ld_radni_sati", NIL, "N" ) 
local _st_stopa := fetch_metric( "ld_porezi_stepenasta_stopa", NIL, "N" )
private GetList:={}

cVarPorol := PADR( cVarPorol, 2 )

Box(, 20, 77)
    
    @ m_x + nX, m_y + 2 SAY "Varijanta obracuna (1/2):" GET gVarObracun
        
    ++nX
    
    @ m_x+nX,m_y+2 SAY "  ' ' - (prazno) stara varijanta obracuna" 
    
    ++nX
    
    @ m_x+nX,m_y+2 SAY "  '2' - nova varijanta obracuna, zak.pr.2009" 
    
    ++nX    
    
    @ m_x+nX,m_y+2 SAY "Tip obracuna (legacy)" GET gTipObr
    @ m_x+nX, col()+1 SAY "Mogucnost unosa mjeseca pri obradi D/N:" GET gUnMjesec  pict "@!" valid gUnMjesec $ "DN"
    ++nX
        
    @ m_x+nX,m_y+2 SAY "Koristiti set formula (sifrarnik Tipovi primanja):" GET gSetForm pict "9" 
    ++nX
        
    @ m_x+nX,m_y+2 SAY "Minuli rad  %/B:" GET gMinR  valid gMinR $ "%B"   pict "@!"
    ++nX
        
    @ m_x+nX,m_y+2 SAY "Pri obracunu napraviti poreske olaksice D/N:" GET gDaPorOl  valid gDaPorOl $ "DN"   pict "@!"
    ++nX
        
    @ m_x+nX,m_y+2 SAY "Ako se prave por.ol.pri obracunu, koja varijanta se koristi:"
    ++nX
        
    @ m_x+nX,m_y+2 SAY " '1' - POROL = RADN->porol*PAROBR->prosld/100 ÄÄ¿  "
    ++nX
        
    @ m_x+nX,m_y+2 SAY " '2' - POROL = RADN->porol, '29' - LD->I29    ÄÄÁÄ>" GET cVarPorOl WHEN gDaPorOl=="D"   PICT "99"
    ++nX
    
    @ m_x+nX,m_y+2 SAY "Grupe poslova u specif.uz platu (1-automatski/2-korisnik definise):" GET gVarSpec  valid gVarSpec $ "12" pict "9"
    ++nX
        
    @ m_x + nX, m_y + 2 SAY "Obrada sihtarice ?" GET gSihtarica VALID gSihtarica $ "DN" pict "@!"
    @ m_x + nX, col() + 1 SAY "Sihtarice po grupama ?" GET gSihtGroup VALID gSihtGroup $ "DN" pict "@!"
    ++ nX
        
    @ m_x+nX,m_y+2 SAY "Filter 'aktivan' u sifraniku radnika ?" GET gRadnFilter VALID gRadnFilter $ "DN" pict "@!"
    ++ nX

    @ m_x + nX, m_y + 2 SAY "Unos i obrada radnih sati (D/N)" GET _radni_sati VALID _radni_sati $ "DN" PICT "@!"

    @ m_x + nX, col() + 2 SAY "Zastita obracuna (D/N) ?" GET gZastitaObracuna VALID gZastitaObracuna $ "DN" PICT "@!"
    ++ nX

    @ m_x + nX, m_y + 2 SAY "Porezi - stepenaste stope ? (D/N)" GET _st_stopa VALID _st_stopa $ "DN" PICT "@!"
    
    READ

BoxC()

if (LastKey() <> K_ESC)
    
    // ako je opcija sihtarica po grupama, onda bazna opcija sihtarica treba biti iskljucena
    if gSihtGroup == "D"
        gSihtarica := "N"
    endif
    
    WPar("fo", gSetForm)
    WPar("mr", @gMinR)   // min rad %, Bodovi
    WPar("p9", @gDaPorOl) // praviti poresku olaksicu D/N
    Wpar("to",gTipObr)
    Wpar("vo",cVarPorOl)
    WPar("um",gUNMjesec)
    Wpar("vs",gVarSpec)
    Wpar("rf",gRadnFilter)

    set_metric( "ld_varijanta_obracuna", NIL, gVarObracun ) 
    set_metric( "ld_obrada_sihtarica", NIL, gSihtarica ) 
    set_metric( "ld_obrada_sihtarica_po_grupama", NIL, gSihtGroup ) 
    set_metric( "ld_radni_sati", NIL, _radni_sati ) 
    set_metric( "ld_porezi_stepenasta_stopa", NIL, _st_stopa )
    set_metric( "ld_zastita_obracuna", NIL, gZastitaObracuna )

endif

return

// -----------------------------------------------
// formati prikaza dokumenata
// -----------------------------------------------
function ld_set_prikaz()
local _pr_kart_pl := fetch_metric("ld_obracun_prikaz_kartice_na_unosu", nil, "N" ) 
private GetList:={}

gPotp1 := PADR(gPotp1, 150)
gPotp2 := PADR(gPotp2, 150)

Box(,15,77)
    @ m_x+1, m_y+2 SAY "Krediti-rekap.po 'na osnovu' (D/N/X)?" GET gReKrOs VALID gReKrOs $ "DNX" PICT "@!"
    @ m_x+2, m_y+2 SAY "Na kraju obrade odstampati listic D/N:" GET _pr_kart_pl  pict "@!" valid _pr_kart_pl $ "DN"
    @ m_x+3, m_y+2 SAY "Prikaz bruto iznosa na kartici radnika (D/N/X) " GET gPrBruto pict "@!" valid gPrBruto $ "DNX"
    @ m_x+4, m_y+2 SAY "Potpis na kartici radnika D/N:" GET gPotp  valid gPotp $ "DN"   pict "@!"
    @ m_x+5, m_y+2 SAY "Varijanta kartice plate za kredite (1/2) ?" GET gReKrKP VALID gReKrKP$"12"
    @ m_x+6, m_y+2 SAY "Opis osnovnih podataka za obracun (1-bodovi/2-koeficijenti) ?" GET gBodK VALID gBodK$"12"
    @ m_x+7, m_y+2 SAY "Pregled plata: varijanta izvjestaja (1/2)" GET gVarPP VALID gVarPP$"12"
    @ m_x+8, m_y+2 SAY "Potpisi na svim izvjestajima (D/N)" GET gPotpRpt VALID gPotpRpt$"DN" PICT "@!"
    read
    
    if gPotpRpt == "D"
        @ m_x+10,m_y+2 SAY "red 1:" GET gPotp1 PICT "@S25"
        @ m_x+10,col()+1 SAY "red 2:" GET gPotp2 PICT "@S25"
        read
    endif
        
    @ m_x+11,m_y+2 SAY "Kartica plate - svi doprinosi (D/N)" GET gKarSDop VALID gKarSDop$"DN" PICT "@!"
    
    read

BoxC()

if (LastKey()<>K_ESC)

    // parametri sql/db 
    set_metric("ld_obracun_prikaz_kartice_na_unosu", nil, _pr_kart_pl ) 

    // postojeci params parmetri
    Wpar("bk",gBodK)
    Wpar("kp",gReKrKP)
    Wpar("pp",gVarPP)
    WPar("pb",gPrBruto)   
    // set formula
    WPar("po",gPotp)   
    // potp4is na listicu
    Wpar("rk",gReKrOs)
    Wpar("pr",gPotpRpt)
    Wpar("P1",gPotp1)
    Wpar("P2",gPotp2)
    Wpar("ks",gKarSDop)

endif

return


// -----------------------------------------
// koliko polja ima ld
// -----------------------------------------
function LDPoljaINI()
public cLDPolja := 60
return



function helpobr(lIzv,cObracun)

if lIzv==nil
    lIzv:=.f.
endif

if gNHelpObr=0
    Box(,3+IF(lIzv,1,0),40)
            @ m_x+0, m_y+2 SAY PADC(" POMOC: ",36,"Í")
            if lIzv
                @ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
                @ m_x+3, m_y+2 SAY "ili prazno ako zelite sve obracune"
            else
                @ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
            endif
            ++gnHelpObr
endif
return .t.




function ValObr(lIzv,cObracun)
local lVrati:=.t.

if lIzv==nil
    lIzv:=.f.
endif

if lIzv
    lVrati:=(cObracun $ " 123456789" )
else
    lVrati:=(cObracun $ "123456789" )
endif

if gnHelpObr>0 .and. lVrati
    BoxC()
        --gnHelpObr
endif

return lVrati


function ClVBox()
local i:=0
for i:=1 to gnHelpObr
    BoxC()
next
gnHelpObr:=0

return



