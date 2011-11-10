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


#include "epdv.ch"

static aHeader:={}
static aZaglLen:={5, 50 }
static aZagl:={}

// izvjestaj je u dvije kolone

// lijeva margina
static RPT_LM  := 5

//  row indent
static RPT_RI := 2

// ispis teksta u jednoj koloni
static RPT_W2 := 45

// sirina jedne kolone
static RPT_COL := 58

// sirina razmaka izmedju kolona
static RPT_GAP := 4

// korekcija sirine za bold colone
static RPT_BOLD_DELTA := 2
// tekuca linija reporta
static nCurrLine := 0

static cRptNaziv := "PDV prijava" 

static cTbl := "PDV"

// source 
// 1 - kuf kif podaci
// 2 - pdv baza
static cSource := "1"

static dDatOd
static dDatDo

// -------------------------------------------
// PDV prijava
// -------------------------------------------
function rpt_p_pdv()
local cAzurirati

aDInt := rpt_d_interval (DATE())

dDate := DATE()

dDatOd := aDInt[1]
dDatDo := aDInt[2]

cAzurirati := "D"

nX:=1
Box(, 12, 60)

  // izvjestaj za period
  @ m_x+nX, m_y+2 SAY "Period"
  nX++
  
  @ m_x+nX, m_y+2 SAY "od " GET dDatOd
  @ m_x+nX, col()+2 SAY "do " GET dDatDo
  
  nX += 2
  @ m_x+nX, m_y+2 SAY "obrazac se pravi na osnovu :"
  nX++
  @ m_x+nX, m_y+2 SAY " 1 - kuf/kif"
  nX++
  @ m_x+nX, m_y+2 SAY " 2 - pdv baze" 
  nX++
  @ m_x+nX, m_y+2 SAY " izbor ?" GET cSource ;
  	PICT "@!" ;
	VALID cSource $ "12"
	
  READ
  nX ++

  if cSource == "1"
  	@ m_x+nX, m_y+2 SAY " azurirati podatke u PDV bazu ?" GET cAzurirati ;
	  	PICT "@!" ;
		VALID cAzurirati $ "DN"
	READ

  endif
  
BoxC()

if LastKey()==K_ESC
	closeret
endif

fill_rpt()
show_rpt(  .f.,  .f.)


save_pdv_obracun(dDatOd, dDatDo)

return




// -----------------------------------
// -----------------------------------
static function cre_r_tbl()
local aArr:={}

close all

ferase ( PRIVPATH + "R_" +  cTbl + ".CDX" )
ferase ( PRIVPATH + "R_" +  cTbl + ".DBF" )

aArr := get_pdv_fields()

// kreiraj tabelu
dbcreate2(PRIVPATH + "R_" + cTbl + ".DBF", aArr)


return
*}

// ------------------------------------------
// napuni r_pdv
// ------------------------------------------
static function fill_rpt()
cre_r_tbl()

if cSource == "1"
	f_iz_kuf_kif()
else
	f_iz_pdv()
endif

return


// -------------------------------------
// napuni iz kuf i kif podataka
// -------------------------------------
static function f_iz_kuf_kif()
local nBPdv
local nUkIzPdv := 0
local nUkUlPdv := 0
// ulazni pdv koji je krajnja potrosnja firme
local nUlPdvKp := 0

O_R_PDV
APPEND BLANK

aMyFirma := my_firma( .t. )

Scatter()

_po_naziv := aMyFirma[1]
_id_br := aMyFirma[2]
_po_ptt := aMyFirma[3]
_po_mjesto := aMyFirma[4]
_po_adresa := aMyFirma[5]


// setuj mem vars

PRIVATE cFilter := ""

// datumski period
cFilter := cm2str(dDatOd) + " <= datum .and. " + cm2str(dDatDo) + ">= datum" 

#ifdef PROBA
MsgBeep(cFilter)
#endif

O_KUF
SET FILTER TO &cFilter
GO TOP

Box(,3, 60)

nCount := 0

// KUF
do while !eof()

++nCount

@ m_x+2, m_y+2 SAY "KUF" + STR(nCount, 6, 0)


cIdTar := id_tar
nBPdv := i_b_pdv
nPdv := i_pdv

do case 

	case t_u_poup(cIdTar)
		_u_nab_21 += nBPdv
		_u_pdv_41 += nPdv
		nUkUlPdv += nPdv
		
	case t_u_uvoz(cIdTar)
		_u_uvoz += nBPdv
		_u_pdv_uv += nPdv
		nUkUlPdv += nPdv

		
	case t_u_polj(cIdTar)
		_u_nab_23 += nBPdv
		_u_pdv_43 += nPdv
		nUkUlPdv += nPdv

	case t_u_polj_0(cIdTar)
		_u_nab_23 += nBPdv
	
        case t_u_n_poup(cIdTar)
		// sve ostale nabavke su 21
		_u_nab_21 += nBPdv
	        // ovaj pdv ide i u statistiku krajnje potrosnje
	        nUlPdvKp += nPdv

	otherwise
		// sve ostale nabavke su 21
		// ali se ne priznaje ulazni porez
		_u_nab_21 += nBPdv
			
endcase


SELECT KUF

SKIP

enddo

// azuriram R_PDV za stavke KUF-a
SELECT r_pdv
Gather()

SELECT KUF
use


Beep(1)

// ----------------------------------------------------------------------
// idemo sada na izlazne fakture
// ----------------------------------------------------------------------
O_KIF

// datumski period
cFilter := cm2str(dDatOd) + " <= datum .and. " + cm2str(dDatDo) + ">= datum" 

#ifdef PROBA
MsgBeep(cFilter)
#endif

O_KIF
SET FILTER TO &cFilter
GO TOP


// ----------------------------------------------------------------------
// dodaj u statistiku krajnju potrosnju iz ulaznog pdv-a
// -----------------------------------------------------------------------
if !empty(gUlPdvKp())
	do case
		   case gUlPdvKp() == "1"
			_i_pdv_nr1 += nUlPdvKp
		   case gUlPdvKp() == "2"
			_i_pdv_nr2 += nUlPdvKp
		   case gUlPdvKp() == "3"
			_i_pdv_nr3 += nUlPdvKp
		endcase
	endif


// KIF
do while !eof()

++nCount

@ m_x+2, m_y+2 SAY "KIF" + STR(nCount, 6, 0)


cIdTar := id_tar
nBPdv := i_b_pdv
nPdv := i_pdv

do case

	case t_i_opor(cIdTar)
		// 11 - oporezive isporuke
		_i_opor += nBPdv
		
	case t_i_izvoz(cIdTar)
		// 12 - isporuke izvoz
		_i_izvoz += nBPdv
	case t_i_neop(cIdTar)
		// 13 - ostale neoporezive isporuke
		_i_neop += nBPdv
		
endcase


if ROUND( g_pdv_stopa(cIdTar), 2) > 0

	// oporezivo, obracunat pdv

	nUkIzPdv += nPdv
	
	if IsPdvObveznik(id_part)

		_i_pdv_r += nPdv
	
	else
		cRejon := part_rejon(id_part)

		do case
			case cRejon == "2"
				// rs
				_i_pdv_nr2 += nPdv
			
			case cRejon == "3"
				// bd
				_i_pdv_nr3 += nPdv
		
			case cRejon == "4"
				// ovoga nema ali eto ... samo nam jos 
				// jedan entitet fali :(
				_i_pdv_nr4 += nPdv
				
			otherwise
				// federacija je "1" ili nije nista stavljeno
				_i_pdv_nr1 += nPdv

		endcase
	endif
				
endif

SELECT KIF

SKIP

enddo

// azuriram R_PDV za stavke KUF-a
SELECT r_pdv

UsTipke()

	
	read_pdv_pars(@_pot_datum, @_pot_mjesto, @_pot_ob, @_pdv_povrat)

	// bez obzira na parametar ponudi danasnji datum
	_pot_datum := DATE()
	
Box(,8, 65)
	@ m_x + 1, m_y + 2 SAY "Prenos PDV iz predhodnog perioda (KM) ?" GET _u_pdv_pp ;
	   PICT PIC_IZN()
	   
	@ m_x + 3, m_y + 2 SAY "- Potpis -----------------"
	@ m_x + 4, m_y + 2 SAY "Datum :" GET _pot_datum ;
		VALID { || _pot_mjesto := PADR(_po_mjesto, LEN(_pot_mjesto)), .t. }
	@ m_x + 5, m_y + 2 SAY "Mjesto :" GET _pot_mjesto  ;
		VALID { || _pot_datum := DATE(), .t. }
	
	@ m_x + 6, m_y + 2 SAY "Ime i prezime ? " GET _pot_ob ;
		PICT "@S30" ;
		
	
	@ m_x + 8, m_y + 2 SAY "Zahtjev za povrat ako je preplata (D/N) ? " GET _pdv_povrat ; 
		VALID _pdv_povrat $ "DN" ;
		PICT "@!"
	
	READ

	save_pdv_pars(_pot_datum, _pot_mjesto, _pot_ob, _pdv_povrat)
	
BoxC()

SELECT r_pdv

_per_od := dDatOd
_per_do := dDatDo

// dodaj na ulazni pdv pdv iz predhodog perioda !!!
nUkUlPdv += _u_pdv_pp
// na stavku 41, nema se gdje drugo dodati !?! ovo su glupo rijesili
// sto su izbacili kolonu iz predhodnog perioda
_u_pdv_41 += _u_pdv_pp

_u_pdv_uk := nUkUlPdv 

_i_pdv_uk := nUkIzPdv 

zaok_p_pdv()

nPdvSaldo := _i_pdv_uk -  _u_pdv_uk 
_pdv_uplatiti := nPdvSaldo

Gather()

SELECT KIF
use

Beep(1)


BoxC()


return

// ------------------------------------
// ------------------------------------
static function zaok_p_pdv()

_u_nab_21 := ROUND(_u_nab_21, ZAO_PDV())
_u_uvoz := ROUND(_u_uvoz, ZAO_PDV())
_u_nab_23 := ROUND(_u_nab_23, ZAO_PDV())


_u_pdv_41 := ROUND(_u_pdv_41, ZAO_PDV())
_u_pdv_uv := ROUND(_u_pdv_uv, ZAO_PDV())
_u_pdv_43 := ROUND(_u_pdv_43, ZAO_PDV())


_i_opor := ROUND(_i_opor, ZAO_PDV())
_i_izvoz := ROUND(_i_izvoz, ZAO_PDV())
_i_neop := ROUND(_i_neop, ZAO_PDV())


_i_pdv_r := ROUND(_i_pdv_r, ZAO_PDV())

_i_pdv_nr1 := ROUND(_i_pdv_nr1, ZAO_PDV())
_i_pdv_nr2 := ROUND(_i_pdv_nr2, ZAO_PDV())
_i_pdv_nr3 := ROUND(_i_pdv_nr3, ZAO_PDV())
_i_pdv_nr4 := ROUND(_i_pdv_nr4, ZAO_PDV())

_u_pdv_uk := ROUND(_u_pdv_uk, ZAO_PDV()) 
_i_pdv_uk := ROUND(_i_pdv_uk, ZAO_PDV()) 
//_pdv_uplatiti := ROUND(_pdv_uplatiti, ZAO_PDV()) 

return

// ------------------------------------
// ------------------------------------
static function f_iz_pdv()

SELECT F_PDV

if !used()
	O_PDV
endif

SET ORDER TO TAG "period"
// "period","DTOS(per_od)+DTOS(per_do)"

// pronadji ovaj obracun
SEEK DTOS(dDatOd) + DTOS(dDatDo)

if !found()
	Beep(2)
	MsgBeep("Ne postoji pohranjen PDV obracun #"+;
	   "za period " + CTOD(dDatOd) + "-" + CTOD(dDatDo) )
	use
	return
endif


// kreiraj r_pdv zapis
O_R_PDV
APPEND BLANK

SELECT (F_PDV)
// setuj mem vars
Scatter()

SELECT (F_R_PDV)
// zapisi u report
Gather()

SELECT (F_PDV)
use


return

// ---------------------------------------
// prikaz pdv prijava
// ---------------------------------------
static function show_rpt()

local nLenUk
local nPom1
local nPom2

nCurrLine := 0

START PRINT CRET
?
nPageLimit := 65

nRow := 0

r_zagl()

SELECT r_pdv
SET ORDER TO TAG "1"
go top


P_COND
? 
?? rpt_lm()
?? PADL( "Obrazac P PDV, ver 01.12", RPT_COL * 2 + RPT_GAP )

?
?? rpt_lm()
?? PADC( " ", RPT_COL * 2 + RPT_GAP )
?? rpt_lm()

?
P_10CPI

P_10CPI
?? SPACE(10)
?? PADC( "P D V   P R I J A V A", ROUND((RPT_COL * 2 + RPT_GAP)/2, 0) )

B_OFF

show_raz_1()

P_12CPI

?? rpt_lm()
?? "1. Identifikacioni broj : " 
?? id_br

?? SPACE(6)
?? "2. Period : "
?? per_od 
?? " - " 
?? per_do

show_raz_1()

?? rpt_lm()
?? "3. Naziv poreskog obveznika : "
?? po_naziv

show_raz_1()

?? rpt_lm()
?? "4. Adresa : " 
?? po_adresa

show_raz_1()

?? rpt_lm()
?? "5. Postanski broj/Mjesto : "
?? po_ptt
?? " / "
?? po_mjesto

show_raz_1()

P_COND

? 
?? rpt_lm()
B_ON
U_ON
?? PADR("I. Isporuke i nabavke (iznosi bez PDV-a)", RPT_COL - RPT_BOLD_DELTA)
U_OFF
B_OFF

show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)

cPom := PADR("11. Oporezive isporuke, osim onih u 12 i 13 ", RPT_W2) + TRANSFORM(i_opor, PIC_IZN())
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
cPom := PADR("21. SVE nabavke osim 22 i 23 ", RPT_W2) + TRANSFORM(u_nab_21, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)


// razmak izmedju dva reda -----------------------------------------
show_raz_1()
?? rpt_lm()
// 12
cPom := PADR("12. Vrijednost izvoza ", RPT_W2) + TRANSFORM(i_izvoz, PIC_IZN())
// sirina kolone - indent
?? SPACE(RPT_RI)
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

// 22
?? SPACE(RPT_RI)
cPom := PADR("22. Vrijednost uvoza ", RPT_W2) + TRANSFORM(u_uvoz, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)


// razmak izmedju dva reda -----------------------------------------
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)

// 13
cPom := PADR("13. Isp. oslobodjene PDV-a ", RPT_W2) + TRANSFORM(i_neop, PIC_IZN())
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
// 23
cPom := PADR("23. Vrijednost nab. od poljoprivrednika ", RPT_W2) + TRANSFORM(u_nab_23, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)



// -------------------- II dio izvjestaja ----------------------------------

show_raz_1()

?
?? rpt_lm()

B_ON
U_ON
?? PADR("II. Izlazni PDV", RPT_COL - RPT_BOLD_DELTA )
U_OFF
B_OFF

?? SPACE(RPT_GAP)
B_ON
U_ON
?? PADL("Ulazni PDV  ", RPT_COL - RPT_BOLD_DELTA)
U_OFF
B_OFF

show_raz_1()
?
?? rpt_lm()
?? SPACE(RPT_RI)

B_ON
?? PADR(" ", RPT_COL - RPT_RI)
B_OFF
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)

B_ON
?? PADR("PDV obracunat na ulaze (dobra i usluge)", RPT_COL - RPT_RI)
B_OFF


// razmak izmedju dva reda -----------------------------------------
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)
// 31
cPom := " "
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
// 41
cPom := PADR("41. Od reg. PDV obveznika osim 42 i 43", RPT_W2) + TRANSFORM(u_pdv_41, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju dva reda -----------------------------------------
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)

cPom := " "
// sirina kolone - indent
?? PADR(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
// 42
cPom := PADR("42. PDV na uvoz ", RPT_W2) + TRANSFORM(u_pdv_uv, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju dva reda -----------------------------------------
show_raz_1()
?? rpt_lm()
?? SPACE(RPT_RI)
// 34
cPom := ""
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
cPom := PADR("43. Pausalna naknada za poljoprivrednike ", RPT_W2) + TRANSFORM(u_pdv_43, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI + 1)


// razmak izmedju dva reda -----------------------------------------
show_raz_1()
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)
cPom :=  PADR("51. PDV obracunat na izlaz (dobra i usluge) ",  RPT_W2 - RPT_BOLD_DELTA ) + TRANSFORM(i_pdv_uk, PIC_IZN())
// sirina kolone - indent
B_ON
?? PADL(cPom, RPT_COL - RPT_RI - RPT_BOLD_DELTA + 1 )
B_OFF

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
// 61
B_ON
cPom := PADR("61. Ulazni PDV (ukupno) ", RPT_W2 - RPT_BOLD_DELTA ) + TRANSFORM(u_pdv_uk, PIC_IZN())
?? PADL(cPom, RPT_COL - RPT_RI - RPT_BOLD_DELTA + 1)
B_OFF

// razmak izmedju dva reda -----------------------------------------
show_raz_1()
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)
// 71
cPom := PADR("71. Obaveza PDV-a za uplatu/povrat ", RPT_W2 - RPT_BOLD_DELTA ) + TRANSFORM(pdv_uplatiti, PIC_IZN())
// sirina kolone - indent
B_ON
?? PADL(cPom, RPT_COL - RPT_RI - RPT_BOLD_DELTA + 1)
B_OFF

// razmak izmedju kolona
?? SPACE(RPT_GAP)

?? SPACE(RPT_RI)
// 72
cPom := PADR("80. Zahtjev za povrat ", RPT_W2 - RPT_BOLD_DELTA - 5 ) + " <" +iif(pdv_povrat == "D", "X", " ") + ">" 
B_ON
?? PADL(cPom, RPT_COL - RPT_RI - RPT_BOLD_DELTA  + 1)
B_OFF


// -------------------- III dio izvjestaja ----------------------------------

show_raz_1()

?
?? rpt_lm()

B_ON
U_ON
?? PADR("III. STATISTICKI PODACI", RPT_COL - RPT_BOLD_DELTA )
U_OFF
B_OFF

show_raz_1()
?? rpt_lm()
?? SPACE(RPT_RI)
cPom := "PDV isporuke licima koji nisu reg. PDV obveznici u:"
// sirina kolone - indent
?? cPom

show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)
cPom := PADR("32. Federacije BiH ", RPT_W2) + TRANSFORM(i_pdv_nr1, PIC_IZN())
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)


// razmak izmedju dva reda -----------------------------------------
show_raz_1()

?? rpt_lm()
?? SPACE(RPT_RI)
cPom := PADR("33. Republike Srpske ", RPT_W2) + TRANSFORM(i_pdv_nr2, PIC_IZN())
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)


// razmak izmedju dva reda -----------------------------------------
show_raz_1()
?? rpt_lm()
?? SPACE(RPT_RI)
// 34
cPom := PADR("34. Brcko Distrikta ", RPT_W2) + TRANSFORM(i_pdv_nr3, PIC_IZN())
// sirina kolone - indent
?? PADL(cPom, RPT_COL - RPT_RI + 1)



// ----- kraj obrasca  -----------------------------------------


show_raz_1()
show_raz_1()


?? rpt_lm()
?? "Pod krivicnom i materijalnom odgovornoscu potvrdjujem da su podaci u PDV prijavi potuni i tacni"

show_raz_1()
show_raz_1()

?? rpt_lm()
?? "Mjesto : "
U_ON

cPom := ALLTRIM(pot_mjesto)
?? PADC( cPom , LEN(pot_mjesto))
U_OFF

?? SPACE(35)
?? "Potpis obveznika"

show_raz_1()

?? rpt_lm()

?? "Datum : "
U_ON
?? pot_datum
U_OFF

?? SPACE(50)
U_ON
cPom:= ALLTRIM(pot_ob)
?? PADC(cPom, 55)
U_OFF

show_raz_1()
?? rpt_lm()
?? SPACE(86)
?? "Ime, prezime"


FF
END PRINT
return
*}

// -----------------------------
// -----------------------------
static function show_raz_1()
?
?
return

// ----------------------------
// ----------------------------
static function r_zagl()

// header
P_COND
B_ON
for i:=1 to LEN(aHeader)
 ? aHeader[i]
 ++nCurrLine
next
B_OFF

P_COND2


for i:=1 to LEN(aZagl)
 ++nCurrLine
 ?
 for nCol:=1 to LEN(aZaglLen)
  	// mergirana kolona ovako izgleda
	// "#3 Zauzimam tri kolone"
 	if LEFT(aZagl[i, nCol],1) = "#" 
	  
	  nMergirano := VAL( SUBSTR(aZagl[i, nCol], 2, 1 ) )
	  cPom := SUBSTR(aZagl[i,nCol], 3, LEN(aZagl[i,nCol])-2)
	  nMrgWidth := 0
	  for nMrg:=1 to nMergirano 
	  	nMrgWidth += aZaglLen[nCol+nMrg-1] 
		nMrgWidth ++
	  next
	  ?? PADC(cPom, nMrgWidth)
	  ?? " "
	  nCol += (nMergirano - 1)
	 else
 	  ?? PADC(aZagl[i, nCol], aZaglLen[nCol])
	  ?? " "
	 endif
 next
next

return

// -----------------------------------
// lijeva margina
// ------------------------------------
static function rpt_lm()
return SPACE(RPT_LM)



