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


#include "pos.ch"


function pos_narudzba()
local _ret

SETKXLAT( "'", "-" ) 

_ret := narudzba_tops()

set key "'" to

return _ret


function narudzba_tops()
local _ret

o_pos_narudzba()

select _pos_pripr

if reccount2() <> 0 .and. !EMPTY( field->brdok )
    _ret := DodajNaRacun( _pos_pripr->brdok )
else
    _ret := NoviRacun()
endif

set key "'" to
close all

return _ret



function dodajnaracun( cBrojRn )
set cursor on

if cBrojRn == nil
    cBrojRn := SPACE(6)
else
    cBrojRn := cBrojRn
endif

UnesiNarudzbu( cBrojRn, _pos->sto )

return 


// --------------------------------------------
// unos novog racuna 
// --------------------------------------------
function noviracun()
local cBrojRn
local cBr2 
local cSto := SPACE(3)
local dx := 3

select _pos
set cursor on

// novi broj racuna...
cBrojRn := "PRIPRE"

if gStolovi == "D"

    set cursor on

    Box(, 6, 40)
        cStZak := "N"
        @ m_x+2, m_y+10 SAY "Unesi broj stola:" GET cSto VALID (!Empty(cSto) .and. VAL(cSto) > 0) PICT "999"
        read
        if LastKey()==K_ESC
            MsgBeep("Unos stola obavezan !")
            return
        endif
        // daj mi info o trenutnom stanju stola
        nStStanje := g_stanje_stola(VAL(cSto))
        @ m_x+4, m_y+2 SAY "Prethodno stanje stola:   " + ALLTRIM(STR(nStStanje)) + " KM"
        if nStStanje > 0
            @ m_x+6, m_y+2 SAY "Zakljuciti prethodno stanje (D/N)?" GET cStZak VALID cStZak$"DN" PICT "@!"
        endif
        read
    BoxC()
        
    if LastKey() == K_ESC
        MsgBeep("Unos novih stavki prekinut !")
        return
    endif
        
    if cStZak == "D"
        zak_sto(VAL(cSto))
    endif
        
endif

// unesi stavke narudzbe
unesinarudzbu( cBrojRn, cSto )

return



 
function PreglRadni(cBrDok)
// koristi se gDatum - uzima se da je to datum radnog racuna SIGURNO
local nPrev:=SELECT()

SELECT _POS
Set Order To tag "1"
cFilt1:="IdPos+IdVd+dtos(datum)+BrDok+IdRadnik=="+cm2str(gIdPos+VD_RN+dtos(gDatum)+cBrDok+gIdRadnik)
Set Filter To &cFilt1
ImeKol:={ { "Roba",         {|| IdRoba+"-"+Left (RobaNaz, 30)},},;
          { "Kolicina",     {|| STR (Kolicina, 8, 2) }, },;
          { "Cijena",       {|| STR (Cijena, 8, 2) }, },;
          { "Iznos stavke", {|| STR (Kolicina*Cijena, 12, 2) }, };
        }
Kol:={1, 2, 3, 4}
GO TOP
ObjDBedit ( "rn2", MAXROWS() - 4, MAXCOLS() - 3,, " Radni racun "+ AllTrim (cBrDok), "", nil )
SET FILTER TO

select _pos_pripr
return



// --------------------------------------------
// zakljucenje racuna
// --------------------------------------------
function ZakljuciRacun()
local _ret
local _ne_zatvaraj := fetch_metric( "pos_konstantni_unos_racuna", my_user(), "N" )

_ret := zakljuci_pos_racun()

if _ne_zatvaraj == "D" .and. _ret == .t.

    // jednostano ponavljaj ove procedure, do ESC
    pos_narudzba()
    zakljuciracun()

endif

return _ret



// --------------------------------------------------------------
// zakljuci racun tops
// --------------------------------------------------------------
function zakljuci_pos_racun()
local _ret := .f.
local _param := hb_hash()

O__POS_PRIPR

if _pos_pripr->(RECCOUNT()) == 0
    close all
    return _ret
endif

go top

_param["idpos"] := _pos_pripr->idpos
_param["idvd"] := _pos_pripr->idvd
_param["datum"] := _pos_pripr->datum
_param["brdok"] := _pos_pripr->brdok
_param["idpartner"] := SPACE(6)
_param["idvrstap"] := "01"
_param["zakljuci"] := "D"
_param["uplaceno"] := 0

// uzmi sve parametre za zakljucenje racuna...
form_zakljuci_racun( @_param )

if _param["zakljuci"] == "D"
    _ret := .t.
    SveNaJedan( _param )
endif

close all
return _ret





// -------------------------------------------------
// zakljucivanje racuna - sve na jedan 
// -------------------------------------------------
function SveNaJedan( params )
local _br_dok := params["brdok"]
local _id_pos := params["idpos"]
local _id_vrsta_p := params["idvrstap"]
local _id_partner := params["idpartner"]
local _uplaceno := params["uplaceno"]

o_stazur()

if gRadniRac == "D"

    _br_dok := SPACE(6)
    set cursor on

    Box(,2,40)
        @ m_x + 1, m_y + 3 SAY "Broj radnog racuna:" GET _br_dok VALID P_RadniRac( @_br_dok )
        READ
        ESC_BCR
    BoxC()

endif

// prebaci iz prip u pos
if ( LEN( aRabat ) > 0 )
    ReCalcRabat( _id_vrsta_p )
endif

_Pripr2_Pos( _id_vrsta_p )

StampAzur( _id_pos, _br_dok, _id_vrsta_p, _id_partner, _uplaceno )

close all

return



// ------------------------------------------------------------------
// stampa i azuriranje racuna
// ------------------------------------------------------------------
function StampAzur( cIdPos, cRadRac, cIdVrsteP, cIdGost, uplaceno )
local cTime, _rec, _dev_id, _dev_params
local nFis_err := 0
private cPartner

select pos_doks

// naredni broj racuna, nova funkcija koja konsultuje sql/db
cStalRac := pos_novi_broj_dokumenta( cIdPos, VD_RN )

gDatum := DATE()

aVezani := {}
//AADD( aVezani, { pos_doks->idpos, cRadRac, cIdVrsteP, pos_doks->datum })
AADD( aVezani, { cIdPos, cRadRac, cIdVrsteP, gDatum })

cPartner := cIdGost

if IsPDV()
    cTime := pos_stampa_racuna_pdv( cIdPos, cRadRac, .f., cIdVrsteP, nil, aVezani )
else
    cTime := pos_stampa_racuna( cIdPos, cRadRac, .f., cIdVrsteP, nil, aVezani )
endif

if (!EMPTY(cTime))
    
    // azuriranje racuna
    azur_pos_racun( cIdPos, cStalRac, cRadRac, cTime, cIdVrsteP, cIdGost )
    
    // azuriranje podataka o kupcu
    if IsPDV()
        AzurKupData(cIdPos)
    endif

    // prikaz info-a o racunu
    if gRnInfo == "D"
        // prikazi info o racunu nakon stampe
        _sh_rn_info( cStalRac )
    endif

    // fiskalizacija, ispisi racun
    if fiscal_opt_active()
    
        // u tops-u uvijek treba da je jedan uredjaj !
        _dev_id := get_fiscal_device( my_user(), NIL, .t. )
        if _dev_id > 0
            _dev_params := get_fiscal_device_params( _dev_id, my_user() )
            if _dev_params == NIL
                return
            endif
        else
            return
        endif

        // stampa fiskalnog racuna, vraca ERR
        nErr := pos_fisc_rn( cIdPos, gDatum, cStalRac, _dev_params, uplaceno )
        
        // da li je nestalo trake ?
        // -20 signira na nestanak trake !
        if nErr = -20
            if Pitanje(,"Da li je nestalo trake (D/N)?", "N") == ;
                "N"
                // setuj kao da je greska
                nErr := 20
            endif
        endif

        // ako postoji ERR vrati racun
        if nErr > 0
            // vrati racun u pripremu...
            pos_povrat_rn( cStalRac, gDatum )
        endif

    endif

endif

// nema vremena, to je znak da nema racuna
if EMPTY( cTime )
    
    if fiscal_opt_active()
        SkloniIznRac()
    endif
    
    MsgBeep("Radni racun <" + ALLTRIM (cRadRac) + "> nije zakljucen!#" + "ponovite proceduru stampanja !!!", 20)
    
    // ako nisam uspio azurirati racun izbrisi iz doks
    select (F_POS_DOKS)
    if !USED()
        O_POS_DOKS
    endif

    select pos_doks
    SEEK gIdPos+"42"+DTOS(gDatum)+cStalRac
    
    if ( pos_doks->idRadnik == "////" )    
        _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )
    endif

endif

return



// ------------------------------------------------------
// ova funkcija treba da izracuna kusur
// ------------------------------------------------------
static function _calc_racun( param )
local _t_area := SELECT()
local _t_rec := RECNO()
local _id_pos := param["idpos"]
local _id_vd := param["idvd"]
local _br_dok := param["brdok"]
local _dat_dok := param["datum"]
local _total := 0
local _iznos := 0
local _popust := 0

select _pos_pripr
go top

do while !EOF() .and. ALLTRIM( field->brdok ) == "PRIPRE"

    _iznos += field->kolicina * field->cijena
    _popust += field->kolicina * field->ncijena
 
    skip

enddo

_total := ( _iznos - _popust )

select ( _t_area )
go ( _t_rec )

return _total


// ---------------------------------------------------------
// ispisuje iznos racuna i kusur
// ---------------------------------------------------------
static function _ispisi( uplaceno, iznos_rn, pos_x, pos_y )
local _vratiti := uplaceno - iznos_rn

if uplaceno <> 0
    @ pos_x, pos_y + 23 SAY "Iznos RN: " + ALLTRIM( STR( iznos_rn, 12, 2 ) ) + ;
                        " vratiti: " + ALLTRIM( STR( _vratiti, 12, 2 ) ) ;
                    COLOR "BR+/B"
endif

return .t.



// -------------------------------------------------------
// forma prije zakljucenja racuna
// -------------------------------------------------------
static function form_zakljuci_racun( params )
local _def_partner := .f.
local _id_vd := params["idvd"]
local _id_pos := params["idpos"]
local _br_dok := params["brdok"]
local _dat_dok := params["datum"]
local _ok := params["zakljuci"]
local _id_vrsta_p := params["idvrstap"]
local _id_partner := params["idpartner"]
local _uplaceno := params["uplaceno"]

if gClanPopust
    // ako je rijec o clanovima pusti da izaberem vrstu placanja
    _id_vrsta_p := SPACE(2)
else
    _id_vrsta_p := gGotPlac
endif

//select _pos
//seek _id_pos + _id_vd + DTOS( _dat_dok ) + _br_dok

Box(, 8, 67 )

    set cursor on
    
    // 01 - gotovina
    // KT - kartica
    // VR - virman
    // CK - cek
    // ...

    @ m_x + 1, m_y + 2 SAY "FORMA ZAKLJUCENJA RACUNA" COLOR "BG+/B"

    @ m_x + 3, m_y + 2 SAY "Nacni placanja (01/KT/VR...):" GET _id_vrsta_p PICT "@!" VALID p_vrstep( @_id_vrsta_p )

    read
     
    // ako nije rijec o gotovini ponudi partnera
    if _id_vrsta_p <> gGotPlac
        _def_partner := .t.
    endif   
    
    if _def_partner
        @ m_x + 4, m_y + 2 SAY "Kupac:" GET _id_partner PICT "@!" VALID P_Firma( @_id_partner )
    else
        _id_partner := SPACE(6)
    endif

    @ _x_pos := m_x + 5, _y_pos := m_y + 2 SAY "Uplaceno:" GET _uplaceno PICT "9999999.99" ;
        VALID {|| if ( _uplaceno <> 0, _ispisi( _uplaceno, _calc_racun( params ), _x_pos, _y_pos ), .t. ), .t. }


    // pitanje za kraj ?
    @ m_x + 8, m_y + 2 SAY "Zakljuciti racun (D/N) ?" GET _ok PICT "@!" VALID _ok $"DN"

    read

BoxC()

if LastKey() == K_ESC
    _ok := "D"
endif

params["zakljuci"] := _ok
params["idpartner"] := _id_partner
params["idvrstap"] := _id_vrsta_p
params["uplaceno"] := _uplaceno

return





function ZakljuciDio()

local cRacBroj:=SPACE(6)

// Zakljucuje dio racuna (ostatak ostaje aktivan)
O__POS

set cursor on
Box (, 1, 50)
// unesi broj racuna
@ m_x+1,m_y+3 SAY "Zakljuci dio radnog racuna broj:" GET cRacBroj VALID P_RadniRac (@cRacBroj)
READ
ESC_BCR
BoxC()

O_StAzur()
O_RAZDR
RazdRac(cRacBroj, .f., 2, "N", "ZAKLJUCENJE DIJELA RACUNA")
close all
return



 
function RazdijeliRacun()
local cOK:=" "
local cAuto:="D"
local cRacBroj:=SPACE(6)
local nKoliko:=0

O__POS

set cursor on
Box(,8,55)
while cOK<>"D"
    @ m_x+1,m_y+3 SAY "          Razdijeli radni racun broj:" GET cRacBroj VALID P_RadniRac (@cRacBroj)
        @ m_x+3,m_y+3 SAY "        Ukupno je potrebno napraviti:" GET nKoliko PICT "99" VALID nKoliko > 1 .AND. nKoliko <= 10
        @ m_x+4,m_y+3 SAY "  (ukljucujuci i ovaj prvi)"
        @ m_x+6,m_y+3 SAY "Automatski razdijeli kolicine? (D/N):" GET cAuto PICT "@!" VALID cAuto $ "DN"
        @ m_x+8,m_y+3 SAY "                  Unos u redu? (D/N):" GET cOK PICT "@!" VALID cOK $ "DN"
        READ
        ESC_BCR
end
BoxC()

O_StAzur()
O_RAZDR
RazdRac(cRacBroj, .t., nKoliko, cAuto, "RAZDIOBA RACUNA")
CLOSERET
return


 
function RobaNaziv(cSifra)
local nARRR:=select()
select roba
hseek cSifra
select(nArrr)
return roba->naz


 
function PromNacPlac()
local cRacun:=SPACE(9)
local cIdVrsPla:=gGotPlac
local cPartner:=SPACE(8)
local cDN:=" "
local cIdPOS
local _rec
private aVezani:={}

O_PARTN
O_VRSTEP
O_ROBA
O__POS_PRIPR
O__POS
O_POS
O_POS_DOKS

Box (, 7, 70)
    // prebaci se na posljednji racun da ti je lakse
    if gVrstaRS<>"S"
        select pos_doks
        seek (gIdPos+VD_RN+Chr (250))
        if pos_doks->IdVd <> VD_RN
            skip -1
        endif
        do while !Bof() .and. pos_doks->(IdPos+IdVd)==(gIdPos+VD_RN) .and. pos_doks->IdRadnik <> gIdRadnik
            skip -1
        enddo
        if !Bof() .and. pos_doks->(IdPos+IdVd)==(gIdPos+VD_RN) .and. pos_doks->IdRadnik==gIdRadnik
            cRacun := PADR (AllTrim (gIdPos)+"-"+AllTrim (pos_doks->BrDok), LEN(cRacun))
        endif
    endif
    
    dDat:=gDatum

    set cursor on
    @ m_x+1,m_y+4 SAY "Datum:" Get dDat
    @ m_x+2,m_y+4 SAY "Racun:" GET cRacun VALID PRacuni (@dDat,@cRacun) ;
                        .and. Pisi_NPG();
                        .AND. RacNijeZaklj (cRacun);
                        .AND. RacNijePlac (@cIdVrspla,@cPartner)
    @ m_x+3,m_y+7 SAY "Nacin placanja:" GET cIdVrsPla ;
                  VALID P_VrsteP (@cIdVrsPla, 3, 26) pict "@!"
    read
    ESC_BCR
  
    if (cIdVrsPla<>gGotPlac)
        @ m_x+5,m_y+9 SAY "Partner:" GET cPartner PICT "@!" ;
                  VALID P_Firma(@cPartner, 5, 26)
        READ
        ESC_BCR
    else
        cPartner:=""
    endif

    // vec je DOKS nastiman u BrowseSRn
    select pos_doks

    _rec := dbf_get_rec()
    _rec["idvrstep"] := cIdVrsPla
    _rec["idgost"] := cPartner    

    update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL")

BoxC()

close all
return


function RacNijeZaklj()
IF (gVrstaRS == "S" .and. kLevel < L_UPRAVN)
  RETURN .t.
EndIF
IF (pos_doks->Datum==gDatum)
  RETURN .t.
EndIF
MsgBeep ("Promjena nacina placanja nije moguca!")
return .f.


function RacNijePlac(cIdVrsPla,cPartner)
//      Provjerava da li je racun pribiljezen kao placen
//      Ako jest, tad promjena nacina placanja nema smisla

IF pos_doks->Placen == "D"
  MsgBeep ("Racun je vec placen!#Promjena nacina placanja nije dopustena!")
  RETURN (.F.)
else
  cIdVrsPla:=pos_doks->idvrstep
  cPartner:= pos_doks->idgost
ENDIF
return (.t.)




function Pisi_NPG()

PushWA()
SELECT VRSTEP
Seek2 (pos_doks->IdVrsteP)
IF FOUND ()
  @ m_x+3,m_y+26 SAY Naz
ENDIF
select partn
Seek2 (pos_doks->IdGost)
IF FOUND ()
  @ m_x+5,m_y+31 SAY LEFT (Naz, 30)
ENDIF
PopWA ()
return (.t.)


 
function RacObilj()
IF ASCAN (aVezani, {|x| x[1]+dtos(x[4])+x[2]==pos_doks->(IdPos+dtos(datum)+BrDok)}) > 0
    RETURN .T.
ENDIF
RETURN .F.


function PreglNezakljRN()
O_StAzur()

dDatOd:=Date()
dDatDo:=Date()

Box (,1,60)
    set cursor on
    @ m_x+1,m_y+2 SAY "Od datuma:" GET dDatOd
    @ m_x+1,m_y+22 SAY "Do datuma:" GET dDatDo
    read
    ESC_BCR
BoxC()

if Pitanje(,"Pregledati nezakljucene racune (D/N) ?","D")=="D"
    StampaNezakljRN(gIdRadnik,dDatOd,dDatDo)
endif
return


 
function RekapViseRacuna()
cBrojStola:=SPACE(3)

O__POS_PRIPR
O_StAzur()

dDatOd:=Date()
dDatDo:=Date()

Box (,2,60)
    set cursor on
    @ m_x+1,m_y+2 SAY "Od datuma:" GET dDatOd
    @ m_x+1,m_y+22 SAY "Do datuma:" GET dDatDo
    @ m_x+2,m_y+2 SAY "Broj stola:" GET cBrojStola VALID !Empty(cBrojStola)
    read
    ESC_BCR
BoxC()

if Pitanje(,"Odstampati zbirni racun (D/N) ?","D")=="D"
    StampaRekap(gIdRadnik, cBrojStola, dDatOd, dDatDo, .t.)
endif

return



// ---------------------------------------------
// prepis racuna 
// ---------------------------------------------
function PrepisRacuna()
local cPolRacun := SPACE(9)
local cIdPos := SPACE(LEN(gIdPos))
local nPoz
private aVezani := {}
private dDatum
private cVrijeme

O__POS_PRIPR
O_StAzur()

Box (, 3, 60)

    dDat := gDatum

    if (klevel <> L_PRODAVAC)
        @ m_x+1,m_y+4 SAY "Datum:" GET dDat
    endif

    set cursor on
    
    @ m_x+2,m_y+4 SAY "Racun:" GET cPolRacun VALID PRacuni( @dDat, @cPolRacun, .t. )
    
    READ
    ESC_BCR

BoxC()

IF LEN(aVezani) > 0
    ASORT (aVezani,,, {|x, y| x[1]+dtos(x[4])+x[2] < y[1]+dtos(y[4])+y[2]})
    cIdPos := aVezani [1][1]
    cPolRacun := dtos(aVezani[1,4])+aVezani [1][2]
ELSE
    nPoz := AT ("-", cPolRacun)
    if npoz<>0
        cIdPos := PADR (AllTrim (LEFT (cPolRacun, nPoz-1)), LEN (gIdPos))
    else
        cIdPos:=gIdPos
    endif
    cPolRacun := PADL (AllTrim (SUBSTR (cPolRacun, nPoz+1)), 6)
    aVezani:={{cIdPos, cPolRacun,"",dDat}}
    cPolRacun:=dtos(dDat)+cPolRacun
    // stampaprep sadrzi 2-param kao dtos(datum)+brdok
ENDIF

StampaPrep( cIdPos, cPolRacun, aVezani )

close all

return



function StrValuta(cNaz2, dDat)
local nTekSel

nTekSel:=select()
select valute
set order to tag "NAZ2"
cNaz2:=padr(cNaz2,4)
seek padr(cnaz2,4)+dtos(dDat)
if valute->naz2<>cnaz2
   skip -1
endif
select (nTekSel)
if valute->naz2<>cnaz2
   return 0
else
   return valute->kurs1
endif



