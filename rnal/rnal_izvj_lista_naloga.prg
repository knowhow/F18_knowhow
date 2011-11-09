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


#include "rnal.ch"



// --------------------------------------------------
// lista naloga otvorenih na tekuci dan
// --------------------------------------------------
function lst_tek_dan()
local cLine
local nOperater
local GetList:={}

O_DOCS
O_CUSTOMS
O_CONTACTS

nOperater := GetUserID()

Box( , 1, 60)
	@ m_x + 1, m_y + 2 SAY "Operater (0 - svi)" GET nOperater PICT "999"
	read
BoxC()

select docs
set order to tag "D1"
go top

seek DTOS( DATE() )

r_l_get_line( @cLine )

START PRINT CRET

?
? "Lista naloga otvorenih na tekuci dan " + DTOC( DATE() )

?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_date) == DTOS( DATE() )
	
	// ako je za tekuæeg operatera
	if nOperater <> 0
		if field->operater_id <> nOperater
			skip
			loop
		endif
	endif

	// ako je nalog zatvoren, preskoci
	if (field->doc_status == 1 ) .or. ( field->doc_status == 2 )
		skip
		loop
	endif

	
	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return

// ---------------------------------------------------
// prikaz partnera / kontakta
// ---------------------------------------------------
static function show_customer( nCust_id, nCont_id )
local cRet
local cCust
local cCont

cCust := ALLTRIM( g_cust_desc( nCust_id ) )
cCont := ALLTRIM( g_cont_desc( nCont_id ) )

cRet := cCust

if !EMPTY( cCont ) .and. cCont <> "?????"
	cRet += " / " + cCont
endif

return cRet



// ------------------------------------
// zaglavlje liste
// ------------------------------------
static function r_list_zagl()
local cLine
local cText

r_l_get_line(@cLine)

cText := PADC("Br.naloga", 10)
cText += " "
cText += PADC("Dat.isp", 8)
cText += " "
cText += PADC("Vri.isp", 8)
cText += " "
cText += PADR("Narucioc / kontakt - naziv", 60)

? cLine
? cText
? cLine

return


// ---------------------------------------
// vraca liniju za zaglavlje
// ---------------------------------------
static function r_l_get_line(cLine)
cLine := REPLICATE("-", 10)
cLine += " "
cLine += REPLICATE("-", 8)
cLine += " "
cLine += REPLICATE("-", 8)
cLine += " "
cLine += REPLICATE("-", 60)
return


// --------------------------------------------------
// lista naloga od izabranog datuma 
// --------------------------------------------------
function lst_ch_date()
local cLine
local dDate := DATE()
local nOperater

nOperater := GetUserID()

Box(, 3, 60)
	
	@ m_x + 1, m_y + 2 SAY "Operater (0 - svi)" GET nOperater PICT "999"
	
	@ m_x + 3, m_y + 2 SAY "Listaj naloge >= datum" GET dDate
	
	read

BoxC()

if LastKey() == K_ESC
	return
endif

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D1"
go top

seek DTOS( dDate )

r_l_get_line( @cLine )

START PRINT CRET

?
? "Lista naloga >= datumu: " + DTOC( dDate )

?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_date) >= DTOS( dDate )
	
	// operater uslov
	if nOperater <> 0 
		if field->operater_id <> nOperater
			skip
			loop
		endif
	endif

	
	// ako je nalog zatvoren, preskoci
	if (field->doc_status == 1 ) .or. ( field->doc_status == 2 )
		
		skip
		loop
	
	endif
	
	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return




// ---------------------------------------------------------
// lista naloga prispjelih za realizaciju na tekuci dan
// ---------------------------------------------------------
function lst_real_tek_dan()
local cLine
local nOperater
local cCurrent := "D"
local GetList:={}

O_DOCS
O_CUSTOMS
O_CONTACTS

nOperater := GetUserID()

Box(, 3, 60)
	@ m_x + 1, m_y + 2 SAY "Operater (0 - svi)" GET nOperater PICT "999" 
	@ m_x + 3, m_y + 2 SAY "Nalozi prispjeli samo na tekuci dan ?" GET cCurrent PICT "@!" VALID cCurrent $ "DN"
	read
BoxC()

select docs
set order to tag "D2"
go top

seek DTOS( DATE() )

r_l_get_line(@cLine)

START PRINT CRET

?
? "Lista naloga prispjelih za realizaciju na tekuci dan " + DTOC( DATE() )
?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_dvr_date) >= DTOS( DATE() )
	
	// uslov po operateru
	if nOperater <> 0 
		if field->operater_id <> nOperater
			skip
			loop
		endif
	endif
	
	// samo tekuci dan!
	if cCurrent == "D"
		if DTOS(field->doc_dvr_date) <> DTOS(DATE())
			skip
			loop
		endif
	endif
	
	// ako je zatvoren, preskoci..
	if field->doc_status == 1 .or. ;
		field->doc_status == 2
		skip
		loop
	endif

	nDoc_no := field->doc_no

	cPom := ""
	cPom += PADR( docno_str(nDoc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom

	
	select docs 

	skip
enddo

? cLine

FF
END PRINT

return



// ---------------------------------------------------------
// lista naloga van roka na tekuci dan
// ---------------------------------------------------------
function lst_vrok_tek_dan()
local cLine
local nDoc_no
local cLog
local nDays := 0
local nOperater
local cEmail := "N"
local i
local aLog
local cPrinter

nOperater := GetUserID()

Box(, 5, 65)
	
	@ m_x + 1, m_y + 2 SAY "Operater (0 - svi)" GET nOperater PICT "999"
	
	@ m_x + 3, m_y + 2 SAY "Uzeti u obzir do br.predh.dana:" GET nDays PICT "99999"
	
	@ m_x + 5, m_y + 2 SAY "Slati report email-om ?" GET cEmail PICT "@!" VALID cEmail $ "DN"
	
	read

BoxC()


O_DOCS
O_DOC_LOG
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D2"
go top

r_l_get_line(@cLine)

// printer setuj na 0, radi sekvenci
if cEmail == "D"
	
	cPrinter := gPrinter
	gPrinter := "0"
	
endif

START PRINT CRET

?
? "Lista naloga van roka na tekuci dan " + DTOC( DATE() )
?

r_list_zagl()

do while !EOF()
	
	// uslov po operateru
	if nOperater <> 0
		if field->operater_id <> nOperater
			skip
			loop
		endif
	endif
	
	// ako je realizovan, preskoci
	if field->doc_status == 1 .or. ;
		field->doc_status == 2
		skip
		loop
	endif

	// ako je u datum isti ili manji, preskoci...
	if DATE() <= field->doc_dvr_date 
		
		skip
		loop
		
	endif

	// uzeti filter i za dane unazad....
	if nDays <> 0
	
		if ( DATE() - nDays ) <= doc_dvr_date
			
			skip
			loop
			
		endif
		
	endif

	nDoc_no := field->doc_no

	cPom := ""
	cPom += PADR( docno_str(nDoc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	
	// drugi red uzmi iz log-a

	select doc_log
	set order to tag "1"
	go top

	seek docno_str( nDoc_no )

	cLog := ""
	
	do while !EOF() .and. field->doc_no == nDoc_no
		
		cLog := DTOC( field->doc_log_date ) 
		cLog += " / " 
		cLog += ALLTRIM( field->doc_log_time )
		cLog += " : "
		cLog += ALLTRIM( field->doc_log_desc )
		
		skip
	enddo
	
	// samo za log, koji nije inicijalni....
	if "Inicij" $ cLog
		cLog := ""
	endif

	// ispisi log 
	if !EMPTY( cLog )
		
		aLog := SjeciStr( cLog, 60 ) 
		
		for i := 1 to LEN( aLog )
			
			? SPACE(29) + aLog[ i ]
		
		next
		
	endif

	// vrati se na docs i idi dalje
	select docs
	skip
enddo

? cLine

FF
END PRINT

// posalji na email
if cEmail == "D"
	
	// vrati stanje printera
	gPrinter := cPrinter
	
	// posalji email
	send_eml()

endif

return


