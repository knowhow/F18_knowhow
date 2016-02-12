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


function RobaIdSredi()
cSifOld:=space(10)
cSifNew:=space(10)

if !spec_funkcije_sifra("spec_funkcije_sifra")
  return
endif

O_ROBA
O_KALK
  O_FAKT
  fSrediF:=.t.

Box(,10,60)

do while .t.
	@ m_x+6,m_y+2 SAY "                 "
	@ m_x+1,m_Y+2 SAY "ISPRAVKA SIFRE ARTIKLA U DOKUMENTIMA"
	@ m_x+2,m_Y+2 SAY "Stara sifra:" GET cSifOld pict "@!"
	@ m_x+3,m_Y+2 SAY "Nova  sifra:" GET cSifNew pict "@!" valid !empty(cSifNew)
	read
	ESC_BCR

	if !(kalk->(flock())) .or. !(fakt->(flock())) .or. !(roba->(flock()))
		Msg("Ostali korisnici ne smiju raditi u programu")
		closeret
	endif

	select kalk
	locate for idroba==cSifNew
	
	if found()
		BoxC()
		Msg("Nova sifra se vec nalazi u prometu. prekid !")
		closeret
	endif

	locate for idroba==cSifOld
	nRbr:=0

	do while found()
		_field->idroba:=cSifNew
		@ m_X+5,m_y+2 SAY ++nRbr pict "999"
		continue
	enddo

	if fSrediF
		select fakt
		locate for idroba==cSifOld
		nRbr:=0
		do while found()
			@ m_X+5,m_y+2 SAY ++nRbr pict "999"
			_field->idroba:=cSifNew
			continue
		enddo
	endif

	select roba
	locate for id==cSifOld
	nRbr:=0
	do while found()
		@ m_X+5,m_y+2 SAY ++nRbr pict "999"
		_field->id:=cSifNew
		continue
	enddo
	Beep(2)
	@ m_x+6,m_y+2 SAY "Sifra promijenjena"
enddo //.t.

BoxC()
closeret


function kalk_sljedeci(cIdFirma,cVrsta)
local cBrKalk
if gBrojac=="D"
 select kalk
 set order to tag "1"
 seek cIdFirma+cVrsta+"X"
 skip -1
 if idvd<>cVrsta
   cBrKalk:=space(8)
 else
   cBrKalk:=brdok
 endif
 cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif
return cBrKalk


