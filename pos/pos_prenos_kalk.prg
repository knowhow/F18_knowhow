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



// -----------------------------------------------------------
// vrati mi vrstu dokumenta za import podataka
// -----------------------------------------------------------
static function _get_vd( tip_dokumenta )
local _ret := "16"

do case
    case tip_dokumenta $ "11#80#81#IP"
        _ret := "16"
    case tip_dokumenta $ "19"
        _ret := "NI"
endcase

return _ret



// ---------------------------------------------------------
// preuzimanje podataka iz modula kalk
// ---------------------------------------------------------
function pos_preuzmi_iz_kalk( tip_dok, br_dok, rs_dbf )
local _imp_table := ""
local _destination := ""
local _br_dok
local _val_otpremnica 
local _val_zaduzenje
local _val_inventura
local _val_nivelacija
local _id_pos, _prodajno_mjesto

_id_pos := gIdPos
_prodajno_mjesto := SPACE(2)
_val_otpremnica := "95"
_val_zaduzenje := "11#12#13#80#81"
_val_inventura := "IP"
_val_nivelacija := "19"

_destination := gKalkDest

SET CURSOR ON
O_PRIPRZ

_br_dok := SPACE( LEN( field->brdok ) )

if priprz->( RecCount2() ) == 0 .and. Pitanje( , "Preuzeti dokumente iz KALK-a", "N" ) == "N"
    return .f.
endif

// odaberi fajl za import
if !get_import_file( _br_dok, @_destination, @_imp_table )
    return .f.
endif

// otvori katops datoteku
select ( F_TMP_KATOPS )
my_use_temp( "KATOPS", _destination + _imp_table )

// daj mi vrstu dokumenta koju cu importovati
_id_tip_dok := _get_vd( katops->idvd )
   
select pos_doks
set order to tag "1"
    
// nadji sljedeci broj TOPS dokumenta
_br_dok := pos_naredni_dokument( _id_pos, tip_dok )
    
select katops
go top
        
MsgO( "kalk -> priprema, update roba ")

do while !EOF()
    if ( katops->idpos == _id_pos )
        if ( import_row( _id_tip_dok, _br_dok, "" ) == 0 )
            exit
        endif
    endif
    select katops
    skip
enddo

select katops
use
    
MsgC()

// pobrisi fajl importa nakon što smo ga importovali
_brisi_fajlove_importa( _destination + _imp_table )

return .t.


// ----------------------------------------------
// brisi fajlove importa
// ----------------------------------------------
static function _brisi_fajlove_importa( import_file )
        
// samo pobrisi fajl prenosa
FileDelete( import_file )
// i txt fajl
FileDelete(strtran( import_file, ".dbf", ".txt"))

return

 
// -----------------------------------------------
// katops -> priprz
// ----------------------------------------------   
static function import_row( id_vd, br_dok, id_odj )
local _t_area := SELECT()

// tabela PRIPRZ = "priprema zaduzenja"
select priprz
append blank

replace idroba with katops->idroba
replace cijena with katops->mpc

if id_vd == "NI"
    // nova cijena
    replace ncijena with katops->mpc2
endif

replace idtarifa with katops->idtarifa
replace kolicina with katops->kolicina
replace jmj with katops->jmj
replace robanaz with katops->naziv
replace k1 with katops->k1
replace k2 with katops->k2
replace k7 with katops->k7
replace k8 with katops->k8
replace k9 with katops->k9
replace n1 with katops->n1
replace n2 with katops->n2
replace barkod with katops->barkod
replace PREBACEN with OBR_NIJE
replace IDRADNIK with gIdRadnik
replace IdPos with KATOPS->IdPos
replace IdOdj WITH id_odj
replace IdVd WITH id_vd
replace Smjena WITH gSmjena 
replace BrDok with br_dok
replace DATUM with gDatum

select (_t_area)

return 1


// -----------------------------------------------
// odaberi - setuj ime kalk dbf-a
// -----------------------------------------------
static function get_import_file( br_dok, destinacija, import_fajl )
local _filter
local _prodajno_mjesto, _id_pos, _prefix
local _imp_files := {}
local _opc := {}
local _h, _i
local _izbor
local _prenesi 

if gMultiPM == "D"

    _filter := 2
    _prodajno_mjesto := GetPm()

    if !EMPTY( _prodajno_mjesto )
        _id_pos := _prodajno_mjesto
        _prefix := ( TRIM( _prodajno_mjesto ) ) + SLASH
    else
        _prefix := ""
    endif
    
    destinacija := TRIM(gKalkDest) + _prefix
    
    // pobrisi fajlove starije od 7 dana
    BrisiSFajlove( destinacija )
    BrisiSFajlove( STRTRAN( destinacija, ":" + SLASH, ":" + SLASH + "chk" + SLASH))

    _imp_files := DIRECTORY( destinacija + "kt*.dbf" )

    ASORT( _imp_files,,,{|x,y| DTOS(x[3]) + x[4] > DTOS(y[3]) + y[4] })   
    // datum + vrijeme
    // KT0512.DBF = elem[1]
        
    AEVAL( _imp_files, {|elem| AADD( _opc, PADR( elem[1], 15 ) + UChkPostoji(trim( destinacija ) + trim(elem[1])) + " "+ dtoc(elem[3]) + " " + elem[4])},1)
    
    // sortiraj po X, R
    if _filter == 1
        ASORT( _opc,,,{|x,y| RIGHT(x,19) > RIGHT(y,19)})  
        // R,X + datum + vrijeme
    endif
    
    if _filter == 2
        ASORT( _opc,,,{|x,y| RIGHT(x,17) > RIGHT(y,17)})  
        // datum + vrijeme
    endif
    
    _h := ARRAY( LEN( _opc ) )
    for _i := 1 to LEN(_h)
        _h[_i]:=""
    next

    // elem 3 - datum
    // elem 4 - time
    if LEN( _opc ) == 0
        MsgBeep("U direktoriju za prenos nema podataka")
        close all
        return .f.
    endif
else    
    MsgBeep ("Pripremi disketu za prenos ....#te pritisni neku tipku za nastavak!!!")
endif

if gMultiPM == "D"
    
    // CITANJE
    _izbor := 1
    _prenesi := .f.
    do while .t.
        _izbor := Menu("k2p", _opc, _izbor, .f.)
        if _izbor == 0
            exit
        else
            import_fajl := TRIM( destinacija ) + TRIM( LEFT( _opc[ _izbor ], 15 ) )
            //SAVE SCREEN TO _screen
            //Vidifajl(strtran(cKalkDBF,".DBF",".TXT"))  // vidi TK1109.TXT
            //RESTORE SCREEN FROM _screen
            if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
                _prenesi:=.t.
                _izbor := 0
            endif
        endif
    enddo
    
    if !_prenesi
        return .f.
    endif
    
else    
    
    // nije modemska veza
    // ako nije modemska veza
    import_fajl := TRIM( destinacija ) + "katops.dbf"
    _a_tmp1 := IscitajCRC( TRIM( destinacija ) + "crckt.crc" )
    _a_tmp2 := IntegDbf( imp_fajl )

    if !( _a_tmp1[1] == _a_tmp2[1] .and. _a_tmp1[2] == _a_tmp2[2] )
        MsgBeep("CRC se ne slaze")
        if Pitanje(, "Ipak zelite prenos (D/N)?", "N") == "N"
            return .f.
        endif
    endif

endif

return .t.


// -----------------------------------------
// vrati prodajno mjesto
// -----------------------------------------
static function GetPm()
local cPm
local cPitanje

cPm:=cIdPos

cPitanje:=IzFmkIni("POS","PrenosGetPm","0")
if ((gVrstaRs<>"S") .and. (cPitanje=="0"))
    return ""
endif


if (gVrstaRs=="S") .or. ((cPitanje=="D") .or. Pitanje(,"Postaviti oznaku prodajnog mjesta? (D/N)","N")=="D")
    Box(,1,30)
        SET CURSOR ON
        @ m_x+1,m_Y+2 SAY "Oznaka prodajnog mjesta:" GET cPm
        read
    BoxC()
endif
return cPm



function Pos2Pos(cIdVd, cBrDok, cRSDbf)

cIdPos:=gIdPos

//  Prenos dokumenta iz POS u POS
//  pos2 - datoteka prenosa

dDatum:=date()

cTops2:=padr("C:\TOPS\KUM2",25)
cCijene:="D"
Box(,3,60)
@ m_x+1,m_Y+2 SAY "Datum:" GET dDatum
@ m_x+2,m_Y+2 SAY "TOPS 2:" GET cTops2
@ m_x+3,m_y+2 SAY "Cijene iz tops 2 (D/N):" GET cCijene
read
BoxC()
select pos
//"1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena", KUMPATH+"POS")
seek gIdPos+"16"+dtos(dDatum)

do while !eof() .and. idpos+idvd+dtos(datum)==gIdPos+"16"+dtos(dDatum)
    cPrenijeti:="N"
        cBrdok:=brdok
        beep(1)
        @ m_x+3,m_y+2 SAY "Prenijeti ulaz broj:"+cbrdok  GET cPrenijeti pict "@!" valid cprenijeti$"DN"
        do while !eof() .and. idpos+idvd+dtos(datum)==gIdPos+"16"+dtos(dDatum)
            if cprenijeti=="D"
                scatter()
                select pos2
            append blank
                gather()
            endif
            skip
        enddo
enddo

BoxC()

return .t.



/*! \fn AutoRek2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos rek2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoRek2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
InigEpson()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
    ? "FORMAT DATUMA NEISPRAVAN...."
    ? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
    Sleep(5)
    return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
    dD1 := CToD(cDate1)
    dD2 := CToD(cDate2)
    ? "Vrsim prenos reklamacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
    // pozovi f-ju Real2Kalk() sa argumentima
    Rek2Kalk(dD1, dD2)
    ? "Izvrsen prenos ..."
    Sleep(1)
endif

return
*}



/*! \fn AutoReal2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos real2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoReal2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
InigEpson()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
    ? "FORMAT DATUMA NEISPRAVAN...."
    ? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
    Sleep(5)
    return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
    dD1 := CToD(cDate1)
    dD2 := CToD(cDate2)
    ? "Vrsim prenos realizacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
    // pozovi f-ju Real2Kalk() sa argumentima
    Real2Kalk(dD1, dD2)
    ? "Izvrsen prenos ..."
    Sleep(1)
endif

return
*}


/*! \fn Rek2Kalk()
 *  \brief Prenos reklamacija u modul kalk
 */
function Rek2Kalk(dD1, dD2)
*{
// pozovi prenos reklamacija
Real2Kalk(dD1, dD2, VD_REK)

return
*}



/*! \fn Real2Kalk(dDatOd, dDatDo)
 *  \brief Generisanje datoteke prenosa realizacije u modul KALK
 *  \param dDatOd - datum od
 *  \param dDatDo - datum do
 */
 
function Real2Kalk(dDateOd, dDateDo, cIdVd)

local cUslRoba := SPACE(150)
local cUslRMark := "U"
local aPom := {}
local i

private cTmp := ""

// ako je nil onda se radi o realizaciji
if (cIdVd == nil)
    cIdVd := "42"
endif

// prenos realizacija POS - KALK
O_ROBA
O_KASE
O_POS
O_POS_DOKS

cIdPos:=gIdPos


if ((dDateOd == nil) .and. (dDateDo == nil))
    dDatOd:=DATE()
    dDatDo:=DATE()
else
    dDatOd:=dDateOd
    dDatDo:=dDateDo
endif

// ako nije APPSRV prikazi box za prenos
if !gAppSrv
    SET CURSOR ON
    Box(,4,70,.f.,"PRENOS REALIZACIJE POS->KALK")
        @ m_x+1,m_y+2 SAY "Prodajno mjesto " GET cIdPos pict "@!" Valid !EMPTY(cIdPos).or.P_Kase(@cIdPos,5,20)
        @ m_x+2,m_y+2 SAY "Prenos za period" GET dDatOd
        @ m_x+2,col()+2 SAY "-" GET dDatDo
        @ m_x+3,m_y+2 SAY "Uslov po artiklima:" GET cUslRoba PICT "@S40"
        @ m_x+4,m_y+2 SAY "Artikle (U)kljuci / (I)skljuci iz prenosa:" GET cUslRMark PICT "@!" VALID cUslRMark $ "UI"
    read
    
    ESC_BCR
    BoxC()
endif

if gVrstaRS<>"S"
    //sasa, ne znam sta je ovo znacilo
    //cIdPos:=gIdPos
    gIdPos:=cIdPos
else
    // ako je server
    gIdPos:=cIdPos
endif

select pos_doks
SET ORDER TO 2  // IdVd+DTOS (Datum)+Smjena
go top
SEEK cIdVd + DTOS(dDatOd)
EOF CRET

aDbf:={}
AADD(aDBF,{"IdPos",    "C",  2, 0})
AADD(aDBF,{"IDROBA",   "C", 10, 0})
AADD(aDBF,{"kolicina", "N", 13, 4})
AADD(aDBF,{"MPC",      "N", 13, 4})
AADD(aDBF,{"STMPC",    "N", 13, 4})
// stmpc - kod dokumenta tipa 42 koristi se za iznos popusta !!
AADD(aDBF,{"IDTARIFA", "C",  6, 0})
AADD(aDBF,{"IDCIJENA", "C",  1, 0})
AADD(aDBF,{"IDPARTNER","C", 10, 0})
AADD(aDBF,{"DATUM",    "D",  8, 0})
AADD(aDBF,{"DATPOS",   "D",  8, 0})
AADD(aDBF,{"IdVd",     "C",  2, 0})
AADD(aDBF,{"BRDOK",    "C", 10, 0})
AADD(aDBF,{"M1",       "C",  1, 0})

select roba
if roba->(FieldPos("barkod"))<>0
    AADD(aDBF,{"BARKOD","C",13,0})
endif

select pos_doks
NaprPom(aDbf)

my_use ("pom",  "NEW", .t.)
INDEX ON IdPos + IdRoba + STR(mpc,13,4) + STR(stmpc,13,4) TAG ("1") TO (PRIVPATH+"POM")
INDEX ON brisano+"10" TAG "BRISAN"    //TO (PRIVPATH+"ZAKSM")
SET ORDER TO 1

cKalkDbf:=ALLTRIM(gKalkDest)
cKalkDbf+="TOPSKA.DBF"

IF gVrstaRS=="S"
    DirMak2(ALLTRIM(gKalkDest)+ALLTRIM(cIdPos))
    cKalkDbf:=ToUnix(ALLTRIM(gKalkDest)+ALLTRIM(cIdPos)+SLASH+"TOPSKA.DBF")
endif
DbCreate2(cKALKDBF,aDbf)
my_use(cKALKDBF, "NEW", .t.)
ZAPP()
__dbPack()

select pos_doks
nRbr:=0

do while !eof() .and. pos_doks->IdVd==cIdVd .and. pos_doks->Datum<=dDatDo
    
    if !EMPTY(cIdPos) .and. pos_doks->IdPos<>cIdPos
            SKIP
        LOOP
    endif
    
    // ako su reklamacije prekoci sve sto je sto="P"
    if IsPlanika() .and. cIdVd==VD_REK
        if PADR(field->sto, 1) == "P"
            skip
            loop
        endif
    endif
    
    SELECT pos
    SEEK pos_doks->(IdPos+IdVd+DTOS(datum)+BrDok)
    
    do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==pos_doks->(IdPos+IdVd+DTOS(datum)+BrDok)
                
        // uslov po robi
        if !EMPTY( cUslRoba )
            
            // parsiraj uslov...
            cTmp := Parsiraj( cUslRoba, "idroba" )

            // ako je tacno !
            if &cTmp
                
                if cUslRMark == "I"
                
                    // ako iskljucujes, onda preskoci
                    
                    skip
                    loop
                    
                endif
            
            else
                // ako treba da je ukljucena roba
                if cUslRMark == "U"
                
                    skip
                    loop
                
                endif
                
            endif
        
        endif
        
        Scatter()
            // uzmi i barkod
        if roba->(fieldpos("barkod"))<>0
            select roba
            set order to tag "ID"
            hseek pos->idroba
        endif
        
        select POM
            HSEEK POS->(IdPos+IdRoba+STR(cijena,13,4)+STR(nCijena,13,4))
            // seekuj i cijenu i popust (koji je pohranjen u ncijena)
            if !FOUND() .or. IdTarifa<>POS->IdTarifa .or. MPC<>POS->Cijena
                append blank
                
            replace IdPos WITH POS->IdPos
            replace IdRoba WITH POS->IdRoba
            replace Kolicina WITH POS->Kolicina
            replace IdTarifa WITH POS->IdTarifa
            replace mpc With POS->Cijena
            replace IdCijena WITH POS->IdCijena
            replace Datum WITH dDatDo
            replace DatPos with pos->datum
            replace brdok with pos->brdok
            
            if gModul=="HOPS"   
                replace IdVd With "47"
            else
                replace idvd with POS->IdVd
            endif
                    
            replace StMPC WITH pos->ncijena
                    
            if roba->(FieldPos("barkod"))<>0
                replace barkod with roba->barkod
            endif
                        
            if !EMPTY(pos_doks->idgost)
                replace idpartner with pos_doks->idgost
            endif
                        
            ++nRbr
            else
                replace Kolicina WITH Kolicina + _Kolicina
            endif
                
            select pos
            SKIP
    END
    select pos_doks
    SKIP
enddo

SELECT POM 
GO TOP
while !eof()
    Scatter()
    SELECT TOPSKA
    append blank
    Gather()
    SELECT POM
    SKIP
enddo

if gMultiPM == "D"
    close all
    cDestMod:=RIGHT(DTOS(dDatDo),4)  // 1998 1105  - 11 mjesec, 05 dan
    cDestMod:="TK"+cDestMod+"."
    
    if !gAppSrv 
        cPm:=GetPm()
    endif
    
    if (!gAppSrv .and. !EMPTY(cPm))
        cPrefix:=(TRIM(cPm))+SLASH
    else
        cPrefix:=""
    endif
            
    if (cIdVd <> VD_REK)
        realizacija_kase(.f.,dDatOd,dDatDo,"1")  // formirace outf.txt
    else
        realizacija_kase(dDatOd, dDatDo) // pregled reklamacija
    endif
    
    cDestMod:=StrTran(cKalkDbf,"TOPSKA.",cPrefix+cDestMod)
    FileCopy(cKalkDBF,cDestMod)
    cDestMod:=StrTran(cDestMod,".DBF",".TXT")
    FileCopy(PRIVPATH+"outf.txt",cDestMod)
    cDestMod:=StrTran(cDestMod,".TXT",".DBF")
    if !gAppSrv     
        MsgBeep("Datoteka "+cDestMod+"je izgenerisana#Broj stavki "+str(nRbr,4))
    else
        ? "Datoteka " + cDestMod + "je izgenerisana. Broj stavki: "+STR(nRbr,4)
    endif
else
    close all
    aPom:=IntegDbf(cKalkDBF)
    NapraviCRC(trim(gKalkDEST)+"CRCTK.CRC" , aPom[1] , aPom[2] )
    if !gAppSrv 
        MsgBeep("Datoteka TOPSKA je izgenerisana#Broj stavki "+str(nRbr,4))
    endif
endif

CLOSERET
return
*}


/*! \fn pos_sifre_katops()
 *  \brief
 */
 
function pos_sifre_katops()
*{
private cDirZip:=ToUnix("C:" + SLASH + "TOPS" + SLASH)

if !SigmaSif("SIGMAXXX")
    return
endif

cIdPos:=gIdPos

gFmkSif:=Trim(gFmkSif)
AddBS(@gFmkSif)

if !EMPTY(gFMKSif) 
    if !FILE(gFmkSif + "ROBA.DBF")
            MsgBeep("Na lokaciji " + TRIM(gFmkSif) + "ROBA.DBF nema tabele")
            return
    endif
    lAddNew:=(Pitanje(,"Dodati nepostojece sifre D/N ?"," ")=="D")
    AzurSifIzFmk("", lAddNew)
    return
endif

O_PARAMS
Private cSection:="T"
private cHistory:=" "
private aHistory:={}

RPar("Dz",@cDirZip)
Params1()

cDirZip:=Padr(cDirZip,30)

Box(,5,70) 
    @ m_x+1,m_y+2 SAY "Lokacija arhive sifrarnika:"
    @ m_x+2,m_y+2 GET cDirZip
    read
BoxC()

cDirZip:=TRIM(cDirZip)
AddBS(@cDirZip) 
 
if Params2()
    WPar("Dz",cDirZip)
endif

select params
use

select (F_ROBA)
use
save screen to cScr
cls

cKomlin:="dir /p " + cDirZip + "robknj.zip"
run &cKomLin

private cKomLin:="unzip -o " + cDirZip + "ROBKNJ.ZIP " + cDirZip
run &cKomLin

private cKomLin:="pause"
run &cKomLin

restore screen from cScr

O_SIFK
O_SIFV

if Pitanje(,"Osvjeziti sifrarnik iz arhive " + cDirZip + "ROBKNJ.ZIP"," ")=="D"
    lAddNew:=(Pitanje(,"Dodati nepostojece sifre D/N ?"," ")=="D")
    AzurSifIzFmk(cDirZip, lAddNew)  
        O_ROBA
        P_Roba()
endif

closeret
return

    
   

