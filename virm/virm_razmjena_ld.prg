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


#include "virm.ch"


static function _o_tables()

select (F_BANKE)
if !USED()
    O_BANKE
endif

select (F_JPRIH)
if !USED()
    O_JPRIH
endif

select (F_SIFK)
if !USED()
    O_SIFK
endif

select (F_SIFV)
if !USED()
    O_SIFV
endif

select (F_KRED)
if !USED()
    O_KRED
endif

select (F_REKLD)
if !USED()
    O_REKLD
endif

select (F_PARTN)
if !USED()
    O_PARTN
endif

select (F_VRPRIM)
if !USED()
    O_VRPRIM
endif

select (F_LDVIRM)
if !USED()
    O_LDVIRM
endif

select (F_VIPRIPR)
if !USED()
    O_VIRM_PRIPR
endif

return



// ------------------------------------------------------------------------
// prenos virmana iz modula LD
// ------------------------------------------------------------------------
function virm_prenos_ld( prenos_ld )
local _poziv_na_broj
local _dat_virm := DATE()
local _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "D" ) 
local _ispl_posebno := fetch_metric( "virm_isplate_za_radnike_posebno", my_user(), "N" ) 
local _dod_opis1 := "D"
local _racun_upl
local _per_od, _per_do
local _id_banka, _dod_opis
local _r_br, _firma

private _mjesec, _godina, broj_radnika

if prenos_ld == NIL
    prenos_ld := .f.
endif

_o_tables()

// uzmi parametre iz sql/db
_godina := fetch_metric( "virm_godina", my_user(), YEAR( DATE() ) )
_mjesec := fetch_metric( "virm_mjesec", my_user(), MONTH( DATE() ) ) 
_poziv_na_broj := fetch_metric( "virm_poziv_na_broj", my_user(), PADR( "", 10 ) ) 
_racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), SPACE(16) ) 
_firma := PADR( fetch_metric("virm_org_id", nil, "" ), 6 )

// period od-do
_per_od := CTOD("")
_per_do := _per_od

Box(, 10, 70 )

    @ m_x + 1, m_y + 2 SAY "GENERISANJE VIRMANA NA OSNOVU OBRACUNA PLATE"

    _id_banka := PADR( _racun_upl, 3 )

    @ m_x + 2, m_y + 2 SAY "Posiljaoc (sifra banke):       " GET _id_banka valid OdBanku( _firma, @_id_banka )
    read

    _racun_upl := _id_banka

    select virm_pripr

    @ m_x + 3, m_y + 2 SAY "Poziv na broj " GET _poziv_na_broj
    @ m_x + 4, m_y + 2 SAY "Godina" GET _godina PICT "9999"
    @ m_x + 5, m_y + 2 SAY "Mjesec" GET _mjesec  PICT "99"
    @ m_x + 7, m_y + 2 SAY "Datum" GET _dat_virm
    @ m_x + 8, m_y + 2 SAY "Porezni period od" GET _per_od
    @ m_x + 8, col() + 2 SAY "do" GET _per_do
    @ m_x + 9, m_y + 2 SAY "Isplate prebaciti pojedinacno za svakog radnika (D/N)?" GET _ispl_posebno VALID _ispl_posebno $ "DN" PICT "@!"
    @ m_x + 10, m_y + 2 SAY "Formirati samo stavke sa iznosima vecim od 0 (D/N)?" GET _bez_nula VALID _bez_nula $ "DN" PICT "@!"
    
    read

    ESC_BCR

BoxC()
    
set_metric( "virm_zr_uplatioca", my_user(), _racun_upl ) 
set_metric( "virm_godina", my_user(), _godina )
set_metric( "virm_mjesec", my_user(), _mjesec ) 
set_metric( "virm_poziv_na_broj", my_user(), _poziv_na_broj ) 
set_metric( "virm_generisanje_nule", my_user(), _bez_nula ) 
set_metric( "virm_isplate_za_radnike_posebno", my_user(), _ispl_posebno ) 

_dod_opis := ", za " + STR( _mjesec, 2 ) + "." + STR( _godina, 4 )

_r_br := 0

// obrada plate
obrada_plate( _godina, _mjesec, _dat_virm, @_r_br, _dod_opis, _per_od, _per_do )

// obradi kredite
obrada_kredita( _godina, _mjesec, _dat_virm, @_r_br, _dod_opis )

// obrada tekucih racuna
obrada_tekuci_racun( _godina, _mjesec, _dat_virm, @_r_br, _dod_opis )

// popuni polja javnih prihoda
filljprih()  

close all
return

// ---------------------------------------------------------------------------------------------
// obrada podataka za isplate na tekuci racun
// ---------------------------------------------------------------------------------------------
static function obrada_tekuci_racun( godina, mjesec, dat_virm, r_br, dod_opis )
local _oznaka := "IS_"
local _id_kred, _rec
local _formula, _izr_formula
local _svrha_placanja
local _poziv_na_broj := fetch_metric( "virm_poziv_na_broj", my_user(), PADR( "", 10 ) ) 
local _racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), SPACE(16) ) 
local _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" ) 
local _ispl_posebno := fetch_metric( "virm_isplate_za_radnike_posebno", my_user(), "N" ) 
local _isplata_opis := ""

select rekld
seek STR( godina, 4 ) + STR( mjesec, 2 ) + _oznaka

do while !EOF() .and. field->id = _oznaka 

    _id_kred := SUBSTR( field->id, 4 )  
    // sifra banke

    // nastimaj se na kreditora i dodaj po potrebi
    _ld_kreditor( _id_kred )     

    // pozicioniraj se na vrprim za isplatu
    _ld_vrprim_isplata()

    select vrprim

    _svrha_placanja := field->id
        
    select partn
    seek _id_kred

    _u_korist := field->id
    _kome_txt := field->naz
    _kome_sjed := field->mjesto
    _nacin_pl := "1"

    _kome_zr := SPACE(16)
    OdBanku( _u_korist, @_kome_zr, .f. )

    select virm_pripr
    go top   
        
    // uzmi podatke iz prve stavke
    _ko_txt := field->ko_txt
    _ko_zr := field->ko_zr

    select partn
    hseek gFirma

    _total := 0
    _kredit := 0
     
    select rekld
    _sk_sifra := field->idpartner 
    // SK=sifra kreditora/banke
     
    // isplate za jednu banku - sumirati
    if _ispl_posebno == "N"

        do while !EOF() .and. field->id = _oznaka .and. field->idpartner = _sk_sifra
            ++ _kredit
            _total += rekld->iznos1
            _isplata_opis := "obuhvaceno " + ALLTRIM( STR( _kredit ) ) + " radnika"
            skip 1
        enddo
        skip -1
     
    else
     
        // svaka isplata ce se tretirati posebno
        _kredit := 1
        _total := rekld->iznos1
        _isplata_opis := ALLTRIM( field->opis2 )

    endif

    select virm_pripr

    if _bez_nula == "N" .or. _total > 0
            
        append blank

        replace field->rbr with ++ r_br
        replace field->mjesto with gmjesto
        replace field->svrha_pl with "IS"
        replace field->iznos with _total
        replace field->na_teret with gFirma
        replace field->kome_txt with _kome_txt 
        replace field->ko_txt with _ko_txt
        replace field->ko_zr with _ko_zr
        replace field->kome_sj with _kome_sjed
        replace field->kome_zr with _kome_zr
        replace field->pnabr with _poziv_na_broj
        replace field->dat_upl with dat_virm
        replace field->svrha_doz with ALLTRIM( vrprim->pom_txt ) + " " + ALLTRIM( dod_opis ) + " " + _isplata_opis
        replace field->u_korist with _id_kred

        if _ispl_posebno == "D"
            // jedan radnik
            replace field->svrha_doz with TRIM( svrha_doz ) + ", tekuci rn:" + TRIM( rekld->opis )
        endif

    endif
 
    select rekld
    skip

enddo


return


// ----------------------------------------------------------------------------------------------------
// obrada virmana za regularnu isplatu plata, doprinosi, porezi itd...
// ----------------------------------------------------------------------------------------------------
static function obrada_plate( godina, mjesec, dat_virm, r_br, dod_opis, per_od, per_do )
local _broj_radnika
local _formula, _izr_formula
local _svrha_placanja
local _poziv_na_broj := fetch_metric( "virm_poziv_na_broj", my_user(), PADR( "", 10 ) ) 
local _racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), SPACE(16) ) 
local _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" ) 

private _kome_zr := ""
private _kome_txt := ""
private _budzorg := ""
private _idjprih := ""
 
select partn 
seek gFirma

_ko_txt := TRIM( partn->naz ) + ", " + ;
           TRIM( partn->mjesto ) + ", " + ;
           TRIM( partn->adresa ) + ", " + ;
           TRIM( partn->telefon )

_broj_radnika := ""  

select ldvirm
go top

do while !EOF()

    _formula := field->formula
     
    // nema formule - preskoci...
    if EMPTY( _formula )
        skip
        loop
    endif
     
    _svrha_placanja := ALLTRIM( field->id )

    select vrprim
    hseek ldvirm->id

    select partn
    hseek gFirma

    select virm_pripr
    
    _izr_formula := &_formula
    // npr. RLD("DOPR1XZE01")

    select virm_pripr

    if _bez_nula == "N" .or. _izr_formula > 0

        append blank

        replace field->rbr with ++ r_br
        replace field->mjesto with gMjesto
        replace field->svrha_pl with _svrha_placanja
        replace field->iznos with _izr_formula
        replace field->pnabr with _poziv_na_broj
        replace field->vupl with "0"

        // posaljioc
        replace field->na_teret with gFirma
        replace field->ko_txt with _ko_txt
        replace field->ko_zr with _racun_upl
        replace field->kome_txt with vrprim->naz

        _tmp_opis := TRIM( vrprim->pom_txt ) + ;
                IF( !EMPTY( dod_opis ), " " + ALLTRIM( dod_opis ), "" ) + ;
                IF( !EMPTY( broj_radnika ), " " + broj_radnika, "" ) 

        // resetuj varijable
        _kome_zr := ""
        _kome_txt := ""
        _budzorg := ""
       
        if PADR( vrprim->idpartner, 2 ) == "JP" 

            // javni prihodi
            // setuj varijable _kome_zr, _kome_txt , _budzorg
            SetJPVar()

            __kome_zr := _kome_zr
            __kome_txt := _kome_txt
            __budz_org := _budzorg
            __org_jed := gOrgJed
            __id_jprih := _idjprih  

        else

            if vrprim->dobav == "D"
                
                _kome_zr := PADR( _kome_zr, 3 )
                
                select partn
                seek vrprim->idpartner
                
                select virm_pripr
                
                MsgBeep( "Odrediti racun za partnera :" + vrprim->idpartner )
                OdBanku( vrprim->idpartner, @_kome_zr )

            else
                _kome_zr := vrprim->racun
            endif

            __kome_zr := _kome_zr
            __budz_org := "" 
            __org_jed := ""
            __id_jprih := ""
            _per_od := ctod("")
            _per_do := ctod("")

        endif

        replace field->kome_zr with __kome_zr
        replace field->dat_upl with dat_virm
        replace field->svrha_doz with _tmp_opis
        replace field->pod with per_od
        replace field->pdo with per_do
        replace field->budzorg with __budz_org
        replace field->bpo with __org_jed
        replace field->idjprih with __id_jprih

    endif

    select ldvirm
    skip 1

enddo 

return



static function _ld_vrprim_kredit()
local _rec
 
select vrprim
hseek PADR( "KR", LEN(field->id) ) 
 
if !FOUND()

    append blank
    _rec := dbf_get_rec()
    _rec["id"] := "KR"
    _rec["naz"] := "Kredit"
    _rec["pom_txt"] := "Kredit"
    _rec["nacin_pl"] := "1"
    _rec["dobav"] := "D"

    update_rec_server_and_dbf( "vrprim", _rec, 1, "FULL" )

endif

return



static function _ld_vrprim_isplata()
local _rec
 
select vrprim
hseek PADR( "IS", LEN(field->id) ) 
 
if !FOUND()

    append blank
    _rec := dbf_get_rec()
    _rec["id"] := "IS"
    _rec["naz"] := "Isplata na tekuci racun"
    _rec["pom_txt"] := "Plata"
    _rec["nacin_pl"] := "1"
    _rec["dobav"] := "D"

    update_rec_server_and_dbf( "vrprim", _rec, 1, "FULL" )

endif

return


static function _ld_kreditor( id_kred )
local _rec

select kred
hseek PADR( id_kred, LEN( kred->id ) )

select partn
hseek PADR( id_kred, LEN( partn->id ) )
     
if !FOUND()  

    // dodaj kreditora u listu partnera
    append blank

    _rec := dbf_get_rec()
    _rec["id"] := kred->id
    _rec["naz"] := kred->naz
    _rec["ziror"] := kred->ziro

    update_rec_server_and_dbf( "partn", _rec, 1, "FULL")

endif

return


// --------------------------------------------------------------------------------------
// obrada virmana za kredite
// --------------------------------------------------------------------------------------
static function obrada_kredita( godina, mjesec, dat_virm, r_br, dod_opis, bez_nula )
local _oznaka := "KRED"
local _id_kred, _rec
local _svrha_placanja, _u_korist
local _kome_txt, _kome_zr, _kome_sjed, _nacin_pl    
local _ko_zr, _ko_txt
local _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" ) 
local _total, _kredit, _sk_sifra
local _kred_opis := ""

// odraditi kredite
select rekld
seek STR( godina, 4 ) + STR( mjesec, 2 ) + _oznaka

do while !EOF() .and. field->id = _oznaka

    // sifra kreditora
    _id_kred := SUBSTR( field->id, 5 )  

    // nastimaj kreditora i dodaj po potrebi
    _ld_kreditor( _id_kred )     

    // vrsta primanja - kredit
    _ld_vrprim_kredit()

    select vrprim
    _svrha_placanja := field->id

    select partn
    seek _id_kred

    _u_korist := field->id
    _kome_txt := field->naz
    _kome_sjed := field->mjesto
    _nacin_pl := "1"
    _kome_zr := SPACE(16)
     
    OdBanku( _u_korist, @_kome_zr, .f. )

    select virm_pripr
    go top   

    // uzmi podatke iz prve stavke
    _ko_txt := field->ko_txt
    _ko_zr := field->ko_zr

    select partn
    hseek gFirma

    _total := 0
    _kredit := 0

    select rekld
    _sk_sifra := field->idpartner 
    // SK=sifra kreditora

    do while !EOF() .and. field->id = "KRED" .and. field->idpartner = _sk_sifra
        ++ _kredit
        _total += rekld->iznos1
        _kred_opis := ALLTRIM( field->opis2 )
        skip 1
    enddo
    skip -1

    select virm_pripr

    if _bez_nula == "N" .or. _total > 0
       
        append blank

        replace field->rbr with ++ r_br
        replace field->mjesto with gMjesto
        replace field->svrha_pl with "KR"
        replace field->iznos with _total
        replace field->na_teret with gFirma
        replace field->kome_txt with _kome_txt
        replace field->ko_txt with _ko_txt
        replace field->ko_zr with _ko_zr
        replace field->kome_sj with _kome_sjed
        replace field->kome_zr with _kome_zr
        replace field->dat_upl with dat_virm
        replace field->svrha_doz with ALLTRIM( vrprim->pom_txt ) + " " + ALLTRIM( dod_opis ) + " " + _kred_opis
        replace field->u_korist with _id_kred

    endif

    select rekld
    skip

enddo

return



// --------------------------------------------
// RLD, funkcija koju zadajemo 
// kao formulu pri prenosu...
// --------------------------------------------
function RLD( cId, nIz12, qqPartn, br_dok )
local nPom1 := 0
local nPom2 := 0

if nIz12 == NIL
    nIz12 := 1
endif

// prolazim kroz rekld i trazim npr DOPR1XSA01
rekapld( cId, _godina, _mjesec, @nPom1, @nPom2, , @broj_radnika, qqPartn )

if VALTYPE(nIz12) == "N" .and. nIz12 == 1
    return nPom1
else
    return nPom2
endif

return 0




// --------------------------------------
// Rekapitulacija LD-a
// --------------------------------------
static function Rekapld( cId, ;
        nGodina, ;
        nMjesec, ;
        nIzn1, ;
        nIzn2, ;
        cIdPartner, ;
        cOpis, ;
        qqPartn )

local lGroup := .f.

PushWA()

if cIdPartner == NIL
    cIdPartner := ""
endif

if cOpis == NIL
    cOpis := ""
endif

// ima li marker "*"
if "**" $ cId
    lGroup := .t.
    // izbaci zvjezdice..
    cId := STRTRAN(cId, "**", "")
endif

select rekld
go top

if qqPartn == NIL
    
    hseek STR( nGodina, 4) + STR( nMjesec, 2) + cId
    
    if lGroup == .t.
    
        do while !EOF() .and. STR( nGodina, 4 ) == field->godina ;
                .and. STR( nMjesec, 2 ) == field->mjesec ;
                .and. id = cId
        
                nIzn1 += field->iznos1
                nIzn2 += field->iznos2
        
                skip
        enddo
        
    else

        nIzn1 := field->iznos1
        nIzn2 := field->iznos2

    endif
    
    cIdPartner := field->idpartner
    cOpis := field->opis

else

    nIzn1 := 0
    nIzn2 := 0
    nRadnika := 0
    aUslP := Parsiraj( qqPartn, "IDPARTNER" )

    seek STR( nGodina, 4 ) + STR( nMjesec, 2 ) + cId

    do while !EOF() .and. field->godina + field->mjesec + field->id = STR( nGodina, 4 ) + STR( nMjesec, 2 ) + cId
        
        if &aUslP
                
            nIzn1 += field->iznos1
            nIzn2 += field->iznos2
                
            if LEFT( field->opis, 1 ) == "("

                cOpis := field->opis
                cOpis := STRTRAN( cOpis, "(", "" )
                cOpis := ALLTRIM( STRTRAN( cOpis, ")", "" ))
                nRadnika += VAL( cOpis )

            endif

        endif

        skip 1

    enddo
    
    cIdPartner := ""

    if nRadnika > 0
        cOpis := "(" + ALLTRIM( STR( nRadnika )) + ")"
    else
        cOpis := ""
    endif

endif

PopWA()

return



