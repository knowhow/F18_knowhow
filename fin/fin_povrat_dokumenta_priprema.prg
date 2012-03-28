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

#include "fin.ch"



function povrat_fin_naloga(lStorno)
local _rec
local nRec
local _del_rec, _ok
local _field_ids, _where_block
local _t_rec

if lStorno==NIL 
    lStorno:=.f.
endif

if Logirati(goModul:oDataBase:cName, "DOK", "POVRAT" )
	lLogPovrat:=.t.
else
	lLogPovrat:=.f.
endif

O_SUBAN
O_FIN_PRIPR
O_ANAL
O_SINT
O_NALOG

if fin_pripr->(RECCOUNT()) <> 0
    MsgBeep("Priprema nije prazna !!!")
endif

SELECT SUBAN
set order to tag "4"

cIdFirma  :=gFirma
cIdFirma2 :=gFirma
cIdVN := cIdVN2  := space(2)
cBrNal:= cBrNal2 := space(8)

Box("", IIF(lStorno, 3, 1), IIF(lStorno, 65, 35))

 @ m_x + 1, m_y + 2 SAY "Nalog:"

 if gNW=="D"
      @ m_x+1,col()+1 SAY cIdFirma PICT "@!"
 else
      @ m_x+1,col()+1 GET cIdFirma PICT "@!"
 endif

 @ m_x + 1, col() + 1 SAY "-" GET cIdVN PICT "@!"
 @ m_x + 1, col() + 1 SAY "-" GET cBrNal VALID _f_brnal(@cBrNal)

 IF lStorno

   @ m_x+3,m_y+2 SAY "Broj novog naloga (naloga storna):"

   if gNW=="D"
       @ m_x+3, col()+1 SAY cIdFirma2
   else
       @ m_x+3, col()+1 GET cIdFirma2
   endif

   @ m_x + 3, col() + 1 SAY "-" GET cIdVN2 PICT "@!"
   @ m_x + 3, col() + 1 SAY "-" GET cBrNal2

 ENDIF

 read
 ESC_BCR

BoxC()


if Pitanje(,"Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + IIF(lStorno," stornirati"," povuci u pripremu") + " (D/N) ?","D") == "N"
   closeret
endif

lBrisi:=.t.
IF !lStorno
    lBrisi := ( Pitanje(,"Nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal + " izbrisati iz baze azuriranih dokumenata (D/N) ?","D") == "D" )
ENDIF

MsgO("fin_suban -> fin_pripr: " + cIdfirma + cIdvn + cBrNal )

select suban
set order to tag "4"
go top
seek cIdfirma + cIdvn + cBrNal

do while !eof() .and. cIdFirma == field->IdFirma .and. cIdVN == field->IdVN .and. cBrNal == field->BrNal

   select fin_pripr

   select SUBAN
   _rec := dbf_get_rec()

   select fin_pripr
   if lStorno
       _rec["idfirma"]  := cIdFirma2
       _rec["idvn"]     := cIdVn2
       _rec["brnal"]    := cBrNal2
       _rec["iznosbhd"] := -_iznosbhd
       _rec["iznosdem"] := -_iznosdem
   endif

   APPEND BLANK

   dbf_update_rec(_rec)

   select SUBAN
   skip
enddo

MsgC()

IF !lBrisi
  CLOSERET
ENDIF

if !lStorno

    select suban
    set order to tag "4"
    go top
    seek cIdfirma + cIdvn + cBrNal
    MsgO( "brisem subanalitiku..." )

    _ok := .t.

    do while !eof() .and. cIdFirma == field->IdFirma .and. cIdVN == field->IdVN .and. cBrNal == field->BrNal

        skip 1
        _t_rec := RECNO()
        skip -1

        _del_rec := dbf_get_rec()
    
        // pobrisi suban
        _ok :=  delete_rec_server_and_dbf("suban", _del_rec )

        go ( _t_rec )

    enddo

    MsgC()        

    select sint
    set order to tag "2"
    go top
    seek cIdfirma + cIdvn + cBrNal

    MsgO( "brisem sintetiku..." )

    _ok := .t.

    do while !eof() .and. cIdFirma == field->IdFirma .and. cIdVN == field->IdVN .and. cBrNal == field->BrNal

        skip 1
        _t_rec := RECNO()
        skip -1

        _del_rec := dbf_get_rec()
        _ok :=  delete_rec_server_and_dbf("sint", _del_rec )

        go ( _t_rec )

    enddo

    MsgC()

    select anal
    set order to tag "2"
    go top
    seek cIdfirma + cIdvn + cBrNal

    MsgO( "brisem analitiku..." )

    _ok := .t.

    do while !eof() .and. cIdFirma == field->IdFirma .and. cIdVN == field->IdVN .and. cBrNal == field->BrNal

        skip 1
        _t_rec := RECNO()
        skip -1

        _del_rec := dbf_get_rec()
        _ok :=  delete_rec_server_and_dbf("anal", _del_rec )

        go ( _t_rec )

    enddo

    MsgC()

    MsgO( "brisem nalog....." )

    select nalog
    set order to tag "1"
    go top
    seek cIdfirma + cIdvn + cBrNal

    if found()
       // na kraju pobrisi nalog
       _del_rec := dbf_get_rec() 
       _ok := delete_rec_server_and_dbf("nalog", _del_rec )
    endif

    MsgC()

endif

if !_ok
    MsgBeep("Ajoooooooj del suban/anal/sint/nalog nije ok ?! " + cIdFirma + "-" + cIdVn + "-" + cBrNal )
endif

if lLogPovrat
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "POVRAT", nil, nil, nil, nil, "", "", cIdFirma + "-" + cIdVn + "-" + cBrNal, Date(), Date(), "", "Povrat naloga u pripremu")
endif

close all
return



/*! \fn Prefin_unos_naloga()
 *  \brief Preknjizenje naloga
 */
function Prefin_unos_naloga()

local fK1:="N"
local fk2:="N"
local fk3:="N"
local fk4:="N"
local cSK:="N"
nC:=50

O_PARAMS

private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)

select params
use

cIdFirma:=gFirma
picBHD:=FormPicL("9 "+gPicBHD,20)

O_PARTN

dDatOd:=CToD("")
dDatDo:=CToD("")

qqKonto:=SPACE(100)
qqPartner:=SPACE(100)
if gRJ=="D"
	qqIdRj:=SPACE(100)
endif

cTip:="1"

Box("",14,65)
set cursor on

cK1:="9"
cK2:="9"
cK3:="99"
cK4:="99"

if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	cK3:="999"
endif

cNula:="N"
cPreknjizi:="P"
cStrana:="D"
cIDVN:="88"
cBrNal:="00000001"
dDatDok:=date()
cRascl:="D"
private lRJRascl:=.f.


do while .t.
	@ m_x+1,m_y+6 SAY "PREKNJIZENJE SUBANALITICKIH KONTA"
 	if gNW=="D"
   		@ m_x+2,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cIdFirma:=Left(cIdFirma,2),.t.}
 	endif
 	@ m_x+3,m_y+2 SAY "Konto   " GET qqKonto  pict "@!S50"
 	@ m_x+4,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
 	if gRJ=="D"
		@ m_x+5,m_y+2 SAY "Rad.jed." GET qqIdRj pict "@!S50"
		@ m_x+6,m_y+2 SAY "Rasclaniti po RJ" GET cRascl pict "@!" valid cRascl$"DN"
 	endif
	@ m_x+7,m_y+2 SAY "Datum dokumenta od" GET dDatOd
 	@ m_x+7,col()+2 SAY "do" GET dDatDo

	// dodata mogucnost izbora i saldo (T), aMersed, 26.03.2004
 	@ m_x+8,m_y+2 SAY "Protustav/Storno/Saldo (P/S/T) " GET cPreknjizi valid cPreknjizi $ "PST" pict "@!"
 	// ako je cPreknjizi T onda mora odrediti na koju stranu knjizi
 	// posto moram provjeriti upravo upisanu varijablu ide READ
 	read
 	
	if cPreknjizi=="T" 
   		@ m_x+9,m_y+38 SAY "Duguje/Potrazuje (D/P)" GET cStrana valid cStrana $ "DP" pict "@!"
 	endif

 	@ m_x+10,m_y+2 SAY "Sifra naloga koji se generise" GET cIDVN
 	@ m_x+10,col()+2 SAY "Broj" GET cBrNal
 	@ m_x+10,col()+2 SAY "datum" GET dDatDok
 	if fk1=="D"
		@ m_x+11,m_y+2 SAY "K1 (9 svi) :" GET cK1
	endif
 	if fk2=="D"
		@ m_x+12,m_y+2 SAY "K2 (9 svi) :" GET cK2
	endif
 	if fk3=="D"
		@ m_x+13,m_y+2 SAY "K3 ("+cK3+" svi):" GET cK3
	endif
 	if fk4=="D"
		@ m_x+14,m_y+2 SAY "K4 (99 svi):" GET cK4
	endif

 	READ
	ESC_BCR
 
 	aUsl1:=Parsiraj(qqKonto,"IdKonto")
 	aUsl2:=Parsiraj(qqPartner,"IdPartner")
	if gRJ=="D" 
		if cRascl=="D"
			lRJRascl := .t.
		endif
	endif
	if gRJ=="D"
 		aUsl3:=Parsiraj(qqIdRj,"IdRj")
	endif
	if aUsl1<>NIL .and. aUsl2<>NIL
		exit
	endif
	
	if gRJ=="D" .and. aUsl3<>NIL
		exit
	endif
	
enddo
BoxC()

cIdFirma:=Left(cIdFirma,2)

O_FIN_PRIPR
O_KONTO
O_SUBAN

if cK1=="9"
	cK1:=""
endif
if cK2=="9"
	cK2:=""
endif
if cK3==REPL("9",LEN(ck3))
  	cK3:=""
else
  	cK3:=K3U256(cK3)
endif
if cK4=="99"
	cK4:=""
endif

select SUBAN

if (gRj=="D" .and. lRjRascl)
	set order to tag "9" //idfirma+idkonto+idrj+idpartner+...	
else
	set order to tag "1"
endif

cFilt1:="IDFIRMA=" + Cm2Str(cIdFirma) + ".and." + aUsl1 + ".and." + aUsl2 + IF(gRJ == "D", ".and." + aUsl3, "")+;
        IF(empty(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
        IF(empty(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))+;
        IF(fk1=="N","",".and.k1="+cm2str(ck1))+;
        IF(fk2=="N","",".and.k2="+cm2str(ck2))+;
        IF(fk3=="N","",".and.k3=ck3")+;
        IF(fk4=="N","",".and.k4="+cm2str(ck4))

cFilt1 := STRTRAN( cFilt1 , ".t..and." , "" )

if !(cFilt1==".t.")
	SET FILTER TO &cFilt1
endif

go top
EOF CRET

Pic:=PicBhd

if cTip=="3"
	m:="------  ------ ------------------------------------------------- --------------------- --------------------"
else
   	m:="------  ------ ------------------------------------------------- --------------------- -------------------- --------------------"
endif

nStr:=0
nUd:=0
nUp:=0      // DIN
nUd2:=0
nUp2:=0    // DEM
nRbr:=0

select fin_pripr
go bottom
nRbr:=VAL(rbr)
select suban

do whileSC !eof()
	cSin:=LEFT(idkonto, 3)
 	nKd:=0
 	nKp:=0
 	nKd2:=0
 	nKp2:=0
 	do whileSC !eof() .and.  cSin==LEFT(idkonto, 3)
     		cIdKonto:=IdKonto
     		cIdPartner:=IdPartner
		if gRj=="D"
			cIdRj:=idRj
     		endif
		nD:=0
     		nP:=0
     		nD2:=0
     		nP2:=0
		
		if (gRj=="D" .and. lRjRascl)
			bCond := {|| cIdKonto==IdKonto .and. IdRj==cIdRj .and. IdPartner==cIdPartner}
		else
			bCond := {|| cIdKonto==IdKonto .and. IdPartner==cIdPartner}
     		endif
		
		do whileSC !eof() .and. EVAL(bCond)
         		if d_P=="1"
           			nD+=iznosbhd
           			nD2+=iznosdem
         		else
           			nP+=iznosbhd
           			nP2+=iznosdem
         		endif
       			skip
     		enddo    // partner

     		select fin_pripr
         
    		// dodata opcija za preknjizenje saldo T
     		if cPreknjizi=="T"
      			if round(nD-nP,2)<>0
       				append blank
       				replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
				replace d_p with iif(cStrana=="D","1","2"), iznosbhd with (nD-nP), iznosdem with (nD2 - nP2)
      				if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
		
		if cPreknjizi=="P"
      			if round(nD-nP,2)<>0
       				append blank
       				replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
       				replace  d_p with IIF(nD-nP > 0,"2","1"), iznosbhd with abs(nD-nP), iznosdem with abs(nD2-nP2)
      				if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
     		
		if cPreknjizi=="S"
        		if round(nD, 3)<>0
         			append blank
        			replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
         			replace  d_p with "1", iznosbhd with -nd, iznosdem with -nd2
        			if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
        		if round(nP, 3)<>0
         			append blank
         			replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
         			replace  d_p with "2", iznosbhd with -nP, iznosdem with -nP2
         			if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
     		select suban
   		nKd+=nD
		nKp+=nP  // ukupno  za klasu
   		nKd2+=nD2
		nKp2+=nP2  // ukupno  za klasu
 	enddo  // sintetika
 	nUd+=nKd
	nUp+=nKp   // ukupno za sve
 	nUd2+=nKd2
	nUp2+=nKp2   // ukupno za sve
enddo // eof
closeret
return



