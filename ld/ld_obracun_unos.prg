/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "ld.ch"

// ------------------------------------------------------
// unos obracuna plate
// ------------------------------------------------------
function ld_unos_obracuna()
local lSaveObracun
local _vals
local _fields
local _pr_kart_pl := fetch_metric("ld_obracun_prikaz_kartice_na_unosu", nil, "N" ) 
private lNovi
private GetList
private cIdRadn
private nPlacenoRSati

cIdRadn := SPACE(_LR_)
GetList := {}
cRj     := gRj
nGodina := gGodina
nMjesec := gMjesec

if GetObrStatus( cRj, nGodina, nMjesec ) $ "ZX"
    MsgBeep("Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!")
    return
elseif GetObrStatus( cRj, nGodina, nMjesec )=="N"
    MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(nMjesec))+"."+ALLTRIM(STR(nGodina)))
    return
endif

do while .t.
    
    lSaveObracun:=.f.
    
    PrikaziBox(@lSaveObracun)

    if (lSaveObracun)
        select ld
        cIdRadn:=field->idRadn
        if (_UIznos<0)
            Beep(2)
            Msg(Lokal("Radnik ne moze imati platu u negativnom iznosu!!!"))
        endif
        nPom:=0
        for i := 1 to cLDPolja
            cPom:=PADL(ALLTRIM(STR(i)),2,"0")
            // ako su sve nule
            nPom+=ABS(_i&cPom) + ABS(_s&cPom)  
        next
        
        if (nPom <> 0)
            
            // upisi tekucu varijantu obracuna
            //_varobr := gVarObracun

            _vals := get_dbf_global_memvars()
            _vals["varobr"] := gVarObracun          

            if !update_rec_server_and_dbf( "ld_ld",  _vals ) 
                delete_with_rlock()
            endif

        else
            if lNovi
                delete_with_rlock()
            endif
        endif

        if _pr_kart_pl == "D"
            if lViseObr
                KartPl(cRj, nMjesec, nGodina, cIdRadn, gObracun)
            else
                KartPl(cRj, nMjesec, nGodina, cIdRadn)
            endif
        endif

    else 
        
        if lNovi  
            // ako je novi zapis  .and. ESCAPE
            delete_with_rlock()
        endif
        
        return
        
    endif

    select ld
    use  
    // svaki put zatvoriti tabelu ld

    Beep(1)

enddo // do while .t.
return

// -----------------------------------
// -----------------------------------
function QQOUTC(cTekst,cBoja)
@ ROW(),COL() SAY cTekst COLOR cBoja
return



// ----------------------------------
// ----------------------------------
function OObracun()

select F_LD
if !used()
    O_LD
endif

select F_PAROBR
if !used()
    O_PAROBR
endif

select F_RADN
if !used()
    O_RADN
endif

select F_VPOSLA
if !used()
    O_VPOSLA
endif

select F_STRSPR
if !used()
    O_STRSPR
endif

select F_DOPR
if !used()
    O_DOPR
endif

select F_POR
if !used()
    O_POR
endif

select F_KBENEF
if !used()
    O_KBENEF
endif

select F_OPS
if !used()
    O_OPS
endif

select F_LD_RJ
if !used()
    O_LD_RJ
endif

select F_RADKR
if !used()
    O_RADKR
endif

select F_KRED
if !used()
    O_KRED
endif

select F_RADSAT
if !used()
    O_RADSAT
endif

if ( IsRamaGlas() )
    MsgBeep("http://redmine.bring.out.ba/issues/25988")
    QUIT
    O_RADSIHT
    O_RNAL
endif

return

function PrikaziBox(lSaveObracun)
local nULicOdb
local cTrosk
local cOpor
local _radni_sati := fetch_metric("ld_radni_sati", nil, "N" ) 
private cIdRj
private cGodina
private cIdRadn
private cMjesec


cIdRadn:=SPACE(6)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun

if Logirati("LD","DOK","UNOS")
    lLogUnos:=.t.
else
    lLogUnos:=.f.
endif

OObracun()

if lViseObr
    O_TIPPRN
else
    select F_TIPPR
    if !used()
        O_TIPPR
    endif
endif

lNovi:=.f.

Box( , MAXROWS()-10, MAXCOLS()-10)
    @ m_x+1, m_y+2 SAY Lokal("Radna jedinica: ")
    QQOutC(cIdRJ, "GR+/N")
    if gUNMjesec=="D"
        @ m_x+1, col()+2 SAY Lokal("Mjesec: ")  GET cMjesec pict "99"
    else
        @ m_x+1, col()+2 SAY Lokal("Mjesec: ")
        QQOutC(str(cMjesec, 2), "GR+/N")
    endif

    if lViseObr
        if gUNMjesec=="D"
            @ m_x+1, col()+2 SAY Lokal("Obracun: ") GET cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
        else
            @ m_x+1, col()+2 SAY Lokal("Obracun: ")
            QQOutC(cObracun, "GR+/N")
        endif
    endif

    @ m_x+1,COL()+2 SAY Lokal("Godina: ")
    QQOutC(str(cGodina,4), "GR+/N")
    
    @ m_x+2,m_y+2 SAY Lokal("Radnik:") GET cIdRadn ;
      VALID {|| P_Radn(@cIdRadn), SetPos(m_x+2, m_y+17), ;
      QQOUT(PADR( TRIM(radn->naz)+" ("+TRIM(radn->imerod)+") "+TRIM(radn->ime), 28 )), .t.}
    
    read
    
    clvbox()
    ESC_BCR

    // da li postoje uneseni parametri obracuna ?
    nO_Ret := ParObr( cMjesec, cGodina, IF(lViseObr, cObracun, nil), ;
        cIdRj )
    
    if nO_ret = 0
        
        msgbeep("Ne postoje uneseni parametri obracuna za " + ;
            STR(cMjesec,2) + "/" + STR(cGodina,4) + " !!")
        
        boxc()
        return

    elseif nO_ret = 2
        
        msgbeep("Ne postoje uneseni parametri obracuna za "+ ;
            STR(cMjesec,2) + "/" + STR(cGodina,4) + " !!" + ;
            "#Koristit cu postojece parametre.")
    endif
    
    select radn
    
    if gVarObracun == "2"
        // tip rada
        cTR := g_tip_rada( cIdRadn, cIdRj )
        // oporeziv
        cOpor := g_oporeziv( cIdRadn, cIdrj )
        // koristi troskove
        cTrosk := radn->trosk
        nULicOdb := ( radn->klo * gOsnLOdb )
        // ovi tipovi nemaju odbitka !
        if cTR $ "A#U#S"
            nULicOdb := 0
        endif
        if lViseObr .and. cObracun <> "1"
            nULicOdb := 0
        endif
    endif

    select ld
    
    seek STR(cGodina,4) + cIdRj + str(cMjesec,2) + IIF(lViseObr,cObracun,"") + cIdRadn
    
    if found()
        lNovi:=.f.
        set_global_vars_from_dbf()
    else
        lNovi:=.t.
        append blank
        set_global_vars_from_dbf()

        _Godina := cGodina
        _idrj   := cIdRj
        _idradn := cIdRadn
        _mjesec := cMjesec
        if gVarObracun == "2"
            _ulicodb := nULicOdb
            if LD->(FIELDPOS("TROSK")) <> 0
                _trosk := cTrosk
                _opor := cOpor
            endif
        endif
        if lViseObr
            _obr := cObracun
        endif
    endif

    if lNovi
        _brbod:=radn->brbod
        _kminrad:=radn->kminrad
        _idvposla:=radn->idvposla
        _idstrspr:=radn->idstrspr
    endif

    ParObr(cMjesec, cGodina, IIF(lViseObr,cObracun,), cIdRj)  
    // podesi parametre obracuna za ovaj mjesec
    
    if gTipObr=="1"
        @ m_x+3, m_y+2   SAY IF(gBodK=="1", Lokal("Broj bodova"), Lokal("Koeficijent")) GET _brbod pict "99999.99" valid FillBrBod(_brbod)
    else
        @ m_x+3, m_y+2   SAY Lokal("Plan.osnov ld") GET _brbod pict "99999.99" valid FillBrBod(_brbod)
    endif
    select ld
    @ m_x+3, col()+2 SAY IF(gBodK=="1", Lokal("Vrijednost boda"), Lokal("Vr.koeficijenta")); @ row(),col()+1 SAY parobr->vrbod  pict "99999.99999"
    if gMinR=="B"
        @ m_x + 3, col() + 2 SAY Lokal("Minuli rad (bod)") GET _kminrad pict "9999.99" valid FillKMinRad(_kminrad)
    else
        @ m_x + 3, col() + 2 SAY Lokal("Koef.minulog rada") GET _kminrad pict "99.99%" valid FillKMinRad(_kminrad)
    endif
    if gVarObracun == "2"
        @ m_x + 4, m_y + 2 SAY "Lic.odb:" GET _ulicodb PICT "9999.99"
        @ m_x + 4, col()+1 SAY Lokal("Vrsta posla koji radnik obavlja") GET _IdVPosla valid (empty(_idvposla) .or. P_VPosla(@_IdVPosla,4,43)) .and. FillVPosla()
    else
        @ m_x+4,m_y+2 SAY Lokal("Vrsta posla koji radnik obavlja") GET _IdVPosla valid (empty(_idvposla) .or. P_VPosla(@_IdVPosla,4,43)) .and. FillVPosla()
    endif
    read

    if (IsRamaGlas() .and. RadnikJeProizvodni())
        UnosSatiPoRNal(cGodina, cMjesec, cIdRadn)
    endif

    if _radni_sati == "D"
        @ m_x + 4, m_y + 59 SAY "R.sati:" GET _radSat
    endif
    
    read
    
    if _radni_sati == "D"
        nTArea := SELECT()
        nSatiPreth := 0
        nSatiPreth := FillRadSati( cIdRadn, _radSat )
        select (nTArea)
    endif
    
    if gSihtarica=="D"
        UzmiSiht()
    endif

    PrikUnos()
    
    PrikUkupno(@lSaveObracun)
    
    if _radni_sati == "D" .and. lSaveObracun == .f.
        // ako nije sacuvan obracun ponisti i radne sate
        delRadSati( cIdRadn, nSatiPreth )
    endif
    
    if lLogUnos
        if lNovi
            EventLog(nUser,goModul:oDataBase:cName,"DOK","UNOS",ld->uiznos,nil,nil,nil,STR(cMjesec,2),ALLTRIM(cIdRadn),STR(cGodina,4),Date(),Date(),"", Lokal("Obracunata plata za radnika"))
        else
            EventLog(nUser,goModul:oDataBase:cName,"DOK","UNOS",ld->uiznos,nil,nil,nil,STR(cMjesec,2),ALLTRIM(cIdRadn),STR(cGodina,4),Date(),Date(),"", Lokal("Korekcija obracuna za radnika"))
        endif
    endif

BoxC()
return



// ----------------------------------
// ispisuje ukupno na dnu obracuna
// ----------------------------------
function PrikUkupno(lSaveObracun)

_USati:=0
_UNeto:=0
_UOdbici:=0

UkRadnik()  
// filuje _USati,_UNeto,_UOdbici    

_UIznos := _UNeto + _UOdbici

if gVarObracun == "2"

    nKLO := radn->klo
    cTipRada := g_tip_rada( _idradn, _idrj )
    nSPr_koef := 0
    nTrosk := 0
    nBrOsn := 0
    cOpor := " "
    cTrosk := " "
    lInRS := .f.
    lInRs := in_rs(radn->idopsst, radn->idopsrad)
    
    // upisi oporeziva i neoporezive naknade
    for i:=1 to 40

        cTp := PADL(ALLTRIM(STR(i)), 2, "0")
        xVar := "_I" + cTp

        nTArea := SELECT()
        
        select tippr
        seek cTp
        
        select (nTArea)
        
        if tippr->uneto == "D"
            _nakn_opor += &(xVar)
        elseif tippr->uneto == "N"
            _nakn_neop += &(xVar)
        endif

        select (nTArea)

    next

    // radnik oporeziv ?
    if radn->(FIELDPOS("opor")) <> 0
        cOpor := radn->opor
    endif
    
    // koristi troskove ?
    if radn->(FIELDPOS("trosk")) <> 0
        cTrosk := radn->trosk
    endif

    // samostalni djelatnik
    if cTipRada == "S"
        if radn->(FIELDPOS("SP_KOEF")) <> 0
            nSPr_koef := radn->sp_koef
        endif
    endif

    // ako su ovi tipovi primanja - nema odbitka !
    if cTipRada $ "A#U#P#S"
        _ULicOdb := 0
    endif

    // bruto osnova
    _UBruto := bruto_osn( _UNeto, cTipRada, _ULicOdb, nSPr_koef, cTrosk ) 

    // ugovor o djelu
    if cTipRada == "U" .and. cTrosk <> "N"
        nTrosk := ROUND2( _UBruto * (gUgTrosk / 100), gZaok2 )
        if lInRS == .t.
            nTrosk := 0
        endif
        _UBruto := _UBruto - nTrosk 
    endif

    // autorski honorar
    if cTipRada == "A" .and. cTrosk <> "N"
        
        nTrosk := ROUND2( _UBruto * (gAhTrosk / 100), gZaok2 )
        if lInRS == .t.
            nTrosk := 0
        endif
        _UBruto := _UBruto - nTrosk
    endif

    // uiznos je sada sa uracunatim brutom i ostalim
    
    nMinBO := _UBruto
    if cTipRada $ " #I#N"
        if _I01 = 0
            // ne racunaj min.bruto osnovu
        else
            nMinBO := min_bruto( _UBruto, _USati )
        endif
    endif

    // ukupni doprinosi IZ place
    nDop := u_dopr_iz( nMinBO, cTipRada )
    _udopr := nDop

    // doprinosi iz place - stopa
    _udop_st := 31.0

    // poreska osnovica
    nPorOsnovica := ( (_ubruto - _udopr) - _ulicodb )

    if nPorOsnovica < 0 .or. !radn_oporeziv( _idradn, _idrj )
        nPorOsnovica := 0
    endif

    // porez
    _uporez := izr_porez( nPorOsnovica, "B" )
    
    // stopa poreza
    _upor_st := 10.0

    // nema poreza
    if !radn_oporeziv( _idradn, _idrj )
        _uporez := 0
        _upor_st := 0
    endif
    
    // neto plata
    _uneto2 := ROUND( ( ( _ubruto - _udopr) - _uporez ), gZaok2 )
    
    // ako je prekoracen minimalni neto uzmi minimalni
    if cTipRada $ " #I#N#" 
        nMinNeto := min_neto( _uneto2, _usati )
        _uneto2 := nMinNeto
    endif

    // ukupno za isplatu
    _uiznos := ROUND2( _uneto2 + _UOdbici, gZaok2 )

    if cTipRada $ "U#A" .and. cTrosk <> "N"
        // kod ovih vrsta dodaj i troskove
        _uIznos := ROUND2( _uiznos + nTrosk, gZaok2 )
        // ako je u RS, onda je isplata ista kao i neto!
        if lInRS == .t.
            _uIznos := _UNeto
        endif
    endif

    if cTipRada $ "S"
        // neto je za isplatu
        _uIznos := _UNeto
    endif

endif

@ m_x+19,m_y+2 SAY "Ukupno sati:"
@ row(),col()+1 SAY _USati PICT gPics

if gVarObracun == "2"
    @ m_x+19,col()+2 SAY "Uk.lic.odb.:"
    @ row(),col()+1 SAY _ULicOdb PICT gPici
endif

@ m_x+20,m_y+2 SAY "Primanja:"
@ row(),col()+1 SAY _UNeto PICT gPici
@ m_x+20,col()+2 SAY "Odbici:"
@ row(),col()+1 SAY _UOdbici PICT gPici
@ m_x+20,col()+2 SAY "UKUPNO ZA ISPLATU:"
@ row(),col()+1 SAY _UIznos PICT gPici
@ m_x+22,m_y+10 SAY "Pritisni <ENTER> za snimanje, <ESC> napustanje"

if gVarObracun == "2" .and. ld->(FIELDPOS("V_ISPL")) <> 0
    @ m_x+21,m_y+2 SAY "Vrsta isplate (1 - 13):"
    @ row(),col()+1 GET _v_ispl
    read
endif

Inkey(0)

do while LastKey()<>K_ESC .and. LastKey()<>K_ENTER
    Inkey(0)
enddo

if LastKey()==K_ESC
    MsgBeep("Obracun nije pohranjen !!!")
    lSaveObracun:=.f.
else
    MsgBeep("Obracun je pohranjen !!!")
    lSaveObracun:=.t.
endif

return

// ------------------------------------------------
// unos tipova primanja
// ------------------------------------------------
function PrikUnos()
local i
private cIdTP:="  "
private nRedTP:=4
private cVarTP
private cIznosTP
cTipPrC:=" "

for i:=1 to cLDPolja
    if i < 10
        cIdTP:="0" + ALLTRIM(STR(i))
        cVarTP:="_S0"+ALLTRIM(STR(i))
        cIznosTP:="_I0"+ALLTRIM(STR(i))
        cPoljeIznos:="I0"+ALLTRIM(STR(i))
        cPoljeSati:="S0"+ALLTRIM(STR(i))
    else
        cIdTP:=ALLTRIM(STR(i))
        cVarTP:="_S"+ALLTRIM(STR(i))
        cIznosTP:="_I"+ALLTRIM(STR(i))
        cPoljeIznos:="I"+ALLTRIM(STR(i))
        cPoljeSati:="S"+ALLTRIM(STR(i))
    endif
    
    nRedTP++
    
    select tippr
    seek cIdTP
    select ld
    
    if LD->(FieldPos(cPoljeIznos)=0) .and. LD->(FieldPos(cPoljeSati)=0)
        MsgBeep("Broj polja u LD -> 30, potrebna modifikacija struktura !!!")
        return  
    endif
    
    cW:="WhUnos("+cm2str(cIdTp)+")"
    cV:="Izracunaj(@"+cIznosTP+")"

    if (tippr->(FOUND()) .and. tippr->aktivan=="D")
        if (tippr->fiksan $ "DN")
                @ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (SATI) " GET &cVarTP PICT gPics when &cW valid &cV
        elseif (tippr->fiksan=="P")
                @ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (%)    " GET &cVarTP. PICT "999.99" when &cW valid &cV
        elseif tippr->fiksan=="B"
                @ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+"(BODOVA)" GET &cVarTP. PICT gPici when &cW valid &cV
        elseif tippr->fiksan=="C"
                @ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+"        " GET cTipPrC when &cW valid &cV
        endif
    
        @ m_x+nRedTP,m_y+50 SAY "IZNOS" GET &cIznosTP PICT gPici
    endif
    
    if (i%17==0)
        read
        @ m_x+5,m_y+2 CLEAR TO m_x+21,m_y+69
        nRedTP:=4
    endif

    if (i==cLDPolja)
        read
    endif

next

return

// --------------------------------------------------
// validacija WHEN na unosu tipova primanja
// --------------------------------------------------
function WhUnos(cTP)
tippr->(DbSeek(cTP))
return .t.




function ValRNal(cPom,i)
if !EMPTY(cPom)
    P_RNal(@cPom)
    cRNal[i]:=cPom
endif
return .t.


function UcitajSateRNal(nGodina,nMjesec,cIdRadn)
local nArr:=SELECT()
local i:=0
select radsiht
seek str(nGodina,4)+str(nMjesec,2)+cIdRadn
do while !eof() .and. str(field->godina,4)+str(field->mjesec,2)+field->idRadn==str(nGodina,4)+str(nMjesec,2)+cIdRadn
    ++i
    cRNal[i]:=field->idRNal
    nSati[i]:=field->sati
    skip 1
enddo
for j:=i+1 to 8
    cRNal[j]:=SPACE(10)
    nSati[j]:=0
next
select (nArr)
return

