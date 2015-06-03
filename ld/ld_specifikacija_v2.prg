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


// -----------------------------------------------
// vrati zadnji dan mjeseca
// -----------------------------------------------
function getlday( nMonth )
local nDay := 0
do case
    case nMonth = 1
        nDay := 31
    case nMonth = 2
        nDay := 28
    case nMonth = 3
        nDay := 31
    case nMonth = 4
        nDay := 30
    case nMonth = 5
        nDay := 31
    case nMonth = 6
        nDay := 30
    case nMonth = 7
        nDay := 31
    case nMonth = 8
        nDay := 31
    case nMonth = 9
        nDay := 30
    case nMonth = 10
        nDay := 31
    case nMonth = 11
        nDay := 30
    case nMonth = 12
        nDay := 31
endcase
return nDay


// ----------------------------------------------
// da li je radnik u republ.srpskoj
// gleda polje region "REG" iz opcina
// " " ili "1" = federacija
// "2" = rs
// ----------------------------------------------
function in_rs( cOpsst, cOpsrad )
local lRet := .f.
local nTArea := SELECT()
O_OPS
select ops
hseek cOpsst
if ops->reg == "2"
    lRet := .t.
endif
select (nTArea)
return lRet


// -----------------------------------------------
// vrati prvi dan u mjesecu
// -----------------------------------------------
function getfday( nMonth )
local nDay := 1
return nDay


// ------------------------------------------------
// specifikacija place, novi obracun
// ------------------------------------------------
function SpecPl2()
local GetList:={}
local aPom:={}
local nGrupaPoslova:=5
local nLM:=5
local nLin
local nPocetak
local i:=0
local j:=0
local k:=0
local nPreskociRedova
local cLin
local nPom
local uNaRuke
local aOps:={}
local cRepSr := "N"
local cRTipRada := " "
local cMatBr
local _proizv_ini
local _a_benef := {}

private aSpec:={}
private cFNTZ:="D"
private gPici:="9,999,999,999,999,999" + IIF(gZaok>0, PADR(".",gZaok+1,"9"), "")
private gPici2:="9,999,999,999,999,999" + IIF(gZaok2>0, PADR(".",gZaok2+1,"9"), "")
private gPici3:="999,999,999,999.99"

_proizv_ini := my_home() + "proizvj.ini"

for i := 1 to nGrupaPoslova+1
    //  br.bodova, br.radnika, minuli rad, uneto
    AADD(aSpec,{0,0,0,0})
next

cIdRJ:="  "
qqIDRJ:=""
qqOpSt:=""

nPorOlaksice:=0
nBrutoOsnova:=0
nMBrutoOsnova:=0
nBrutoDobra:=0
nBrutoOsBenef := 0
nPojBrOsn := 0
nPojBrBenef := 0
nOstaleObaveze:=0
nBolPreko:=0
nPorezOstali:=0
nObustave:=0
nOstOb1:=0
nOstOb2:=0
nOstOb3:=0
nOstOb4:=0
nPorOsnovica:=0
uNaRuke := 0

// prvi dan mjeseca
nDanOd := getfday( gMjesec )
nMjesecOd:=gMjesec
nGodinaOd:=gGodina
// posljednji dan mjeseca
nDanDo := getlday( gMjesec )
nMjesecDo:=gMjesec
nGodinaDo:=gGodina

// varijable izvjestaja
nMjesec := gMjesec
nGodina := gGodina

cObracun:=gObracun
cMRad:="17"
cPorOl:="  "
cBolPr:="  "

ccOO1:=SPACE(20)
ccOO2:=SPACE(20)
ccOO3:=SPACE(20)
ccOO4:=SPACE(20)
cnOO1:=SPACE(20)
cnOO2:=SPACE(20)
cnOO3:=SPACE(20)
cnOO4:=SPACE(20)

cMatBr := PADR( "--", 13 )
cDopr1:="10"
cDopr2:="11"
cDopr3:="12"
cDopr5:="20"
cDopr6:="21"
cDopr7:="22"
cDDoprPio:=SPACE(100)
cDDoprZdr:=SPACE(100)
cPrimDobra:=SPACE(100)
cDoprOO:=""
cPorOO:=""
cFirmNaz:=SPACE(35)
cFirmAdresa:=SPACE(35)
cFirmOpc:=SPACE(35)  
cFirmVD:=SPACE(50)  
cIsplata := "A"

OSpecif()

if (FieldPos("DNE")<>0)
    go top
    do while !eof()
        AADD(aOps,{id,dne,0}) // sifra opstine, dopr.koje nema, neto
        skip 1
    enddo
    lPDNE:=.t.
else
    lPDNE:=.f.
endif

cFirmNaz := fetch_metric("org_naziv", nil, cFirmNaz)
cFirmNaz := PADR(cFirmNaz, 35)

cFirmAdresa := fetch_metric("ld_firma_adresa", nil, cFirmAdresa)
cFirmAdresa := PADR( cFirmAdresa, 35 )

cFirmOpc := fetch_metric("ld_firma_opcina", nil, cFirmOpc)
cFirmOpc := PADR(cFirmOpc, 35)

cFirmVD := fetch_metric("ld_firma_vrsta_djelatnosti", nil, cFirmVD )
cFirmVD := PADR(cFirmVD, 50)

cMRad := fetch_metric("ld_specifikacija_minuli_rad", nil, cMRad ) 
cPrimDobra := fetch_metric("ld_specifikacija_primanja_dobra", nil, cPrimDobra)
cDopr1 := fetch_metric("ld_specifikacija_doprinos_1", nil, cDopr1)
cDopr2 := fetch_metric("ld_specifikacija_doprinos_2", nil, cDopr2)
cDopr3 := fetch_metric("ld_specifikacija_doprinos_3", nil, cDopr3)
cDopr5 := fetch_metric("ld_specifikacija_doprinos_5", nil, cDopr5)
cDopr6 := fetch_metric("ld_specifikacija_doprinos_6", nil, cDopr6)
cDopr7 := fetch_metric("ld_specifikacija_doprinos_7", nil, cDopr7)
cDDoprPio := fetch_metric("ld_specifikacija_doprinos_pio", nil, cDDoprPio)
cDDoprZdr := fetch_metric("ld_specifikacija_doprinos_zdr", nil, cDDoprZdr)
cc001 := fetch_metric("ld_specifikacija_c1", nil, ccOO1)
cc002 := fetch_metric("ld_specifikacija_c2", nil, ccOO2)
cc003 := fetch_metric("ld_specifikacija_c3", nil, ccOO3)
cc004 := fetch_metric("ld_specifikacija_c4", nil, ccOO4)
cn001 := fetch_metric("ld_specifikacija_n1", nil, cnOO1)
cn002 := fetch_metric("ld_specifikacija_n2", nil, cnOO2)
cn003 := fetch_metric("ld_specifikacija_n3", nil, cnOO3)
cn004 := fetch_metric("ld_specifikacija_n4", nil, cnOO4)
qqIdRj := fetch_metric("ld_specifikacija_rj", nil, qqIdRJ)
qqOpSt := fetch_metric("ld_specifikacija_opcine", nil, qqOpSt)
qqIdRj:=PadR(qqIdRj, 80) 
qqOpSt:=PadR(qqOpSt, 80)

cIsplata := fetch_metric("ld_specifikacija_vrsta_isplate", nil, cIsplata)

cMatBr := fetch_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )
cMatBR := padr(cMatBr,13) 

dDatIspl := date()

do while .t.
    Box(,22+IF(gVarSpec=="1",0,1),75)
            
        @ m_x+ 1,m_y+ 2 SAY "Radna jedinica (prazno-sve): " ;
            GET qqIdRJ PICT "@!S15"
            @ m_x+ 1,col()+1 SAY "Djelatnost" GET cRTipRada ;
            VALID val_tiprada( cRTipRada ) PICT "@!"
        @ m_x+ 1,col()+1 SAY "Spec.za RS" GET cRepSr ;
            VALID cRepSr $ "DN" PICT "@!"

        @ m_x+ 2,m_y+ 2 SAY "Opstina stanov.(prazno-sve): " ;
            GET qqOpSt PICT "@!S20"
        
        if lViseObr
            @ m_x+ 2,col()+1 SAY "Obr.:" GET cObracun ;
                WHEN HelpObr(.t.,cObracun) ;
                VALID ValObr(.t.,cObracun)
        endif
        
        @ m_x+ 3,m_y+ 2 SAY "Period od:" GET nDanOd pict "99"
        @ m_x+ 3,col()+1 SAY "/" GET nMjesecOd pict "99"
        @ m_x+ 3,col()+1 SAY "/" GET nGodinaOd pict "9999"
        @ m_x+ 3,col()+1 SAY "do:" GET nDanDo pict "99"
        @ m_x+ 3,col()+1 SAY "/" GET nMjesecDo pict "99"
        @ m_x+ 3,col()+1 SAY "/" GET nGodinaDo pict "9999"
        
        @ m_x+ 4,m_y+ 2 SAY " Naziv: " GET cFirmNaz
        @ m_x+ 5,m_y+ 2 SAY "Adresa: " GET cFirmAdresa
        @ m_x+ 6,m_y+ 2 SAY "Opcina: " GET cFirmOpc
        @ m_x+ 7,m_y+ 2 SAY "Vrsta djelatnosti: " GET cFirmVD
            
        @ m_x+ 4,m_y+ 52 SAY "ID.broj :" GET cMatBR
        @ m_x+ 5,m_y+ 52 SAY "Dat.ispl:" GET dDatIspl
            
        
        @ m_x+9,m_y+ 2 SAY "Prim.u usl.ili dobrima (npr: 12;14;)" ;
            GET cPrimDobra  PICT "@!S20"
            
        @ m_x+10,m_y+ 2 SAY "Dopr.pio (iz)" GET cDopr1
        @ m_x+10,col()+ 2 SAY "Dopr.pio (na)" GET cDopr5
        @ m_x+11,m_y+ 2 SAY "Dopr.zdr (iz)" GET cDopr2
        @ m_x+11,col()+ 2 SAY "Dopr.zdr (na)" GET cDopr6
        @ m_x+12,m_y+ 2 SAY "Dopr.nez (iz)" GET cDopr3
        @ m_x+12,col()+ 2 SAY "Dopr.nez (na)" GET cDopr7
            
        @ m_x+13,m_y+ 2 SAY "Dod.dopr.pio" GET cDDoprPio PICT "@S35"
        @ m_x+14,m_y+ 2 SAY "Dod.dopr.zdr" GET cDDoprZdr PICT "@S35"
        
        @ m_x+15,m_y+ 2 SAY "Ost.obaveze: NAZIV                  USLOV"
        @ m_x+16,m_y+ 2 SAY " 1." GET ccOO1
        @ m_x+16,m_y+30 GET cnOO1
        @ m_x+17,m_y+ 2 SAY " 2." GET ccOO2
        @ m_x+17,m_y+30 GET cnOO2
        @ m_x+18,m_y+ 2 SAY " 3." GET ccOO3
        @ m_x+18,m_y+30 GET cnOO3
        @ m_x+19,m_y+ 2 SAY " 4." GET ccOO4
        @ m_x+19,m_y+30 GET cnOO4
            
        @ m_x+21, m_y+2 SAY "Isplata: 'A' doprinosi+porez, 'B' samo doprinosi, 'C' samo porez" GET cIsplata VALID cIsplata $ "ABC" PICT "@!"

        read
        clvbox()
        ESC_BCR
    BoxC()
    
    aUslRJ:=Parsiraj(qqIdRj,"IDRJ")
    aUslOpSt:=Parsiraj(qqOpSt,"IDOPSST")
    if (aUslRJ<>nil .and. aUslOpSt<>nil)
        EXIT
    endif
enddo

set_metric("org_naziv", nil, cFirmNaz)
set_metric("ld_firma_adresa", nil, cFirmAdresa)
set_metric("ld_firma_opcina", nil, cFirmOpc)
set_metric("ld_firma_vrsta_djelatnosti", nil, cFirmVD)
set_metric("ld_specifikacija_minuli_rad", nil, cMRad)
set_metric("ld_specifikacija_primanja_dobra", nil, cPrimDobra)
set_metric("ld_specifikacija_doprinos_1", nil, cDopr1)
set_metric("ld_specifikacija_doprinos_2", nil, cDopr2)
set_metric("ld_specifikacija_doprinos_3", nil, cDopr3)
set_metric("ld_specifikacija_doprinos_5", nil, cDopr5)
set_metric("ld_specifikacija_doprinos_6", nil, cDopr6)
set_metric("ld_specifikacija_doprinos_7", nil, cDopr7)
set_metric("ld_specifikacija_doprinos_pio", nil, cDDoprPio)
set_metric("ld_specifikacija_doprinos_zdr", nil, cDDoprZdr)
set_metric("ld_specifikacija_c1", nil, ccOO1)
set_metric("ld_specifikacija_c2", nil, ccOO2)
set_metric("ld_specifikacija_c3", nil, ccOO3)
set_metric("ld_specifikacija_c4", nil, ccOO4)
set_metric("ld_specifikacija_n1", nil, cnOO1)
set_metric("ld_specifikacija_n2", nil, cnOO2)
set_metric("ld_specifikacija_n3", nil, cnOO3)
set_metric("ld_specifikacija_n4", nil, cnOO4)
set_metric("ld_specifikacija_vrsta_isplate", nil, cIsplata)

qqIdRj:=TRIM(qqIdRj)
qqOpSt:=TRIM(qqOpSt)

set_metric("ld_specifikacija_rj", nil, qqIdRJ)
set_metric("ld_specifikacija_opcine", nil, qqOpSt)

set_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )

PoDoIzSez(nGodina,nMjesec)

// ovo ce biti ini u koji ces ubacivati podatke
cIniName := _proizv_ini

 //
 // Radi DRB6 iskoristio f-ju Razrijedi()
 //   npr.:    string  ->  s t r i n g
 //
UzmiIzIni(cIniName,'Varijable',"NAZ", cFirmNaz ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"ADRESA", cFirmAdresa ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"OPCINA", cFirmOpc ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"VRDJ", cFirmVD ,'WRITE')

UzmiIzIni(cIniName,'Varijable',"GODOD",Razrijedi(str(nGodinaOd,4)),'WRITE')
UzmiIzIni(cIniName,'Varijable',"GODDO",Razrijedi(str(nGodinaDo,4)),'WRITE')

UzmiIzIni(cIniName,'Varijable',"MJOD",Razrijedi(strtran(str(nMjesecOd,2)," ","0")),'WRITE')
UzmiIzIni(cIniName,'Varijable',"MJDO",Razrijedi(strtran(str(nMjesecDo,2)," ","0")),'WRITE')

UzmiIzIni(cIniName,'Varijable',"DANOD",Razrijedi(strtran(str(nDanOd,2)," ","0")),'WRITE')
UzmiIzIni(cIniName,'Varijable',"DANDO",Razrijedi(strtran(str(nDanDo,2)," ","0")),'WRITE')

UzmiIzIni(cIniName,'Varijable',"MATBR",Razrijedi(cMatBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"DATISPL",DTOC(dDatIspl),'WRITE')

cObracun:=TRIM(cObracun)

cDoprOO1:=Izrezi("D->",2,@cnOO1)
cDoprOO2:=Izrezi("D->",2,@cnOO2)
cDoprOO3:=Izrezi("D->",2,@cnOO3)
cDoprOO4:=Izrezi("D->",2,@cnOO4)

// dodatni doprinos pio
cDodDoprP := Izrezi("D->",2,@cDDoprPio)
// dodatni doprinos zdr
cDodDoprZ := Izrezi("D->",2,@cDDoprZdr)

ParObr(nMjesec,nGodina,cObracun,LEFT(qqIdRJ,2))

SELECT LD
SET ORDER TO TAG (TagVO("2"))

PRIVATE cFilt:=".t."

IF !EMPTY(qqIdRJ)
   cFilt += ( ".and." + aUslRJ )
ENDIF

IF !EMPTY(cObracun)
   cFilt += ( ".and. OBR==" + cm2str(cObracun) )
ENDIF

SET FILTER TO &cFilt

GO TOP
HSEEK STR(nGodina,4)+STR(nMjesec,2)

IF !FOUND()
	MsgBeep("Obracun za ovaj mjesec ne postoji !")
	close all
	return .t.
ENDIF
 
nUNeto:=0
nUNetoOsnova:=0
nPorNaPlatu:=0
nKoefLO := 0
nURadnika:=0
nULicOdbitak := 0
nDodDoprZ := 0
nDodDoprP := 0
 
DO WHILE STR( nGodina, 4 ) + STR( nMjesec, 2 ) == STR( godina, 4 ) + STR( mjesec, 2 )
   
    SELECT RADN
    HSEEK LD->idradn
    cRTR := g_tip_rada( ld->idradn, ld->idrj )
    nRSpr_koef := 0
    if cRTR == "S"
        nRSpr_koef := radn->sp_koef
    endif
    
    if cRTR $ "I#N" .and. EMPTY(cRTipRada)
        // ovo je uredu...
        // jer je i ovo nesamostalni rad
    elseif cRTipRada <> cRTR
        select ld
        skip
        loop
    endif

    // provjeri da li se radi o republici srpskoj
    if cRepSr == "N"
        if in_rs( radn->idopsst, radn->idopsrad )
            select ld
            skip
            loop
        endif
    else
        if !in_rs( radn->idopsst, radn->idopsrad )
            select ld
            skip
            loop
        endif
    endif

    SELECT LD
   
    IF ! ( RADN->(&aUslOpSt) )
        SKIP 1
        LOOP
    ENDIF
  
    //nKoefLO := (gOsnLOdb * radn->klo)
    nKoefLO := ld->ulicodb

    nULicOdbitak += nKoefLO

    nP77 := IF( !EMPTY(cMRad)  , LD->&("I"+cMRad)  , 0 )
    nP78 := IF( !EMPTY(cPorOl) , LD->&("I"+cPorOl) , 0 )

    //nP79 := IF( !EMPTY(cBolPr) , LD->&("I"+cBolPr) , 0 )
    nP79:=0
    IF !EMPTY(cBolPr) .or. !EMPTY(cBolPr)
        FOR t:=1 TO 99
            cPom := IF( t>9, STR(t,2), "0"+STR(t,1) )
            IF LD->( FIELDPOS( "I" + cPom ) ) <= 0
                EXIT
            ENDIF
            nP79 += IF( cPom $ cBolPr   , LD->&("I"+cPom) , 0 )
        NEXT
    ENDIF

    nP80 := nP81 := nP82 := nP83 := nP84 := nP85 := 0
   
    IF LD->uneto>0  // zbog npr.bol.preko 42 dana koje ne ide u neto
        IF LEN(aPom)<1 .or. ( nPom := ASCAN(aPom,{|x| x[1]==LD->brbod}) ) == 0
            AADD( aPom , { LD->brbod , 1 , nP77 , LD->uneto } )
        ELSE
            if ! ( lViseObr .and. EMPTY(cObracun) .and. LD->obr$"23456789" )
                aPom[nPom,2] += 1  // broj radnika
            endif
            aPom[nPom,3] += nP77  // minuli rad
            aPom[nPom,4] += LD->uneto // neto
        ENDIF
    ENDIF

    nPrDobra := 0
    IF !EMPTY(cPrimDobra) 
        FOR t:=1 TO 99
            cPom := IF( t>9, STR(t,2), "0"+STR(t,1) )
            IF LD->( FIELDPOS( "I" + cPom ) ) <= 0
                EXIT
            ENDIF
            nPrDobra += IF( cPom $ cPrimDobra, LD->&("I"+cPom), 0 )
        NEXT
    ENDIF

    nUNeto+=ld->uneto
    nNetoOsn:=MAX(ld->uneto,PAROBR->prosld*gPDLimit/100)
    nUNetoOsnova+=nNetoOsn
  
    // prvo doprinosi i bruto osnova ....
    nPojBrOsn := bruto_osn( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )
   
    // pojedinacni bruto - dobra ili usluge
    nPojBrDobra := 0
    if nPrDobra > 0
        nPojBrDobra := bruto_osn( nPrDobra, cRTR, nKoefLO, nRSpr_koef )
    endif

    nMPojBrOsn := nPojBrOsn

    if calc_mbruto()
        // minimalni bruto 
        nMPojBrOsn := min_bruto( nPojBrOsn, field->usati )
    endif

    nBrutoOsnova += nPojBrOsn
    nBrutoDobra += nPojBrDobra
    nMBrutoOsnova += nMPojBrOsn

    // reset matrice
    _a_benef := {}

    // beneficirani radnici
    if UBenefOsnovu()
    
        cFFTmp := gBFForm
        gBFForm := STRTRAN( gBFForm, "_", "" )
    
        nPojBrBenef := bruto_osn( nNetoOsn - IF(!EMPTY(gBFForm),&gBFForm,0), cRTR, nKoefLO, nRSpr_koef )
    
        nBrutoOsBenef += nPojBrBenef

        _benef_st := BenefStepen()
        add_to_a_benef( @_a_benef, ALLTRIM(radn->k3), _benef_st, nPojBrBenef )

        gBFForm := cFFtmp

    endif
 

    // ukupno na ruke sto ide radniku...
    //uNaRuke += ld->_uiznos

    // ukupno bruto
    nPom := nMBrutoOsnova

    nkDopZX := 0
    nkDopPX := 0

    UzmiIzIni(cIniName, 'Varijable', 'U017', FormNum2(nPom,16,gPici2), 'WRITE')

    SELECT DOPR
    GO TOP

    DO WHILE !EOF()
   
        IF DOPR->poopst == "1" .and. lPDNE
            nBOO:=0
            FOR i:=1 TO LEN(aOps)
                IF ! ( DOPR->id $ aOps[i,2] )
                    nBOO += aOps[i,3]
                ENDIF
            NEXT
            nBOO := bruto_osn( nBOO, cRTR, nKoefLO )
        ELSE
            nBOO := nMBrutoOsnova
        ENDIF

        // dodatni doprinos PIO
        IF ID $ cDodDoprP
            nkDopPX += iznos
            if !EMPTY( field->idkbenef )
                nDodDoprP += ROUND2( MAX( DLIMIT, get_benef_osnovica( _a_benef, field->idkbenef ) * iznos / 100 ), gZaok2 ) 
            else
                nDodDoprP += ROUND2( MAX( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
            endif
        ENDIF
   
        // dodatni doprinos ZDR
        IF ID $ cDodDoprZ
            nkDopZX += iznos
            if !EMPTY( field->idkbenef )
                // beneficirani 
                nDodDoprZ += ROUND2( MAX( DLIMIT, get_benef_osnovica( _a_benef, field->idkbenef ) * iznos / 100), gZaok2 )
            else
                nDodDoprZ += ROUND2( MAX( DLIMIT, nBOO * iznos / 100), gZaok2 )
            endif
        ENDIF
  
        SKIP 1

    ENDDO

    nkD1X := Ocitaj( F_DOPR , cDopr1 , "iznos" , .t. )
    nkD2X := Ocitaj( F_DOPR , cDopr2 , "iznos" , .t. )
    nkD3X := Ocitaj( F_DOPR , cDopr3 , "iznos" , .t. )
    nkD5X := Ocitaj( F_DOPR , cDopr5 , "iznos" , .t. )
    nkD6X := Ocitaj( F_DOPR , cDopr6 , "iznos" , .t. )
    nkD7X := Ocitaj( F_DOPR , cDopr7 , "iznos" , .t. )

    //stope na bruto
    nPom:=nKD1X+nKD2X+nKD3X
    UzmiIzIni(cIniName,'Varijable','D11B',FormNum2(nPom,16,gpici3)+"%" , 'WRITE')
    nPom:=nKD1X
    UzmiIzIni(cIniName,'Varijable','D11_1B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
    nPom:=nKD2X
    UzmiIzIni(cIniName,'Varijable','D11_2B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
    nPom:=nKD3X
    UzmiIzIni(cIniName,'Varijable','D11_3B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

    nPom:=nKD5X+nKD6X+nKD7X+nkDopZX+nkDopPX
    UzmiIzIni(cIniName,'Varijable','D12B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
    nPom:=nKD5X
    UzmiIzIni(cIniName,'Varijable','D12_1B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
    nPom:=nKD6X
    UzmiIzIni(cIniName,'Varijable','D12_2B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
    nPom:=nKD7X
    UzmiIzIni(cIniName,'Varijable','D12_3B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

    nPom:=nkDopPX
    UzmiIzIni(cIniName,'Varijable','D12_4B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

    nPom:=nkDopZX
    UzmiIzIni(cIniName,'Varijable','D12_5B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

    nDopr1X := round2(nMBrutoOsnova * nkD1X / 100, gZaok2)
    nDopr2X := round2(nMBrutoOsnova * nkD2X / 100, gZaok2)
    nDopr3X := round2(nMBrutoOsnova * nkD3X / 100, gZaok2)
    nDopr5X := round2(nMBrutoOsnova * nkD5X / 100, gZaok2)
    nDopr6X := round2(nMBrutoOsnova * nkD6X / 100, gZaok2)
    nDopr7X := round2(nMBrutoOsnova * nkD7X / 100, gZaok2)

    nPojDoprIZ := round2((nMPojBrOsn * nkD1X /100), gZaok2 ) + ;
        round2((nMPojBrOsn * nkD2X / 100), gZaok2) + ;
        round2((nMPojBrOsn* nkD3X / 100), gZaok2 )

    // iznos doprinosa
 
    nPom:=nDopr1X+nDopr2X+nDopr3X
 
    // ukupni doprinosi iz plate
    nUkDoprIZ := nPom  

    UzmiIzIni(cIniName,'Varijable','D11I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
    nPom:=nDopr1X
    UzmiIzIni(cIniName,'Varijable','D11_1I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
    nPom:=nDopr2X
    UzmiIzIni(cIniName,'Varijable','D11_2I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
    nPom:=nDopr3X
    UzmiIzIni(cIniName,'Varijable','D11_3I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

    nPom:=nDopr5X+nDopr6X+nDopr7X+nDodDoprP+nDodDoprZ
    UzmiIzIni(cIniName,'Varijable','D12I',FormNum2(_ispl_d(nPom,cIsplata),16,gPici2) , 'WRITE')
    nPom:=nDopr5X
    UzmiIzIni(cIniName,'Varijable','D12_1I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
    nPom:=nDopr6X
    UzmiIzIni(cIniName,'Varijable','D12_2I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
    nPom:=nDopr7X
    UzmiIzIni(cIniName,'Varijable','D12_3I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

    // dodatni doprinos zdr i pio
    nPom:=nDodDoprP
    UzmiIzIni(cIniName,'Varijable','D12_4I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
 
    nPom:=nDodDoprZ
    UzmiIzIni(cIniName,'Varijable','D12_5I', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

    nPojPorOsn := ( nPojBrOsn - nPojDoprIz ) - nKoefLO
 
    if nPojPorOsn >= 0 .and. radn_oporeziv( radn->id, ld->idrj )
        // osnovica za porez na platu
        //nPorOsnovica := ( nBrutoOsnova - nUKDoprIZ ) - nULicOdbitak
        nPorOsnovica += nPojPorOsn
    endif

    // osnovica mora biti veca od 0
    if nPorOsnovica < 0
        nPorOsnovica := 0
    endif

    // resetuj varijable
    nPorNaPlatu := 0
    nPorezOstali := 0

    //porez na platu i ostali porez
    SELECT POR
    GO TOP

    DO WHILE !EOF()

        PozicOps(POR->poopst)
     
        IF !ImaUOp("POR",POR->id)
            SKIP 1
            LOOP
        ENDIF
        IF por->por_tip == "B"
            nPorNaPlatu  += POR->iznos * MAX(nPorOsnovica,PAROBR->prosld*gPDLimit/100) / 100
        ENDIF
        SKIP 1
    ENDDO

    SELECT LD
   
    nURadnika++
    nPorOlaksice+=nP78
    nBolPreko+=nP79
    nObustave+=nP80
    nOstaleObaveze+=nP81
    nOstOb1+=nP82
    nOstOb2+=nP83
    nOstOb3+=nP84
    nOstOb4+=nP85
   
    IF lPDNE
        nOps := ASCAN( aOps , {|x| x[1]==RADN->idopsst} )
        IF nOps>0
            aOps[nOps,3] += MAX(ld->uneto,PAROBR->prosld*gPDLimit/100)
        ELSE
            AADD( aOps , { RADN->idopsst, "", MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) } )
        ENDIF
    ENDIF
   
    SKIP 1
 
ENDDO

nPorNaPlatu:=round2(nPorNaPlatu,gZaok2)
 
// obustave iz place
UzmiIzIni(cIniName,'Varijable','O18I', FormNum2(-nObustave,16,gPici2), 'WRITE')

// Ostale obaveze = OstaleObaveze.1

ASORT( aPom , , , {|x,y| x[1]>y[1]} )
FOR i:=1 TO LEN(aPom)
    IF gVarSpec=="1"
        IF i<=nGrupaPoslova
            aSpec[i,1]:=aPom[i,1]; aSpec[i,2]:=aPom[i,2]; aSpec[i,3]:=aPom[i,3]
            aSpec[i,4]:=aPom[i,4]
        ELSE
            aSpec[nGrupaPoslova,2]+=aPom[i,2]; aSpec[nGrupaPoslova,3]+=aPom[i,3]
            aSpec[nGrupaPoslova,4]+=aPom[i,4]
        ENDIF
    ELSE     // gVarSpec=="2"
        DO CASE
            CASE aPom[i,1] <= nLimG5
                aSpec[5,1]:=aPom[i,1]; aSpec[5,2]+=aPom[i,2]
                aSpec[5,3]+=aPom[i,3]; aSpec[5,4]+=aPom[i,4]
            CASE aPom[i,1] <= nLimG4
                aSpec[4,1]:=aPom[i,1]; aSpec[4,2]+=aPom[i,2]
                aSpec[4,3]+=aPom[i,3]; aSpec[4,4]+=aPom[i,4]
            CASE aPom[i,1] <= nLimG3
                aSpec[3,1]:=aPom[i,1]; aSpec[3,2]+=aPom[i,2]
                aSpec[3,3]+=aPom[i,3]; aSpec[3,4]+=aPom[i,4]
            CASE aPom[i,1] <= nLimG2
                aSpec[2,1]:=aPom[i,1]; aSpec[2,2]+=aPom[i,2]
                aSpec[2,3]+=aPom[i,3]; aSpec[2,4]+=aPom[i,4]
            CASE aPom[i,1] <= nLimG1
                aSpec[1,1]:=aPom[i,1]; aSpec[1,2]+=aPom[i,2]
                aSpec[1,3]+=aPom[i,3]; aSpec[1,4]+=aPom[i,4]
        ENDCASE
    ENDIF
    aSpec[nGrupaPoslova+1,2]+=aPom[i,2]; aSpec[nGrupaPoslova+1,3]+=aPom[i,3]
    aSpec[nGrupaPoslova+1,4]+=aPom[i,4]
NEXT

// ukupno radnika
UzmiIzIni(cIniName,'Varijable','U016', str(nURadnika,0) ,'WRITE')
// ukupno neto
UzmiIzIni(cIniName,'Varijable','U018',FormNum2(nUNETO,16,gPici2),'WRITE')
UzmiIzIni(cIniName,'Varijable','D13N', " ", 'WRITE')
 
SELECT POR
SEEK "01"
 
UzmiIzIni(cIniName,'Varijable','D13_1N',FormNum2(POR->IZNOS,16,gpici3)+"%",'WRITE')

nPom=nPorNaPlatu-nPorOlaksice
UzmiIzIni(cIniName,'Varijable','D13I',FormNum2(_ispl_p(nPom,cIsplata),16,gPici2),'WRITE')
nPom=nPorNaPlatu
UzmiIzIni(cIniName,'Varijable','D13_1I',FormNum2(_ispl_p(nPom,cIsplata),16,gPici2),'WRITE')
nPom:=nPorOlaksice
UzmiIzIni(cIniName,'Varijable','D13_2I',FormNum2(_ispl_p(nPom,cIsplata),16,gPici2),'WRITE')
nPom:=nBolPreko
UzmiIzIni(cIniName,'Varijable','N17I',FormNum2(nPom,16,gPici2),'WRITE')

nPorOlaksice   := ABS( nPorOlaksice   )
nBolPreko      := ABS( nBolPreko      )
nObustave      := ABS( nObustave      )
nOstOb1        := ABS( nOstOb1        )
nOstOb2        := ABS( nOstOb2        )
nOstOb3        := ABS( nOstOb3        )
nOstOb4        := ABS( nOstOb4        )
nOstaleObaveze := ABS( IF( nOstaleObaveze==0, nOstOb1+nOstOb2+nOstOb3+nOstOb4, nOstaleObaveze ) )

if cIsplata == "A"
    // sve obaveze
    nPom := nDopr1X+nDopr2x+nDopr3x+;
            nDopr5x+nDopr6x+nDopr7x+;
            nPorNaPlatu+nPorezOstali-;
            nPorOlaksice+nOstaleOBaveze+nDodDoprP+nDodDoprZ

elseif cIsplata == "B"
    // samo doprinosi
    nPom := nDopr1X+nDopr2x+nDopr3x+;
            nDopr5x+nDopr6x+nDopr7x+;
            nDodDoprP+nDodDoprZ

elseif cIsplata == "C"
    // samo porez
    nPom := nPorNaPlatu+nPorezOstali-nPorOlaksice+nOstaleOBaveze

endif

// ukupno obaveze
UzmiIzIni(cIniName,'Varijable','U15I', FormNum2(nPom,16,gPici2), 'WRITE')

nPom := nMBrutoOsnova - nBrutoDobra
nUUNR := nPom
UzmiIzIni(cIniName,'Varijable','UNR', FormNum2(nPom,16,gPici2), 'WRITE')
 
// ukupno ostalo
nPom := nBrutoDobra
nUUsluge := nPom
UzmiIzIni(cIniName,'Varijable','UNUS', FormNum2(nPom,16,gPici2), 'WRITE')

// ukupno ostalo
nPom := nUUNR + nUUsluge
UzmiIzIni(cIniName,'Varijable','UNUK', FormNum2(nPom,16,gPici2), 'WRITE')

// ukupno placa_i_obaveze = obaveze + ukupno_neto + poreskeolaksice
nPom := nPom + nUNETO + nPorOlaksice
UzmiIzIni(cIniName,'Varijable','U16I', FormNum2(nPom,16,gPici2), 'WRITE')

// obustave
nPom := nObustave
UzmiIzIni(cIniName,'Varijable','O18I', FormNum2(nPom,16,gPici2), 'WRITE')

// neto za isplatu  = neto  + nPorOlaksice
// -----------------------------------------
// varijanta D - specificno za FEB jer treba da izbazi bol.preko.42
// dana iz neta za isplatu na specifikaciji, vec je uracunat u netu.

if IzFmkIni('LD','BolPreko42IzbaciIz19','N',KUMPATH)=='D'
    nPom := nUNETO + nPorOlaksice - nObustave
else
    nPom := nUNETO + nBolPreko + nPorOlaksice - nObustave
endif
 
UzmiIzIni(cIniName,'Varijable','N19I', FormNum2(nPom,16,gPici2), 'WRITE')

// PIO iz + PIO na placu
nPom:=nDopr1x+nDopr5x+nDodDoprP
UzmiIzIni(cIniName,'Varijable','D20', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

// zdravsveno iz + zdravstveno na placu
nPom:=nDopr2x+nDopr6x+nDodDoprZ
nPom2 := nPom
UzmiIzIni(cIniName,'Varijable','D21', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
 
// zdravstvo za RS
nPom := nPom2 * 0.09
nD21a := nPom
UzmiIzIni(cIniName,'Varijable','D21a', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

// nezaposlenost iz + nezaposlenost na placu
nPom:=nDopr3x+nDopr7x
nPom2 := nPom
UzmiIzIni(cIniName,'Varijable','D22', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')
 
// nezaposlenost za RS
nPom := nPom2 * 0.30
nD22a := nPom
UzmiIzIni(cIniName,'Varijable','D22a', FormNum2(_ispl_d(nPom,cIsplata),16,gPici2), 'WRITE')

nPom=nPorNaPlatu-nPorOlaksice
UzmiIzIni(cIniName,'Varijable','P23', FormNum2(_ispl_p(nPom,cIsplata),16,gPici2), 'WRITE')

nPom=nPorezOstali
UzmiIzIni(cIniName,'Varijable','O14_1I', FormNum2(_ispl_p(nPom,cIsplata),16,gPici2), 'WRITE')

nPom=nOstaleObaveze + nPorezOstali
UzmiIzIni(cIniName,'Varijable','O14I', FormNum2(_ispl_p(nPom,cIsplata),16,gPici2), 'WRITE')

// ukupno za RS obaveze
if cIsplata == "A"
    nPom := nDopr1x+nDopr5x+nD21a+nD22a+nPorNaPlatu
elseif cIsplata == "B"
    nPom := nDopr1x+nDopr5x+nD21a+nD22a
elseif cIsplata == "C"
    nPom := nPorNaPlatu
endif
 
UzmiIzIni(cIniName,'Varijable','URSOB', FormNum2(nPom,16,gPici2), 'WRITE')
 
IniRefresh()

close all

if LastKey() != K_ESC

    cSpecRtm := "spec"
 
    if cRepSr == "D"
        cSpecRtm := cSpecRtm + "rs"
    else
        cSpecRtm := cSpecRtm + "b"
    endif

    if cRTipRada $ "I#N"
        cRTipRada := ""
    endif

    // "SPECBN", "SPECBR" ...
    cSpecRtm := cSpecRtm + cRTipRada

    // stampaj specifikaciju
    f18_rtm_print( ALLTRIM( cSpecRtm ), "DUMMY", "1" )

endif

return .t.


// ---------------------------------------------
// isplata doprinosa, kontrola iznosa
// ---------------------------------------------
function _ispl_d( nIzn, cIspl )

if cIspl $ "AB"
    return nIzn
else
    return 0
endif

return

// ---------------------------------------------
// isplata poreza, kontrola iznosa
// ---------------------------------------------
function _ispl_p( nIzn, cIspl )

if cIspl $ "AC"
    return nIzn
else
    return 0
endif

return
