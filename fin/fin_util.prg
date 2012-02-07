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


// ----------------------------------
// fix brnal
// ----------------------------------
function _f_brnal( cBrNal )

if RIGHT( ALLTRIM( cBrNal ), 1 ) == "*"
    cBrNal := STRTRAN( cBrNal, "*", "" )
    cBrNal := PADL( ALLTRIM( cBrNal ), 8 )
elseif LEFT( ALLTRIM( cBrNal ), 1 ) == "*"
    cBrNal := STRTRAN( cBrNal, "*", "" )
    cBrNal := PADR( ALLTRIM( cBrNal ), 8 )
else
    if !EMPTY( ALLTRIM(cBrNal) ) .and. LEN(ALLTRIM(cBrNal)) < 8
	    cBrNal := PADL( ALLTRIM(cBrNal), 8, "0" )
    endif
endif

return .t.


/*! \fn Izvj0()
 *  \brief
 */
function Izvj0()

Izvjestaji()

return


/*! \fn PovratNaloga()
 *  \brief Povrat naloga
 */
function PovratNaloga()

//if gBezVracanja == "N"
povrat_fin_naloga()
//endif

return


/*! \fn Preknjizenje()
 *  \brief preknjizenje
 */
function Preknjizenje()

cSecur := SecurR(KLevel,"Preknjiz")
cSecur2 := SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
	MsgBeep("Opcija nedostupna !")
else
	Prefin_unos_naloga()
endif
return


/*! \fn Prebfin_kartica()
 *  \brief Prebacivanja kartica
 */
function Prebfin_kartica()
//cSecur:=SecurR(KLevel,"Prekart")
//cSecur2:=SecurR(KLevel,"SGLEDAJ")
//if ImaSlovo("TX",cSecur) .or. ImaSlovo("D",cSecur2)
//	MsgBeep("Opcija nedostupna !")
//else
	fin_prekart()
//endif
return


/*! \fn GenPocStanja()
 *  \brief generacija pocetnog stanja
 */
function GenPocStanja()
PrenosFin()
return


/*! \fn ImaUSubanNemaUNalog()
 *  \brief Ispituje da li nalog postoji u SUBAN ako ga nema u NALOG
 */
function ImaUSubanNemaUNalog()

Box(,5,60)
close all
select 1
use nalog
set order to tag "1"
select 2
use suban
set order to 0
select 3
use anal
set order to 0
select 4
use sint
set order to 0
for i:=1 to 3
	if i==1
		cAlias:="SUBAN"
	elseif i==2
		cAlias:="ANAL"
	else
		cAlias:="SINT"
	endif
	select &cAlias
	go top
	do while !eof().and. inkey()!=27
		select nalog
		seek &cAlias->(idfirma+idvn+brnal)
		if !found()
			select &cAlias
			Beep(1)
			@ m_x+5,m_y+2 SAY  "nema naloga! "
			?? idfirma+"-"+idvn+"-"+brnal
			Inkey(0)
			@ m_x+5,m_y+2 SAY  "             "
		else
			@ m_x+3,m_y+2 SAY idfirma+"-"+idvn+"-"+brnal
		endif
		select &cAlias
		@ m_x+1,m_y+2 SAY recno()
		?? calias
		skip 1
	enddo
next
BoxC()
close all
return


// ----------------------------------
// storniranje naloga
// ----------------------------------
function StornoNaloga()
Povrat_fin_naloga(.t.)
return


// ---------------------------------------------
// vraca unos granicnog datuma za report
// ---------------------------------------------
static function _g_gr_date()
local dDate := DATE()

Box(,1, 45)
	@ m_x + 1, m_y + 2 SAY "Unesi granicni datum" GET dDate
	read
BoxC()

if LASTKEY() == K_ESC
	return nil
endif

return dDate



// ----------------------------------------------------------------
// report sa greskama sa datumom na nalozima izazvanim opcijom
// "Unos datuma naloga = 'D'"
// 
// ----------------------------------------------------------------
function daterr_rpt()

local __brnal
local __idfirma
local __idvn
local __t_date

local dSubanDate

local nTotErrors := 0

local nNalCnt := 0

local nMonth

local nSubanKto

local nGrDate

local nGrMonth

local nGrSaldo := 0

close all

O_SUBAN
select suban 
set order to tag "10"
// idfirma+idvn+brnal+idkonto+datdok

O_ANAL
select anal
set order to tag "2"

O_NALOG
select nalog
set order to tag "1"
go top

// granicni datum
dGrDate := nil

if pitanje(,"Gledati granicni datum ?", "N") == "D"
	dGrDate := _g_gr_date()
endif

start print cret

? "------------------------------------------------"
? "Lista naloga sa neispravnim datumima:"
? "------------------------------------------------"
? "       broj           datum    datum    datum   "
? " R.br  naloga         naloga   suban.   anal.   "
? "                               prva.st  prva.st "
? "------ ------------- -------- -------- -------- "

do while !EOF()

	// init. variables
	
	__idfirma := field->idfirma
	__brnal := field->brnal
	__idvn := field->idvn

	// datum naloga
	__t_date := field->datnal

	++ nNalCnt 

	// provjeri suban.dbf

	select suban
	go top
	seek __idfirma + __idvn + __brnal
	
	if !FOUND()
	
		select nalog
		skip
		loop
		
	endif
	
	dSubanDate := field->datdok

	// 1. provjeri prvo da li je razlicit datum naloga i subanalitike

	if __t_date <> dSubanDate
	
		// uzmi datum sa prve stavke subanilitike
		
		cSubanKto := field->idkonto
		nMonth := MONTH( field->datdok )
		
		do while !EOF() .and. field->idfirma == __idfirma ;
				.and. field->idvn == __idvn ;
				.and. field->brnal == __brnal ;
				.and. field->idkonto == cSubanKto

			if MONTH(field->datdok) == nMonth
				dSubanDate := field->datdok
			endif
						
			skip
			
		enddo
		
		
		// provjeri analitiku

		select anal
		go top
		seek __idfirma + __idvn + __brnal

		if !FOUND()
			select nalog 
			skip
			loop
		endif
		
		if field->datnal <> dSubanDate
		
			++ nTotErrors
			
			? STR(nTotErrors, 5) + ") " + __idfirma + "-" + ;
				__idvn + "-" + ALLTRIM(__brnal), __t_date, dSubanDate, field->datnal
			
		
		endif
		
	
	endif
		
	
	// 2. provjeri granicni datum

	if dGrDate <> nil
		
		select suban
		go top
		seek __idfirma + __idvn + __brnal
		
		lManji := .f.
		lVeci := .f.


		// mjesec granicnog datuma
		nGrMonth := MONTH( dGrDate )
		
		// to znaci da nalog mora da sadrzi samo taj mjesec ili manji
		
		// prodji po nalogu....
		do while !EOF() .and. suban->(idfirma+idvn+brnal) == ;
			(__idfirma + __idvn + __brnal)

			// ako u subanalitici ima manji datum od 
			// granicnog datuma
			if suban->datdok <= dGrDate
				
				lManji := .t.
			
				// saldiraj ga
				if suban->d_p == "1"
					nGrSaldo += suban->iznosbhd
				else
					nGrSaldo -= suban->iznosbhd
				endif
			
			endif

			// ako u subanalitici ima veci datum od
			// granicnog datuma i iskace iz mjeseca
			if suban->datdok > dGrDate .and. ;
				MONTH(suban->datdok) > nGrMonth
				
				lVeci := .t.
			endif
			
			skip
			
		enddo
		
		// ako unutar jednog naloga ima i veci i manji datum od
		// granicnog datuma pretpostavljamo da je to error
		
		if lManji == .t. .and. lVeci == .t.
				
			++ nTotErrors
			
			? STR(nTotErrors, 5) + ") " + __idfirma + "-" + ;
				__idvn + "-" + ALLTRIM(__brnal), ;
				nalog->datnal, "ERR: granicni datum"
	
		endif
		
	endif
	

	select nalog
	skip
	
enddo

if nTotErrors == 0
	?
	? "   !!!!! Nema gresaka !!!!!"
	?
endif

if dGrDate <> nil .and. nGrSaldo <> 0

	?
	? " Razlika utvrdjena po granicnom datumu =", STR( nGrSaldo, 12, 2) 
	?

endif

ff
end print

close all

return





