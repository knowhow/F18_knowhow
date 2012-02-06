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



// -----------------------------------
// otvaranje potrebnih tabela
// -----------------------------------
static function _o_tbl()
O_SIFK
O_SIFV
O_TDOK
O_ROBA
O_KONCIJ
O_KONTO
O_PARTN
return


// -----------------------------------------------
// finansijska lager lista magacina
// -----------------------------------------------
function FLLM()
local cTipDok, cDokNaz
local _t_area, _a_exp
local _export := .f.
local _exp_dn := "N"
local _launch
local cPartnNaz, cPartnMj, cPartnPtt

_o_tbl()

PicDem := REPLICATE("9", VAL(gFPicDem)) + gPicDem
PicCDem := REPLICATE("9", VAL(gFPicCDem)) + gPicCDem

cIdKonto := PADR( "1320", gDuzKonto )
dDatOd := CTOD("")
dDatDo := DATE()
qqRoba := SPACE(60)
qqMKonta := SPACE(60)
qqTarifa := SPACE(60)
qqidvd := SPACE(60)
private cPNab:="N"
private cNula:="D"
private cErr:="N"
private cPapir:="1"

if IsDomZdr()
    private cKalkTip:=SPACE(1)
endif

Box( , 11, 60 )

do while .t.

    if gNW $ "DX"
        @ m_x+1,m_y+2 SAY "Firma "
        ?? gFirma, "-", gNFirma
    else
        @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif

    @ m_x+3,m_y+2 SAY "Varijanta (1/2)" GET cPapir VALID cPapir $ "12"

    read

    if cPapir=="2"
        qqidvd := PADR( "10;", 60 )
    endif

    private cViseKonta := "N"

    @ m_x+4,m_y+2 SAY "Vise konta (D/N)" GET cViseKonta VALID cViseKonta$"DN" PICT "@!"

    read

    if cViseKonta=="N"
        @ m_x+5,m_y+2 SAY "Konto   " GET cIdKonto valid "." $ cidkonto .or. P_Konto(@cIdKonto)
    else
        @ m_x+5,m_y+2 SAY "Konta " GET qqMKonta PICT "@!S30"
    endif

    @ m_x+7,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
    @ m_x+8,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
    @ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
    @ m_x+9,col()+2 SAY "do" GET dDatDo

    if IsDomZdr()
        @ m_x+10,m_y+2 SAY "Prikaz po tipu sredstva " GET cKalkTip PICT "@!"
    endif

    @ m_x + 11, m_y + 2 SAY "Export podataka (D/N) ?" GET _exp_dn VALID _exp_dn $ "DN" PICT "@!"

    read

    ESC_BCR

    private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
    private aUsl3:=Parsiraj(qqIDVD,"idvd")

    if cViseKonta=="D"
        private aUsl4:=Parsiraj(qqMKonta,"mkonto")
    endif

    if aUsl2<>NIL
        exit
    endif

    if aUsl3<>NIL
        exit
    endif

    if cViseKonta=="D" .and. aUsl4<>NIL
        exit
    endif

enddo

BoxC()

// treba li exportovati podatke
if _exp_dn == "D"
    _export := .t.
endif

if _export

    // napravi pomocnu tabelu
    _cre_tmp_tbl()
    // otvori ponovo tabele izvjestaja
    _o_tbl()

endif

cIdFirma := gFirma

// sinteticki konto
if cViseKonta=="N"
    if len(trim(cidkonto))<=3 .or. "." $ cidkonto
        if "." $ cidkonto
                cidkonto:=strtran(cidkonto,".","")
        endif
        cIdkonto:=trim(cidkonto)
    endif
endif

O_KALK    
select kalk
set order to tag "5"
// "idFirma+dtos(datdok)+idvd+brdok+rbr"

hseek cIdFirma

select koncij
seek trim(cidkonto)
select kalk

EOF CRET

nLen := 1

aFLLM:={}
AADD(aFLLM, {5, " R.br"})
AADD(aFLLM, {8, " Datum"})
AADD(aFLLM, {11, " Broj dok."})
if cPapir=="2"
    AADD(aFLLM, {32, " Sifra i naziv partnera"})
    AADD(aFLLM, {13, "fakt./otp"})
    AADD(aFLLM, {10, " NV Dug."})
    AADD(aFLLM, {LEN(PicDem), c10T1})
    AADD(aFLLM, {LEN(PicDem), c10T2})
    AADD(aFLLM, {LEN(PicDem), c10T3})
    AADD(aFLLM, {LEN(PicDem), c10T4})
    AADD(aFLLM, {LEN(PicDem), c10T5})
    AADD(aFLLM, {LEN(PicDem), " marza"})
    AADD(aFLLM, {LEN(PicDem), " VPV Dug."})
else
    AADD(aFLLM, {LEN(PicDem), " NV.Dug."})
    AADD(aFLLM, {LEN(PicDem), " NV.Pot."})
    AADD(aFLLM, {LEN(PicDem), " NV"})
    AADD(aFLLM, {LEN(PicDem), " VPV Dug."})
    AADD(aFLLM, {LEN(PicDem), " VPV Pot."})
    AADD(aFLLM, {LEN(PicDem), " VPV"})
    AADD(aFLLM, {LEN(PicDem), " Rabat"})
endif
private cLine:=SetRptLineAndText(aFLLM, 0)
private cText1:=SetRptLineAndText(aFLLM, 1, "*")

START PRINT CRET

?

if cPapir=="2"
    P_COND2
else
    P_COND
endif

private nTStrana:=0
private bZagl:={|| ZaglFLLM()}

Eval(bZagl)
nTUlaz:=nTIzlaz:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=27
private nRbr:=0

IF cPapir!="4"
 ntDod1:=ntDod2:=ntDod3:=ntDod4:=ntDod5:=ntDod6:=ntDod7:=ntDod8:=0
ENDIF


do while !eof() .and. cidfirma==idfirma .and.  IspitajPrekid()
    nUlaz:=0
    nIzlaz:=0
    nVPVU:=0
    nVPVI:=0
    nNVU:=0
    nNVI:=0
    nRabat:=0
    IF cPapir!="4"
        nDod1:=nDod2:=nDod3:=nDod4:=nDod5:=nDod6:=nDod7:=nDod8:=0
    ENDIF

    if cViseKonta=="N" .and. mkonto<>cidkonto
        skip
        loop
    else
    
    endif
 
    cBrFaktP := IF( cPapir=="2" , brfaktp , "" )
    cIdPartner:=idpartner
    dDatDok:=datdok
    cBroj:=idvd+"-"+brdok
    cTipDok := idvd

    _t_area := SELECT()
    
    select tdok
    hseek cTipDok
    cDokNaz := field->naz

    select partn
    hseek cIdPartner

    cPartnNaz := field->naz
    cPartnPtt := field->ptt
    cPartnMj := field->mjesto

    select ( _t_area )

    do while !eof() .and. cIdFirma+dtos(dDatDok)+cBroj==idFirma+dtos(datdok)+idvd+"-"+brdok .and.  IspitajPrekid()
        if cViseKonta=="N" .and. (datdok<dDatOd .or. datdok>dDatDo .or. mkonto<>cidkonto)
            skip
            loop
        endif
        if len(aUsl2)<>0          // premjesteno odozgo
            if !Tacno(aUsl2)    //
                skip        //
                loop        //
            endif               //
        endif                     //

        if len(aUsl3)<>0
            if !Tacno(aUsl3)
                skip
                loop
            endif
        endif
        
        if cViseKonta=="D" .and. len(aUsl4)<>0
            if !Tacno(aUsl4)
                skip
                loop
            endif
        endif
        
        if IsDomZdr() .and. !Empty(cKalkTip)
            if kalk->tip <> cKalkTip
                skip
                loop
            endif
        endif
        
        if mu_i=="1" .and. !(idvd $ "12#22#94")
                nVPVU+=round( vpc*(kolicina-gkolicina-gkolicin2), gZaokr)
                nNVU+=round( nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
        elseif mu_i=="5"
                nVPVI+=round( vpc*kolicina , gZaokr)
                nRabat+=round( rabatv/100*vpc*kolicina , gZaokr)
                nNVI+=round( nc*kolicina , gZaokr)
        elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
                nVPVI-=round( vpc*kolicina , gZaokr)
                nRabat-=round( rabatv/100*vpc*kolicina , gZaokr)
                nNVI-=round( nc*kolicina , gZaokr)
        elseif mu_i=="3"    // nivelacija
                nVPVU+=round( vpc*kolicina , gZaokr)
        endif

        if cPapir!="4"
            nDod1+=MMarza(); nDod2+=MMarza2()
            nDod3+=prevoz; nDod4+=prevoz2; nDod5+=banktr
            nDod6+=spedtr; nDod7+=cardaz; nDod8+=zavtr
        endif

        skip 1
    
    enddo 

    if round(nNVU-nNVI,4)==0 .and. round(nVPVU-nVPVI,4)==0
        loop
    endif

    if prow()>61+gPStranica
        FF
        eval(bZagl)
    endif

    ? str(++nrbr,4)+".",dDatDok,cBroj
    nCol1:=pcol()+1

    nTVPVU+=nVPVU; nTVPVI+=nVPVI
    nTNVU+=nNVU; nTNVI+=nNVI
    nTRabat+=nRabat
    ntDod1+=nDod1; ntDod2+=nDod2; ntDod3+=nDod3; ntDod4+=nDod4; ntDod5+=nDod5
    ntDod6+=nDod6; ntDod7+=nDod7; ntDod8+=nDod8

    if cPapir="2"
        @ prow(),pcol()+1 SAY cIdPartner + " " + PADR( cPartnNaz, 28 ) + " " + cBrFaktP
        @ prow(),pcol()+1 SAY nNVU pict picdem
        @ prow(),pcol()+1 SAY nDod3 pict picdem
        @ prow(),pcol()+1 SAY nDod5 pict picdem
        @ prow(),pcol()+1 SAY nDod6 pict picdem
        @ prow(),pcol()+1 SAY nDod7 pict picdem
        @ prow(),pcol()+1 SAY nDod8 pict picdem
        @ prow(),pcol()+1 SAY nDod1 pict picdem
        @ prow(),pcol()+1 SAY nVPVU pict picdem
    else
        @ prow(),pcol()+1 SAY nNVU pict picdem
        @ prow(),pcol()+1 SAY nNVI pict picdem
        @ prow(),pcol()+1 SAY nTNVU-nTNVI pict picdem
        @ prow(),pcol()+1 SAY nVPVU pict picdem
        @ prow(),pcol()+1 SAY nVPVI pict picdem
        @ prow(),pcol()+1 SAY nTVPVU-nTVPVI pict picdem
        @ prow(),pcol()+1 SAY nRabat pict picdem
    endif

    // dodaj u r_export
    if _export 

        _add_to_exp( cBroj, dDatDok, cDokNaz, cIdPartner, ;
                     cPartnNaz, cPartnMj, cPartnPtt, cBrFaktP, ;
                     nNVU, nNVI, nTNVU - nTNVI, ;
                     nVPVU, nVPVI, nTVPVU - nTVPVI, ;
                     nRabat )

    endif

enddo

? cLine
? "UKUPNO:"

if cPapir=="2"
    @ prow(),pcol()+64 SAY ntNVU pict picdem
    @ prow(),pcol()+1 SAY ntDod3 pict picdem
    @ prow(),pcol()+1 SAY ntDod5 pict picdem
    @ prow(),pcol()+1 SAY ntDod6 pict picdem
    @ prow(),pcol()+1 SAY ntDod7 pict picdem
    @ prow(),pcol()+1 SAY ntDod8 pict picdem
    @ prow(),pcol()+1 SAY ntDod1 pict picdem
    @ prow(),pcol()+1 SAY ntVPVU pict picdem
else
    @ prow(),nCol1    SAY ntNVU pict picdem
    @ prow(),pcol()+1 SAY ntNVI pict picdem
    @ prow(),pcol()+1 SAY ntNVU-NtNVI pict picdem
    @ prow(),pcol()+1 SAY ntVPVU pict picdem
    @ prow(),pcol()+1 SAY ntVPVI pict picdem
    @ prow(),pcol()+1 SAY ntVPVU-NtVPVI pict picdem
    @ prow(),pcol()+1 SAY ntRabat pict picdem
endif

? cLine

FF
END PRINT

// pregled izvjestaja nakon generisanja u spreadsheet aplikaciji
if _export
    _launch := exp_report()
    tbl_export( _launch )
endif

close all
return

// -----------------------------------------
// zaglavlje izvjestaja
// -----------------------------------------
static function ZaglFLLM()

Preduzece()

if cPapir=="2"
    P_COND2
else
    P_COND
endif

if cViseKonta=="N"
    select konto
    hseek cidkonto
endif

?? "KALK: Finansijsko stanje za period", dDatOd, "-", dDatDo, " NA DAN "
?? date(), SPACE(10), "Str:", STR( ++nTStrana, 3 )

if cViseKonta=="N"
    ? "Magacin:", cIdKonto, "-", konto->naz
else
    ? "Magacini:", qqMKonta
endif

if IsDomZdr() .and. !Empty(cKalkTip)
    PrikTipSredstva(cKalkTip)
endif

select kalk

? cLine
? cText1
? cLine

return


// ----------------------------------------------
// kreiranje pomocne tabele izvjestaja
// ----------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}

AADD( _dbf, { "broj"      , "C", 10, 0 } )
AADD( _dbf, { "datum"     , "D",  8, 0 } )
AADD( _dbf, { "vr_dok"    , "C", 30, 0 } )
AADD( _dbf, { "idpartner" , "C",  6, 0 } )
AADD( _dbf, { "part_naz"  , "C",100, 0 } )
AADD( _dbf, { "part_mj"   , "C", 50, 0 } )
AADD( _dbf, { "part_ptt"  , "C", 10, 0 } )
AADD( _dbf, { "br_fakt"   , "C", 20, 0 } )
AADD( _dbf, { "nv_dug"    , "N", 15, 2 } )
AADD( _dbf, { "nv_pot"    , "N", 15, 2 } )
AADD( _dbf, { "nv_saldo"  , "N", 15, 2 } )
AADD( _dbf, { "vp_dug"    , "N", 15, 2 } )
AADD( _dbf, { "vp_pot"    , "N", 15, 2 } )
AADD( _dbf, { "vp_saldo"  , "N", 15, 2 } )
AADD( _dbf, { "vp_rabat"  , "N", 15, 2 } )

t_exp_create( _dbf )

return _dbf


// ---------------------------------------
// dodaj podatke u r_export tabelu
// ---------------------------------------
static function _add_to_exp( broj_dok, datum_dok, vrsta_dok, id_partner, ;
                            part_naz, part_mjesto, part_ptt, broj_fakture, ;
                            n_v_dug, n_v_pot, n_v_saldo, ;
                            v_p_dug, v_p_pot, v_p_saldo, ;
                            v_p_rabat )

local _t_area := SELECT()

O_R_EXP

APPEND BLANK

REPLACE field->broj WITH broj_dok
REPLACE field->datum WITH datum_dok
REPLACE field->vr_dok WITH vrsta_dok
REPLACE field->idpartner WITH id_partner
REPLACE field->part_naz WITH part_naz
REPLACE field->part_mj WITH part_mjesto
REPLACE field->part_ptt WITH part_ptt
REPLACE field->br_fakt WITH broj_fakture
REPLACE field->nv_dug WITH n_v_dug
REPLACE field->nv_pot WITH n_v_pot
REPLACE field->nv_saldo WITH n_v_saldo
REPLACE field->vp_dug WITH v_p_dug
REPLACE field->vp_pot WITH v_p_pot
REPLACE field->vp_saldo WITH v_p_saldo
REPLACE field->vp_rabat WITH v_p_rabat

select (_t_area)
return


