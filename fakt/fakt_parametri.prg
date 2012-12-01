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

#include "fakt.ch"

static __fakt_params := NIL

// -----------------------------------------
// Fakt parametri
// -----------------------------------------
function mnu_fakt_params()
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private Izbor:=1
private opc:={}
private opcexe:={}

O_ROBA
O_PARAMS

SELECT params
USE


AADD(opc,"1. postaviti osnovne podatke o firmi           ")
AADD(opcexe,{|| org_params() })

AADD(opc,"2. postaviti varijante obrade dokumenata       ") 
AADD(opcexe,{|| fakt_par_varijante_prikaza()})

AADD(opc,"3. izgled dokumenata      ")
AADD(opcexe,{|| par_fakt_izgled_dokumenta()})

if IsPDV()
    AADD(opc,"4. izgled dokumenata - zaglavlje ")
    AADD(opcexe,{|| fakt_zagl_params()})
endif

AADD(opc,"5. nazivi dokumenata i teksta na kraju (potpis)")
AADD(opcexe,{|| fakt_par_nazivi_dokumenata()})

AADD(opc,"6. prikaza cijena, iznos ")
AADD(opcexe,{|| fakt_par_cijene()})

AADD(opc,"F. fiskalni parametri  ")
AADD(opcexe,{|| f18_fiscal_params_menu() })

AADD(opc,"P. parametri labeliranja, barkod stampe  ")
AADD(opcexe,{|| label_params() })

AADD(opc,"R. postaviti parametre - razno                 ")
AADD(opcexe,{|| fakt_par_razno()})

Menu_SC("parf")


fakt_params(.t.)
return nil 


// -------------------------------------------------------------
// postavi parametre unosa fakt_dokumenta
// -------------------------------------------------------------
procedure fakt_params(read)

if read == NIL
  read = .f.
endif

if read .or. __fakt_params == NIL
    __fakt_params := hb_hash()

    // TODO: prebaciti na get_set sistem
    __fakt_params["def_rj"] := fetch_metric( "fakt_default_radna_jedinica", my_user(), SPACE(2) )

    __fakt_params["barkod"] := fetch_metric("fakt_prikaz_barkod", my_user(), "0" )

    // TODO: ugasiti ovaj globalni parametar
    if destinacije() == "D"
      __fakt_params["destinacije"] := .t.
    else
      __fakt_params["destinacije"] := .f.
    endif

    // ako se koristi rnal, koriste se veze izmedju fakt dokumenata
    __fakt_params["fakt_dok_veze"] :=  f18_use_module("rnal")

    __fakt_params["fakt_opis_stavke"] := IIF(fakt_opis_stavke() == "D", .t., .f.)
    __fakt_params["fakt_prodajna_mjesta"] := IIF(fakt_prodajna_mjesta() == "D", .t., .f.)
    __fakt_params["ref_lot"] := IIF(ref_lot() == "D", .t., .f.)
    __fakt_params["fakt_vrste_placanja"] := IIF(fakt_vrste_placanja() == "D", .t., .f.)
endif

return __fakt_params



// ------------------------------------------
// setuju parametre pri pokretanju modula
// napuni sifrarnike
// ------------------------------------------
function fakt_set_params()

// PTXT 01.50 compatibility switch
public gPtxtC50 := .t.

fill_part()

return


/*! \fn fakt_par_razno()
 *  \brief Podesenja parametri-razno
 */
function fakt_par_razno()
local _def_rj := fetch_metric( "fakt_default_radna_jedinica", my_user(), SPACE(2) )
local _prik_bk := fetch_metric("fakt_prikaz_barkod", my_user(), "0" )
local _ext_pdf := fetch_metric( "fakt_dokument_pdf_lokacija", my_user(), PADR("", 300) )
local _unos_barkod := fetch_metric( "fakt_unos_artikala_po_barkodu", my_user(), "N" )
local _pm := fakt_prodajna_mjesta()
local _rabat := fetch_metric( "pregled_rabata_kod_izlaza", my_user(), "N" )
local _racun_na_email := PADR( fetch_metric( "fakt_dokument_na_email", my_user(), "" ), 300 )
local _def_template := PADR( fetch_metric( "fakt_default_odt_template", my_user(), "" ), 20)
local _x := 1
local _unos_ref_lot := ref_lot()
local _unos_opisa := fakt_opis_stavke() 
local _vr_pl := fakt_vrste_placanja()
local _unos_dest := destinacije()


private cSection:="1"
private cHistory:=" "
private aHistory:={}
private GetList:={}

O_PARAMS

gKomLin := PADR( gKomLin, 70 )

Box(, MAXROWS() - 5, MAXCOLS() - 15, .f., "OSTALI PARAMETRI (RAZNO)" )

_x := 2

@ m_x + _x, m_y + 2 SAY "Inicijalna meni-opcija (1/2/.../G)" GET gIMenu ;
            VALID gIMenu $ "123456789ABCDEFG" PICT "@!"

++ _x
++ _x

@ m_x + _x, m_y + 2 SAY "Default radna jedinica kod unosa dokumenta:" GET _def_rj     

++ _x
    
@ m_x + _x, m_y + 2 SAY "Unos dokumenata pomocu barkod-a (D/N) ?" GET _unos_barkod VALID _unos_barkod $ "DN" PICT "@!"

++ _x
 
@ m_x + _x, m_y + 2 SAY "Pregled zadnjih izlaza kod unosa dokumenta (D/N) ?" GET _rabat VALID _rabat $ "DN" PICT "@!"

++ _x
    
@ m_x + _x, m_y + 2 SAY "Duzina sifre artikla sinteticki " GET gnDS VALID gnDS > 0 PICT "9"

++ _x

@ m_x + _x, m_y + 2 SAY "Voditi samo kolicine " GET gSamoKol PICT "@!" VALID gSamoKol $ "DN"

++ _x
    
@ m_x + _x, m_y + 2 SAY "Tekuca vrijednost za rok placanja  " GET gRokPl PICT "999"

++ _x
    
@ m_x + _x, m_y + 2 SAY "Uvijek resetuj artikal pri unosu dokumenata (D/N)" GET gResetRoba PICT "@!" VALID gResetRoba $ "DN"

++ _x

@ m_x + _x, m_y + 2 SAY "Prikaz barkod-a na fakturi (0/1/2)" GET _prik_bk VALID _prik_bk $ "012"

++ _x

@ m_x + _x, m_y + 2 SAY "Racun na email:" GET _racun_na_email PICT "@S50"

++ _x

@ m_x + _x, m_y + 2 SAY "ODT fakturu konvertuj u PDF na lokaciju:" GET _ext_pdf PICT "@S35"

++ _x

@ m_x + _x, m_y + 2 SAY "Default ODT template:" GET _def_template PICT "@S35"
++ _x

read_dn_parametar("Pracenje po destinacijama", m_x + _x, m_y + 2, @_unos_dest)
++ _x

read_dn_parametar("Fakturisanje po prodajnim mjestima", m_x + _x, m_y + 2, @_pm)
++ _x

read_dn_parametar("Fakturisanje po vrstama placanja", m_x + _x, m_y + 2, @_vr_pl)
++ _x

read_dn_parametar("Fakt dodatni opis po stavkama", m_x + _x, m_y + 2, @_unos_opisa)
++ _x

read_dn_parametar("REF/LOT brojevi", m_x + _x, m_y + 2, @_unos_ref_lot)
++ _x

@ m_x + _x, m_y + 2 SAY "Ispis racuna MP na traku (D/N/X)" GET gMPPrint  PICT "@!"   VALID gMPPrint $ "DNXT"
read

if gMPPrint $ "DXT"

	++ _x
        
    @ m_x + _x, m_y + 2 SAY "Oznaka lokalnog porta za stampu: LPT" ;
            GET gMPLocPort ;
            VALID gMPLocPort $ "1234567" PICT "@!"
    ++ _x
        
    @ m_x + _x, m_y + 2 SAY "Redukcija trake (0/1/2):" ;
            GET gMPRedTraka ;
            VALID gMPRedTraka $ "012"
  	++ _x
    
    @ m_x + _x, m_y + 2 SAY "Ispis id artikla na racunu (D/N):" ;
            GET gMPArtikal ;
            VALID gMPArtikal $ "DN" PICT "@!"
  	++ _x
    
    @ m_x + _x, m_y + 2 SAY "Ispis cjene sa pdv (2) ili bez (1):" ;
            GET gMPCjenPDV ;
            VALID gMPCjenPDV $ "12"
    

   	read

endif

BoxC()

gKomLin := TRIM( gKomLin )

if LastKey() <> K_ESC

    set_metric( "fakt_voditi_samo_kolicine", nil, gSamoKol )
    set_metric( "fakt_rok_placanja_tekuca_vrijednost", my_user(), gRokPl )
    set_metric( "fakt_reset_artikla_na_unosu", my_user(), gResetRoba )
    set_metric( "fakt_incijalni_meni_odabri", my_user(), gIMenu )
	set_metric( "fakt_default_radna_jedinica", my_user(), _def_rj )
	set_metric( "fakt_prikaz_barkod", my_user(), _prik_bk )
	set_metric( "fakt_dokument_pdf_lokacija", my_user(), _ext_pdf )
	set_metric( "fakt_unos_artikala_po_barkodu", my_user(), _unos_barkod )
    set_metric( "pregled_rabata_kod_izlaza", my_user(), _rabat )
	set_metric( "fakt_dokument_na_email", my_user(), ALLTRIM( _racun_na_email ) )
    set_metric( "fakt_default_odt_template", my_user(), ALLTRIM( _def_template ) )

    destinacije(_unos_dest)
    fakt_opis_stavke(_unos_opisa)
    ref_lot(_unos_ref_lot)
    fakt_prodajna_mjesta(_pm)
    fakt_vrste_placanja(_vr_pl)
    
    // setuj mi default odt template ako treba
    __default_odt_template()

    Wpar("NF",gFNar)
    Wpar("UF",gFUgRab)
    Wpar("ds",gnDS)
    WPar("if",gImeF)
    WPar("95",gKomLin)   
    WPar("Fi",@gIspPart)
    WPar("mP",gMpPrint)
    WPar("mL",gMpLocPort)
    WPar("mT",gMpRedTraka)
    WPar("mA",gMpArtikal)
    WPar("mC",gMpCjenPDV)

endif

return 


// ---------------------------------------------
// ---------------------------------------------
function fakt_zagl_params()
local nSay := 17
local sPict := "@S55"
local nX := 1
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private GetList:={}

gFNaziv := PADR( gFNaziv , 250 )
gFPNaziv := PADR( gFPNaziv, 250 )
gFIdBroj := PADR(gFIdBroj, 13)
gFText1 := PADR( gFText1, 72)
gFText2 := PADR( gFText2, 72)
gFText3 := PADR( gFText3, 72)
gFTelefon := PADR(gFTelefon, 72)
gFEmailWeb := PADR( gFEmailWeb, 72)

Box( , 21, 77, .f., "Izgleda dokumenata - zaglavlje")

    // opci podaci
    @ m_x+nX, m_y+2 SAY PADL("Puni naziv firme:", nSay) GET gFNaziv ;
        PICT sPict
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Dodatni opis:", nSay) GET gFPNaziv ;
        PICT sPict
    nX++

    @ m_x+nX, m_y+2 SAY PADL("Adresa firme:", nSay) GET gFAdresa ;
        PICT sPict 
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Ident.broj:", nSay) GET gFIdBroj
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Telefoni:", nSay) GET gFTelefon ;
        PICT sPict 
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("email/web:", nSay) GET gFEmailWeb ;
        PICT sPict 
    nX++
    
    // banke
    @ m_x+nX,  m_y+2 SAY PADL("Banka 1:", nSay) GET gFBanka1 ;
        PICT sPict
    nX++
    
    @ m_x+nX,  m_y+2 SAY PADL("Banka 2:", nSay) GET gFBanka2 ;
        PICT sPict
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Banka 3:", nSay) GET gFBanka3 ;
        PICT sPict
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Banka 4:", nSay) GET gFBanka4 ;
        PICT sPict
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Banka 5:", nSay) GET gFBanka5 ;
        PICT sPict
    nX += 2
    
    // dodatni redovi
    @ m_x+nX, m_y+2 SAY "Proizvoljan sadrzaj na kraju"
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Red 1:", nSay) GET gFText1 ;
        PICT sPict
    nX++
    
    
    @ m_x+nX, m_y+2 SAY PADL("Red 2:", nSay) GET gFText2 ;
        PICT sPict
    nX++
    
    @ m_x+nX, m_y+2 SAY PADL("Red 3:", nSay) GET gFText3 ;
        PICT sPict
    nX += 2

    @ m_x+ nX, m_y+2 SAY "Koristiti tekstualno zaglavlje (D/N)?" GET gStZagl ;
        VALID gStZagl $ "DN" PICT "@!"

    nX += 2
    
    @ m_x + nX, m_y+2 SAY PADL("Slika na vrhu fakture (redova):", nSay + 15) GET gFPicHRow PICT "99"
    
    nX += 1
    
    @ m_x + nX, m_y+2 SAY PADL("Slika na dnu fakture (redova):", nSay + 15) GET gFPicFRow PICT "99"
    read
    
BoxC()

if (LASTKEY() <> K_ESC)
    set_metric( "org_naziv", nil, gFNaziv )
    set_metric( "org_naziv_dodatno", nil, gFPNaziv )
    set_metric( "org_adresa", nil, gFAdresa )
    set_metric( "org_pdv_broj", nil, gFIdBroj )
    set_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
    set_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
    set_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
    set_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
    set_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
    set_metric( "fakt_zagl_telefon", nil, gFTelefon )
    set_metric( "fakt_zagl_email", nil, gFEmailWeb )
    set_metric( "fakt_zagl_dtxt_1", nil, gFText1 )
    set_metric( "fakt_zagl_dtxt_2", nil, gFText2 )
    set_metric( "fakt_zagl_dtxt_3", nil, gFText3 )
    set_metric( "fakt_zagl_koristiti_txt", nil, gStZagl )
    set_metric( "fakt_zagl_pic_header", nil, gFPicHRow )
    set_metric( "fakt_zagl_pic_footer", nil, gFPicFRow )
endif

return 



function fakt_par_cijene()
local nX
private  GetList:={}

PicKol := STRTRAN( PicKol, "@Z ", "" )

nX:=1
Box(, 6, 60, .f.,"PARAMETRI PRIKAZA")

    @ m_x+nX,m_y+2 SAY "Prikaz cijene   " GET PicCDem
    nX++
    
    @ m_x+nX, m_y+2 SAY "Prikaz iznosa   " GET PicDem
    nX++
    
    @ m_x+nX, m_y+2 SAY "Prikaz kolicine " GET PicKol
    nX++

    @ m_x+nX, m_y+2 SAY "Na kraju fakture izvrsiti zaokruzenje" GET gFZaok PICT "99"
    nX++
    
    @ m_x+nX, m_y+2 SAY "Zaokruzenje 5 pf (D/N)?" GET gZ_5pf PICT "@!" ;
        VALID gZ_5pf $ "DN"

    read

BoxC()

if (LASTKEY()<>K_ESC)

    set_metric( "fakt_prikaz_cijene", NIL, PicCDem )
    set_metric( "fakt_prikaz_iznosa", NIL, PicDem )
    set_metric( "fakt_prikaz_kolicine", NIL, PicKol )
    set_metric( "fakt_zaokruzenje", NIL, gFZaok )
    set_metric( "fakt_zaokruzenje_5_pf", NIL, gZ_5pf )

endif

return 



function fakt_par_varijante_prikaza()
private  GetList:={}

O_PARAMS

Box(, 23, 76, .f., "VARIJANTE OBRADE DOKUMENATA")
    @ m_x+1,m_y+2 SAY "Unos Dat.pl, otpr., narudzbe D/N (1/2) ?" GET gDoDPar VALID gDodPar $ "12" PICT "@!"
    @ m_x+1,m_y+46 SAY "Dat.pl.u svim v.f.9 (D/N)?" GET gDatVal VALID gDatVal $ "DN" PICT "@!"
    @ m_x+2,m_y+2 SAY "Generacija ulaza prilikom izlaza 13" GET gProtu13 VALID gProtu13 $ "DN" PICT "@!"
    @ m_x+4,m_y+2 SAY "Maloprod.cijena za 13-ku ( /1/2/3/4/5/6)   " GET g13dcij VALID g13dcij$" 123456"
    @ m_x+5,m_y+2 SAY "Varijanta dokumenta 13 (1/2)   " GET gVar13 VALID gVar13$"12"
    @ m_x+6,m_y+2 SAY "Varijanta numeracije dokumenta 13 (1/2)   " GET gVarNum VALID gVarNum$"12"
    @ m_x+7,m_y+2 SAY "Pratiti trenutnu kolicinu D/N ?" GET gPratiK PICT "@!" VALID gPratiK $ "DN"
    @ m_x+7,col()+1 SAY "Pratiti cijene na unosu D/N ?" GET gPratiC PICT "@!" VALID gPratiC $ "DN"
    @ m_x+8,m_y+2 SAY  "Koristenje VP cijene:"
    @ m_x+9,m_y+2 SAY  "  ( ) samo VPC   (X) koristiti samo MPC    (1) VPC1/VPC2 "
    @ m_x+10,m_y+2 SAY "  (2) VPC1/VPC2 putem rabata u odnosu na VPC1   (3) NC "
    @ m_x+11,m_y+2 SAY "  (4) Uporedo vidi i MPC............" GET gVarC
    @ m_x+12,m_y+2 SAY "U fakturi maloprodaje koristiti:"
    @ m_x+13,m_y+2 SAY "  (1) MPC iz sifrarnika  (2) VPC + PPP + PPU   (3) MPC2 "
    @ m_x+14,m_y+2 SAY "  (4) MPC3  (5) MPC4  (6) MPC5  (7) MPC6 ....." GET gMP VALID gMP $ "1234567"
    @ m_x+15,m_y+2 SAY "Numericki dio broja dokumenta:" GET gNumDio PICT "99"
    @ m_x+16,m_y+2 SAY "Upozorenje na promjenu radne jedinice:" GET gDetPromRj PICT "@!" VALID gDetPromRj $ "DN"
    @ m_x+17,m_y+2 SAY "Var.otpr.-12 sa porezom :" GET gV12Por PICT "@!" VALID gV12Por $ "DN"
    @ m_x+17,m_y+35 SAY "Var.fakt.po ugovorima (1/2) :" GET gVFU PICT "9" VALID gVFU $ "12"
    @ m_x+18,m_y+2 SAY "Var.fakt.rok plac. samo vece od 0 :" GET gVFRP0 PICT "@!" VALID gVFRP0 $ "DN"
    @ m_x+20,m_y+2 SAY "Prikaz samo kolicina na dokumentima (0/D/N)" GET gPSamoKol PICT "@!" VALID gPSamoKol $ "0DN"
    @ m_x+21,m_y+2 SAY "Pretraga artikla po indexu:" GET gArtCdx PICT "@!"
    @ m_x+22,m_y+2 SAY "Koristiti rabat iz sif.robe (polje N1) ?" GET gRabIzRobe PICT "@!" VALID gRabIzRobe $ "DN"
    @ m_x+23,m_y+2 SAY "Brisi direktno u smece" GET gcF9usmece PICT "@!" VALID gcF9usmece $ "DN"
    @ m_x+23,col()+2 SAY "Timeout kod azuriranja" GET gAzurTimeout PICT "9999" 
    
    read

BoxC()

if (LASTKEY()<>K_ESC)

    set_metric( "fakt_datum_placanja_otpremnica", nil, gDoDPar )
    set_metric( "fakt_datum_placanja_svi_dokumenti", nil, gDatVal )
    set_metric( "fakt_numericki_dio_dokumenta", nil, gNumDio )
    set_metric( "fakt_prikaz_samo_kolicine", nil, gPSamoKol )
    set_metric( "fakt_povrat_u_smece", nil, gcF9usmece )
    set_metric( "fakt_varijanta_dokumenta_13", nil, gVar13 )

    WPar("pd",gProtu13)
    WPar("dc",g13dcij)
    WPar("vn",gVarNum)
    WPar("pk",gPratik)
    WPar("pc",gPratiC)
    WPar("50",gVarC)
    WPar("mp",gMP)  
    WPar("PR",gDetPromRj)
    WPar("vp",gV12Por)
    WPar("vu",gVFU)
    WPar("v0",gVFRP0)
    WPar("g1",gKarC1)
    WPar("g2",gKarC2)
    WPar("g3",gKarC3)
    WPar("g4",gKarN1)
    WPar("g5",gKarN2)
    WPar("gC",gArtCDX)
    WPar("rR",gRabIzRobe)
    WPar("Fz",gAzurTimeout)
    
endif

return 



function par_fakt_izgled_dokumenta()
local nX
local nDx1 := 0
local nDx2 := 0
local nDx3 := 0
local nSw1 := 72
local nSw2 := 1
local nSw3 := 72
local nSw4 := 31
local nSw5 := 1
local nSw6 := 1
local nSw7 := 0
local _params := fakt_params()

private GetList:={}
private cIzvj:="1"

O_PARAMS

if ValType(gTabela)<>"N"
    gTabela:=1
endif

RPar("c1",@cIzvj)

cSection := "F"
RPar("x1", @nDx1)
RPar("x2", @nDx2)
RPar("x3", @nDx3)
RPar("x4", @nSw1)
RPar("x5", @nSw2)
RPar("x6", @nSw3)
RPar("x7", @nSw4)
RPar("x8", @nSw5)
RPar("x9", @nSw6)
RPar("y1", @nSw7)

cSection := "1"

nX:=2
Box( ,22, 76, .f., "Izgled dokumenata")

    if !IsPdv()
        
        @ m_x + nX, m_y+2 SAY "Prikaz cijena podstavki/cijena u glavnoj stavci (1/2)" GET cIzvj
        nX++
        @ m_x + nX, m_y+2 SAY "Izgled fakture 1/2/3" GET gTipF VALID gTipF $ "123"
        nX++
        @ m_x + nX, m_y+2 SAY "Varijanta 1/2/3/4/9/A/B" GET gVarF VALID gVarF $ "12349AB"
        nX++
    endif
    
    @ m_x + nX, m_y+2 SAY "Dodat.redovi po listu " GET gERedova ;
         PICT "999"
    nX++
    @ m_x + nX, m_y+2 SAY "Lijeva margina pri stampanju " GET gnLMarg PICT "99"
    nX++
    
    // legacy
    if !IsPdv()
        @ m_x+ nX, m_y+35 SAY "L.marg.za v.2/9/A5 " GET gnLMargA5 PICT "99"
        nX++
    endif
    
    @ m_x+ nX, m_y+2 SAY "Gornja margina " GET gnTMarg PICT "99"
    nX++

    // legacy
    if !IsPdv()
        @ m_x + nX, m_y+2 SAY "Koristiti A5 obrazac u varijanti 9 D/N/0" GET gFormatA5 PICT "@!" VALID gFormatA5 $ "DN0"
        nX++
    
        @ m_x+ nX, m_y+58 SAY "A4   A5"
        nX++
        @ m_x+ nX, m_y+2 SAY "Horizont.pomjeranje zaglavlja u varijanti 9 (br.kolona)" GET gFPzag PICT "99"
        @ m_x+ nX, m_y+63 GET gFPzagA5 PICT "99"
        nX++
        @ m_x + nX, m_y+2 SAY "Vertikalno pomjeranje stavki u fakturi var.9(br.redova)" GET gnTmarg2 PICT "99"
        @ m_x + nX, m_y+63 GET gnTmarg2A5 PICT "99"
        nX++
        @ m_x + nX, m_y+2 SAY "Vertikalno pomjeranje totala u fakturi var.9(br.redova)" GET gnTmarg3 PICT "99"
        @ m_x + nX, m_y+63 GET gnTmarg3A5 PICT "99"
        nX++
        @ m_x + nX, m_y+2 SAY "Vertikalno pomj.donjeg dijela fakture  var.9(br.redova)" GET gnTmarg4 PICT "99"
        @ m_x + nX, m_y+63 GET gnTmarg4A5 PICT "99"
        nX++
        @ m_x + nX, m_y+2 SAY "Vertik.pomj.znakova krizanja i br.dok.var.9(br.red.>=0)" GET gKriz PICT "99"
        @ m_x + nX, m_y+63 GET gKrizA5 PICT "99"
        nX++
        @ m_x + nX, m_y+2 SAY "Znak kojim se precrtava dio teksta na papiru" GET gZnPrec
        nX++
        @ m_x + nX, m_y+2 SAY "Broj linija za odvajanje tabele od broja dokumenta" GET gOdvT2 VALID gOdvT2>=0 PICT "9"
        nX++
        @ m_x + nX, m_y+2 SAY "Nacin crtanja tabele (0/1/2) ?" GET gTabela VALID gTabela<3.and.gTabela>=0 PICT "9"
        nX++
        @ m_x + nX, m_y+2 SAY "Zaglavlje na svakoj stranici D/N  (1/2) ? " GET gZagl VALID gZagl $ "12" PICT "@!"
        nX++
        @ m_x + nX, m_y+2 SAY "Crni-masni prikaz fakture D/N  (1/2) ? " GET gBold VALID gBold $ "12" PICT "@!"
        nX++
        @ m_x + nX, m_y+2 SAY "Var.RTF-fakt.,izgled tipa 2 (' '-standardno, 1-MINEX, 2-LIKOM, 3-ZENELA)" GET gVarRF VALID gVarRF $ " 123"
        nX++
        @ m_x + nX, m_y+2 SAY "Prikaz rekapitulacije po tarifama na 13-ci:" GET gRekTar VALID gRekTar $ "DN" PICT "@!"
        nX++
        @ m_x + nX, m_y+2 SAY "Prikaz horizot. linija:" GET gHLinija VALID gHLinija $ "DN" PICT "@!"
        nX++ 
        @ m_x + nX, m_y+2 SAY "Prikaz rabata u %(procentu)? (D/N):" GET gRabProc VALID gRabProc $ "DN" PICT "@!"
        nX++
    endif

    if IsPdv()
        @ m_x+ nX, m_y+2 SAY "PDV Delphi RB prikaz (D/N)" GET gPDVDrb PICT "@!" VALID gPDVDrb $ "DN"
        nX++
        @ m_x+ nX, m_y+2 SAY "PDV TXT dokument varijanta " GET gPDVDokVar PICT "@!" VALID gPDVDokVar $ "123"
        nX++
    endif

    if IsPdv()
        nX += 2
        @ m_x+nX, m_y+2 SAY "Koordinate iznad kupac/ispod kupac/nar_otp-tabela"
        nX ++
        @ m_x+nX, m_y+2 SAY "DX-1 :" GET nDx1 ;
             PICT "99" 
        @ m_x+nX, col()+2 SAY "DX-2 :" GET nDx2 ;
             PICT "99" 
        @ m_x+nX, col()+2 SAY "DX-3 :" GET nDx3 ;
             PICT "99"
        nX += 2
        @ m_x+nX, m_y+2 SAY "SW-1 :" GET nSw1 ;
             PICT "99" 
        @ m_x+nX, col()+2 SAY "SW-2 :" GET nSw2 ;
             PICT "99" 
        @ m_x+nX, col()+2 SAY "SW-3 :" GET nSw3 ;
             PICT "99" 
        @ m_x+nX, col()+2 SAY "SW-4 :" GET nSw4 ;
             PICT "99"
        @ m_x+nX, col()+2 SAY "SW-5 :" GET nSw5 ;
             PICT "99"
        nX += 2     
        @ m_x+nX, m_y+2 SAY "SW-6 :" GET nSw6 ;
             PICT "9" 
        @ m_x+nX, col()+2 SAY "SW-7 :" GET nSw7 ;
             PICT "9" 
        nX += 2

        // parametri fin.stanje na dod.txt...
        @ m_x+nX, m_y+2 SAY "Ispis grupacije robe poslije naziva (D/N)" GET glRGrPrn PICT "@!" VALID glRGrPrn $ "DN"
     
        nX += 2

        // parametri fin.stanje na dod.txt...
        @ m_x+nX, m_y+2 SAY "Prikaz fin.salda kupca/dobavljaca na dodatnom tekstu (D/N)" GET gShSld PICT "@!" VALID gShSld $ "DN"

        nX += 1
     
        @ m_x+nX, m_y+2 SAY PADL("Konto duguje:", 20) GET gFinKtoDug VALID !EMPTY(gFinKtoDug) .and. P_Konto(@gFinKtoDug) WHEN gShSld == "D"

        nX += 1
    
        @ m_x+nX, m_y+2 SAY PADL("Konto potrazuje:", 20) GET gFinKtoPot VALID !EMPTY(gFinKtoPot) .and. P_Konto(@gFinKtoPot) WHEN gShSld == "D"
     
        nX += 1
     
        @ m_x+nX, m_y+2 SAY "Varijanta prikaza podataka (1/2)" GET gShSldVar PICT "9" VALID gShSldVar > 0 .and. gShSldVar < 3 WHEN gShSld == "D"

    endif

    read

BoxC()

if ( LASTKEY() <> K_ESC )
    
    WPar("c1", cIzvj)
    WPar("tf", @gTipF)
    WPar("vf", @gVarF)
    WPar("kr", @gKriz)
    WPar("55", @gKrizA5)
    WPar("vr", @gVarRF)
    WPar("56", gnLMargA5)
    WPar("a5", gFormatA5)
    WPar("fp", gFPzag)
    WPar("51", gFPzagA5)
    WPar("52", gnTMarg2A5)
    WPar("53", gnTMarg3A5)
    WPar("54", gnTMarg4A5)
    WPar("d1", gnTMarg2)
    WPar("d2", gnTMarg3)
    WPar("d3", gnTMarg4)
    WPar("cr", gZnPrec)
    WPar("ot", gOdvT2)
    WPar("tb", gTabela)
    WPar("za", gZagl)   
    WPar("zb", gbold)
    WPar("RT", gRekTar)
    WPar("HL", gHLinija)
    WPar("rp", gRabProc)
    
    cSection := "F"
    WPar("x1", nDx1)
    WPar("x2", nDx2)
    WPar("x3", nDx3)
    WPar("x4", nSw1)
    WPar("x5", nSw2)
    WPar("x6", nSw3)
    WPar("x7", nSw4)
    WPar("x8", nSw5)
    WPar("x9", nSw6)
    WPar("y1", nSw7)

    cSection := "1"
    

    set_metric( "fakt_ispis_grupacije_na_dokumentu", nil, glRGrPrn )
    set_metric( "fakt_ispis_salda_kupca_dobavljaca", nil, gShSld )
    set_metric( "fakt_ispis_salda_kupca_dobavljaca_varijanta", nil, gShSldVar )
    set_metric( "konto_duguje", nil, gFinKtoDug )
    set_metric( "konto_potrazuje", nil, gFinKtoPot )

    set_metric( "fakt_dokument_dodati_redovi_po_listu", nil, gERedova )
    set_metric( "fakt_dokument_lijeva_margina", nil, gnLMarg )
    set_metric( "fakt_dokument_top_margina", nil, gnTMarg )
    set_metric( "fakt_dokument_delphirb_prikaz", nil, gPDVDrb )
    set_metric( "fakt_dokument_txt_prikaz_varijanta", nil, gPDVDokVar )

endif

return 



 
function fakt_par_nazivi_dokumenata()
private  GetList:={}

O_PARAMS

g10Str := PADR(g10Str,20)
g16Str := PADR(g16Str,20)
g06Str:=PADR(g06Str,20)
g11Str:=PADR(g11Str,20)
g12Str:=PADR(g12Str,20)
g13Str:=PADR(g13Str,20)
g15Str:=PADR(g15Str,20)
g20Str:=PADR(g20Str,20)
g21Str:=PADR(g21Str,20)
g22Str:=PADR(g22Str,20)
g23Str:=PADR(g23Str,20)
g25Str:=PADR(g25Str,20)
g26Str:=PADR(g26Str,24)
g27Str:=PADR(g27Str,20)

g10ftxt:=PADR(g10ftxt,100)
g11ftxt:=PADR(g11ftxt,100)
g12ftxt:=PADR(g12ftxt,100)
g13ftxt:=PADR(g13ftxt,100)
g15ftxt:=PADR(g15ftxt,100)
g16ftxt:=PADR(g16ftxt,100)
g20ftxt:=PADR(g20ftxt,100)
g21ftxt:=PADR(g21ftxt,100)
g22ftxt:=PADR(g22ftxt,100)
g23ftxt:=PADR(g23ftxt,100)
g25ftxt:=PADR(g25ftxt,100)
g26ftxt:=PADR(g26ftxt,100)
g27ftxt:=PADR(g27ftxt,100)

g10Str2T:=PADR(g10Str2T,132)
g16Str2T:=PADR(g16Str2T,132)
g06Str2T:=PADR(g06Str2T,132)
g11Str2T:=PADR(g11Str2T,132)
g15Str2T:=PADR(g15Str2T,132)
g12Str2T:=PADR(g12Str2T,132)
g13Str2T:=PADR(g13Str2T,132)
g20Str2T:=PADR(g20Str2T,132)
g21Str2T:=PADR(g21Str2T,132)
g22Str2T:=PADR(g22Str2T,132)
g23Str2T:=PADR(g23Str2T,132)
g25Str2T:=PADR(g25Str2T,132)
g26Str2T:=PADR(g26Str2T,132)
g27Str2T:=PADR(g27Str2T,132)
gNazPotStr:=PADR(gNazPotStr,132)

Box(,22,76,.f.,"Naziv dokumenata, potpis na kraju, str. 1")
    @ m_x+ 1,m_y+2 SAY "06 - Tekst"      GET g06Str
    @ m_x+ 2,m_y+2 SAY "06 - Potpis TXT" GET g06Str2T PICT"@S50"
    @ m_x+ 4,m_y+2 SAY "10 - Tekst"      GET g10Str
    @ m_x+ 4,col()+1 SAY "d.txt lista:" GET g10ftxt PICT "@S25"
    @ m_x+ 5,m_y+2 SAY "10 - Potpis TXT" GET g10Str2T PICT"@S50"
    @ m_x+ 7,m_Y+2 SAY "11 - Tekst"      GET g11Str
    @ m_x+ 7,col()+1 SAY "d.txt lista:" GET g11ftxt PICT "@S25"
    @ m_x+ 8,m_y+2 SAY "11 - Potpis TXT" GET g11Str2T PICT "@S50"
    @ m_x+10,m_y+2 SAY "12 - Tekst"      GET g12Str
    @ m_x+10,col()+1 SAY "d.txt lista:" GET g12ftxt PICT "@S25"
    @ m_x+11,m_y+2 SAY "12 - Potpis TXT" GET g12Str2T PICT "@S50"
    @ m_x+13,m_y+2 SAY "13 - Tekst"      GET g13Str
    @ m_x+13,col()+1 SAY "d.txt lista:" GET g13ftxt PICT "@S25"
    @ m_x+14,m_y+2 SAY "13 - Potpis TXT" GET g13Str2T PICT "@S50"
    @ m_x+16,m_y+2 SAY "15 - Tekst"      GET g15Str
    @ m_x+16,col()+1 SAY "d.txt lista:" GET g15ftxt PICT "@S25"
    @ m_x+17,m_y+2 SAY "15 - Potpis TXT" GET g15Str2T PICT "@S50"
    @ m_x+19,m_y+2 SAY "16 - Tekst"      GET g16Str
    @ m_x+19,col()+1 SAY "d.txt lista:" GET g16ftxt PICT "@S25"
    @ m_x+20,m_y+2 SAY "16 - Potpis TXT" GET g16Str2T PICT"@S50"
    read
BoxC()

Box(,22, 76,.f.,"Naziv dokumenata, potpis na kraju, str. 2")
    @ m_x+ 1,m_y+2 SAY "20 - Tekst"      GET g20Str
    @ m_x+ 1,col()+1 SAY "d.txt lista:" GET g20ftxt PICT "@S25"
    @ m_x+ 2,m_y+2 SAY "20 - Potpis TXT" GET g20Str2T PICT "@S50"
    @ m_x+ 4,m_y+2 SAY "21 - Tekst"      GET g21Str
    @ m_x+ 4,col()+1 SAY "d.txt lista:" GET g21ftxt PICT "@S25"
    @ m_x+ 5,m_y+2 SAY "21 - Potpis TXT" GET g21Str2T PICT "@S50"
    @ m_x+ 7,m_y+2 SAY "22 - Tekst"      GET g22Str
    @ m_x+ 7,col()+1 SAY "d.txt lista:" GET g22ftxt PICT "@S25"
    @ m_x+ 8,m_y+2 SAY "22 - Potpis TXT" GET g22Str2T PICT"@S50"
    
    @ m_x+ 10,m_y+2 SAY "23 - Tekst"      GET g23Str
    @ m_x+ 10,col()+1 SAY "d.txt lista:" GET g23ftxt PICT "@S25"
    @ m_x+ 11,m_y+2 SAY "23 - Potpis TXT" GET g23Str2T PICT"@S50"
    
    @ m_x+13,m_y+2 SAY "25 - Tekst"      GET g25Str
    @ m_x+13,col()+1 SAY "d.txt lista:" GET g25ftxt PICT "@S25"
    @ m_x+14,m_y+2 SAY "25 - Potpis TXT" GET g25Str2T PICT"@S50"
    @ m_x+16,m_y+2 SAY "26 - Tekst"      GET g26Str
    @ m_x+16,col()+1 SAY "d.txt lista:" GET g26ftxt PICT "@S25"
    @ m_x+17,m_y+2 SAY "26 - Potpis TXT" GET g26Str2T PICT"@S50"
    @ m_x+19,m_y+2 SAY "27 - Tekst"      GET g27Str
    @ m_x+19,col()+1 SAY "d.txt lista:" GET g27ftxt PICT "@S25"
    @ m_x+20,m_y+2 SAY "27 - Potpis TXT" GET g27Str2T PICT"@S50"
    @ m_x+22,m_y+2 SAY "Dodatni red    " GET gNazPotStr PICT"@S50"
    
    read
BoxC()

if (LASTKEY()<>K_ESC)

    set_metric( "fakt_dokument_dok_10_naziv", nil, g10Str )
    set_metric( "fakt_dokument_dok_10_potpis", nil, g10Str2T )
    set_metric( "fakt_dokument_dok_10_txt_lista", nil, g10ftxt )
    set_metric( "fakt_dokument_dok_11_naziv", nil, g11Str )
    set_metric( "fakt_dokument_dok_11_potpis", nil, g11Str2T )
    set_metric( "fakt_dokument_dok_11_txt_lista", nil, g11ftxt )
    set_metric( "fakt_dokument_dok_12_naziv", nil, g12Str )
    set_metric( "fakt_dokument_dok_12_potpis", nil, g12Str2T )
    set_metric( "fakt_dokument_dok_12_txt_lista", nil, g12ftxt )
    set_metric( "fakt_dokument_dok_13_naziv", nil, g13Str )
    set_metric( "fakt_dokument_dok_13_potpis", nil, g13Str2T )
    set_metric( "fakt_dokument_dok_13_txt_lista", nil, g13ftxt )
    set_metric( "fakt_dokument_dok_16_naziv", nil, g16Str )
    set_metric( "fakt_dokument_dok_16_potpis", nil, g16Str2T )
    set_metric( "fakt_dokument_dok_16_txt_lista", nil, g16ftxt )
    set_metric( "fakt_dokument_dok_20_naziv", nil, g20Str )
    set_metric( "fakt_dokument_dok_20_potpis", nil, g20Str2T )
    set_metric( "fakt_dokument_dok_20_txt_lista", nil, g20ftxt )
    set_metric( "fakt_dokument_dok_22_naziv", nil, g22Str )
    set_metric( "fakt_dokument_dok_22_potpis", nil, g22Str2T )
    set_metric( "fakt_dokument_dok_22_txt_lista", nil, g22ftxt )


    WPar("r3",g06Str)
    WPar("xl",@g15Str)
    WPar("x9",@g21Str)
    WPar("xC",@g23Str)
    WPar("xf",@g25Str)
    WPar("xi",@g26Str)
    WPar("xo",@g27Str)

    WPar("r4",@g06Str2T)
    WPar("xm",@g15Str2T)
    WPar("xa",@g21Str2T)
    WPar("xD",@g23Str2T)
    WPar("xg",@g25Str2T)
    WPar("xj",@g26Str2T)
    WPar("xp",@g27Str2T)
 
    WPar("uc",@gNazPotStr)

    // liste
    WPar("ye",@g15ftxt)
    WPar("yh",@g21ftxt)
    WPar("yI",@g23ftxt)
    WPar("yj",@g25ftxt)
    WPar("yk",@g26ftxt)
    WPar("yl",@g27ftxt)

endif

return 



function P_WinFakt()

cIniName:=EXEPATH+'proizvj.ini'

cFirma:=PADR(UzmiIzIni(cIniName,'Varijable','Firma','--','READ'),30)
cAdresa:=PADR(UzmiIzIni(cIniName,'Varijable','Adres','--','READ'),30)
cTelefoni:=PADR(UzmiIzIni(cIniName,'Varijable','Tel','--','READ'),50)
cFax:=PADR(UzmiIzIni(cIniName,'Varijable','Fax','--','READ'),30)
cRBroj:=PADR(UzmiIzIni(cIniName,'Varijable','RegBroj','--','READ'),13)
cPBroj:=PADR(UzmiIzIni(cIniName,'Varijable','PorBroj','--','READ'),13)
cBrSudRj:=PADR(UzmiIzIni(cIniName,'Varijable','BrSudRj','--','READ'),45)
cBrUpisa:=PADR(UzmiIzIni(cIniName,'Varijable','BrUpisa','--','READ'),45)
cZRac1:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun1','--','READ'),45)
cZRac2:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun2','--','READ'),45)
cZRac3:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun3','--','READ'),45)
cZRac4:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun4','--','READ'),45)
cZRac5:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun5','--','READ'),45)
cZRac6:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun6','--','READ'),45)
cNazivRtm:=PADR(IzFmkIni('Fakt','NazRTM','',EXEPATH),15)
cNazivFRtm:=PADR(IzFmkIni('Fakt','NazRTMFax','',EXEPATH),15)
cPictLoc:=PADR(UzmiIzIni(cIniName,'Varijable','LokSlika','--','READ'),30)
cDN:="D"

Box(,22,63)
    @ m_x+1,m_Y+2 SAY "Podesavanje parametara Win stampe:"
    @ m_x+3,m_Y+2 SAY "Naziv firme: " GET cFirma
    @ m_x+4,m_Y+2 SAY "Adresa: " GET cAdresa
    @ m_x+5,m_Y+2 SAY "Telefon: " GET cTelefoni
    @ m_x+6,m_Y+2 SAY "Fax: " GET cFax
    @ m_x+7,m_Y+2 SAY "Ziro racun 1: " GET cZRac1
    @ m_x+8,m_Y+2 SAY "Ziro racun 2: " GET cZRac2
    @ m_x+9,m_Y+2 SAY "Ziro racun 3: " GET cZRac3
    @ m_x+10,m_Y+2 SAY "Ziro racun 4: " GET cZRac4
    @ m_x+11,m_Y+2 SAY "Ziro racun 5: " GET cZRac5
    @ m_x+12,m_Y+2 SAY "Ziro racun 6: " GET cZRac6
    @ m_x+13,m_Y+2 SAY "Identifikac.broj: " GET cRBroj
    @ m_x+14,m_Y+2 SAY "Porezni dj. broj: " GET cPBroj
    @ m_x+15,m_Y+2 SAY "Br.sud.rjesenja: " GET cBrSudRj
    @ m_x+16,m_Y+2 SAY "Reg.broj upisa: " GET cBrUpisa
    
    @ m_x+17,m_Y+2 SAY "--------------------------------------------"
    @ m_x+18,m_Y+2 SAY "Lokacija slike: " GET cPictLoc
    @ m_x+19,m_Y+2 SAY "Naziv RTM fajla za fakture: " GET cNazivRtm
    @ m_x+20,m_Y+2 SAY "Naziv RTM fajla za slanje dok.faksom: " GET cNazivFRtm
    @ m_x+21,m_Y+2 SAY "Snimi podatke D/N? " GET cDN valid cDN $ "DN" pict "@!"
    read
BoxC()

if lastkey()=K_ESC
    return
endif

if cDN=="D"
    UzmiIzIni(cIniName,'Varijable','Firma',cFirma,'WRITE')
        UzmiIzIni(cIniName,'Varijable','Adres',cAdresa,'WRITE')
        UzmiIzIni(cIniName,'Varijable','Tel',cTelefoni,'WRITE')
        UzmiIzIni(cIniName,'Varijable','Fax',cFax,'WRITE')
        UzmiIzIni(cIniName,'Varijable','RegBroj',cRBroj,'WRITE')
        UzmiIzIni(cIniName,'Varijable','PorBroj',cPBroj,'WRITE')
        UzmiIzIni(cIniName,'Varijable','BrSudRj',cBrSudRj,'WRITE')
        UzmiIzIni(cIniName,'Varijable','BrUpisa',cBrUpisa,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun1',cZRac1,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun2',cZRac2,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun3',cZRac3,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun4',cZRac4,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun5',cZRac5,'WRITE')
        UzmiIzIni(cIniName,'Varijable','ZRacun6',cZRac6,'WRITE')
        UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTM',cNazivRtm,'WRITE')
        UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTMFax',cNazivFRtm,'WRITE')
        UzmiIzIni(cIniName,'Varijable','LokSlika',cPictLoc,'WRITE')
        MsgBeep("Podaci snimljeni!")
else
    return
endif

return



// ----------------------------------------------------
// specificne funkcije za fakturisanje uglja
// ----------------------------------------------------
function is_fakt_ugalj()
return .f.


// ----------------------------------------------------------------
// dodatni opis na stavke u fakt dokumentu
// ----------------------------------------------------------------
function fakt_opis_stavke(value)
return get_set_global_param("fakt_opis_stavke", value, "N")


// ----------------------------------------------------------------
// koriste se REF/LOT oznake
// ----------------------------------------------------------------
function ref_lot(value)
return get_set_global_param("ref_lot", value, "N")


// ----------------------------------------------------------------
// prate se destinacije
// ----------------------------------------------------------------
function destinacije(value)
return get_set_global_param("destinacije", value, "N")

// ----------------------------------------------------------------
// fakturise se po prodajnim mjestima
// ----------------------------------------------------------------
function fakt_prodajna_mjesta(value)
return get_set_global_param("fakt_prodajna_mjesta", value, "N")

// ----------------------------------------------------------------
// fakturise se po vrstama placanja
// ----------------------------------------------------------------
function fakt_vrste_placanja(value)
return get_set_global_param("fakt_unos_vrste_placanja", value, "N")

