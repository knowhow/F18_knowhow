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


#include "kalk.ch"


// ---------------------------------------------------------------------
// centralna funkcija za azuriranje kalkulacije
// poziva raznorazne funkcije, generisanje dokumenata, provjere
// azuriranje u dbf, sql itd...
// ---------------------------------------------------------------------
function azur_kalk( lAuto )
local lViseDok := .f.
local aRezim := {}
local aOstaju := {}
local lGenerisiZavisne := .f.
local lBrStDoks := .f.

if ( lAuto == nil )
    lAuto := .f.
endif

if !lAuto .and. Pitanje(, "Zelite li izvrsiti azuriranje KALK dokumenta (D/N) ?", "N") == "N"
    return
endif

O_KALK_PRIPR
select kalk_pripr
go top

if kalk_doc_exist( kalk_pripr->idfirma, kalk_pripr->idvd, kalk_pripr->brdok )
    MsgBeep( "Dokument " + kalk_pripr->idfirma + "-" + kalk_pripr->idvd + "-" + ;
             ALLTRIM(kalk_pripr->brdok) + " vec postoji u bazi !#Promjenite broj dokumenta pa ponovite proceduru." )
    return
endif

select kalk_pripr
go top

// provjeri redne brojeve
if !provjeri_redni_broj()
    MsgBeep( "Redni brojevi dokumenta nisu ispravni !!!" )
    return 
endif

// isprazni kalk_pripr2
// trebat ce nam poslije radi generisanja zavisnih dokumenata
O_KALK_PRIPR2
my_dbf_zap()
use

lViseDok := kalk_provjeri_duple_dokumente( @aRezim )

// otvori potrebne tabele za azuriranje
// parametar .t. je radi rasporeda troskova
// to odradi samo jednom

o_kalk_za_azuriranje( .t. )

select kalk_doks

if fieldpos("ukstavki") <> 0
    lBrStDoks := .t.
endif

// provjeri razne uslove, metode itd...
if gCijene == "2" .and. !kalk_provjera_integriteta( @aOstaju, lViseDok )
    // nisu zadovoljeni uslovi, bjaži...
    return
endif

// provjeri vpc, itd...
if !kalk_provjera_cijena()
    // nisu zadovoljeni uslovi, bjaži....
    return
endif

// treba li generisati šta-god ?
lGenerisiZavisne := kalk_generisati_zavisne_dokumente( lAuto )

if lGenerisiZavisne = .t.
    // generiši, 11-ke, 96-ce itd...
    kalk_zavisni_dokumenti()
endif

// azuriraj kalk dokument !
if kalk_azur_sql()
   
    o_kalk_za_azuriranje()
    
    if !kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
        MsgBeep("Neuspjesno KALK/DBF azuriranje !?")
        return
    endif

else
    MsgBeep("Neuspjesno KALK/SQL azuriranje !?")
    return
endif

// pobrisi mi fakt_atribute takodjer
F18_DOK_ATRIB():new("kalk", F_KALK_ATRIB):zapp_local_table()

// generisi zavisne dokumente nakon azuriranja kalkulacije
kalk_zavisni_nakon_azuriranja( lGenerisiZavisne, lAuto )

// ostavi duple dokumente ili pobrisi pripemu
if lViseDok == .t. .and. LEN( aOstaju ) > 0
    kalk_ostavi_samo_duple( aOstaju )
else
    // pobrisi kalk_pripr
    select kalk_pripr
    my_dbf_zap()

endif

if lGenerisiZavisne = .t.
    // vrati iz pripr2 dokumente, ako postoje !
    kalk_vrati_iz_pripr2()
endif

close all

return



// ---------------------------------------------------------------------
// vraca iz tabele kalk_pripr2 sve sto je generisano
// da bi se moglo naknadno obraditi
// recimo kalk 16/96 itd...
// ---------------------------------------------------------------------
static function kalk_vrati_iz_pripr2()
local lPrebaci := .f.
local _rec

O_KALK_PRIPR
O_KALK_PRIPR2

if field->idvd $ "18#19"  
    // otprema
    if kalk_pripr2->(reccount2())<>0
        Beep(1)
        Box(,4,70)
        @ m_x+1,m_y+2 SAY "1. Cijene robe su promijenjene."
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument nivelacije:" + kalk_pripr2->(idfirma+"-"+idvd+"-"+brdok)
        @ m_x+3,m_y+2 SAY "3. Nove cijene su stavljene u sifrarnik."
        @ m_x+4,m_y+2 SAY "3. Obradite ovaj dokument."
        inkey(0)
        BoxC()
        lPrebaci := .t.
    endif

elseif field->idvd $ "95"  
    // otprema
    if kalk_pripr2->(reccount2())<>0
        Beep(1)
        Box(,4,70)
        @ m_x+1,m_y+2 SAY "1. Formiran je dokument 95 na osnovu inventure."
        @ m_x+4,m_y+2 SAY "3. Obradite ovaj dokument."
        inkey(0)
        BoxC()
        lPrebaci := .t.
    endif

elseif field->idvd $ "16" .and. gGen16 == "1" 
   // nakon otpreme doprema
    if kalk_pripr2->(reccount2())<>0
        Beep(1)
        Box(,4,70)
        @ m_x+1,m_y+2 SAY "1. Roba je otpremljena u magacin "+kalk_pripr2->idkonto
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument dopreme:"+kalk_pripr2->(idfirma+"-"+idvd+"-"+brdok)
        @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
        inkey(0)
        BoxC()
        lPrebaci := .t.
    endif

elseif field->idvd $ "11"  
    // nakon povrata unos u drugu prodavnicu
    if kalk_pripr2->(reccount2())<>0
        Beep(1)
        Box(,4,70)
        @ m_x+1,m_y+2 SAY "1. Roba je prenesena u prodavnicu "+kalk_pripr2->idkonto
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument zaduzenja:"+kalk_pripr2->(idfirma+"-"+idvd+"-"+brdok)
        @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
        inkey(0)
        BoxC()
        lPrebaci := .t.
    endif
endif

if lPrebaci == .t.

    select kalk_pripr2
    do while !EOF()

        _rec := dbf_get_rec()
        select kalk_pripr
        append blank
        dbf_update_rec( _rec )
        select kalk_pripr2
        skip

    enddo

    select kalk_pripr2
    my_dbf_zap() 

endif

return


// ------------------------------------------------------------------------
// generisanje zavisnih dokumenata nakon azuriranja kalkulacije
// mozda cemo dobiti i nove dokumente u pripremi
// ------------------------------------------------------------------------
static function kalk_zavisni_nakon_azuriranja( lGenerisi, lAuto )
local lForm11 := .f.
local cNext11 := ""
local cOdg := "D"
local lgAFin := gAFin
local lgAMat := gAMat

o_kalk_za_azuriranje()

// generisanje 11-ke iz 10-ke
if Generisati11_ku()
    lForm11 := .t.
    cNext11 := SljBrKalk("11", gFirma)
    Generisi11ku_iz10ke( cNext11 )
endif

select KALK

if lGenerisi = .t. 

    RekapK()
 
    if ( gafin == "D" .or. gaMat == "D" )
        kalk_kontiranje_naloga( .t., lAuto )
    endif

    P_Fin( lAuto )

    gAFin := lgAFin
    gAMat := lgAMat

    O_KALK_PRIPR

    if field->idvd $ "10#12#13#16#11#95#96#97#PR#RN" .and. gAFakt=="D"

        if field->idvd $ "16#96"
            cOdg := "N"
        endif

        if Pitanje(,"Formirati dokument u FAKT ?", cOdg)=="D"
            
            P_Fakt()
            o_kalk_za_azuriranje()

        endif

    endif

endif

// 11-ku obradi iz smeca
if lForm11 == .t.
    Get11FromSmece( cNext11 )
endif

return


// ----------------------------------------------------------------
// ova opcija ce pobrisati iz pripreme samo one dokumente koji 
// postoje medju azuriranim 
// ----------------------------------------------------------------
static function kalk_ostavi_samo_duple( lViseDok, aOstaju )

// izbrisi samo azurirane
select kalk_pripr

GO TOP
DO WHILE !EOF()
    SKIP 1
    nRecNo:=RECNO()
    SKIP -1
    IF ASCAN(aOstaju, field->idfirma + field->idvd + field->brdok) = 0
        DELETE
    ENDIF
    GO (nRecNo)
ENDDO
my_dbf_pack()

MsgBeep("U kalk_pripremi su ostali dokumenti koji izgleda da vec postoje medju azuriranim!")
  
return



// -------------------------------------------------------
// treba li generisati dokumente ?
// -------------------------------------------------------
static function kalk_generisati_zavisne_dokumente( lAuto )
local lGen := .f.

if gCijene == "2"
    lGen := .t.
else
    if gMetodaNC == " "
        lGen := .f.
    elseif lAuto == .t.
        lGen := .t.
    else
        lGen := Pitanje(,"Zelite li formirati zavisne dokumente pri azuriranju","D") == "D"
    endif
endif

return lGen



// ---------------------------------------------------------
// generisanje zavisnih dokumenata
// prije azuriranja kalkulacije u dbf i sql
// ---------------------------------------------------------
static function kalk_zavisni_dokumenti()

if !(IsMagPNab() .or. IsMagSNab())
    // ako nije slucaj da je
    // 1. pdv rezim magacin po nabavnim cijenama
    // ili
    // 2. magacin samo po nabavnim cijenama
        
    // nivelacija 10,94,16
    Niv_10()  
endif
    
Niv_11() 
// nivelacija 11,81

Otprema() 
// iz otpreme napravi ulaza
Iz13u11()  
// prenos iz prodavnice u prodavnicu
    
// inventura magacina - manjak / visak
InvManj()
    
return



// ----------------------------------------------------------------------------
// azuriranje podataka u dbf
// ----------------------------------------------------------------------------
static function kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
local cIdFirma, _rec
local cIdVd
local cBrDok
local cNPodBr
local nNv := 0
local nVpv := 0
local nMpv := 0
local nRabat := 0
local cOpis
local nBrStavki

Tone(360,2)

MsgO( "Azuriram pripremu u DBF tabele...")

select kalk_pripr
go top

cIdFirma := field->idfirma

select kalk_doks
set order to tag "3"
seek cIdfirma + dtos( kalk_pripr->datdok ) + chr(255)
skip -1

if field->datdok == kalk_pripr->datdok
    if  kalk_pripr->idvd $ "18#19" .and. kalk_pripr->TBankTr=="X"    
        // rijec je o izgenerisanom dokumentu
        if len(field->podbr) > 1
            cNPodbr:=chr256(asc256(field->podbr)-3)
        else
            cNPodbr:=chr(asc(field->podbr)-3)
        endif
    else    
        if len(field->podbr) > 1
            cNPodbr:=chr256(asc256(field->podbr)+6)
        else
            cNPodbr:=chr(asc(field->podbr)+6)
        endif
    endif
else    
    if len(field->podbr) > 1
        cNPodbr:=chr256(30*256+30)
    else
        cNPodbr:=chr(30)
    endif
endif

select kalk_pripr
go top

do while !eof()

    cIdFirma := field->idfirma
    cBrDok := field->brdok
    cIdvd := field->idvd
  
    if lViseDok .and. ASCAN( aOstaju, cIdFirma + cIdVd + cBrDok ) <> 0  
        // preskoci postojece
        skip 1
        loop
    endif
    
    // azuriranje tabele KALK_DOKS.DBF

    select kalk_doks
    append blank
    
    _rec := dbf_get_rec()
    _rec["idfirma"] := cIdFirma
    _rec["idvd"] := cIdVd
    _rec["brdok"] := cBrDok
    _rec["datdok"] := kalk_pripr->datdok
    _rec["idpartner"] := kalk_pripr->idpartner
    _rec["mkonto"] := kalk_pripr->mkonto
    _rec["pkonto"] := kalk_pripr->pkonto
    _rec["idzaduz"] := kalk_pripr->idzaduz
    _rec["idzaduz2"] := kalk_pripr->idzaduz2
    _rec["brfaktp"] := kalk_pripr->brfaktp

    dbf_update_rec( _rec, .t. )
 
    if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
        
        cOpis := cIDFirma + "-" + cIdVd + "-" + ALLTRIM(cBrDok)

        EventLog(nUser,goModul:oDataBase:cName,"DOK","AZUR",nil,nil,nil,nil,cOpis, "", "", kalk_pripr->datdok, Date(),"","Azuriranje dokumenta")
    
    endif

    // azuriranje tabele KALK_KALK.DBF

    select kalk_pripr
    go top

    nBrStavki := 0
    
    do while !eof() .and. cIdfirma == field->idfirma .and. cBrdok == field->brdok .and. cIdvd == field->idvd
            
        ++ nBrStavki
        _rec := dbf_get_rec()
        _rec["podbr"] := cNPodbr
        
        select kalk
        append blank

        dbf_update_rec( _rec, .t. )

        if cIdVd == "97"

            _rec := dbf_get_rec()
            append blank

            _rec["tbanktr"] := "X"
            _rec["mkonto"] := _idkonto
            _rec["mu_i"] := "1"
            _rec["rbr"] := PADL( STR( 900 + VAL( ALLTRIM( _rbr ) ), 3 ), 3 )

            dbf_update_rec( _rec, .t. )

        endif
   
        select kalk_pripr
        
        if !( cIdVd $ "97" )
            // setuj nnv, nmpv ....
            kalk_set_doks_total_fields( @nNv, @nVpv, @nMpv, @nRabat ) 
        endif

        skip
    
    enddo

    select kalk_doks

    _rec := dbf_get_rec()

    _rec["nv"] := nNv
    _rec["vpv"] := nVpv
    _rec["rabat"] := nRabat
    _rec["mpv"] := nMpv
    _rec["podbr"] := cNPodBr

    if lBrStDoks
        _rec["ukstavki"] := nBrStavki
    endif

    dbf_update_rec( _rec, .t. )

    select kalk_pripr

enddo

MsgC()

return .t.



static function kalk_provjera_cijena()
local cIdFirma
local cIdVd
local cBrDok

O_KALK_PRIPR

select kalk_pripr
go top

do while !eof()

    cIdFirma := field->idfirma
    cIdVd := field->idvd
    cBrDok := field->brdok

    do while !eof() .and. cIdfirma == field->idfirma .and. cIdvd == field->idvd .and. cBrdok == field->brdok
        if field->idvd == "11".and. field->vpc == 0
            Beep(1)
            Msg('VPC = 0, pozovite "savjetnika" sa <Alt-H>!')
            close all
            return .f.
        endif
        skip
    enddo

    select kalk_pripr

enddo 

return .t.


// ------------------------------------------------------------
// ------------------------------------------------------------
static function kalk_provjera_integriteta( aDoks, lViseDok )
local nBrDoks
local cIdFirma
local cIdVd
local cBrDok
local dDatDok
local cIdZaduz2

o_kalk_za_azuriranje()

select kalk_pripr
go top

nBrDoks := 0

do while !eof()

    ++ nBrDoks

    cIdFirma := field->idfirma
    cIdVd := field->idvd
    cBrDok := field->brdok
    dDatDok := field->datdok
    cIdzaduz2 := field->idzaduz2

    do while !eof() .and. cIdFirma == field->idfirma .and. cIdVd == field->idvd .and. cBrdok == field->brdok

        if gMetodaNC <> " " .and. ( field->error == "1" .and. field->tbanktr == "X" )
            Beep(2)
            MSG("Izgenerisane stavke su ispravljane, azuriranje nece biti izvrseno",6)
            close all
            return .f.
        endif

        if gMetodaNC <> " " .and. field->error == "1"
            Beep(2)
            MSG("Utvrdjena greska pri obradi dokumenta, rbr: "+rbr,6)
            close all
            return .f.
        endif

        if !(IsJerry() .and. cIdVd = "4")
            if gMetodaNC <> " " .and. field->error == " "
                Beep(2)
                MSG("Dokument je izgenerisan, pokrenuti opciju <A> za obradu",6)
                close all
                return .f.
            endif
            if dDatDok <> field->datdok
                Beep(2)
                if Pitanje(,"Datum razlicit u odnosu na prvu stavku. Ispraviti ?", "D") == "D"
                    replace field->datdok with dDatDok
                else
                    close all
                    return .f.
                endif
            endif
        endif
    
        if field->idvd <> "24" .and. empty(field->mu_i) .and. empty(field->pu_i)
            Beep(2)
            Msg("Stavka broj " + field->rbr + ". neobradjena , sa <A> pokrenite obradu")
            close all
            return .f.
        endif
        
        if cIdzaduz2 <> field->idzaduz2
            Beep(2)
            Msg("Stavka broj " + field->rbr + ". razlicito polje RN u odnosu na prvu stavku")
            close all
            return .f.
        endif

        skip
    
    enddo

    select kalk
    seek cIdFirma + cIdVD + cBrDok
    
    if found()
        Beep(1)
        Msg("Vec postoji dokument pod brojem " + cIdFirma + "-" + cIdvd + "-" + ALLTRIM(cBrDok) )
        if !lViseDok
            close all
            return .f.
        else
            AADD( aDoks, cIdFirma + cIdVd + cBrDok )
        endif
    endif

    select kalk_pripr

enddo 

if gMetodaNC <> " " .and. nBrDoks > 1
    Beep(1)
    Msg("U kalk_pripremi je vise dokumenata.Prebaci ih u smece, pa obradi pojedinacno")
    close all
    return .f.
endif

close all

return .t.



// provjerava da li u pripremi postoji vise dokumeata
static function kalk_provjeri_duple_dokumente( aRezim )
local lViseDok := .f.

O_KALK_PRIPR
go bottom

cTest := field->idfirma + field->idvd + field->brdok

go top

if cTest <> field->idfirma + field->idvd + field->brdok
    Beep(1)
    Msg("U kalk_pripremi je vise dokumenata! Ukoliko zelite da ih azurirate sve#"+;
      "odjednom (npr.ako ste ih preuzeli sa drugog racunara putem diskete)#"+;
      "na sljedece pitanje odgovorite sa 'D' i dokumenti ce biti azurirani#"+;
      "bez provjera koje se vrse pri redovnoj obradi podataka.")
    if Pitanje(,"Zelite li bezuslovno dokumente azurirati? (D/N)","N")=="D"
        
        lViseDok := .t.
        aRezim := {}

        AADD(aRezim, gCijene )
        AADD(aRezim, gMetodaNC )
        gCijene   := "1"
        gMetodaNC := " "
    endif

elseif gCijene == "2"       
    // ako je samo jedan dokument u kalk_pripremi

    DO WHILE !EOF()         
        // i strogi rezim rada
        IF ERROR=="1"
            Beep(1)
            Msg("Program je kontrolisuci redom stavke utvrdio da je stavka#"+;
                "br."+rbr+" sumnjiva! Ukoliko bez obzira na to zelite da izvrsite#"+;
                "azuriranje ovog dokumenta, na sljedece pitanje odgovorite#"+;
                "sa 'D'.")
            IF Pitanje(,"Zelite li dokument azurirati bez obzira na upozorenje? (D/N)","N")=="D"
                aRezim := {}
                AADD(aRezim, gCijene )
                AADD(aRezim, gMetodaNC )
                gCijene   := "1"
            ENDIF
            EXIT
        ENDIF
        SKIP 1
    ENDDO

endif

return lViseDok



// -------------------------------------------------
// otvori tabele za azuriranje
// -------------------------------------------------
static function o_kalk_za_azuriranje( raspored_tr )

if raspored_tr == NIL
    raspored_tr := .f.
endif

// prvo zatvori sve tabele
close all

O_KALK_PRIPR
O_KALK
O_KALK_DOKS2
O_KALK_DOKS

// vidi treba li rasporediti troskove
if raspored_tr
    _raspored_troskova()
endif

return


// ----------------------------------------------------------------
// raspored troskova
// ----------------------------------------------------------------
static function _raspored_troskova()
select kalk_pripr

if (( field->tprevoz == "R" .or. field->TCarDaz == "R" .or. field->TBankTr == "R" .or. ;
   field->TSpedTr == "R" .or. field->TZavTr == "R" ) .and. field->idvd $ "10#81" )  .or. ;
   field->idvd $ "RN"

    O_SIFK
    O_SIFV
    O_ROBA
    O_TARIFA
    O_KONCIJ

    select kalk_pripr
    RaspTrosk( .t. )

endif

return




// ----------------------
// ----------------------
static function kalk_azur_sql()
local _ok := .t.
local _record := hb_hash()
local _doks_nv := 0
local _doks_vpv := 0
local _doks_mpv := 0
local _doks_rabat := 0
local _tbl_kalk
local _tbl_doks
local _i, _n
local _tmp_id
local _ids := {}
local _ids_kalk := {}
local _ids_doks := {}
local _log_dok
local oAtrib

_tbl_kalk := "kalk_kalk"
_tbl_doks := "kalk_doks"

Box(, 5, 60)

_tmp_id := "x"

// otvori tabele
o_kalk_za_azuriranje()

if !f18_lock_tables({_tbl_kalk, _tbl_doks})
    MsgBeep("lock tabela neuspjesan, azuriranje prekinuto")
    return .f.
endif

// end lock semaphores --------------------------------------------------

sql_table_update(nil, "BEGIN")
  
select kalk_pripr
go top

_record := dbf_get_rec()
// algoritam 2 - dokument nivo
_tmp_id := _record["idfirma"] + _record["idvd"] + _record["brdok"]
AADD( _ids_kalk, "#2" + _tmp_id )

_log_dok := _record["idfirma"] + "-" + _record["idvd"] + "-" + _record["brdok"]

@ m_x + 1, m_y + 2 SAY "kalk_kalk -> server: " + _tmp_id 

do while !eof()

    // setuj total varijable za upisivanje u tabelu doks   
    kalk_set_doks_total_fields( @_doks_nv, @_doks_vpv, @_doks_mpv, @_doks_rabat ) 
 
    _record := dbf_get_rec()

    if !sql_table_update("kalk_kalk", "ins", _record )
        _ok := .f.
        exit
    endif

    if _record["idvd"] == "97"

        // dodaj zapis za 97-cu
        _record["tbanktr"] := "X"
        _record["mkonto"] := _record["idkonto"]
        _record["mu_i"] := "1"
        _record["rbr"] := PADL( STR( 900 + VAL( ALLTRIM( _record["rbr"] ) ), 3 ), 3 )
    
        if !sql_table_update("kalk_kalk", "ins", _record )
            _ok := .f.
            exit
        endif

    endif

    SKIP

enddo

if _ok = .t.

    // ubaci zapis u tabelu doks
    select kalk_pripr
    go top

    _record := hb_hash()
  
    _record["idfirma"] := field->idfirma
    _record["idvd"] := field->idvd
    _record["brdok"] := field->brdok
    _record["datdok"] := field->datdok
    _record["brfaktp"] := field->brfaktp
    _record["idpartner"] := field->idpartner
    _record["idzaduz"] := field->idzaduz
    _record["idzaduz2"] := field->idzaduz2
    _record["pkonto"] := field->pkonto
    _record["mkonto"] := field->mkonto
    _record["nv"] := _doks_nv
    _record["vpv"] := _doks_vpv
    _record["rabat"] := _doks_rabat
    _record["mpv"] := _doks_mpv
    _record["podbr"] := field->podbr
    _record["sifra"] := SPACE(6)

    // za ids-ove 
    _tmp_id := _record["idfirma"] + _record["idvd"] + _record["brdok"]
    AADD( _ids_doks, _tmp_id )

    @ m_x + 2, m_y + 2 SAY "kalk_doks -> server: " + _tmp_id 

    if !sql_table_update("kalk_doks", "ins", _record )
         _ok := .f.
    endif
   
endif

if _ok == .t.

    @ m_x + 3, m_y + 2 SAY "kalk_atributi -> server "

    oAtrib := F18_DOK_ATRIB():new("kalk", F_KALK_ATRIB)
    oAtrib:dok_hash["idfirma"] := _record["idfirma"]
    oAtrib:dok_hash["idtipdok"] := _record["idvd"]
    oAtrib:dok_hash["brdok"] := _record["brdok"]

    _ok := oAtrib:atrib_dbf_to_server()

endif


if !_ok

    _msg := "kalk azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"

    log_write( _msg, 2 )
    MsgBeep(_msg)
    // transakcija neuspjesna
    // server nije azuriran 
    sql_table_update(nil, "ROLLBACK" )
    f18_free_tables({_tbl_kalk, _tbl_doks})

else

    @ m_x+4, m_y+2 SAY "push ids to semaphore"
    push_ids_to_semaphore( _tbl_kalk , _ids_kalk )
    push_ids_to_semaphore( _tbl_doks  , _ids_doks  )

    // kalk 
    @ m_x+5, m_y+2 SAY "update semaphore version"

    f18_free_tables({_tbl_kalk, _tbl_doks})
    sql_table_update(nil, "END")

    // logiraj operaciju
    log_write( "F18_DOK_OPER: azuriranje kalk dokumenta: " + _log_dok, 2 )

endif

BoxC()

return _ok



// -----------------------------------------------------------
// napuni matricu sa podacima pripreme
// -----------------------------------------------------------
static function _pripr_2_arr()
local _arr := {}
local _scan

select kalk_pripr
go top

do while !EOF()

    _scan := ASCAN( _arr, { | var | var[1] == field->idfirma .and. ;
                                    var[2] == field->idvd .and. ;
                                    var[3] == field->brdok  } )

    if _scan == 0
        AADD( _arr, { field->idfirma, field->idvd, field->brdok, 0 } )
    endif

    skip

enddo

return _arr


// ----------------------------------------------------------
// provjeri da li već postoje dokumenti u smeću 
// ----------------------------------------------------------
static function _provjeri_smece( arr )
local _i
local _ctrl 

for _i := 1 to LEN( arr )

    _ctrl := arr[ _i, 1 ] + arr[ _i, 2 ] + arr[ _i, 3 ]

    select kalk_pripr9
    seek _ctrl
    
    if FOUND()
        // setuj u matrici da ovaj dokument postoji
        arr[ _i, 4 ] := 1
    endif

next

return




// ------------------------------------------------------------
// azuriranje kalk_pripr9 tabele
// koristi se za smece u vecini slucajeva
// ------------------------------------------------------------
function azur_kalk_pripr9()
local lGen := .f.
local cPametno := "D" 
local cIdFirma
local cIdvd
local cBrDok
local _a_pripr
local _i, _rec, _scan
local _id_firma, _id_vd, _br_dok

O_KALK_PRIPR9
O_KALK_PRIPR

select kalk_pripr
go top

if kalk_pripr->(RECCOUNT()) == 0
    return
endif

if Pitanje("p1", "Zelite li pripremu prebaciti u smece (D/N) ?", "N" ) == "N"
    return
endif

// prebaci iz pripreme dokumente u matricu
_a_pripr := _pripr_2_arr()

// usaglasi dokumente sa smecem
// da li vec neki dokumenti postoje
_provjeri_smece( @_a_pripr )

// sada imamo stanje sta treba prenjeti a sta ne...

select kalk_pripr 
go top

do while !EOF()

    _scan := ASCAN( _a_pripr, { |var| var[1] == field->idfirma .and. ;
                                    var[2] == field->idvd .and. ;
                                    var[3] == field->brdok } ) 

    if _scan > 0 .and. _a_pripr[ _scan, 4 ] == 0
        
        // treba ga prebaciti !
        _id_firma := field->idfirma
        _id_vd := field->idvd
        _br_dok := field->brdok

        do while !EOF() .and. field->idfirma + field->idvd + field->brdok == _id_firma + _id_vd + _br_dok

            _rec := dbf_get_rec()       

            select kalk_pripr9
            append blank

            dbf_update_rec( _rec )
            
            select kalk_pripr
            skip

        enddo

        log_write( "F18_DOK_OPER: kalk, prenos dokumenta iz pripreme u smece: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 2 )

    endif

enddo

select kalk_pripr
my_dbf_zap()

close all
return



// -------------------------------------------------------
// povrat kalkulacije u tabelu pripreme
// -------------------------------------------------------
function povrat_kalk_dokumenta()
local _brisi_kum
local _rec
local _id_firma
local _id_vd
local _br_dok
local _del_rec, _ok
local _t_rec
local _dok_hash, oAtrib

_brisi_kum := .f.

if gCijene=="2" .and. Pitanje(,"Zadati broj (D) / Povrat po hronologiji obrade (N) ?","D") = "N"
    Beep(1)
    PNajn()
    close all
    return
endif

O_KALK_DOKS
O_KALK_DOKS2
O_KALK
set order to tag "1"

O_KALK_PRIPR

SELECT KALK
set order to tag "1"  

_id_firma := gfirma
_id_vd := space(2)
_br_dok := space(8)

Box("",1,35)
    @ m_x+1,m_y+2 SAY "Dokument:"
    if gNW $ "DX"
        @ m_x+1,col()+1 SAY _id_firma
    else
        @ m_x+1,col()+1 GET _id_firma
    endif
    @ m_x+1,col()+1 SAY "-" GET _id_vd pict "@!"
    @ m_x+1,col()+1 SAY "-" GET _br_dok
    read
    ESC_BCR
BoxC()

// ako je uslov sa tackom, vrati sve nabrojane u pripremu...
if _br_dok = "."
    povrat_vise_dokumenata()
    close all
    return
endif
    
if Pitanje( "", "Kalk. " + _id_firma + "-" + _id_vd + "-" + _br_dok + " povuci u pripremu (D/N) ?", "D" ) == "N"
    close all
    return
endif

_brisi_kum := Pitanje(,"Izbrisati dokument iz kumulativne tabele ?", "D" ) == "D"

select kalk
hseek _id_firma + _id_vd + _br_dok

EOF CRET

MsgO("Prebacujem u pripremu...")

do while !EOF() .and. _id_firma == field->IdFirma .and. _id_vd == field->IdVD .and. _br_dok == field->BrDok
    
    select kalk
    _rec := dbf_get_rec()
    select kalk_pripr

    IF ! ( _rec["idvd"] $ "97" .and. _rec["tbanktr"] == "X" )
        append ncnl
        _rec["error"] := ""
        dbf_update_rec( _rec )
    ENDIF

    select kalk
    skip

enddo

MsgC()

// kalk atributi....
_dok_hash := hb_hash()
_dok_hash["idfirma"] := _id_firma
_dok_hash["idtipdok"] := _id_vd
_dok_hash["brdok"] := _br_dok

oAtrib := F18_DOK_ATRIB():new("kalk", F_KALK_ATRIB)
oAtrib:dok_hash := _dok_hash
oAtrib:atrib_server_to_dbf()


if _brisi_kum
    
    if !f18_lock_tables({"kalk_doks", "kalk_kalk", "kalk_doks2" })
         MsgBeep("ne mogu lockovati kalk tabele ?!")
         return .f.
    else
        o_kalk_za_azuriranje()
    endif

    MsgO("Brisem dokument iz KALK-a")

    sql_table_update( nil, "BEGIN" )

    select kalk
    hseek _id_firma + _id_vd + _br_dok

    if FOUND()

        log_write( "F18_DOK_OPER: kalk povrat dokumenta: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 2 )

        _del_rec := dbf_get_rec()

        _ok := .t.
        
        // pobrisi atribute ih sa servera...
        _ok := _ok .and.  oAtrib:delete_atrib_from_server()

        _ok := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )
    
        select kalk_doks
        hseek _id_firma + _id_vd + _br_dok

        if FOUND()
            
            _del_rec := dbf_get_rec()
            _ok := .t.
            _ok := delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )
        
        endif

        select kalk_doks2
        hseek _id_firma + _id_vd + _br_dok

        if FOUND()
            
            _del_rec := dbf_get_rec()
            _ok := .t.
            _ok := delete_rec_server_and_dbf( "kalk_doks2", _del_rec, 1, "CONT" )
        
        endif

    endif

    MsgC()

    if _ok
        f18_free_tables({"kalk_doks", "kalk_kalk", "kalk_doks2" })
        sql_table_update( nil, "END" )
    else

        sql_table_update( nil, "ROLLBACK" )
        f18_free_tables({"kalk_doks", "kalk_kalk", "kalk_doks2" })

        msgbeep("Brisanje KALK dokumenta neuspjesno !?")
        close all
        return
    endif

    // vrati i dokument iz kalk_doksRC
    povrat_doksrc( _id_firma, _id_vd, _br_dok )

endif

select kalk_doks
use

select kalk
use

close all
return


// -----------------------------------------------------
// povrat vise dokumenata od jednom...
// -----------------------------------------------------
static function povrat_vise_dokumenata()
local _br_dok := SPACE(80)
local _dat_dok := SPACE(80)
local _id_vd := SPACE(80)    
local _usl_br_dok
local _usl_dat_dok
local _usl_id_vd
local _brisi_kum := .f.
local _filter
local _id_firma := gFirma
local _rec
local _del_rec, _ok
local _dok_hash, oAtrib, __firma, __idvd, __brdok

if !SigmaSif()
    close all
    return .f.
endif
    
Box(,3,60)
    do while .t.
        @ m_x+1, m_y+2 SAY "Vrste kalk.    " GET _id_vd pict "@S40"
        @ m_x+2, m_y+2 SAY "Broj dokumenata" GET _br_dok pict "@S40"
        @ m_x+3, m_y+2 SAY "Datumi         " GET _dat_dok pict "@S40"
        read
        _usl_br_dok := Parsiraj( _br_dok, "BrDok", "C")
        _usl_dat_dok := Parsiraj( _dat_dok,"DatDok", "D")
        _usl_id_vd := Parsiraj( _id_vd, "IdVD", "C")
        if _usl_br_dok <> NIL .and. _usl_dat_dok <> NIL .and. _usl_id_vd <> NIL
                exit
        endif
    enddo
Boxc()

if Pitanje(, "Povuci u pripremu kalk sa ovim kriterijom ?", "N" ) == "D"

    _brisi_kum := Pitanje(, "Izbrisati dokument iz kumulativne tabele ?", "D" ) == "D"

    select kalk

    _filter := "IDFIRMA==" + cm2str( _id_firma ) + ".and." + _usl_br_dok + ".and." + _usl_id_vd + ".and." + _usl_dat_dok
    _filter := STRTRAN( _filter, ".t..and.", "" )

    IF !( _filter == ".t." )
        SET FILTER TO &(_filter)
    ENDIF

    select kalk
    go top

    MsgO("Prolaz kroz kumulativnu datoteku KALK...")

    // vrati prvo dokumente u pripremu...
    do while !eof()

        select kalk

        __firma := field->idfirma
        __idvd := field->idvd
        __brdok := field->brdok

        _rec := dbf_get_rec()

        select kalk_pripr
                
        IF ! ( _rec["idvd"] $ "97" .and. _rec["tbanktr"] == "X" )

            append ncnl
            _rec["error"] := ""
            dbf_update_rec( _rec )

            // kalk atributi....
            _dok_hash := hb_hash()
            _dok_hash["idfirma"] := __firma
            _dok_hash["idtipdok"] := __idvd
            _dok_hash["brdok"] := __brdok

            oAtrib := F18_DOK_ATRIB():new("kalk", F_KALK_ATRIB)
            oAtrib:dok_hash := _dok_hash
            oAtrib:atrib_server_to_dbf()
 
        ENDIF

        select kalk
        skip
    
    enddo

    MsgC()
     
    select kalk
    set order to tag "1"
    go top

    // ako ne treba brisati kumulativ
    if !_brisi_kum
        close all
        return .f.
    endif

    MsgO("update server kalk")    

    if !f18_lock_tables({"kalk_doks", "kalk_kalk", "kalk_doks2" })
          return .f.
    endif

    sql_table_update( nil, "BEGIN" )

    // idemo sada na brisanje dokumenata
    do while !EOF()

        _id_firma := field->idfirma
        _id_vd := field->idvd
        _br_dok := field->brdok

        _del_rec := dbf_get_rec()

        // prodji kroz dokument do kraja...
        do while !EOF() .and. field->idfirma == _id_firma .and. field->idvd == _id_vd .and. field->brdok == _br_dok
            skip
        enddo
        
        _t_rec := RECNO()

        _ok := .t.

        _dok_hash := hb_hash()
        _dok_hash["idfirma"] := _id_firma
        _dok_hash["idtipdok"] := _id_vd
        _dok_hash["brdok"] := _br_dok

        oAtrib := F18_DOK_ATRIB():new("kalk", F_KALK_ATRIB)
        oAtrib:dok_hash := _dok_hash
        
        _ok := _ok .and.  oAtrib:delete_atrib_from_server()

        _ok := delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )

        if _ok
            // pobrsi mi sada tabelu kalk_doks
            select kalk_doks
            go top
            seek _id_firma + _id_vd + _br_dok

            if found()

                log_write( "F18_DOK_OPER: kalk brisanje vise dokumenata: " + _id_firma + _id_vd + _br_dok , 2 )

                _del_rec := dbf_get_rec()
                // brisi prvo tabelu kalk_doks            
                _ok := .t.
                _ok :=  delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )

            endif

        endif


        if !_ok
            MsgC()
            MsgBeep("Problem sa brisanjem tabele kalk !!!")
            close all
            return .f.
        endif
        
        select kalk
        go ( _t_rec )
                        
    enddo

    MsgC()

    f18_free_tables({"kalk_doks", "kalk_kalk", "kalk_doks2" })
    sql_table_update( nil, "END" )


endif
    
close all
    
return .t.




// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr
// ------------------------------------------------------------------
function Povrat9( cIdFirma, cIdVd, cBrDok )
local nRec
local _rec

lSilent := .t.

O_KALK_PRIPR9
O_KALK_PRIPR

SELECT kalk_pripr9
set order to tag "1"  
// idFirma+IdVD+BrDok+RBr

if ((cIdFirma == nil) .and. (cIdVd == nil) .and. (cBrDok == nil))
    lSilent := .f.
endif

if !lSilent
    cIdFirma:=gFirma
    cIdVD:=SPACE(2)
    cBrDok:=SPACE(8)
endif

if !lSilent
    Box("",1,35)
        @ m_x+1,m_y+2 SAY "Dokument:"
        if gNW $ "DX"
            @ m_x+1,col()+1 SAY cIdFirma
        else
            @ m_x+1,col()+1 GET cIdFirma
        endif
        @ m_x+1,col()+1 SAY "-" GET cIdVD
        @ m_x+1,col()+1 SAY "-" GET cBrDok
        read
        ESC_BCR
    BoxC()

    if cBrDok="."
        private qqBrDok:=qqDatDok:=qqIdvD:=space(80)
        qqIdVD:=padr(cidvd+";",80)
        Box(,3,60)
            do while .t.
                @ m_x+1,m_y+2 SAY "Vrste dokum.   "  GEt qqIdVD pict "@S40"
                @ m_x+2,m_y+2 SAY "Broj dokumenata"  GEt qqBrDok pict "@S40"
                @ m_x+3,m_y+2 SAY "Datumi         " GET  qqDatDok pict "@S40"
                read
                private aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
                private aUsl2:=Parsiraj(qqDatDok,"DatDok","D")
                private aUsl3:=Parsiraj(qqIdVD,"IdVD","C")
                if aUsl1<>NIL .and. aUsl2<>NIL .and. ausl3<>NIL
                    exit
                endif
            enddo
        Boxc()

        if Pitanje(,"Povuci u pripremu dokumente sa ovim kriterijom ?","N")=="D"
            select kalk_pripr9
            PRIVATE cFilt1:=""
            cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl2+".and."+aUsl3
            cFilt1 := STRTRAN(cFilt1,".t..and.","")
            IF !(cFilt1==".t.")
                SET FILTER TO &cFilt1
            ENDIF

            go top
            MsgO("Prolaz kroz SMECE...")

            do while !eof()
                select kalk_pripr9
                Scatter()
                select kalk_pripr
                append ncnl
                _ERROR:=""
                Gather2()
                select kalk_pripr9
                skip
                nRec := recno()
                skip -1
                dbDelete2()
                go nRec
            enddo
            MsgC()
        endif
        close all
        return
    endif
endif 

if Pitanje("","Iz smeca "+cIdFirma+"-"+cIdVD+"-"+cBrDok+" povuci u pripremu (D/N) ?","D")=="N"
    if !lSilent
        close all
        return
    else
        return
    endif
endif

select kalk_pripr9

hseek cIdFirma+cIdVd+cBrDok
EOF CRET

MsgO("PRIPREMA")

do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    select kalk_pripr9
    Scatter()
    select kalk_pripr
    append ncnl
    _ERROR:=""
    Gather2()
    select kalk_pripr9
    skip
enddo

select kalk_pripr9
seek cidfirma+cidvd+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    skip 1
    nRec:=recno()
    skip -1
    dbdelete2()
    go nRec
enddo
use
MsgC()

log_write( "F18_DOK_OPER: kalk, povrat dokumenta iz smeca: " + cIdFirma + "-" + cIdVd + "-" + cBrDok, 2 )

if !lSilent
    close all
    return
endif

O_KALK_PRIPR9
select kalk_pripr9

return



// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr najstariju kalkulaciju
// ------------------------------------------------------------------
function P9najst()
local nRec

O_KALK_PRIPR9
O_KALK_PRIPR

SELECT kalk_pripr9
set order to tag "3"
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

if Pitanje(,"Povuci u pripremu najstariji dokument ?","N")=="N"
    close all
    return
endif

select kalk_pripr9
go top

cidfirma:=idfirma
cIdVD:=idvd
cBrDok:=brdok

MsgO("PRIPREMA")

do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    select kalk_pripr9
    Scatter()
    select kalk_pripr
    append blank
    _ERROR:=""
    Gather()
    select kalk_pripr9
    skip
enddo

set order to tag "1"
select kalk_pripr9
seek cidfirma+cidvd+cBrDok

do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    skip 1
    nRec:=recno()
    skip -1
    dbdelete2()
    go nRec
enddo
use
MsgC()

close all
return




// ------------------------------------------------------------------
// iz kalk u kalk_pripr najnoviju kalkulaciju
// ------------------------------------------------------------------
function Pnajn()
local nRec
local cBrsm
local fbof
local nVraceno:=0
local _rec, _del_rec

O_KALK_DOKS
O_KALK
O_KALK_PRIPR

SELECT kalk
set order to tag "5"  
// str(datdok)
cIdfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

go bottom
cIdfirma := idfirma
dDatDok := datdok

if EOF()
    Msg("Na stanju nema dokumenata..")
    close all
    return
endif

if Pitanje(,"Vratiti u pripremu dokumente od "+dtoc(dDatDok)+" ?","N")=="N"
    close all
    return
endif

select kalk

MsgO("Povrat dokumenata od "+dtoc(dDatDok)+" u pripremu")

do while !BOF() .and. cIdFirma==IdFirma .and. datdok==dDatDok
    cIDFirma:=idfirma
    cIdvd:=idvd
    cBrDok:=brdok
    cBrSm:=""

    do while !bof() .and. cIdFirma==IdFirma .and. cidvd==idvd .and. cbrdok==brdok

        select kalk

        _rec := dbf_get_rec()
        
        if !( _rec["tbanktr"] == "X" )

            select kalk_pripr                           
            append blank

            _rec["error"] := ""
            dbf_update_rec( _rec )    

            nVraceno ++

        elseif _rec["tbanktr"] == "X" .and. ( _rec["mu_i"] == "5" .or. _rec["pu_i"] == "5" )

            select kalk_pripr

            if rbr <> _rec["rbr"] .or. ( idfirma + idvd + brdok) <> _rec["idfirma"] + _rec["idvd"] + _rec["brdok"]
                nVraceno++
                append blank
                _rec["error"] := ""
            else 
                _rec["kolicinai"] += kalk_pripr->kolicina
            endif

            _rec["error"] := ""
            _rec["tbanktr"] := ""
            
            dbf_update_rec( _rec )

        elseif _rec["tbanktr"] == "X" .and. ( _rec["mu_i"] == "3" .or. _rec["pu_i"] == "3" )
            if cBrSm <> (cBrSm := idfirma + "-" + idvd + "-" + brdok )     
                Beep(1)
                Msg("Dokument: "+cbrsm+" je izgenerisan,te je izbrisan bespovratno")
            endif
        endif
  
        select kalk
        skip -1
  
        if BOF()
            fBof:=.t.
            nRec:=0
        else
            fBof:=.f.
            nRec:=recno()
            skip 1
        endif

        select kalk_doks
        seek kalk->(idfirma+idvd+brdok)

        if found()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "FULL" )
            delete
        endif

        select kalk
        _del_rec := dbf_get_rec()
        delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 1, "FULL" )
    
        go nRec

        if fBof
            exit
        endif

    enddo

enddo 

MsgC()

close all
return



