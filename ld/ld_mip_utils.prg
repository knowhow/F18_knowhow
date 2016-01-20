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


#include "f18.ch"


// --------------------------------------------
// pregled tabele za MIP obrazac
// --------------------------------------------
function MIP_View()
private Kol
private ImeKol

select r_export
go top

ImeKol := {}

AADD(ImeKol,{ "Radnik", {|| idradn } })
AADD(ImeKol,{ "RJ", {|| idrj } })
AADD(ImeKol,{ PADR("Period",7), {|| STR(godina,4) + "/" + STR(mjesec,2) } })
AADD(ImeKol,{ "V.Ispl", {|| PADR( vr_ispl, 2 ) } })
AADD(ImeKol,{ "Opcina", {|| PADR( r_opc, 3 ) } })
AADD(ImeKol,{ "Sati", {|| r_sati } })
AADD(ImeKol,{ "Sati b.", {|| r_satib } })
AADD(ImeKol,{ "Bruto", {|| bruto } })
AADD(ImeKol,{ "print", {|| print }, "print", {|| .t.}, {|| .t.} })

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)

@ m_x+17,m_y+2 SAY "<F2> Ispravi stavku                           "
@ m_x+18,m_y+2 SAY "<c-T> Brisi stavku     "
@ m_x+19,m_y+2 SAY "<SPACE> markiraj stavku za stampu"
@ m_x+20,m_y+2 SAY "               "

ObjDbedit("R_EXPORT",20,77,{|| EdMIP()},"","Pregled tabele za gen.mip obrasca", , , , {|| if(bol_preko == "1", .t., .f.) } , 4)

BoxC()

return


// ----------------------------------------
// edit mip
// ----------------------------------------
static function EdMIP()

// prikazi na vrhu radnika
show_radnik()

do case

	case Ch==K_CTRL_T 
		// brisanje stavke iz pregleda
      		if Pitanje(,"Sigurno zelite izbrisati zapis ?", "N") == "D"
			delete
		endif
		return DE_REFRESH
	
	case Ch==K_F2 
		// ispravi stavku
		return EditItem()

	case Ch==ASC(" ") .or. Ch==K_ENTER
		
		if EMPTY( field->print )
			replace field->print with "X"
		else
			replace field->print with ""
		endif

		return DE_REFRESH

endcase

return DE_CONT



// ----------------------------------------
// ispravka stavke
// ----------------------------------------
static function edititem()
local nX := 1

scatter()

Box(,20,70)
	
	@ m_x + nX, m_y + 2 SAY ALLTRIM(_idradn) + " - " + ;
		PADR( _r_ime, 30 )

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "'kod' opcine" GET _r_opc PICT "@S3"

	++ nX

	@ m_x + nX, m_y + 2 SAY "vrsta isplate" GET _vr_ispl PICT "@S10"

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "sati" GET _r_sati
	@ m_x + nX, col() + 1 SAY "sati bolov." GET _r_satib

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "bruto" GET _bruto
	@ m_x + nX, col() + 1 SAY "opor.prih." GET _u_opor
	
	++ nX 
	++ nX 

	@ m_x + nX, m_y + 2 SAY "dopr.pio" GET _u_d_pio
	@ m_x + nX, col() + 1 SAY "dopr.zdr" GET _u_d_zdr
	@ m_x + nX, col() + 1 SAY "dopr.nez" GET _u_d_nez
	
	++ nX 
	
	@ m_x + nX, m_y + 2 SAY "uk.dopr.iz" GET _u_d_iz

	++ nX
	++ nX

	@ m_x + nX, m_y + 2 SAY "licni odbici" GET _l_odb

	++ nX
	++ nX 

	@ m_x + nX, m_y + 2 SAY "osnovica poreza" GET _osn_por
	@ m_x + nX, col() + 1 SAY "porez" GET _izn_por
	
	read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

gather()

return DE_REFRESH


// --------------------------------------------
// prikaz radnika na vrhu forme
// --------------------------------------------
static function show_radnik()
@ 2, 2 SAY PADR(field->r_ime, 30) + ;
	"(" + ALLTRIM(field->r_jmb) + ")"
return


