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


/*! \fn OStUndo()
 *  \brief Otvorene stavke - UNDO operacija
 */
function OStUndo()

if !SigmaSif("SCUNDO")
	MsgBeep("Nemate ovlastenja za koristenje ove operacije!")
	return
endif

MsgBeep("Prije ove operacije obavezno arhivirati podatke!")

dDatOd:=CToD("")
dDatDo:=DATE()
cPartn:=SPACE(6)
cKonto:="2120"
cVNal:=PADR("61;",40)
cDp:="1"

O_SUBAN
select suban

cKonto:=PADR(cKonto, LEN(suban->idkonto))
cPartn:=PADR(cPartn, LEN(suban->idPartner))

// setuj parametre
if GetVars(@dDatOd, @dDatDo, @cPartn, @cKonto, @cDp, @cVNal) == 0
	MsgBeep("Operacija prekinuta !!!")
	return
endif

// pokreni undo opciju
OStRunUndo(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)

if Pitanje(,"Pokrenuti opciju automatskog zatvaranja stavki?","D")=="D"
	fin_automatsko_zatvaranje_otvorenih_stavki(.t., cKonto, cPartn)
endif

return



/*! \fn GetVars(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)
 *  \brief Setuj parametre
 */
static function GetVars(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)

O_PARTN
O_KONTO

Box(,5,60)
	@ m_x+1,m_y+2 SAY "Datum od" GET dDatOd 
	@ m_x+1,m_y+21 SAY "do" GET dDatDo 
	@ m_x+2,m_y+2 SAY "Konto   " GET cKonto VALID P_KontoFin(@cKonto) PICT "@!"
  	@ m_x+3,m_y+2 SAY "Partner (prazno-svi)" GET cPartn VALID EMPTY(cPartn) .or. P_Firma(@cPartn) PICT "@!"
  	@ m_x+4,m_y+2 SAY "Konto duguje / potrazuje" GET cDp WHEN {|| cDp:=iif(cKonto='54','2','1'), .t.} VALID cDp$"12 "
  	@ m_x+5,m_y+2 SAY "Vrste naloga" GET cVNal 
  	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

return 1



/*! \fn OStRunUndo()
 *  \brief glavna funkcija obrade dokumenta 
 */
static function OStRunUndo(dDOd, dDDo, cIdPartn, cIdKonto, cDugPot, cVNal)
local _rec

select suban
set order to tag "1"
go top

if !Empty(cIdPartn)
	seek gFirma + cIdKonto + cIdPartn
else
	seek gFirma + cIdKonto
endif

cBrNal:=""
cTipNal:=""
cKupac:=""

Box(, 3, 70)

do while !EOF() .and. field->idkonto=cIdKonto .and. field->datdok <= dDatDo .and. if(!Empty(cIdPartn), field->idpartner=cIdPartn, .t.)

	// uzmi broj prvog naloga
	cBrNal := field->brnal
	cTipNal := field->idvn
	cKupac := field->idpartner

	select partn
	hseek cKupac

	select suban
	
	@ 1+m_x, 2+m_y SAY "Partner: " + partn->naz
	
	// ako tip naloga nije u zadatim tipovima naloga
	if AT(cTipNal, cVNal)==0
		skip
		loop
	endif
	
	nIznBhd := 0
	nIznDem := 0
	
	@ 2+m_x, 2+m_y SAY "Nalog: " + gFirma + "-" + cTipNal + "-" + ALLTRIM(cBrNal)
	
	do while !EOF() .and. field->idkonto=cIdKonto .and. field->idpartner=cKupac .and. field->datdok <= dDatDo .and. field->brnal=cBrNal .and. field->idvn=cTipNal
		
		do case
			case cDugPot == "1"
				// varijanta duguje
				if (field->d_p == "1")
					skip
				endif
				
			case cDugPot == "2"
				// varijanta potrazuje
				// uplate
				if (field->d_p == "2")
					skip
				endif
		endcase
		
		nIznBhd += field->iznosbhd
		nIznDem += field->iznosdem
		
		@ 3+m_x, 2+m_y SAY SPACE(50)
		@ 3+m_x, 2+m_y SAY "Suma += " + ALLTRIM(STR(nIznBhd))
		
		skip
		
        f18_lock_tables({"fin_suban"})		
		sql_table_update( nil, "BEGIN" )
		
		// ako je sljedeci nalog razlicit, updateuj postojeci sa sumom
		if (field->brnal<>cBrNal .or. field->idvn <> cTipNal)

			skip -1

			_rec := dbf_get_rec()

			_rec["iznosbhd"] := nIznBhd
			_rec["iznosdem"] := nIznDem
			_rec["brdok"] := ""
			_rec["otvst"] := ""

			update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

			skip

		else

			// izbrisi prethodnu stavku
			skip -1

			_rec := dbf_get_rec()
			delete_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

			skip

		endif
			
        f18_free_tables({"fin_suban"})		
		sql_table_update( nil, "END" )

	enddo

enddo

BoxC()

MsgBeep("Opcija zavrsena!#Pogledajte rezultate...")

return



/*! \fn OStAfterAzur(cIdPart, cIdKonto, cDp)
 *  \brief Pokrece asistenta otvorenih stavki poslije azuriranja naloga
 */
function OStAfterAzur(aPartList, cIdPart, cIdKonto, cDp)
return



