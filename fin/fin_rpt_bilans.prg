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


#include "fin.ch"

static __par_len
static __BB_LEN := 60


// --------------------------------------
// bilansni izvjestaji
// --------------------------------------
function Bilans()

IF gVar1 == "0"
    private opc[5],Izbor
ELSE
    private opc[4],Izbor
ENDIF

cTip:=ValDomaca()

M6:= "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
M7:= "*        *          POｬETNO STANJE       *         TEKU終 PROMET         *        KUMULATIVNI PROMET     *            SALDO             *"
M8:= "  KLASA   ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M9:= "*        *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *    POTRAｦUJE *"
M10:="--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

opc[1]:="1. po grupama       "
opc[2]:="2. sintetika"
opc[3]:="3. analitika"
opc[4]:="4. subanalitika"
IF gVar1=="0"; opc[5]:="5. obracun: "+cTip; h[5]:=""; ENDIF
h[1]:=h[2]:=h[3]:=h[4]:=""


Izbor:=1
private PicD:=FormPicL(gPicBHD,15)
DO WHILE .T.
   Izbor:=Menu("bb",opc,Izbor,.f.)
   DO CASE
      CASE Izbor==0
         EXIT

      CASE izbor=1
         cBBV:=cTip; nBBK:=1
         GrupBB()

      CASE izbor=2
         cBBV:=cTip; nBBK:=1
         SintBB()

      CASE izbor=3
         cBBV:=cTip; nBBK:=1
         AnalBB()

      CASE izbor=4
         cBBV:=cTip; nBBK:=1
         SubAnBB()

      CASE izbor=5
         if cTip==ValDomaca()
           PicD:=FormPicL(gPicDEM,15)
           cTip:=ValPomocna()
         else
           PicD:=FormPicL(gPicBHD,15)
           cTip:=ValDomaca()
         endif
         opc[5]:="5. obracun: "+cTip

      CASE izbor=5
         Izbor:=0
   ENDCASE
ENDDO


return



// ----------------------------------
// filuje tabelu za export
// ----------------------------------
static function fill_ssbb_tbl(cKonto, cIdPart, cNaziv, ;
            nFDug, nFPot, nFSaldo )
local nArr
nArr:=SELECT()

O_R_EXP
append blank
replace field->konto with cKonto
replace field->idpart with cIdPart
replace field->naziv with cNaziv
replace field->duguje with nFDug
replace field->potrazuje with nFPot
replace field->saldo with nFSaldo

select (nArr)

return


// ------------------------------------------------
// filovanje tabele sbb
// ------------------------------------------------
static function fill_sbb_tbl(cKonto, cIdPart, cNaziv, ;
            nPsDug, nPsPot, nKumDug, nKumPot, ;
            nSldDug, nSldPot )
local nArr
nArr:=SELECT()

O_R_EXP
append blank
replace field->konto with cKonto
replace field->idpart with cIdPart
replace field->naziv with cNaziv
replace field->psdug with nPsDug
replace field->pspot with nPsPot
replace field->kumdug with nKumDug
replace field->kumpot with nKumPot
replace field->slddug with nSldDug
replace field->sldpot with nSldPot

select (nArr)

return



// ------------------------------------------
// vraca matricu sa sub.bb poljima
// ------------------------------------------
static function get_sbb_fields(lBBSkraceni, nPartLen )
if nPartLen == nil
    nPartLen := 6
endif

aFields := {}
AADD(aFields, {"konto", "C", 7, 0})
AADD(aFields, {"idpart", "C", nPartLen, 0})
AADD(aFields, {"naziv", "C", 40, 0})

if lBBSkraceni
  AADD(aFields, {"duguje", "N", 15, 2})
  AADD(aFields, {"potrazuje", "N", 15, 2})
  AADD(aFields, {"saldo", "N", 15, 2})
else
  AADD(aFields, {"psdug", "N", 15, 2})
  AADD(aFields, {"pspot", "N", 15, 2})
  AADD(aFields, {"kumdug", "N", 15, 2})
  AADD(aFields, {"kumpot", "N", 15, 2})
  AADD(aFields, {"slddug", "N", 15, 2})
  AADD(aFields, {"sldpot", "N", 15, 2})
endif


return aFields


// -----------------------------------------------
// Subanaliticki bruto bilans
// -----------------------------------------------
function SubAnBB()
local _params 

cIdFirma := gFirma

O_KONTO
O_PARTN

__par_len := LEN( partn->id )

// uslovi izvjestaja bruto bilans...
if !fin_bruto_bilans_get_vars( @_params )
    return 
endif

// open office stampa...
if _params["varijanta"] == 2
    fin_bruto_bilans_sql( _params )
    return
endif

qqKonto := _params["konto"]
dDatOd := _params["datum_od"]
dDatDo := _params["datum_do"]
cFormat := _params["format"]
cPodKlas := _params["klase"]
cNule := _params["saldo_nula"]
cExpRptDN := _params["export_dbf"]
cBBSkrDN := _params["export_sk"]
cPrikaz := _params["prikaz"]
cIdRJ := ""

if gRj == "D"
    cIdRj := _params["id_rj"]
endif

aUsl1 := Parsiraj(qqKonto,"IdKonto")
cIdFirma := trim(cIdFirma)

if cIdRj == "999999"
    cIdRj := ""
endif

if gRJ == "D" .and. "." $ cIdRj
    cIdRj:=trim(strtran(cIdRj,".",""))
    // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

IF cFormat $ "1#3"
    private REP1_LEN := 236
    th1:= "---- ------- -------- --------------------------------------------------- -------------- ----------------- --------------------------------- ------------------------------- ------------------------------- -------------------------------"
    th2:= "*R. * KONTO *PARTNER *     NAZIV KONTA ILI PARTNERA                      *    MJESTO    *      ADRESA     *        POｬETNO STANJE           *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
    th3:= "                                                                                                           --------------------------------- ------------------------------- ------------------------------- -------------------------------"
    th4:= "*BR.*       *        *                                                   *              *                 *    DUGUJE       *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE  *"
    th5:= "---- ------- -------- --------------------------------------------------- -------------- ----------------- ----------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ELSE
    private REP1_LEN := 158
    th1:= "---- ------- -------- -------------------------------------- --------------------------------- ------------------------------- -------------------------------"
    th2:= "*R. * KONTO *PARTNER *    NAZIV KONTA ILI PARTNERA          *        POｬETNO STANJE           *       KUMULATIVNI PROMET      *            SALDO             *"
    th3:= "                                                             --------------------------------- ------------------------------- -------------------------------"
    th4:= "*BR.*       *        *                                      *    DUGUJE       *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *   POTRAｦUJE  *"
    th5:= "---- ------- -------- -------------------------------------- ----------------- --------------- --------------- --------------- --------------- ---------------"
ENDIF

private lExpRpt := ( cExpRptDN == "D" )
private lBBSkraceni := ( cBBSkrDN == "D" )

if lExpRpt
    aExpFields := get_sbb_fields(lBBSkraceni, __par_len )
    t_exp_create(aExpFields)
    cLaunch := exp_report()
endif

// duzina stranice...
__BB_LEN := RPT_PAGE_LEN

if cFormat == "3"
    // u formatu landscape, ovo je duzina
    __BB_LEN := 44
endif

O_KONTO
O_PARTN
O_SUBAN
O_KONTO
O_BBKLAS

select BBKLAS
ZAPP()

private cFilter:=""

select SUBAN

if gRj=="D" .and. len(cIdrj)<>0
    cFilter+=iif(empty(cFilter),"",".and.") + "idrj="+cm2str(cidrj)
endif

if aUsl1<>".t."
    cFilter+=iif(empty(cFilter),"",".and.")+ aUsl1
endif
if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter+=iif(empty(cFilter),"",".and.")+"DATDOK>=CTOD('"+dtoc(dDatOd)+"') .and. DATDOK<=CTOD('"+dtoc(dDatDo)+"')"
endif

if !empty(cFilter) .and. LEN(cIdFirma)==2
    set filter to &cFilter
endif

if LEN(cIdFirma)<2
    SELECT SUBAN
    Box(,2,30)
        nSlog := 0
        nUkupno:=RECCOUNT2()
        cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
        cSort1 := "IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
        INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt EVAL( fin_tek_rec_2() ) EVERY 1
        GO TOP
    BoxC()
else
    HSEEK cIdFirma
endif

EOF CRET

nStr := 0

BBMnoziSaK()

START PRINT CRET

B := B1 := B2 := 0  
// brojaci

select SUBAN

D1S:=D2S:=D3S:=D4S:=0
P1S:=P2S:=P3S:=P4S:=0

D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=0
nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma  
    // idfirma

    if prow() == 0
        ZaglSan( cFormat )
    endif

    // PS - pocetno stanje
    // TP - tekuci promet
    // KP - kumulativni promet
    // S - saldo
   
    D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
    cKlKonto := LEFT( IdKonto, 1 )
   
    DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)   
      
        // klasa konto

        cSinKonto:=left(IdKonto,3)
        D2PS:=P2PS:=D2TP:=P2TP:=D2KP:=P2KP:=D2S:=P2S:=0
      
        DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cSinKonto==left(IdKonto,3)   
            // sint. konto

            cIdKonto:=IdKonto
            D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
            
            DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto 
        
                // konto

                cIdPartner:=IdPartner
                D0PS:=P0PS:=D0TP:=P0TP:=D0KP:=P0KP:=D0S:=P0S:=0
            
                DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner 
          
                    // partner
              
                    if cTip == ValDomaca()
                        IF D_P = "1"
                            D0KP += IznosBHD*nBBK
                        ELSE
                            P0KP += IznosBHD*nBBK
                        ENDIF
                    else
                        IF D_P = "1"
                            D0KP += IznosDEM
                        ELSE
                            P0KP += IznosDEM
                        ENDIF
                    endif

                    if cTip == ValDomaca()
                        IF IdVN = "00"
                            IF D_P == "1"; D0PS+=IznosBHD*nBBK; ELSE; P0PS+=IznosBHD*nBBK; ENDIF
                        ELSE
                            IF D_P == "1"; D0TP+=IznosBHD*nBBK; ELSE; P0TP+=IznosBHD*nBBK; ENDIF
                        ENDIF
                    else
               
                        IF IdVN = "00"
                            IF D_P=="1"; D0PS+=IznosDEM; ELSE; P0PS+=IznosDEM; ENDIF
                        ELSE
                            IF D_P=="1"; D0TP+=IznosDEM; ELSE; P0TP+=IznosDEM; ENDIF
                        ENDIF
                    endif

                    SKIP
                ENDDO // partner

                __bb_nova_stranica( cFormat )
                
                IF (cNule == "N" .and. ROUND(D0KP-P0KP, 2) == 0)
                    // ne prikazuj
                else
              
                    //if cPrikaz $ "12" 
           
                    @ prow()+1,0 SAY  ++B  PICTURE '9999'    // ; ?? "."
                    @ prow(),pcol()+1 SAY cIdKonto
                    @ prow(),pcol()+1 SAY cIdPartner       // IdPartner(cIdPartner)
                    SELECT PARTN
                    HSEEK cIdPartner
              
                    IF cFormat == "2"
                        @ prow(),pcol()+1 SAY PADR(naz,48-LEN (cidpartner))   // difidp
                    ELSE
                        @ prow(),pcol()+1 SAY PADR(naz,32)
                        @ prow(),pcol()+1 SAY PADR(naz2,20)
                        @ prow(),pcol()+1 SAY Mjesto
                        @ prow(),pcol()+1 SAY Adresa PICTURE 'XXXXXXXXXXXXXXXXX'
                    ENDIF

                    select SUBAN
                    nCol1:=pcol()+1
                    @ prow(),pcol()+1 SAY D0PS PICTURE PicD
                    @ prow(),PCOL()+1 SAY P0PS PICTURE PicD

                    IF cFormat $ "13"
                        @ prow(),PCOL()+1 SAY D0TP PICTURE PicD
                        @ prow(),PCOL()+1 SAY P0TP PICTURE PicD
                    ENDIF

                    @ prow(),PCOL()+1 SAY D0KP PICTURE PicD
                    @ prow(),PCOL()+1 SAY P0KP PICTURE PicD

                    D0S:=D0KP-P0KP

                    IF D0S>=0
                        P0S:=0
                    else
                        P0S:=-D0S
                        D0S:=0
                    endif

                    @ prow(),PCOL()+1 SAY D0S PICTURE PicD
                    @ prow(),PCOL()+1 SAY P0S PICTURE PicD
         
                    //endif
         
                    D1PS+=D0PS;P1PS+=P0PS;D1TP+=D0TP;P1TP+=P0TP;D1KP+=D0KP;P1KP+=P0KP
             
                    if lExpRpt .and. !EMPTY(cIdPartner) .and. cPrikaz $ "12"
                        if lBBSkraceni
                            fill_ssbb_tbl(cIdKonto, cIdPartner, partn->naz, D0KP, P0KP, D0KP - P0KP)
                        else
                            fill_sbb_tbl(cIdKonto, cIdPartner, partn->naz, D0PS, P0PS, D0KP, P0KP, D0S, P0S)
                        endif
                    endif
                endif
         
            ENDDO // konto

            __bb_nova_stranica( cFormat, 3 )
            
            @ prow()+1,2 SAY replicate("-",REP1_LEN-2)
            @ prow()+1,2 SAY ++B1 PICTURE '9999'      // ; ?? "."
            @ prow(),pcol()+1 SAY cIdKonto

            select KONTO
            HSEEK cIdKonto

            IF cFormat == "1"
                @ prow(), pcol()+1 SAY naz
            ELSE
                @ prow(), pcol()+1 SAY LEFT (naz,47)  // 40
            ENDIF

            select SUBAN

            @ prow(),nCol1     SAY D1PS PICTURE PicD
            @ prow(),PCOL()+1  SAY P1PS PICTURE PicD

            IF cFormat $ "13"
                @ prow(),PCOL()+1  SAY D1TP PICTURE PicD
                @ prow(),PCOL()+1  SAY P1TP PICTURE PicD
            ENDIF

            @ prow(),PCOL()+1  SAY D1KP PICTURE PicD
            @ prow(),PCOL()+1  SAY P1KP PICTURE PicD
     
            D1S:=D1KP-P1KP
         
            if D1S>=0
                P1S:=0
                D2S+=D1S;D3S+=D1S;D4S+=D1S
            else
                P1S:=-D1S; D1S:=0
                P2S+=P1S;P3S+=P1S;P4S+=P1S
            endif
         
            @ prow(),PCOL()+1 SAY D1S PICTURE PicD
            @ prow(),PCOL()+1 SAY P1S PICTURE PicD
            @ prow()+1,2 SAY replicate("-",REP1_LEN-2)
     
            SELECT SUBAN
            D2PS+=D1PS;P2PS+=P1PS;D2TP+=D1TP;P2TP+=P1TP;D2KP+=D1KP;P2KP+=P1KP

            if lExpRpt .and. (( cPrikaz == "1" .and. EMPTY(cIdPartner)) .or. cPrikaz $ "23" )
                if lBBSkraceni
                    fill_ssbb_tbl(cIdKonto, "", konto->naz, D1KP, P1KP, D1KP - P1KP)
                else
                    fill_sbb_tbl(cIdKonto, "", konto->naz, D1PS, P1PS, D1KP, P1KP, D1S, P1S)
                endif
            endif
      
        ENDDO  // sin konto

        __bb_nova_stranica( cFormat, 3 )

        @ prow()+1,4 SAY replicate("=",REP1_LEN-4)

        @ prow()+1,4 SAY ++B2 PICTURE '9999';?? "."
        @ prow(),pcol()+1 SAY cSinKonto

        select KONTO; hseek cSinKonto

        IF cFormat $ "13"
            @ prow(),pcol()+1 SAY left(naz,50)
        ELSE
            @ prow(),pcol()+1 SAY left(naz,44)       // 45
        ENDIF

        select SUBAN

        @ prow(),nCol1    SAY D2PS PICTURE PicD
        @ prow(),PCOL()+1 SAY P2PS PICTURE PicD

        IF cFormat $ "13"
            @ prow(),PCOL()+1 SAY D2TP PICTURE PicD
            @ prow(),PCOL()+1 SAY P2TP PICTURE PicD
        ENDIF

        @ prow(),PCOL()+1 SAY D2KP PICTURE PicD
        @ prow(),PCOL()+1 SAY P2KP PICTURE PicD
        @ prow(),PCOL()+1 SAY D2S PICTURE PicD
        @ prow(),PCOL()+1 SAY P2S PICTURE PicD

        @ prow()+1,4 SAY replicate("=",REP1_LEN-4)

        SELECT SUBAN

        D3PS+=D2PS;P3PS+=P2PS;D3TP+=D2TP;P3TP+=P2TP;D3KP+=D2KP;P3KP+=P2KP

        if lExpRpt
            if lBBSkraceni
                fill_ssbb_tbl(cSinKonto, "", konto->naz, D2KP, P2KP, D2KP - P2KP)
            else
                fill_sbb_tbl(cSinKonto, "", konto->naz, D2PS, P2PS, D2KP, P2KP, D2S, P2S)
            endif
        endif
    
    ENDDO  // klasa konto

    SELECT BBKLAS
    APPEND BLANK
    REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S
    SELECT SUBAN
   
    IF cPodKlas=="D"

        ? th5
        ? "UKUPNO KLASA "+cklkonto
        @ prow(),nCol1    SAY D3PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P3PS PICTURE PicD

        if cFormat $ "13"
            @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
            @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
        endif

        @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY D3S PICTURE PicD
        @ PROW(),pcol()+1 SAY P3S PICTURE PicD
        ? th5

    ENDIF
   
    D4PS+=D3PS;P4PS+=P3PS;D4TP+=D3TP;P4TP+=P3TP;D4KP+=D3KP;P4KP+=P3KP

    if lExpRpt
        if lBBSkraceni
            fill_ssbb_tbl(cKlKonto, "", konto->naz, D3KP, P3KP, D3KP - P3KP)
        else
            fill_sbb_tbl(cKlKonto, "", konto->naz, D3PS, P3PS, D3KP, P3KP, D3S, P3S)
        endif
    endif
    
ENDDO

__bb_nova_stranica( cFormat, 3 )

? th5
@ prow()+1,6 SAY "UKUPNO:"
@ prow(),nCol1 SAY D4PS PICTURE PicD
@ prow(),PCOL()+1 SAY P4PS PICTURE PicD

IF cFormat $ "13"
    @ prow(),PCOL()+1 SAY D4TP PICTURE PicD
    @ prow(),PCOL()+1 SAY P4TP PICTURE PicD
ENDIF

@ prow(),PCOL()+1 SAY D4KP PICTURE PicD
@ prow(),PCOL()+1 SAY P4KP PICTURE PicD
@ prow(),PCOL()+1 SAY D4S PICTURE PicD
@ prow(),PCOL()+1 SAY P4S PICTURE PicD
? th5

if lExpRpt
    if lBBSkraceni
        fill_ssbb_tbl("UKUPNO", "", "", D4KP, P4KP, D4KP - P4KP)
    else
        fill_sbb_tbl("UKUPNO", "", "", D4PS, P4PS, D4KP, P4KP, D4S, P4S)
    endif
endif

if ( prow() + 16 ) > ( __BB_LEN + gpStranica )
    FF
    ?
else
    ?
    ?
endif

?? "REKAPITULACIJA PO KLASAMA NA DAN:"
@ PROW(), PCOL() + 2 SAY DATE()
? M6
? M7
? M8
? M9
? M10

SELECT BBKLAS
GO TOP
nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()

    @ prow()+1,4      SAY IdKlasa
    @ prow(),10       SAY PocDug               PICTURE PicD
    @ prow(),PCOL()+1 SAY PocPot               PICTURE PicD
    @ prow(),PCOL()+1 SAY TekPDug              PICTURE PicD
    @ prow(),PCOL()+1 SAY TekPPot              PICTURE PicD
    @ prow(),PCOL()+1 SAY KumPDug              PICTURE PicD
    @ prow(),PCOL()+1 SAY KumPPot              PICTURE PicD
    @ prow(),PCOL()+1 SAY SalPDug              PICTURE PicD
    @ prow(),PCOL()+1 SAY SalPPot              PICTURE PicD

    nPocDug   += PocDug
    nPocPot   += PocPot
    nTekPDug  += TekPDug
    nTekPPot  += TekPPot
    nKumPDug  += KumPDug
    nKumPPot  += KumPPot
    nSalPDug  += SalPDug
    nSalPPot  += SalPPot

    SKIP

ENDDO

? M10
? "UKUPNO:"
@ prow(),10 SAY  nPocDug    PICTURE PicD
@ prow(),PCOL()+1 SAY  nPocPot    PICTURE PicD
@ prow(),PCOL()+1 SAY  nTekPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nTekPPot   PICTURE PicD
@ prow(),PCOL()+1 SAY  nKumPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nKumPPot   PICTURE PicD
@ prow(),PCOL()+1 SAY  nSalPDug   PICTURE PicD
@ prow(),PCOL()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF

END PRINT

if lExpRpt
    tbl_export(cLaunch)
endif

RETURN


// -------------------------------------------------
// nova stranica za bruto bilans...
// -------------------------------------------------
static function __bb_nova_stranica( format, dodaj )

if dodaj == NIL
    dodaj := 0
endif        

IF ( prow() + dodaj ) > ( __BB_LEN + gpStranica )
    FF 
    ZaglSan( format )
ENDIF

return




/*! \fn ZaglSan()
 *  \brief Zaglavlje strane subanalitickog bruto bilansa
 */
 
function ZaglSan(cFormat)

if cFormat == nil
    cFormat := "2"
endif

?

if cFormat $ "1#3" 
    ? "#%LANDS#"
endif

P_COND2

?? "FIN: SUBANALITIｬKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(), REP1_LEN-15 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 ? "Firma:"
 @ prow(),pcol()+2 SAY cIdFirma
 select PARTN
 HSEEK cIdFirma
 @ prow(),pcol()+2 SAY Naz; @ prow(),pcol()+2 SAY Naz2
endif

IF gRJ=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

? th1
? th2
? th3
? th4
? th5

SELECT SUBAN
RETURN



/*! \fn AnalBB()
 *  \brief Analiticki bruto bilans
 */
 
function AnalBB()
private A1,D4PS,P4PS,D4TP,P4TP,D4KP,P4KP,D4S,P4S

cIdFirma := gFirma

O_KONTO
O_PARTN

qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N"

Box("",8,60)
    set cursor on
    do while .t.
        @ m_x+1,m_y+2 SAY "ANALITICKI BRUTO BILANS"
        if gNW=="D"
            @ m_x+2,m_y+2 SAY "Firma "
            ?? gFirma,"-",gNFirma
        else
            @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| EMPTY(cIdFirma).or.P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
        endif
        @ m_x+3,m_y+2 SAY "Konto " GET qqKonto PICT "@!S50"
        @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
        @ m_x+4,col()+2 SAY "do" GET dDatDo
        @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4/A4L (1/2/3)" GET cFormat
        @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
        cIdRJ:=""
        IF gRJ=="D" .and. gSAKrIz=="D"
            cIdRJ:="999999"
            @ m_x+8,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
        ENDIF
        READ
        ESC_BCR
        aUsl1:=Parsiraj(qqKonto,"IdKonto")
        if aUsl1<>NIL; exit; endif
    enddo
BoxC()

cidfirma:=trim(cidfirma)

if cIdRj == "999999"
    cIdrj := ""
endif

if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
    cIdrj:=trim(strtran(cidrj,".",""))
    // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

IF cFormat $ "13"
    M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
    M2:= "*REDNI*   KONTO   *                NAZIV ANALITICKOG KONTA                  *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
    M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
    M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
    M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ELSE
    M1:= "------ ----------- ---------------------------------------- ------------------------------- ------------------------------- -------------------------------"
    M2:= "*REDNI*   KONTO   *         NAZIV ANALITICKOG KONTA        *        POｬETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
    M3:= "                                                            ------------------------------- ------------------------------- -------------------------------"
    M4:= "*BROJ *           *                                        *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
    M5:= "------ ----------- ---------------------------------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ENDIF

O_BBKLAS

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
    SintFilt(.f.,"IDRJ='"+cIdRJ+"'")
ELSE
    O_ANAL
ENDIF

select BBKLAS
zap

select ANAL

cFilter := ""

if !(empty(qqkonto))
    if !(empty(dDatOd) .and. empty(dDatDo))
        cFilter += ( iif(empty(cFilter),"",".and.") +;
        aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
    else
        cFilter += ( iif(empty(cFilter),"",".and.") + aUsl1 )
    endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
    cFilter += ( iif(empty(cFilter),"",".and.") +;
        "DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
endif

if LEN(cIdFirma)<2
    SELECT ANAL
    Box(,2,30)
        nSlog:=0
        nUkupno:=RECCOUNT2()
        cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
        cSort1:="IdKonto+dtos(DatNal)"
        INDEX ON &cSort1 TO "ANATMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
        GO TOP
    BoxC()
else
    SET FILTER TO &cFilter
    HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

__BB_LEN := RPT_PAGE_LEN

if cFormat == "3"
    __BB_LEN := 43
endif

START PRINT CRET

B:=0

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0

D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

    IF prow()==0
        BrBil_21( cFormat )
    ENDIF

    cKlKonto:=left(IdKonto,1)
    D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
    DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1) // kl konto

        cSinKonto:=LEFT(idkonto,3)
        D2PS:=P2PS:=D2TP:=P2TP:=D2KP:=P2KP:=D2S:=P2S:=0
        DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cSinKonto==LEFT(idkonto,3) // sin konto

            cIdKonto:=IdKonto

            D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
            DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto // konto
                if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
                D1KP=D1KP+Dug
                P1KP=P1KP+Pot
                IF IdVN="00"
                    D1PS+=Dug; P1PS+=Pot
                ELSE
                    D1TP+=Dug; P1TP+=Pot
                ENDIF
                SKIP
            ENDDO   // konto

            @ prow()+1,1 SAY ++B PICTURE '9999';?? "."
            @ prow(),10 SAY cIdKonto

            SELECT KONTO
            HSEEK cIdKonto

            IF cFormat $ "13"
                @ prow(),19 SAY PADR( naz, 57 )
            ELSE
                @ prow(),19 SAY PADR( naz, 40 )
            ENDIF

            select ANAL

            nCol1:=pcol()+1
            @ prow(),pcol()+1 SAY D1PS PICTURE PicD
            @ PROW(),pcol()+1 SAY P1PS PICTURE PicD
            IF cFormat $ "13"
                @ PROW(),pcol()+1 SAY D1TP PICTURE PicD
                @ PROW(),pcol()+1 SAY P1TP PICTURE PicD
            ENDIF
            @ PROW(),pcol()+1 SAY D1KP PICTURE PicD
            @ PROW(),pcol()+1 SAY P1KP PICTURE PicD

            D1S=D1KP-P1KP
            IF D1S>=0
                P1S:=0
                D2S+=D1S; D3S+=D1S; D4S+=D1S
            ELSE
                P1S:=-D1S; D1S:=0
                P1S:=P1KP-D1KP
                P2S+=P1S
                P3S+=P1S; P4S+=P1S
            ENDIF
            @ prow(),pcol()+1 SAY D1S PICTURE PicD
            @ prow(),pcol()+1 SAY P1S PICTURE PicD

            D2PS=D2PS+D1PS
            P2PS=P2PS+P1PS
            D2TP=D2TP+D1TP
            P2TP=P2TP+P1TP
            D2KP=D2KP+D1KP
            P2KP=P2KP+P1KP
   
            __anal_bb_nova_strana( cFormat )     

        ENDDO  // sinteticki konto

        __anal_bb_nova_strana( cFormat )      

        ? M5
        @ prow()+1,10 SAY cSinKonto
        @ prow(),nCol1    SAY D2PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P2PS PICTURE PicD
        IF cFormat $ "13"
            @ PROW(),pcol()+1 SAY D2TP PICTURE PicD
            @ PROW(),pcol()+1 SAY P2TP PICTURE PicD
        ENDIF
        @ PROW(),pcol()+1 SAY D2KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P2KP PICTURE PicD
        @ PROW(),pcol()+1 SAY D2S PICTURE PicD
        @ PROW(),pcol()+1 SAY P2S PICTURE PicD
        ? M5

        D3PS=D3PS+D2PS; P3PS=P3PS+P2PS
        D3TP=D3TP+D2TP; P3TP=P3TP+P2TP
        D3KP=D3KP+D2KP; P3KP=P3KP+P2KP

    ENDDO  // klasa konto

    SELECT BBKLAS
    APPEND BLANK
    REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

    SELECT ANAL

    IF cPodKlas=="D"
        ? M5
        ? "UKUPNO KLASA "+cklkonto
        @ prow(),nCol1    SAY D3PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
        if cFormat $ "13"
            @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
            @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
        endif
        @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY D3S PICTURE PicD
        @ PROW(),pcol()+1 SAY P3S PICTURE PicD
        ? M5
    ENDIF
    D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

__anal_bb_nova_strana( cFormat, 3 )

? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
IF cFormat $ "13"
    @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
    @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
ENDIF
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5

if ( prow() + 16 ) > __BB_LEN + gpStranica
    FF  
    ?
else
    ?
    ?
endif

?? "REKAPITULACIJA PO KLASAMA NA DAN: ";?? DATE()
?  M6
?  M7
?  M8
?  M9
?  M10

select BBKLAS
go top

nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()

    @ prow()+1,4   SAY IdKlasa
    @ prow(),10       SAY PocDug               PICTURE PicD
    @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
    @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

    nPocDug   += PocDug
    nPocPot   += PocPot
    nTekPDug  += TekPDug
    nTekPPot  += TekPPot
    nKumPDug  += KumPDug
    nKumPPot  += KumPPot
    nSalPDug  += SalPDug
    nSalPPot  += SalPPot
    
    SKIP

ENDDO

? M10
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF
END PRINT

close all
return



static function __anal_bb_nova_strana( format, dodaj )

if dodaj == NIL
    dodaj := 0
endif

if ( prow() + dodaj ) > ( __BB_LEN + gpStranica )
    FF
    BrBil_21( format )
endif

return



/*! \fn BrBil_21()
 *  \brief Zaglavlje analitickog bruto bilansa
 */
 
function BrBil_21( format )
?
if format == "3"
    ? "#%LANDS#"
endif
P_COND2
?? "FIN: ANALITIｬKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(), IF(cFormat=="1",220,142) SAY "Str:"+str(++nStr,3)

if gNW=="D"
    ? "Firma:",gFirma,gNFirma
else
    select PARTN
    HSEEK  cIdFirma
    ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
    ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select ANAL

? M1
? M2
? M3
? M4
? M5

RETURN



static function __sint_bb_nova_strana( format, dodaj )

if dodaj == NIL
    dodaj := 0
endif

if ( prow() + dodaj ) > ( __BB_LEN + gpStranica )
    FF
    BrBil_31( format )
endif

return



/*! \fn SintBB()
 *  \brief Sinteticki bruto bilans
 */

function SintBB()
local nPom

cIdFirma := gFirma

O_PARTN

Box("",8,60)
    set cursor on
    qqKonto:=space(100)
    dDatOd:=dDatDo:=ctod("")
    private cFormat:="2",cPodKlas:="N"

    do while .t.
        @ m_x+1,m_y+2 SAY "SINTETICKI BRUTO BILANS"
        if gNW=="D"
            @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
        else
            @ m_x+2,m_y+2 SAY "Firma " GET cIdFirma valid {|| empty(cIdFirma) .or. P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
        endif
        @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
        @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
        @ m_x+4,col()+2 SAY "do" GET dDatDo
        @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4/A4L (1/2/3)" GET cFormat VALID cFormat $ "123"
        @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"

        cIdRJ:=""

        IF gRJ=="D" .and. gSAKrIz=="D"
            cIdRJ:="999999"
            @ m_x+8,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
        ENDIF

        READ
        ESC_BCR
        aUsl1:=Parsiraj(qqKonto,"IdKonto")

        if aUsl1<>NIL
            exit
        endif

    enddo

    cIdfirma := trim(cidfirma)

BoxC()

if cIdRj == "999999"
    cIdrj := ""
endif

if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
    cIdrj:=trim(strtran(cidrj,".",""))
    // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

if cFormat $ "13"
    M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
    M2:= "*REDNI*   KONTO   *                  NAZIV SINTETICKOG KONTA                *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
    M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
    M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
    M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
else
    M1:= "---- ------------------------------ ------------------------------- ------------------------------- -------------------------------"
    M2:= "    *                              *        POｬETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
    M3:= "    *    SINTETIｬKI KONTO           ------------------------------- ------------------------------- -------------------------------"
    M4:= "    *                              *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
    M5:= "---- ------------------------------ --------------- --------------- --------------- --------------- --------------- ---------------"
endif


O_KONTO
O_BBKLAS

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
    SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
    O_SINT
ENDIF

select BBKLAS
ZAP
select SINT

cFilter:=""

if !(empty(qqkonto))
    if !(empty(dDatOd) .and. empty(dDatDo))
        cFilter:=aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
    else
        cFilter:=aUsl1
    endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:="DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
endif

if LEN(cIdFirma)<2
    SELECT SINT
    Box(,2,30)
        nSlog:=0; nUkupno:=RECCOUNT2()
        cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
        cSort1:="IdKonto+dtos(DatNal)"
        INDEX ON &cSort1 TO "SINTMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
        GO TOP
    BoxC()
else
    IF !EMPTY(cFilter)
        SET FILTER TO &cFilter
    ENDIF
    HSEEK cIdFirma
endif

EOF CRET

__BB_LEN := RPT_PAGE_LEN

if cFormat == "3"
    __BB_LEN := 42
endif

nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=1

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0
D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0
nStr:=0
nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma
    
    IF prow() == 0
        BrBil_31( cFormat )
    ENDIF

    cKlKonto:=left(IdKonto,1)

    D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
    
    DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)

        cIdKonto:=IdKonto
        D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
      
        DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cIdKonto==left(IdKonto,3)
            if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
            D1KP+=Dug
            P1KP+=Pot
            IF IdVN="00"
                D1PS+=Dug; P1PS+=Pot
            ELSE
                D1TP+=Dug; P1TP+=Pot
            ENDIF
            SKIP
        ENDDO // konto

        __sint_bb_nova_strana( cFormat )

        if cFormat $ "13"
            @ prow()+1,1 SAY B PICTURE '9999'; ?? "."
            @ prow(),10 SAY cIdKonto
            select KONTO
            HSEEK cIdKonto
            @ prow(),19 SAY naz
            nCol1:=pcol()+1
            @ prow(),pcol()+1 SAY D1PS PICTURE PicD
            @ prow(),pcol()+1 SAY P1PS PICTURE PicD
            @ prow(),pcol()+1 SAY D1TP PICTURE PicD
            @ prow(),pcol()+1 SAY P1TP PICTURE PicD
            @ prow(),pcol()+1 SAY D1KP PICTURE PicD
            @ prow(),pcol()+1 SAY P1KP PICTURE PicD
            D1S:=D1KP-P1KP
            IF D1S>=0
                P1S:=0; D3S+=D1S; D4S+=D1S
            ELSE
                P1S:=-D1S; D1S:=0
                P3S+=P1S; P4S+=P1S
            ENDIF
            @ prow(),pcol()+1 SAY D1S PICTURE PicD
            @ prow(),pcol()+1 SAY P1S PICTURE PicD

        else  // cformat=="2" - A4

            @ prow()+1,1 SAY cIdKonto
            select KONTO
            HSEEK cIdKonto

            private aRez:=SjeciStr(naz,30)
            private nColNaz:=pcol()+1
            @ prow(),pcol()+1 SAY padr(aRez[1],30)
            nCol1:=pcol()+1
            @ prow(),pcol()+1 SAY D1PS PICTURE PicD
            @ prow(),pcol()+1 SAY P1PS PICTURE PicD
            @ prow(),pcol()+1 SAY D1KP PICTURE PicD
            @ prow(),pcol()+1 SAY P1KP PICTURE PicD
            D1S:=D1KP-P1KP
            IF D1S>=0
                P1S:=0; D3S+=D1S; D4S+=D1S
            ELSE
                P1S:=-D1S; D1S:=0
                P3S+=P1S; P4S+=P1S
            ENDIF
            @ prow(),pcol()+1 SAY D1S PICTURE PicD
            @ prow(),pcol()+1 SAY P1S PICTURE PicD

            if len(aRez)==2
                @ prow()+1,nColNaz SAY padr(aRez[2],30)
            endif
        endif // cformat

        SELECT SINT
        D3PS+=D1PS; P3PS+=P1PS; D3TP+=D1TP; P3TP+=P1TP; D3KP+=D1KP; P3KP+=P1KP

        ++B


    ENDDO // klasa konto

    SELECT BBKLAS
    APPEND BLANK
    REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

    SELECT SINT

    IF cPodKlas=="D"
        ? M5
        ? "UKUPNO KLASA "+cklkonto
        @ prow(),nCol1    SAY D3PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
        if cFormat $ "13"
            @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
            @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
        endif
        @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY D3S PICTURE PicD
        @ PROW(),pcol()+1 SAY P3S PICTURE PicD
        ? M5
    ENDIF
    D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

__sint_bb_nova_strana( cFormat, 3 )

? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
if cFormat $ "13"
    @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
    @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
endif
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5
nPom:=d4ps-p4ps
@ prow()+1,nCol1   SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4tp-p4tp

if cFormat $ "13"
    @ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
    @ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
endif

nPom:=d4kp-p4kp
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
nPom:=d4s-p4s
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
? M5

FF

? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? DATE()
? IF(cFormat $ "13", M6, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? IF(cFormat $ "13", M7, "*        *          POｬETNO STANJE       *        KUMULATIVNI PROMET     *            SALDO             *")
? IF(cFormat $ "13", M8, "  KLASA   ------------------------------- ------------------------------- -------------------------------")
? IF(cFormat $ "13", M9, "*        *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *     DUGUJE    *    POTRAｦUJE *")
? IF(cFormat $ "13", M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

select BBKLAS; go top

nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
    @ prow()+1,4      SAY IdKlasa
    @ prow(),10       SAY PocDug               PICTURE PicD
    @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
    if cFormat $ "13"
        @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
        @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
    endif
    @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

    nPocDug   += PocDug
    nPocPot   += PocPot
    nTekPDug  += TekPDug
    nTekPPot  += TekPPot
    nKumPDug  += KumPDug
    nKumPPot  += KumPPot
    nSalPDug  += SalPDug
    nSalPPot  += SalPPot
    SKIP
ENDDO

? IF(cFormat $ "13",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
if cFormat $ "13"
    @ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
    @ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
endif
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? IF(cFormat $ "13",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

FF
END PRINT

close all

return




/*! \fn BrBil_31()
 *  \brief Zaglavlje sintetickog bruto bilansa
 */

function BrBil_31( format )
?

if format == "3"
    ? "#%LANDS#"
endif

P_COND2

?? "FIN: SINTETICKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? "  NA DAN: "; ?? DATE()
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select SINT
? M1
? M2
? M3
? M4
? M5
RETURN



static function __grupa_bb_nova_strana( format, dodaj )

if dodaj == NIL
    dodaj := 0
endif

if ( prow() + dodaj ) > __BB_LEN + gpStranica
    FF
    BrBil_41( format )
endif

return



/*! \fn GrupBB()
 *  \brief Bruto bilans po grupama konta
 */

function GrupBB()
local nPom
local cFormat := "2"

cIdFirma:=gFirma

O_PARTN

Box("",8,60)
    set cursor on
    qqKonto:=space(100)
    dDatOd:=dDatDo:=ctod("")
    private cPodKlas:="N"

    do while .t.
        @ m_x+1,m_y+2 SAY "BRUTO BILANS PO GRUPAMA KONTA"
        if gNW=="D"
            @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
        else
            @ m_x+2,m_y+2 SAY "Firma " GET cIdFirma valid {|| empty(cIdFirma) .or.;
                          P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
        endif
        @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
        @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
        @ m_x+4,col()+2 SAY "do" GET dDatDo
        @ m_x+5,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
        cIdRJ:=""
        IF gRJ=="D" .and. gSAKrIz=="D"
            cIdRJ:="999999"
            @ m_x+6,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
        ENDIF
        @ m_x + 7, m_y + 2 SAY "Format izvjestaja A3/A4/A4L (1/2/3)" GET cFormat VALID cFormat $ "123"
        READ
        ESC_BCR
        aUsl1:=Parsiraj(qqKonto,"IdKonto")
        if aUsl1<>NIL; exit; endif
    enddo

    cidfirma:=trim(cidfirma)

BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
    cidrj:=trim(strtran(cidrj,".",""))
    // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

M1:= "------ ----------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M2:= "*REDNI*   GRUPA   *        POｬETNO STANJE         *         TEKU終 PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
M3:= "          KONTA    ------------------------------- ------------------------------- ------------------------------- -------------------------------"
M4:= "*BROJ *           *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE   *    DUGUJE     *   POTRAｦUJE  *"
M5:= "------ ----------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

O_KONTO
O_BBKLAS

select BBKLAS
ZAP

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
    SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
    O_SINT
ENDIF

cFilter:=""

if !(empty(qqkonto))
    if !(empty(dDatOd) .and. empty(dDatDo))
        cFilter:=aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
    else
        cFilter:=aUsl1
    endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:="DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
endif

if LEN(cIdFirma)<2
    SELECT SINT
    Box(,2,30)
        nSlog:=0; nUkupno:=RECCOUNT2()
        cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
        cSort1:="IdKonto+dtos(DatNal)"
        INDEX ON &cSort1 TO "SINTMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
        GO TOP
    BoxC()
else
    IF !EMPTY(cFilter)
        SET FILTER TO &cFilter
    ENDIF
    HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

__BB_LEN := RPT_PAGE_LEN

if cFormat == "3"
    __BB_LEN := 43
endif

START PRINT CRET

B:=1

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0
D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0
nStr:=0
nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

    IF prow()==0
        BrBil_41( cFormat )
    ENDIF

    cKlKonto:=left(IdKonto,1)
    D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   
    DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)

        cIdKonto:=LEFT(IdKonto,2)
        D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
      
        DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cIdKonto==LEFT(IdKonto,2)
            if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
            D1KP+=Dug
            P1KP+=Pot
            IF IdVN="00"
                D1PS+=Dug; P1PS+=Pot
            ELSE
                D1TP+=Dug; P1TP+=Pot
            ENDIF
            SKIP
        ENDDO // konto
      
        __grupa_bb_nova_strana( cFormat )

        @ prow()+1,1 SAY B PICTURE '9999'; ?? "."
        @ prow(),10 SAY PADC(cIdKonto,8)
        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY D1PS PICTURE PicD
        @ prow(),pcol()+1 SAY P1PS PICTURE PicD
        @ prow(),pcol()+1 SAY D1TP PICTURE PicD
        @ prow(),pcol()+1 SAY P1TP PICTURE PicD
        @ prow(),pcol()+1 SAY D1KP PICTURE PicD
        @ prow(),pcol()+1 SAY P1KP PICTURE PicD
        D1S:=D1KP-P1KP
        IF D1S>=0
            P1S:=0; D3S+=D1S; D4S+=D1S
        ELSE
            P1S:=-D1S; D1S:=0
            P3S+=P1S; P4S+=P1S
        ENDIF
        @ prow(),pcol()+1 SAY D1S PICTURE PicD
        @ prow(),pcol()+1 SAY P1S PICTURE PicD

        SELECT SINT
        D3PS+=D1PS; P3PS+=P1PS; D3TP+=D1TP; P3TP+=P1TP; D3KP+=D1KP; P3KP+=P1KP

        ++B


    ENDDO // klasa konto

    SELECT BBKLAS
    APPEND BLANK
    REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

    SELECT SINT

    IF cPodKlas=="D"
        ? M5
        ? "UKUPNO KLASA "+cklkonto
        @ prow(),nCol1    SAY D3PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
        @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
        @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
        @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
        @ PROW(),pcol()+1 SAY D3S PICTURE PicD
        @ PROW(),pcol()+1 SAY P3S PICTURE PicD
        ? M5
    ENDIF
    D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

__grupa_bb_nova_strana( cFormat, 3 )
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
@ PROW(),pcol()+1 SAY D4TP PICTURE PicD
@ PROW(),pcol()+1 SAY P4TP PICTURE PicD
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5
nPom:=d4ps-p4ps
@ prow()+1,nCol1   SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4tp-p4tp                                  
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4kp-p4kp
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
nPom:=d4s-p4s
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
? M5

FF

?
?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? DATE()
?  M6
?  M7
?  M8
?  M9
?  M10

select BBKLAS
go top

nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
    @ prow()+1,4      SAY IdKlasa
    @ prow(),10       SAY PocDug               PICTURE PicD
    @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
    @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

    nPocDug   += PocDug
    nPocPot   += PocPot
    nTekPDug  += TekPDug
    nTekPPot  += TekPPot
    nKumPDug  += KumPDug
    nKumPPot  += KumPPot
    nSalPDug  += SalPDug
    nSalPPot  += SalPPot
    SKIP
ENDDO

? M10
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF
END PRINT

close all

return



/*! \fn BrBil_41()
 *  \brief Zaglavlje bruto bilansa po grupama 
 */

function BrBil_41( format )

?

if format == "3"
    ? "#%LANDS#"
endif

P_COND2
?? "FIN.P:BRUTO BILANS PO GRUPAMA KONTA U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? "  NA DAN: "; ?? DATE()
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select SINT
? M1
? M2
? M3
? M4
? M5
RETURN




/*! \fn BBMnoziSaK()
 *  \brief
 */
 
function BBMnoziSaK()

LOCAL nArr:=SELECT()
  IF cTip==ValDomaca().and.;
     IzFMKIni("FIN","BrutoBilansUDrugojValuti","N",KUMPATH)=="D"
    Box(,5,70)
      @ m_x+2, m_y+2 SAY "Pomocna valuta      " GET cBBV pict "@!" valid ImaUSifVal(cBBV)
      @ m_x+3, m_y+2 SAY "Omjer pomocna/domaca" GET nBBK WHEN {|| nBBK:=OmjerVal2(cBBV,cTip),.t.} PICT "999999999.999999999"
      READ
    BoxC()
  ELSE
    cBBV:=cTip
    nBBK:=1
  ENDIF
 SELECT (nArr)
RETURN




