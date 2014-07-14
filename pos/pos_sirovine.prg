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

 
function GenUtrSir(dDatOD,dDatDo,cSmjena)
*{
local cIdPos
private fTekuci

if cSmjena==nil
	cSmjena:=""
	fTekuci:=.f.
else
	// generise se pri zakljucenju/ulasku u izvjestaje
  	fTekuci:=.t.
endif

if Pcount()==0
	// kad radim forsirano generisanje utroska sirovina
  	Box(,5,60)
  	dDatOd:=CTOD("")
  	dDatDo:=gDatum    // DATE()
  	cSmjena := ""
  	@ m_x+1,m_y+5 Say "Generisi za period pocevsi od:" GET dDatOd
  	@ m_x+3,m_y+5 Say "                 zakljucno sa:" GET dDatDo
  	READ
  	ESC_BCR
  	BoxC()
endif

MsgO("SACEKAJTE ... GENERISEM UTROSAK SIROVINA ...")

O_PRIPRG
O_SIFK
O_SIFV
O_SAST
O_ROBA
O_ODJ
O_DIO
O_POS_DOKS
O_POS

if empty(cSmjena) // za period ponovo izgenerisi
	select pos_doks
	set order to tag "2" // IdVd+DTOS (Datum)+Smjena
  	// prvo pobrisem stare dokumente razduzenja sirovina
  	Seek "96"+DTOS (dDatOd)
  	do while !eof() .and. pos_doks->IdVd=="96" .and. pos_doks->Datum<=dDatDo
    		@ m_x+1 , m_y+15 SAY "B/"+dtoc(datum)+Brdok
    		SELECT POS
    		Seek pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
    		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
      			Del_Skip()
    		enddo
    		select pos_doks
    		Del_Skip()
  	enddo
endif  // za period ponovo izgenerisi

RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)

MsgC()

CLOSERET
*}


/*! \fn RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)
 *  \brief
 */
 
function RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)
local i:=1
local cVrsta
local fNaso

// ispraznim pripremu
SELECT PRIPRG
my_dbf_zap()

Scatter()

select pos_doks
Set order to tag "2"

for i:=1 to 2
	if i==1
 		cVrsta:="42"
	else
 		cVrsta:="01"
	endif
	Seek cVrsta+DTOS (dDatOd)
	do while !eof() .and. pos_doks->IdVd==cVrsta .and. pos_doks->Datum<=dDatDo
  		if fTekuci .and. (pos_doks->Smjena<>cSmjena .or. pos_doks->M1==OBR_JEST)
    			Skip
			Loop
  		endif
		SELECT POS
  		Seek pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
  		@ m_x+1 , m_y+15 SAY "G/"+dtoc(datum)+Brdok
  		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
    			if POS->M1==OBR_JEST
      				Skip
				Loop
    			endif
    			Scatter()     // uzmi podatke o promjeni
    			select sast
    			Seek _idroba
    			if FOUND()  // idemo po sastavnici
      				do while !eof() .and. sast->Id==_idroba
        				select roba
					HSEEK sast->Id2
        				if FOUND ()
          					_Cijena := roba->mpc
        				else
          					_Cijena := 0
        				endif
        				SELECT PRIPRG
        				HSEEK _IdPos+_IdOdj+_IdDio+sast->Id2+DTOS(_Datum)+_Smjena
        				if !FOUND ()
          					APPEND BLANK // priprg
          					_IdVd:="96"
						_MU_I:=S_I
          					_BrDok:=SPACE(LEN(_BrDok))
          					_IdRadnik:=SPACE(LEN(_IdRadnik))
          					Gather()  // priprg
          					// priprg
          					REPLACE IdRoba WITH sast->Id2,Kolicina WITH _Kolicina * sast->Kolicina
        				else
          					REPLACE Kolicina WITH Kolicina + _Kolicina*sast->Kolicina
        				endif
        				select sast
					SKIP
      				enddo
    			else // u sastavnici nema robe
      				SELECT PRIPRG 
				HSEEK _IdPos+_IdOdj+_IdDio+_IdRoba+DTOS(_Datum)+_Smjena
      				if !FOUND ()
        				APPEND BLANK
        				_IdVd:="96"
					_MU_I:=S_I
        				_BrDok:=SPACE(LEN(_BrDok))
        				_IdRadnik:=SPACE(LEN(_IdRadnik))
        				Gather() // priprg
      				else
        				// priprg
        				REPLACE Kolicina WITH _Kolicina + Kolicina
      				endif
    			endif
    			SELECT POS
			SKIP
  		enddo // POS
  		select pos_doks
  		SKIP
	enddo

next // i

// prebaci dokumente razduzenja u DOKS/POS

select pos_doks
Set order to tag "2"
select POS
set order to tag "1"
SELECT PRIPRG
set order to tag "2"
GO TOP
while !eof()
	cIdPos := PRIPRG->IdPos
  	do while !eof() .and. PRIPRG->IdPos==cIdPos
    		xDatum := PRIPRG->Datum
    		do while !Eof() .and. PRIPRG->IdPos==cIdPos .and. PRIPRG->Datum==xDatum
      			xSmjena := PRIPRG->Smjena
      			Scatter()
      			select pos_doks
      			Seek "96"+DTOS (xDatum)+xSmjena
      			if !Found()
        			set order to tag "1"
        			cBrDok := _BrDok := pos_novi_broj_dokumenta( cIdPos, VD_RZS )
        			if (gBrojSto=="D")
					_zakljucen := "Z"
				endif
				Set order to tag "2"
        			Append Blank
        			Gather()
      			else
        			cBrDok := ""
        			do while !Eof() .and. pos_doks->IdVd=="96" .and. pos_doks->Datum==xDatum.and. pos_doks->Smjena==xSmjena
          				if pos_doks->IdPos==cIdPos
            					cBrDok := pos_doks->BrDok
            					EXIT
          				endif
          				SKIP
        			enddo
        			if Empty(cBrDok)  
					// ne postoji RZS za cIdPos
          				set order to tag "1"
          				cBrDok := _BrDok := pos_novi_broj_dokumenta( cIdPos, VD_RZS )
          				if (gBrojSto=="D")
						_zakljucen := "Z"
					endif
					Set order to tag "2"
          				Append Blank
          				Gather()
        			endif
      			endif
      			SELECT PRIPRG    // xDatum je priprg->datum
      			do while !eof() .and. PRIPRG->IdPos==cIdPos .and. PRIPRG->Datum==xDatum.and.PRIPRG->Smjena==xSmjena
        			Scatter()
        			_BrDok := cBrDok
        			_Prebacen := OBR_NIJE
        			fNaso := .f.
        			SELECT POS
        			Seek cIdPos+"96"+dtos(xDatum)+cBrDok+_IdRoba
        			do while !Eof() .and.POS->(IdPos+IdVd+dtos(datum)+BrDok+IdRoba)==cIdPos+VD_RZS+dtos(xDatum)+cBrDok+_IdRoba
          				if POS->Cijena==PRIPRG->Cijena .and.POS->IdCijena==PRIPRG->IdCijena .and. pos->idodj==priprg->idodj
            					fNaso := .t.
            					Exit
          				endif
          				Skip
        			enddo
        			if fNaso
          				// POS
          				REPLACE Kolicina WITH Kolicina+_Kolicina
          				REPLSQL Kolicina WITH Kolicina+_Kolicina
        			else
          				Append Blank
          				_BrDok := cBrDok
          				Gather()
        			endif
        			SELECT PRIPRG
        			SKIP
      			enddo
    		enddo
  	enddo
enddo

// oznaci da si obradio racune

for i:=1 to 2
	if i==1
 		cVrsta:="42"
	else
 		cVrsta:="01"
	endif
	select pos_doks
	Set order to tag "2"
	Seek cVrsta+DTOS (dDatOd)
	do while !Eof() .and. pos_doks->IdVd==cVrsta .and. pos_doks->Datum <= dDatDo
  		if fTekuci .and. (pos_doks->Smjena<>cSmjena .or. pos_doks->M1==OBR_JEST)
    			Skip
			Loop
  		endif
  		// doks
  		REPLACE M1 WITH OBR_JEST
  		REPLSQL M1 WITH OBR_JEST
  		Skip
	enddo
next //i

SELECT PRIPRG

my_dbf_zap()
return




