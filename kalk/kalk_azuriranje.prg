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
local oServer
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

// isprazni kalk_pripr2
// trebat ce nam poslije radi generisanja zavisnih dokumenata
O_KALK_PRIPR2
zap
use

lViseDok := kalk_provjeri_duple_dokumente( @aRezim )

O_KALK_DOKS
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

oServer := pg_server()

if oServer == NIL
    CLEAR SCREEN 
    ? "kalk_azur oServer nil ?!"
    INKEY(0)
    QUIT
endif

if kalk_azur_sql( oServer )
    
    o_kalk_za_azuriranje()
    
    if !kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
        MsgBeep("Neuspjesno KALK/DBF azuriranje !?")
        return
    endif

else
    MsgBeep("Neuspjesno KALK/SQL azuriranje !?")
    return
endif

// generisi zavisne dokumente nakon azuriranja kalkulacije
kalk_zavisni_nakon_azuriranja( lGenerisiZavisne, lAuto )

// ostavi duple dokumente ili pobrisi pripemu
if lViseDok == .t. .and. LEN( aOstaju ) > 0
    kalk_ostavi_samo_duple( aOstaju )
else
    // pobrisi kalk_pripr
    select kalk_pripr
    zap
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

O_KALK_PRIPR2

if field->idvd $ "18#19"  
    // otprema
    if kalk_pripr2->(reccount2())<>0
        Beep(1)
        Box(,4,70)
        @ m_x+1,m_y+2 SAY "1. Cijene robe su promijenjene."
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument nivelacije:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
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
        @ m_x+1,m_y+2 SAY "1. Roba je otpremljena u magacin "+pripr2->idkonto
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument dopreme:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
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
        @ m_x+1,m_y+2 SAY "1. Roba je prenesena u prodavnicu "+pripr2->idkonto
        @ m_x+2,m_y+2 SAY "2. Formiran je dokument zaduzenja:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
        @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
        inkey(0)
        BoxC()
        lPrebaci := .t.
    endif
endif

if lPrebaci == .t.
    select kalk_pripr
    append from kalk_pripr2
    select kalk_pripr2
    zap
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


O_KALK_DOKS
O_KALK
O_KALK_PRIPR

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
__dbpack()
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
    
Niv_11()  // nivelacija 11,81

Otprema() // iz otpreme napravi ulaza
Iz13u11()  // prenos iz prodavnice u prodavnicu
    
// inventura magacina - manjak / visak
InvManj()
    
return



// ----------------------------------------------------------------------------
// azuriranje podataka u dbf
// ----------------------------------------------------------------------------
static function kalk_azur_dbf( lAuto, lViseDok, aOstaju, aRezim, lBrStDoks )
local cIdFirma
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

MsgO("Azuriram pripremu ...")

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
    
    select kalk_doks
    append blank
    replace field->idfirma with cIdFirma, field->brdok with cBrdok,;
            field->datdok with kalk_pripr->datdok, field->idvd with cIdvd,;
            field->idpartner with kalk_pripr->idpartner, field->mkonto with kalk_pripr->mkonto,;
            field->pkonto with kalk_pripr->pkonto,;
            field->idzaduz with kalk_pripr->idzaduz, field->idzaduz2 with kalk_pripr->idzaduz2,;
            field->brfaktp with kalk_pripr->BrFaktP
  
    if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
        
        cOpis := cIDFirma + "-" + cIdVd + "-" + ALLTRIM(cBrDok)

        EventLog(nUser,goModul:oDataBase:cName,"DOK","AZUR",nil,nil,nil,nil,cOpis, "", "", kalk_pripr->datdok, Date(),"","Azuriranje dokumenta")
    
    endif

    select kalk_pripr
    go top

    nBrStavki := 0
    
    do while !eof() .and. cIdfirma == field->idfirma .and. cBrdok == field->brdok .and. cIdvd == field->idvd
            
        ++ nBrStavki
        Scatter()
        _Podbr := cNPodbr
        select kalk
        append blank
        Gather()
        if cIdVd == "97"
            append blank
            _TBankTr := "X"
            _mkonto  := _idkonto
            _mu_i    := "1"
            Gather()
        endif
   
        select kalk_pripr
        if !( cIdVd $ "97" )
            // setuj nnv, nmpv ....
            kalk_set_doks_total_fields( @nNv, @nVpv, @nMpv, @nRabat ) 
        endif
        skip
    
    enddo

    select kalk_doks
    replace field->nv with nNv, ;
            field->vpv with nVpv, ;
            field->rabat with nRabat, ;
            field->mpv with nMpv, ;
            field->podbr with cNPodbr

    if lBrStDoks
        replace ukstavki with nBrStavki
    endif

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


static function kalk_provjera_integriteta( aDoks, lViseDok )
local nBrDoks
local cIdFirma
local cIdVd
local cBrDok
local dDatDok
local cIdZaduz2

O_KALK
O_KALK_PRIPR

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
                MSG("Dokument je izgenerisan, sa <a-F10> izvrsiti njegovu obradu",6)
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
            Msg("Stavka broj " + field->rbr + ". neobradjena , sa <a-F10> pokrenite obradu")
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



static function o_kalk_za_azuriranje()

O_KALK
O_KALK_DOKS
O_KALK_PRIPR

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
static function kalk_azur_sql(oServer)
local lOk := .t.
local record := hb_hash()
local _doks_nv := 0
local _doks_vpv := 0
local _doks_mpv := 0
local _doks_rabat := 0
local _tbl_kalk
local _tbl_doks
local _i, _n
local _tmp_id, _tmp_doc
local _ids := {}
local _ids_doc := {}
local _ids_tmp := {}

_tbl_kalk := "kalk_kalk"
_tbl_doks := "kalk_doks"

lock_semaphore( _tbl_kalk, "lock" )
lock_semaphore( _tbl_doks, "lock" )

if lOk = .t.

  // azuriraj kalk
  MsgO("sql kalk_kalk")

  O_KALK_PRIPR

  select kalk_pripr
  go top

  sql_kalk_kalk_update("BEGIN")

  do while !eof()
 
   record["id_firma"] := field->idfirma
   record["id_vd"] := field->idvd
   record["br_dok"] := field->brdok
   record["r_br"] := field->rbr
   record["dat_dok"] := field->datdok
   record["br_fakt_p"] := field->brfaktp
   record["dat_fakt_p"] := field->datfaktp
   record["id_roba"] := field->idroba
   record["id_konto"] := field->idkonto
   record["id_konto2"] := field->idkonto2
   record["id_zaduz"] := field->idzaduz
   record["id_zaduz2"] := field->idzaduz2
   record["id_partner"] := field->idpartner
   record["dat_kurs"] := field->datkurs
   record["kolicina"] := field->kolicina
   record["g_kolicina"] := field->gkolicina
   record["g_kolicina_2"] := field->gkolicin2
   record["f_cj"] := field->fcj
   record["f_cj2"] := field->fcj2
   record["f_cj3"] := field->fcj3
   record["t_rabat"] := field->trabat
   record["rabat"] := field->rabat
   record["t_prevoz"] := field->tprevoz
   record["prevoz"] := field->prevoz
   record["t_prevoz2"] := field->tprevoz2
   record["prevoz2"] := field->prevoz2
   record["t_banktr"] := field->tbanktr
   record["banktr"] := field->banktr
   record["t_spedtr"] := field->tspedtr
   record["spedtr"] := field->spedtr
   record["t_cardaz"] := field->tcardaz
   record["cardaz"] := field->cardaz
   record["t_zavtr"] := field->tzavtr
   record["zavtr"] := field->zavtr
   record["nc"] := field->nc
   record["t_marza"] := field->tmarza
   record["marza"] := field->marza
   record["vpc"] := field->vpc
   record["rabatv"] := field->rabatv
   record["vpc_sa_p"] := field->vpcsap
   record["t_marza2"] := field->tmarza2
   record["marza2"] := field->marza2
   record["mpc"] := field->mpc
   record["id_tarifa"] := field->idtarifa
   record["mpc_sa_pp"] := field->mpcsapp
   record["m_konto"] := field->mkonto
   record["p_konto"] := field->pkonto
   record["rok_tr"] := field->roktr
   record["mu_i"] := field->mu_i
   record["pu_i"] := field->pu_i
   record["error"] := field->error
   record["pod_br"] := field->podbr
                
   _tmp_doc := record["id_firma"] + record["id_vd"] + record["br_dok"]
   _tmp_id := record["id_firma"] + record["id_vd"] + record["br_dok"] + record["r_br"]
   
   AADD( _ids, _tmp_id )

   if !sql_kalk_kalk_update( "ins", record )
       lOk := .f.
       exit
    
    endif
    
    // setuj total varijable za upisivanje u tabelu doks   
    kalk_set_doks_total_fields( @_doks_nv, @_doks_vpv, @_doks_mpv, @_doks_rabat ) 
    
    SKIP

  enddo

  MsgC()

endif

if lOk = .t.

  // azuriraj doks...
  MsgO("sql kalk_doks")

  select kalk_pripr
  go top

  record := hb_hash()
  
  sql_kalk_doks_update("BEGIN")

  record["id_firma"] := field->idfirma
  record["id_vd"] := field->idvd
  record["br_dok"] := field->brdok
  record["dat_dok"] := field->datdok
  record["br_fakt_p"] := field->brfaktp
  record["id_partner"] := field->idpartner
  record["id_zaduz"] := field->idzaduz
  record["id_zaduz2"] := field->idzaduz2
  record["p_konto"] := field->pkonto
  record["m_konto"] := field->mkonto
  record["nv"] := _doks_nv
  record["vpv"] := _doks_vpv
  record["rabat"] := _doks_rabat
  record["mpv"] := _doks_mpv
  record["pod_br"] := field->podbr
 
  if !sql_kalk_doks_update( "ins", record )
       lOk := .f.
  endif
   
  MsgC()

endif

if !lOk

    // vrati promjene
    sql_kalk_kalk_update("ROLLBACK")
    sql_kalk_doks_update("ROLLBACK")
        
else

    // snimi promjene

    update_semaphore_version( _tbl_doks, .t. )
    update_semaphore_version( _tbl_kalk, .t. )
    
    for _n := 1 to LEN( _ids )

        // dodaj za kalk po stavkama
        _ids_tmp := {}
        AADD( _ids_tmp, _ids[ _n ] )

        push_ids_to_semaphore( _tbl_kalk, _ids_tmp ) 

    next

    // za doks ide _ids_doc
    AADD( _ids_doc, _tmp_doc )
    push_ids_to_semaphore( _tbl_doks, _ids ) 

    // zavrsi transakcije
    sql_kalk_doks_update("END")
    sql_kalk_kalk_update("END")

endif

// otkljucaj tabele svakako
lock_semaphore( _tbl_kalk, "free" )
lock_semaphore( _tbl_doks, "free" )

return lOk


// ------------------------------------------------------------
// azuriranje kalk_pripr9 tabele
// koristi se za smece u vecini slucajeva
// ------------------------------------------------------------
function Azur9()
local lGen := .f.
local cPametno := "D" 
local cIdFirma
local cIdvd
local cBrDok

if Pitanje("p1","Zelite li pripremu prebaciti u smece (D/N) ?","N")=="N"
    return
endif

O_KALK_PRIPR9
O_KALK_PRIPR

do while !eof()

    cIdFirma:=idfirma
    cIdvd:=idvd
    cBrdok:=brdok

    // ???????
    do while !eof() .and. cIdfirma == field->idfirma ;
            .and. cIdvd == field->idvd ;
            .and. cBrdok == brdok
        skip
    enddo

    select kalk_pripr9
    seek cIdFirma+cIdVD+cBrDok
    
    if found()
        Beep(1)
        Msg("U smecu vec postoji "+cidfirma+"-"+cidvd+"-"+cbrdok)
        close all
        return
    endif

    select kalk_pripr
enddo 

select kalk_pripr 
go top

select kalk_pripr9
append from kalk_pripr

select kalk_pripr
go top

if Logirati(goModul:oDataBase:cName, "DOK", "SMECE")
    cOpis := cIdFirma + "-" + ;
        cIdvd + "-" + ;
        cBrdok

    EventLog(nUser, goModul:oDataBase:cName,"DOK","SMECE", ;
    nil,nil,nil,nil,;
    cOpis, "", "", ;
    kalk_pripr->datdok, DATE(), ;
    "", "prebacivanje dokumenta u smece")
endif

select kalk_pripr
zap

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

_brisi_kum := .f.

if gCijene=="2" .and. Pitanje(,"Zadati broj (D) / Povrat po hronologiji obrade (N) ?","D") = "N"
    Beep(1)
    PNajn()
    close all
    return
endif

O_KALK_DOKS
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

do while !eof() .and. _id_firma == field->IdFirma .and. _id_vd == field->IdVD .and. _br_dok == field->BrDok
    
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

if _brisi_kum
    
    MsgO("Brisem dokument iz KALK-a")

    select kalk
    hseek _id_firma + _id_vd + _br_dok

    do while !eof() .and. _id_firma == field->IdFirma .and. _id_vd == field->IdVD .and. _br_dok == field->BrDok

        skip 1
        _t_rec := RECNO()
        skip -1

        _del_rec := dbf_get_rec()
        _ok := .t.
        _ok := delete_rec_server_and_dbf( ALIAS(), _del_rec )

        if !_ok
            msgbeep("imam veliki problem sa brisanjem ovog dokumenta iz tabele kalk !!!!")
            close all
            return
        endif
        
        go ( _t_rec )

    enddo

    select kalk_doks
    hseek _id_firma + _id_vd + _br_dok
         
    _del_rec := dbf_get_rec()
    _ok := delete_rec_server_and_dbf( ALIAS(), _del_rec )

    if !_ok
        msgbeep("imam veliki problem sa brisanjem ovog dokumenta iz tabele doks !!!!")
        close all
        return
    endif

    MsgC()

    if Logirati(goModul:oDataBase:cName,"DOK","POVRAT")
        _descr := _id_firma + "-" + _id_vd + "-" + ALLTRIM(_br_dok)
        EventLog(nUser, goModul:oDataBase:cName,"DOK","POVRAT",nil,nil,nil,nil,_descr,"","",Date(),Date(),"","KALK - Povrat dokumenta u pripremu")
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
            
    select kalk
    set order to tag "1"
    go top

    // ako ne treba brisati kumulativ
    if !_brisi_kum
        close all
        return .f.
    endif

    // idemo sada na brisanje dokumenata
    do while !EOF()

        _id_firma := field->idfirma
        _id_vd := field->idvd
        _br_dok := field->brdok

        // prodji kroz dokument do kraja...
        do while !EOF() .and. field->idfirma == _id_firma .and. field->idvd == _id_vd .and. field->brdok == _br_dok

            _del_rec := hb_hash()
            _del_rec["idfirma"] := field->idfirma
            _del_rec["idvd"]    := field->idvd
            _del_rec["brdok"]   := field->brdok
            _del_rec["rbr"]     := field->rbr

            _ok := .t.
            _ok :=  delete_rec_server_and_dbf( ALIAS(), _del_rec )

            if !_ok
                msgbeep("Problem sa brisanjem tabele kalk !!!")
                msgc()
                close all
                return .f.
            endif
 
            skip

        enddo

        // pobrsi mi sada tabelu kalk_doks

        _del_rec := hb_hash()
        _del_rec["idfirma"] := _id_firma
        _del_rec["idvd"]    := _id_vd
        _del_rec["brdok"]   := _br_dok

        // brisi prvo tabelu kalk_doks            
        select kalk_doks
        _ok := .t.
        _ok :=  delete_rec_server_and_dbf( ALIAS(), _del_rec )

        if !_ok
            msgbeep("Problem sa brisanjem tabele kalk !!!")
            msgc()
            close all
            return .f.
        endif
            
    enddo

    msgc()

endif
    
close all
    
return .t.


// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr
// ------------------------------------------------------------------
function Povrat9(cIdFirma, cIdVd, cBrDok)
local nRec

lSilent := .t.

O_KALK_PRIPR9
O_KALK_PRIPR

SELECT kalk_pripr9
set order to tag "1"  // idFirma+IdVD+BrDok+RBr

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
    if !flock(); Msg("PRIPR9 - SMECE je zauzeta ",3); closeret; endif
    PRIVATE cFilt1:=""
    cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl2+".and."+aUsl3
    cFilt1 := STRTRAN(cFilt1,".t..and.","")
    IF !(cFilt1==".t.")
      SET FILTER TO &cFilt1
    ENDIF
    go top
    MsgO("Prolaz kroz SMECE...")
    do while !eof()
      select kalk_pripr9; Scatter()
      select kalk_pripr
      append ncnl;_ERROR:="";  Gather2()
      select kalk_pripr9
      skip; nRec:=recno(); skip -1
      dbdelete2()
      go nRec
    enddo
    MsgC()
  endif
  closeret
endif

endif // lSilent

if Pitanje("","Iz smeca "+cIdFirma+"-"+cIdVD+"-"+cBrDok+" povuci u pripremu (D/N) ?","D")=="N"
    if !lSilent
        CLOSERET
    else
        return
    endif
endif

select kalk_pripr9

hseek cIdFirma+cIdVd+cBrDok
EOF CRET

MsgO("PRIPREMA")
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   select kalk_pripr9; Scatter()
   select kalk_pripr
   append ncnl;_ERROR:="";  Gather2()
   select kalk_pripr9
   skip
enddo

select kalk_pripr9
seek cidfirma+cidvd+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   skip 1; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use
MsgC()

if !lSilent
    closeret
endif

O_KALK_PRIPR9
select kalk_pripr9

return
*}


// ------------------------------------------------------------------
// iz kalk_pripr 9 u kalk_pripr najstariju kalkulaciju
// ------------------------------------------------------------------
function P9najst()
local nRec

O_KALK_PRIPR9
O_KALK_PRIPR

//CREATE_INDEX(PRIVPATH+"PRIPR9i3","dtos(datdok)+mu_i+pu_i",PRIVPATH+"PRIPR9")
SELECT kalk_pripr9; set order to tag "3"  // str(datdok)
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

if Pitanje(,"Povuci u pripremu najstariji dokument ?","N")=="N"
  closeret
endif
select kalk_pripr9
if !flock(); Msg("PRIPR9 - SMECE je zauzeta ",3); closeret; endif
go top

cidfirma:=idfirma
cIdVD:=idvd
cBrDok:=brdok

MsgO("PRIPREMA")
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
  select kalk_pripr9; Scatter()
  select kalk_pripr
  append ncnl;_ERROR:="";  Gather2()
  select kalk_pripr9
  skip
enddo
//CREATE_INDEX(PRIVPATH+"PRIPR9i1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR9")

set order to tag "1"
select kalk_pripr9
seek cidfirma+cidvd+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   skip 1; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use
MsgC()

closeret
*}



// ------------------------------------------------------------------
// iz kalk u kalk_pripr najnoviju kalkulaciju
// ------------------------------------------------------------------
function Pnajn()
local nRec,cbrsm, fbof, nVraceno:=0

O_KALK_DOKS
O_KALK
O_KALK_PRIPR

SELECT kalk; set order to tag "5"  // str(datdok)
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

if !flock(); Msg("KALK je zauzeta ",3); closeret; endif
go bottom
cidfirma:=idfirma
dDatDok:=datdok

if eof(); Msg("Na stanju nema dokumenata.."); closeret; endif

if Pitanje(,"Vratiti u pripremu dokumente od "+dtoc(dDatDok)+" ?","N")=="N"
  closeret
endif
select kalk

MsgO("Povrat dokumenata od "+dtoc(dDatDok)+" u pripremu")
do while !bof() .and. cIdFirma==IdFirma .and. datdok==dDatDok
 cIDFirma:=idfirma; cIdvd:=idvd; cBrDok:=brdok
 cBrSm:=""
 do while !bof() .and. cIdFirma==IdFirma .and. cidvd==idvd .and. cbrdok==brdok
  select kalk; Scatter()
  if !( _tbanktr=="X")
   select kalk_pripr                           // izlaz, a izgenerisana je
   append ncnl;  _ERROR:=""; Gather2()    // u tom slucaju nemoj je
   nVraceno++
  elseif  _tbanktr=="X" .and. (_mu_i=="5" .or. _pu_i=="5")
    select kalk_pripr
    if rbr<>_rbr  .or. (idfirma+idvd+brdok)<>_idfirma+_idvd+_brdok
      nVraceno++
      append ncnl; _ERROR:=""
    else // na{tiklaj na postojecu stavku
      _kolicina+=kalk_pripr->kolicina
    endif
    _TBankTr:="";_ERROR:=""; Gather2()

  elseif  _tbanktr=="X" .and. (_mu_i=="3" .or. _pu_i=="3")
   if cBrSm<>(cBrSm:=idfirma+"-"+idvd+"-"+brdok)     // vracati, samo je izbrisi
     Beep(1)
     Msg("Dokument: "+cbrsm+" je izgenerisan,te je izbrisan bespovratno")
   endif
  endif
  
  select kalk
  skip -1
  
  if bof()
    fBof:=.t.
    nRec:=0
  else
    fBof:=.f.
    nRec:=recno()
    skip 1
  endif

  select kalk_doks
  seek kalk->(idfirma+idvd+brdok)   // izbrisi u kalk_doks
  if found()
    delete
  endif

  select kalk
  dbdelete2()
  go nRec
  if fBof
    exit
  endif
 enddo
 //if nVraceno>0; exit; endif  // vrati sve od tog datuma
enddo // bof()
MsgC()

closeret
*}


// ------------------------------------------------------------------
// ------------------------------------------------------------------
function ErPripr9(cIdF, cIdVd, cBrDok)
if Pitanje(,"Sigurno zelite izbrisati dokument?","N")=="N"
    return
endif

select kalk_pripr9
seek cIdF+cIdVd+cBrDok

do while !eof() .and. cIdF==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    skip 1
    nRec:=RecNo()
    skip -1
    dbdelete2()
    go nRec
enddo

return


// ------------------------------------------------------------------
// ------------------------------------------------------------------
function ErP9All()

if Pitanje(,"Sigurno zelite izbrisati sve zapise?","N")=="N"
    return
endif

select kalk_pripr9
go top
zap

return

