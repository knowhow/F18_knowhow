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



// -------------------------------------------------------------
// provjera duplih partnera pri pomoci asistenta
// -------------------------------------------------------------
function ProvDuplePartnere(cIdP, cIdK, cDp, lAsist, lSumirano)

if gOAsDuPartn == "N"
	return 0
endif

select fin_pripr
go top

nCnt := 0
nSuma := 0

if fNovi
	nTot := 0
else
	nTot := 1
endif

do while !EOF()
	if field->idpartner == cIdP .and. field->idkonto == cIdK .and. field->d_p == cDp
		++ nCnt
		nSuma += field->iznosbhd
	endif
	skip
enddo

if (nCnt > nTot) .and. Pitanje(,"Spojiti duple uplate za partnera?","D")=="D"
	go top
	do while !EOF()
		if field->idpartner == cIdP .and. field->idkonto == cIdK .and. field->d_p == cDp
			MY_DELETE
			//replace field->idfirma with "XX"
			//replace field->rbr with "000"
		endif
		skip
	enddo
	lSumirano := .t.
else
	lAsist := .f.
	return nSuma
endif

return nSuma



// brisanje zapisa idfirma "XX"
static function _del_nal_xx()
local nTArea := SELECT()
local nTREC := RECNO()
select fin_pripr
set order to tag "1"
go top

seek "XX"

do while !EOF() .and. field->idfirma == "XX"
	
	if field->rbr == "000"
		MY_DELETE
	endif
	
	skip
enddo

select (nTArea)
go (nTRec)

return .t.


// -----------------------------------------------------------
// kreiranje tabele ostav za otvorene stavke
// -----------------------------------------------------------
static function _cre_ostav()
local _dbf
local _ret := .t.
local _table := "ostav"

// formiraj datoteku ostav
_dbf := {}
AADD( _dbf, { 'DATDOK'              , 'D' ,   8 ,  0 })
AADD( _dbf, { 'DATVAL'              , 'D' ,   8 ,  0 })
AADD( _dbf, { 'DATZPR'              , 'D' ,   8 ,  0 })
AADD( _dbf, { 'BRDOK'               , 'C' ,   10 ,  0 })
AADD( _dbf, { 'D_P'                 , 'C' ,   1 ,  0 })
AADD( _dbf, { 'IZNOSBHD'            , 'N' ,  21 ,  2 })
AADD( _dbf, { 'UPLACENO'            , 'N' ,  21 ,  2 })
AADD( _dbf, { 'M2'                  , 'C' ,  1 , 0 })

DBCREATE( my_home() + _table + ".dbf", _dbf )

select ( F_OSTAV )

my_use_temp("OSTAV", my_home() + _table, .f., .t. )

index on DTOS( DatDok ) + DTOS( iif( EMPTY( datval ), datdok, datval ) ) + brdok tag "1"

return _ret


// --------------------------------------------------------------------------------------------------
// sredjivanje otvorenih stavki pri knjizenju, poziv na polju strane valute<a+O>
// --------------------------------------------------------------------------------------------------
function konsultos( xEdit )
local fgenerisano
local nNaz := 1
local nRec := RECNO()
local _col, _row
local _rec, _i

lAsist := .t.
lSumirano := .f.
nZbir := 0
nZbir := ProvDuplePartnere( _idpartner, _idkonto, _d_p, @lAsist, @lSumirano )

if nZbir > 0 .and. !lAsist
	MsgBeep("Na dokumentu postoje dvije ili vise uplata#za istog kupca. Asistent onemogucen!")
	return (NIL)
endif

cIdFirma := gFirma
cIdPartner := _idpartner

if gOAsDuPartn == "D" .and. ( nZbir <> 0 )
	if fNovi	
		nIznos := _iznosbhd + nZbir
	else
		nIznos := nZbir
	endif
else
	nIznos := _iznosbhd
endif

cDugPot := _d_p
cOpis := _Opis

if gRJ == "D"
	cIdRj := _idrj
endif

if gTroskovi == "D"
  	cFunk := _Funk
  	cFond := _Fond
endif

picD := FormPicL( "9 " + gPicBHD, 14 )
picDEM := FormPicL( "9 " + gPicDEM, 9 )

cIdKonto := _idkonto

cIdFirma := LEFT( cIdFirma, 2 )

SELECT (F_SUBAN)

if !USED()
	O_SUBAN
endif

select suban
set order to tag "1" 
// IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

go top

Box(, 20, 77)

	@ m_x, m_y + 25 SAY "KONSULTOVANJE OTVORENIH STAVKI"

	// kreiraj tabelu ostav
	_cre_ostav()

	nUkDugBHD := 0
	nUkPotBHD := 0
	
	select suban
	set order to tag "3"

	seek cIdfirma + cIdkonto + cIdpartner

	dDatDok := CTOD("")

	cPrirkto := "1"   
	// priroda konta

	select (F_TRFP2)
	if !used()
		O_TRFP2
	endif

	HSEEK "99 " + LEFT( cIdKonto, 1 )

	do while !EOF() .and. field->idvd == "99" .and. TRIM( field->idkonto ) != LEFT( cIdKonto, LEN( TRIM( field->idkonto ) ) )
		skip 1
	enddo

	if field->idvd == "99" .and. TRIM( field->idkonto ) == LEFT( cIdKonto, LEN( TRIM( field->idkonto ) ) )
  		cPrirkto := field->d_p
	else
  		if cIdKonto = "21"
     		cPrirkto := "1"
  		else
     		cPrirkto := "2"
  		endif
	endif

	select suban

	nUDug2 := 0
	nUPot2 := 0
	nUDug := 0
	nUPot := 0

	fPrviprolaz:=.t.
	
	do while !EOF() .and. field->idfirma == cIdFirma .and. cIdKonto == field->idkonto .and. cIdPartner == field->idpartner

    	cBrDok := field->brdok
		cOtvSt := field->otvst
      	dDatDok := MAX( field->datval, field->datdok )
      	
		nDug2 := 0
		nPot2 := 0
      	nDug := 0
		nPot := 0

      	aFaktura := { CTOD(""), CTOD(""), CTOD("") }

      	do while !EOF() .and. field->idfirma == cIdFirma .and. cIdKonto == field->idkonto .and. cIdPartner == field->idpartner ;
                 		.and. field->brdok == cBrDok

       		dDatDok := MIN( MAX( field->datval, field->datdok ), dDatDok )

         	if field->d_p == "1"
            	nDug += field->IznosBHD
            	nDug2 += field->IznosDEM
         	else
            	nPot += field->IznosBHD
            	nPot2 += field->IznosDEM
         	endif

         	if field->d_p == cPrirkto
           		aFaktura[1] := field->DATDOK
           		aFaktura[2] := field->DATVAL
         	endif
	 
         	if aFaktura[3] < field->DatDok  
				// datum zadnje promjene
            	aFaktura[3] := field->DatDok
         	endif

         	skip
      	
		enddo

      	if ROUND( nDug - nPot, 2 ) <> 0
        	
			select ostav
          	append blank
          	
			//replace iznosbhd with (ndug-npot), datdok with dDatDok, brdok with cbrdok
          	replace field->iznosbhd with ( nDug - nPot )
          	replace field->datdok with aFaktura[1]
          	replace field->datval with aFaktura[2]
          	replace field->datzpr with aFaktura[3]
          	replace field->brdok with cBrDok
          
	  		if ( cDugPot == "2" )
	  			replace field->d_p with "1"
	  		else
	  			replace field->d_p with "2"
				replace field->iznosbhd with -iznosbhd
	 		endif
	  
	  		select suban
	  
       	endif
	
	enddo 

	ImeKol := {}

	AADD(ImeKol,{ "Br.Veze",     {|| BrDok}                          })
	AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                         })
	AADD(ImeKol,{ "Dat.Val.",   {|| DatVal}                         })
	AADD(ImeKol,{ "Dat.ZPR.",   {|| DatZPR}                         })
	AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="1",iznosbhd,0)),14,2)}     })
	AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="2",iznosbhd,0)),14,2)}     })
	AADD(ImeKol,{ PADR("Uplaceno",14), {|| str(uplaceno,14,2)}     })

	Kol := {}

	for _i := 1 to LEN( ImeKol )
		AADD( Kol, _i )
	next

	_row := MAXROWS() - 15
	_col := MAXCOLS() - 6

	Box(, _row, _col, .t. )

		set cursor on

		@ m_x + _row - 2, m_y + 1 SAY '<Enter> Izaberi/ostavi stavku'
		@ m_x + _row - 1, m_y + 1 SAY '<F10>   Asistent'
		@ m_x + _row ,    m_y + 1 SAY ""

		?? "  IZNOS Koji zatvaramo: " + IF( cDugPot == "1", "duguje", "potrazuje" ) + " " + ALLTRIM( STR( nIznos ) )

		private cPomBrDok := SPACE(10)

		select ostav
		go top

		ObjDbedit( "KOStav", _row, _col, {|| EdKonsRos() }, "", "Otvorene stavke.", , , ,{|| field->m2 = '3' }, 3 ) 

	Boxc()

	select ostav

	nNaz := Kurs( _datdok )

	fM3 := .f.
	
	go top
	
	do while !eof()
  		if field->m2 = "3"
    		fm3 := .t.
    		exit
  		endif
  		skip
	enddo

	fGenerisano := .f.

	if fM3 .and. Pitanje( "", "Izgenerisati stavke u nalogu za knjizenje ?", "D" ) == "D"  
		// napraviti stavke?

  		select (F_OSTAV)
  		go top

  		select ostav

  		do while !EOF()

    		if field->m2 == "3"
      				
				replace field->m2 with ""
      				
				select ( F_FIN_PRIPR )
      				
				if fgenerisano
         			append blank
      			else
        			if !fNovi
						if lSumirano
							append blank
						else
							go nRec
						endif
 					else
						append blank
					endif
        				
					// prvi put
        			fGenerisano := .t.

      			endif
      				
				Scatter("w")
      				
				widfirma  := cidfirma
      			widvn     := _idvn
     		 	wbrnal    := _brnal
      			widtipdok := _idtipdok
      			wdATvAL   := ctod("")
      			wdatdok   := _datdok
      			wopis     := ""
      			wIdkonto  := cidkonto
      			widpartner:= cidpartner
      			wOpis     := cOpis
      			wk1       := _k1
      			wk2       := _k2
      			wk3       := K3U256(_k3)
      			wk4       := _k4
      			wm1       := _m1

      			if gRJ == "D"
        			widrj     := cIdRj
      			endif

      			if gTroskovi == "D"
        			wFunk := cFunk
        			wFond := cFond
      			endif

      			wrbr      := STR(nRBr,4)
      			nRbr ++
      			wd_p      :=_D_p
      			wIznosBhd := ostav->uplaceno
      				
				if ostav->uplaceno <> ostav->iznosbhd
        			wOpis:=trim(cOpis)+", DIO"
      			endif

      			wBrDok    := ostav->brdok
      			wiznosdem := if( ROUND( nNaz, 4 ) == 0, 0, wiznosbhd/nNaz )
      				
				Gather("w")
      
				select ( F_OSTAV )
    			
			endif 
    
			skip 1

  		enddo

	endif

BoxC()

if fGenerisano
  		
	-- nRbr

 	select (F_FIN_PRIPR)

	// uzmi posljednji slog
  	Scatter()  

	if fNovi
    	delete
		__dbPack()
  	else
		// pa ga za svaki slucaj pohrani
    	Gather()   
  	endif
  
	_k3 := K3Iz256( _k3 )

	ShowGets()
	
endif
	
select ( F_OSTAV )
use

select ( F_FIN_PRIPR )

if !fGenerisano
  	if !used()
     	o_fin_edit()
    	select ( F_FIN_PRIPR )
   	endif
   	go nRec
endif

return (NIL)


// -----------------------------------------------------------------
// key handler 
// -----------------------------------------------------------------
static function EdKonsROS()
local oBrDok := ""
local cBrdok := ""
local nTrec
local cDn := "N"
local nRet := DE_CONT
local GetList := {}          
local _rec

do case

	case Ch==K_F2

    	if pitanje(, "Izvrsiti ispravku broja veze u SUBAN ?", "N" ) == "D"

        	oBrDok:=BRDOK
        	cBrDok:=BRDOK

        	Box(,2,60)
          		@ m_x+1,m_Y+2 SAY "Novi broj veze:" GET cBRDok
          		read
        	BoxC()

        	if lastkey() <> K_ESC

           		select suban
				PushWa()
           		set order to tag "3"
           		seek _idfirma+_idkonto+_idpartner+obrdok

           		do while !eof() .and. _idfirma + _idkonto + _idpartner + obrdok == idfirma+idkonto+idpartner+brdok
             		
					skip
					nTrec := recno()
					skip -1
					
					_rec := dbf_get_rec()
					_rec["brdok"] := cBrDok
					
					my_use_semaphore_off()
					sql_table_update( nil, "BEGIN" )
					update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
					sql_table_update( nil, "END" )
					my_use_semaphore_on()
					
             		go nTRec

           		enddo

           		PopWa()

           		select ostav
				_rec := dbf_get_rec()
				_rec["brdok"] := cBrDok
				dbf_update_rec( _rec )

           		nRet := DE_ABORT

           		MsgBeep("Nakon ispravke morate ponovo pokrenuti asistenta sa <a-O>  !")

        	endif

     	else

       		nRet := DE_REFRESH

     	endif
  	
	case Ch == K_CTRL_T

    	if Pitanje(, "Izbrisati stavku ?", "N" ) == "D"
        	MY_DELETE
        	nRet := DE_REFRESH
     	else
      		nRet := DE_CONT
     	endif

	case Ch == K_ENTER

    	if uplaceno = 0
      		_uplaceno := iznosbhd
     	else
      		_uplaceno := uplaceno
     	endif

     	Box(,2,60)
        	@ m_x+1,m_y+2 SAY "Uplaceno po ovom dokumentu:" GET _uplaceno pict "999999999.99"
        	read
     	Boxc()
     	
		if lastkey() <> K_ESC
       		if _uplaceno <> 0
          		replace m2 with "3"
				replace uplaceno with _uplaceno
       		else
         		replace m2 with ""
				replace uplaceno with 0
       		endif
     	endif

     	nRet := DE_REFRESH

	case Ch = K_F10
        
		select ostav
		go top

        if Pitanje(,"Asistent zatvara stavke ?","D")=="D"

	    	nPIznos := nIznos  
			// iznos uplate npr

            go top

            DO WHILE !EOF()
            	IF cDugPot <> d_p .and. nPIznos > 0 
                	_Uplaceno := MIN( field->iznosbhd, nPIznos )
                 	replace m2 with "3"
					replace uplaceno with _uplaceno
                 	nPIznos-=_uplaceno
               	ELSE
                	replace m2 with ""
              	ENDIF
               	SKIP 1
            ENDDO

            go top

            if nPIznos > 0  

				// ostao si u avansu
            	append blank
               	Scatter("w")
               	wbrdok := PADR( "AVANS", 10 )

               	if cDugPot=="1"
                 	wd_p:="1"
               	else
                 	wd_p:="2"
               	endif

               	wiznosbhd:=npiznos
               	wuplaceno:=npiznos
               	wdatdok:=date()
               	wm2:="3"

               	Box(,2,60)
                  	@ m_x+1,m_y+2 SAY  "Ostatak sredstava knjiziti na dokument:" GET wbrdok
                  	read
               	Boxc()

               	gather("w")

            endif

        endif

     	nRet:=DE_REFRESH

endcase

return nRet



