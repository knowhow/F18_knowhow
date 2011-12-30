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


#include "fmk.ch"


// -----------------------------------------
// otvaranje tabele roba - sifrarnik
// -----------------------------------------
function P_Roba(cId, dx, dy, cSeek )
local cRet
local bRoba
local nTArea
local lArtGroup := .f.
private ImeKol
private Kol

// pretraga po dobavljacu
if cSeek == nil
	cSeek := ""
endif

PushWa()
ImeKol:={}

nTArea := SELECT()

O_ROBA

if (IzFmkIni("Svi","SifAuto","N", SIFPATH)=="N") .or.;
   (IzFmkIni("SifRoba","ID","D", SIFPATH)=="D")
	AADD(ImeKol, {padc("ID",10),  {|| id }, iif(IzFmkIni("Svi","SifAuto","N", SIFPATH)="D","","id")  , {|| .t.}, {|| vpsifra(wId)} })
endif

if roba->(fieldpos("FISC_PLU")) <> 0
	AADD( ImeKol, { padc("PLU kod", 8), ;
		{|| PADR(fisc_plu, 10)}, ;
		"fisc_plu", {|| gen_plu(@wfisc_plu), .f.}, ;
		{|| .t. } })
endif

// kataloski broj
if roba->(fieldpos("KATBR"))<>0
	AADD(ImeKol, {padc("KATBR",14 ), {|| PADR(katBr, 14)}, "katBr"   })
endif

// sifra dobavljaca
if roba->(fieldpos("SIFRADOB"))<>0
	AADD(ImeKol, {padc("S.dobav.",13 ), {|| PADR(sifraDob, 13)}, "sifraDob"   })
endif

// naziv
if glProvNazRobe
	AADD(ImeKol, {padc("Naziv",40), {|| LEFT(naz, 40)},"naz",{|| .t.}, {|| VpNaziv(wNaz)}})
else
	AADD(ImeKol, {padc("Naziv",40), {|| LEFT(naz, 40)},"naz",{|| .t.}, {|| .t.}})
endif

// jedinica mjere
AADD(ImeKol, {padc("JMJ",3), {|| jmj},       "jmj"    })

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
	AADD(ImeKol, {padc("Debljina",10 ), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })

	AADD(ImeKol, {padc("Roba tip",10 ), {|| roba_tip}, "roba_tip", {|| .t.}, {|| .t. }})
endif

// STRINGS
if roba->(fieldpos("STRINGS")) <> 0
	AADD(ImeKol, {padc("Strings", 10 ), {|| strings}, "strings", {|| .t.}, {|| .t. }})
endif

// VPC
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC"))
	AADD(ImeKol, {padc("VPC",10 ), {|| transform(VPC,"999999.999")}, "vpc" , nil, nil, nil, gPicCDEM  })
endif

// VPC2
if roba->(fieldpos("vpc2"))<>0
	if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC2"))
		if IzFMkIni('SifRoba',"VPC2",'D', SIFPATH)=="D"
			AADD(ImeKol, {padc("VPC2",10 ), {|| transform(VPC2,"999999.999")}, "vpc2", NIL, NIL,NIL, gPicCDEM   })
 		endif
	endif
endif

AADD(ImeKol, {padc("MPC",10 ), {|| transform(MPC,"999999.999")}, "mpc", NIL, NIL,NIL, gPicCDEM  })

if roba->(fieldpos("PLC"))<>0  .and. IzFMkIni("SifRoba","PlanC","N", SIFPATH)=="D"
	AADD(ImeKol, {padc("Plan.C",10 ), {|| transform(PLC,"999999.999")}, "PLC", NIL, NIL,NIL, gPicCDEM    })
endif

for i:=2 to 10
	cPom:="MPC"+ALLTRIM(STR(i))
	cPom2:='{|| transform('+cPom+',"999999.999")}'
	if roba->( fieldpos( cPom ) )  <>  0
		if i>1  // parametriziraj
			cPrikazi:=IzFMkIni('SifRoba',cPom,'D', SIFPATH)
		else
			cPrikazi:="D"
		endif

		if cPrikazi=="D"
			AADD(ImeKol, {padc(cPom,10 ), &(cPom2) , cPom , nil, nil, nil, gPicCDEM })
		endif
	endif
next

if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWNC"))
	AADD(ImeKol, {padc("NC",10 ), {|| transform(NC,gPicCDEM)}, "NC", NIL, NIL, NIL, gPicCDEM  })
endif

AADD(ImeKol, {"Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa) }   })

AADD(ImeKol, {"Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| wTip $ " TUCKVPSXY" } ,NIL,NIL,NIL,NIL, 27 } )

if roba->(fieldpos("BARKOD"))<>0
	if glAutoFillBK
		AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| WhenBK()} , {|| DodajBK(@wBarkod) }  })
	else
		AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| .t.} , {|| DodajBK(@wBarkod) }  })
	endif
endif

if roba->(fieldpos("mink"))<>0
	AADD (ImeKol,{ padc("MINK",10 ), {|| transform(MINK,"999999.99")}, "MINK"   })
endif

if roba->(fieldpos("K1"))<>0
	AADD (ImeKol,{ padc("K1",4 ), {|| k1 }, "k1"   })
	AADD (ImeKol,{ padc("K2",4 ), {|| k2 }, "k2", ;
		{|| .t.}, {|| .t.}, nil, nil, nil, nil, 35   })
	AADD (ImeKol,{ padc("N1",12), {|| N1 }, "N1"   })
	AADD (ImeKol,{ padc("N2",12 ), {|| N2 }, "N2", ;
		{|| .t.}, {|| .t.}, nil, nil, nil, nil, 35   })
endif

if roba->(fieldpos("K7"))<>0
	AADD (ImeKol,{ padc("K7",2 ), {|| k7 }, "k7"   })
	AADD (ImeKol,{ padc("K8",2 ), {|| k8 }, "k8"  })
	AADD (ImeKol,{ padc("K9",3 ), {|| k9 }, "k9" })
endif

// AUTOMATSKI TROSKOVI ROBE, samo za KALK
if goModul:oDataBase:cName == "KALK" .and. roba->(fieldpos("TROSK1")) <> 0
	AADD (ImeKol,{ PADR(c10T1,8) ,{|| trosk1 }, "trosk1", {|| .t.}, {|| .t.} })
	AADD (ImeKol,{ PADR(c10T2,8), {|| trosk2 }, "trosk2", ;
		{|| .t. }, {|| .t. }, nil, nil, nil, nil, 30 })
	AADD (ImeKol,{ PADR(c10T3,8), {|| trosk3 }, "trosk3", {|| .t.}, {|| .t.} })
	AADD (ImeKol,{ PADR(c10T4,8), {|| trosk4 }, "trosk4", ;
		{|| .t. }, {|| .t. }, nil, nil, nil, nil, 30 })
	AADD (ImeKol,{ PADR(c10T5,8), {|| trosk5 }, "trosk5"   })
endif

if roba->(fieldpos("ZANIVEL"))<>0
	AADD (ImeKol,{ padc("Nova cijena", 20 ), {|| transform(zanivel,"999999.999")}, "zanivel", NIL, NIL,NIL, gPicCDEM  })
endif
if roba->(fieldpos("ZANIV2"))<>0
	AADD (ImeKol,{ padc("Nova cijena/2", 20 ), {|| transform(zaniv2,"999999.999")}, "zaniv2", NIL, NIL,NIL, gPicCDEM  })
endif

if roba->(fieldpos("IDKONTO"))<>0
	AADD (ImeKol,{ "Id konto",{|| idkonto}, "idkonto", {|| .t. }, {|| P_Konto(@widkonto) }   })
endif

if roba->(fieldpos("IDTARIFA2"))<>0
	AADD (ImeKol,{ "Tarifa R2",{|| IdTarifa2}, "IdTarifa2", {|| .t. }, {|| set_tar_rs(@wIdTarifa2, wIdTarifa) .or. P_Tarifa(@wIdTarifa2) }   })
	AADD (ImeKol,{ "Tarifa R3",{|| IdTarifa3}, "IdTarifa3", {|| .t. }, {|| set_tar_rs(@wIdTarifa3, wIdTarifa) .or. P_Tarifa(@wIdTarifa3) }   })
endif



Kol := {}

FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

select sifk
set order to tag "ID"
seek "ROBA"

do while !eof() .and. ID="ROBA"
	AADD (ImeKol, {  IzSifKNaz("ROBA",SIFK->Oznaka) })
 	AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('ROBA','" + sifk->oznaka + "')) }" ) )
 	AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 	if sifk->edkolona > 0
   		for ii:=4 to 9
    			AADD( ImeKol[Len(ImeKol)], NIL  )
   		next
   		AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 	else
   		for ii:=4 to 10
    			AADD( ImeKol[Len(ImeKol)], NIL  )
   		next
 	endif

	// postavi picture za brojeve
 	if sifk->Tip="N"
   		if f_decimal > 0
     			ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina-sifk->f_decimal-1 )+"."+replicate("9",sifk->f_decimal)
   		else
     			ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   		endif
 	endif
	AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )
	skip
enddo

select (nTArea)

bRoba:=gRobaBlock

if !EMPTY(cSeek)
	cPomTag := cSeek
else
	cPomTag := IzFMKIni("SifRoba","SortTag","ID",SIFPATH)
endif

cRet := PostojiSifra(F_ROBA, (cPomTag), 15, MAXCOLS() - 5 , "Lista artikala - robe", @cId, dx, dy, bRoba,,,,,{"ID"})

PopWa()

return cRet



// ------------------------------------
// formiranje MPC na osnovu VPC
// ------------------------------------
function MpcIzVpc()

if pitanje(,"Formirati MPC na osnovu VPC ? (D/N)","N")=="N"
	return DE_CONT
endif

private GetList:={}
private nZaokNa:=1
private cMPC:=" "
private cVPC:=" "

Scatter()
select tarifa
hseek _idtarifa
select roba

Box(,4,70)
@ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
@ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
READ
IF EMPTY(cVPC)
	cVPC:=""
ENDIF
IF EMPTY(cMPC)
	cMPC:=""
ENDIF
BoxC()

Box(,6,70)
@ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(LEFT(roba->naz, 40))
@ m_X+2, m_y+2 SAY "TARIFA"
@ m_X+2, col()+2 SAY _idtarifa
@ m_X+3, m_y+2 SAY "VPC"+cVPC
@ m_X+3, col()+1 SAY _VPC&cVPC pict gPicDem
@ m_X+4, m_y+2 SAY "Postojeca MPC"+cMPC
@ m_X+4, col()+1 SAY roba->MPC&cMPC pict gPicDem
@ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict "9"
@ m_X+6, m_y+2 SAY "MPC"+cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict gPicDem
read
BoxC()
if lastkey()<>K_ESC
	Gather()
        IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je MPC"+cMPC+"=0 ? (D/N)","N")=="D"
        	nRecAM:=RECNO()
           	Postotak(1,RECCOUNT2(),"Formiranje cijena")
           	nStigaoDo:=0
           	GO TOP
           	DO WHILE !EOF()
             		IF ROBA->MPC&cMPC == 0
               			Scatter()
                		select tarifa
				hseek _idtarifa
				select roba
                		_MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa)
               			Gather()
             		ENDIF
             		Postotak(2,++nStigaoDo)
             		SKIP 1
           	ENDDO
           	Postotak(0)
           	GO (nRecAM)
        ENDIF
        return DE_REFRESH
endif
return DE_CONT


// -------------------------------------------------------
// setovanje tarife 2 i 3 u sifrarniku na osnovu idtarifa
// -------------------------------------------------------
function set_tar_rs(cId1, cId2)
if EMPTY(cId1)
	cId1 := cId2
endif
return .t.


function WhenBK()
if empty(wBarKod)
	wBarKod:=PADR(wId,LEN(wBarKod))
	AEVAL(GetList,{|o| o:display()})
endif
return .t.


// roba ima zasticenu cijenu
// sto znaci da krajnji kupac uvijek placa fixan iznos pdv-a 
// bez obzira po koliko se roba prodaje
function RobaZastCijena( cIdTarifa )
lZasticena := .f.
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDVZ",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDV17Z",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("CIGA05",6))

return lZasticena



// ------------------------------------
// setuje u sifk parametre GR1, GR2
// ------------------------------------
function set_sifk_roba_group()

local _seek
local _naziv
local _id
local _rec

SELECT (F_SIFK)

if !used()
	O_SIFK
endif

SET ORDER TO TAG "ID"
GO TOP
// id + SORT + naz

_id := PADR( "ROBA", SIFK_LEN_DBF ) 
_naziv := PADR( "Grupa 1", LEN(field->naz) )
_seek :=  _id + "01" + _naziv

SEEK _seek   

// dodaj grupa 1 ako ne postoji

if !FOUND()
    
    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["id"] := _id
    _rec["naz"] := _naziv
    _rec["oznaka"] := "GR1"
    _rec["sort"] := "01"
    _rec["tip"] := "C"
    _rec["duzina"] := 20
    _rec["veza"] := "1"

    if !update_rec_server_and_dbf("sifk", _rec) 
        delete_with_rlock()
    endif

endif

// dodaj grupa 2 ako ne postoji
GO TOP

_id := PADR( "ROBA", SIFK_LEN_DBF ) 
_naziv := PADR( "Grupa 2", LEN(field->naz) )
_seek :=  _id + "02" + _naziv

SEEK _seek   

if !FOUND()
    
    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["id"] := _id
    _rec["naz"] := _naziv
    _rec["oznaka"] := "GR2"
    _rec["sort"] := "02"
    _rec["tip"] := "C"
    _rec["duzina"] := 20
    _rec["veza"] := "1"

    if !update_rec_server_and_dbf("sifk", _rec) 
        delete_with_rlock()
    endif

endif

return .t.


//---------------------------------------------------
//---------------------------------------------------
function OFmkRoba()

O_SIFK
O_SIFV
O_KONTO
O_KONCIJ
O_TRFP
O_TARIFA
O_ROBA
O_SAST
return


//---------------------------------------------------
//---------------------------------------------------
function CreRoba(ver)
local _table_name, _alias

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'SIFRADOB'            , 'C' ,  20 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' , 250 ,  0 })
AADD(aDBf,{ 'STRINGS'             , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'JMJ'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'PLC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC3'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K7'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K8'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K9'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'N1'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'N2'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MINK'                , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'Opis'                , 'C' , 250 ,  0 })
AADD(aDBf,{ 'BARKOD'              , 'C' ,  13 ,  0 })
AADD(aDBf,{ 'FISC_PLU'            , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'ZANIVEL'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'ZANIV2'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TROSK1'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK2'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK3'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK4'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK5'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  5 })

_alias := "ROBA"
_table_name := "roba"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
endif

// 0.2.1
if ver["current"] < 00201
   modstru( {"*" + _table_name, "A IDKONTO C 7 0"})
endif

reset_semaphore_version(_table_name)
my_use(_alias)
use



if !file(f18_ime_dbf("_roba"))
        dbcreate2(PRIVPATH+'_roba.dbf',aDbf)
endif

CREATE_INDEX("ID", "ID", "roba") 

index_mcode(SIFPATH, "roba")
CREATE_INDEX("NAZ","LEFT(naz,40)", SIFPATH+"roba")
CREATE_INDEX("ID","id", PRIVPATH+"_roba") 
CREATE_INDEX("BARKOD","BARKOD", "roba") // roba, artikli
CREATE_INDEX("SIFRADOB","SIFRADOB",SIFPATH+"roba") // roba, artikli
CREATE_INDEX("ID_VSD","SIFRADOB", SIFPATH + "roba") // sifra dobavljaca
CREATE_INDEX("PLU","str(fisc_plu, 10)", SIFPATH + "roba") // sifra dobavljaca

close all
O_ROBA

if used()
    if fieldpos("KATBR")<>0
    select (F_ROBA)
    use
    CREATE_INDEX("KATBR","KATBR",SIFPATH+"roba") // roba, artikli
    endif
endif

// dodaj polja grupe u sifrarnik sifk
set_sifk_roba_group()

// TARIFA
if !file(f18_ime_dbf("tarifa"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
        add_f_mcode(@aDbf)
	    AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
        AADD(aDBf,{ 'OPP'                 , 'N' ,   6 ,  2 })  // ppp
        AADD(aDBf,{ 'PPP'                 , 'N' ,   6 ,  2 })  // ppu
        AADD(aDBf,{ 'ZPP'                 , 'N' ,   6 ,  2 })  //nista
        AADD(aDBf,{ 'VPP'                 , 'N' ,   6 ,  2 })  // pnamar
        AADD(aDBf,{ 'MPP'                 , 'N' ,   6 ,  2 })  // pnamar MP
        AADD(aDBf,{ 'DLRUC'               , 'N' ,   6 ,  2 })  // donji limit RUC-a(%)
        dbcreate2( "TARIFA", aDbf)
		reset_semaphore_version("tarifa")
		my_use("tarifa")
		close all
endif
CREATE_INDEX("ID","id",  SIFPATH+"TARIFA")
CREATE_INDEX("naz","naz", SIFPATH+"TARIFA")
index_mcode(SIFPATH, "TARIFA")

// KONCIJ
if !file(f18_ime_dbf("koncij"))
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'IDPRODMJES'          , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'REGION'              , 'C' ,   2 ,  0 })
   dbcreate2('KONCIJ',aDbf)
   reset_semaphore_version("koncij")
   my_use("koncij")
   close all
endif
CREATE_INDEX("ID","id",SIFPATH+"KONCIJ") // konta
index_mcode(SIFPATH, "KONCIJ")

// TRFP
if !file(f18_ime_dbf("trfp"))
    aDbf:={}
    AADD(aDBf,{ 'ID'                  , 'C' ,  60 ,  0 })
    add_f_mcode(@aDbf)
	AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
    AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
    AADD(aDBf,{ 'DOKUMENT'            , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'PARTNER'             , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'ZNAK'                , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
    dbcreate2("TRFP",aDbf)
    reset_semaphore_version("trfp")
    my_use("trfp")
    close all
endif
CREATE_INDEX("ID", "idvd+shema+Idkonto", "trfp")
index_mcode(SIFPATH, "TRFP")


// SAST
if !file(f18_ime_dbf("sast"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'R_BR'                , 'N' ,    4 ,  0 })
   AADD(aDBf,{ 'ID2'                 , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'KOLICINA'            , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'K1'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'K2'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'N1'                  , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'N2'                  , 'N' ,   20 ,  5 })
   dbcreate2('SAST', aDbf)
   reset_semaphore_version("sast")
   my_use("sast")
   close all
endif

CREATE_INDEX("ID", "ID+ID2", "SAST")

close all
O_SAST
if used()
    if sast->(fieldpos("R_BR"))<>0
        use
        CREATE_INDEX("IDRBR", "ID+STR(R_BR,4,0)+ID2", SIFPATH + "SAST")
    endif
    use
endif

CREATE_INDEX("NAZ", "ID2+ID", SIFPATH + "SAST")


if !file(f18_ime_dbf("barkod"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,   13 ,  0 })
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  250 ,  0 })
   AADD(aDBf,{ 'L1'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L2'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L3'                  , 'C' ,   40 ,  0})
   AADD(aDBf,{ 'VPC'                 , 'N' ,   12 ,  2 })
   AADD(aDBf,{ 'MPC'                 , 'N' ,   12 ,  2 })
   dbcreate2(PRIVPATH+'BARKOD.DBF',aDbf)
endif
CREATE_INDEX("1","barkod+id",PRIVPATH+"BARKOD")
CREATE_INDEX("ID","id+LEFT(naziv,40)",PRIVPATH+"BARKOD")
CREATE_INDEX("Naziv","LEFT(Naziv,40)+id",PRIVPATH+"BARKOD")

// kreiranje tabele strings
cre_strings()

cre_fin_mat()

return






