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


#include "mat.ch"



function mat_povrat_naloga()

O_mat_suban
O_mat_anal
O_mat_sint
O_mat_nalog
O_mat_pripr
O_ROBA
O_SIFK
O_SIFV

SELECT mat_suban
set order to tag "4"

cIdFirma:=gFirma
cIdVN:=space(2)
cBrNal:=space(4)

Box("",1,35)
 @ m_x+1,m_y+2 SAY "mat_nalog:"
 if gNW$"DR"
  @ m_x+1,col()+1 SAY gFirma
 else
  @ m_x+1,col()+1 GET cIdFirma
 endif
 @ m_x+1,col()+1 SAY "-" GET cIdVN
 @ m_x+1,col()+1 SAY "-" GET cBrNal
 read; ESC_BCR
BoxC()

seek cidfirma+cidvn+cbrNal
if Pitanje("","mat_nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal+" povuci u mat_pripremu (D/N) ?","N")=="N"
   closeret
endif


if !(  mat_suban->(flock()) .and. mat_anal->(flock()) .and. mat_sint->(flock()) .and. mat_nalog->(flock()) )
  Beep(1)
  Msg("Neko vec koristi datoteke !")
  closeret
endif

MsgO("mat_suban")
select mat_suban
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
   select mat_pripr; Scatter()
   select mat_suban; Scatter()
   select mat_pripr
   APPEND NCNL
   if _Iznos<>0 .and. _Kolicina<>0
     _Cijena:=_Iznos/_Kolicina
   else
     _Cijena:=0
   endif
   Gather2()

   nUlazK:=nIzlK:=nDug:=nPot:=0
   IF _U_I="1"
     nUlazK:=_Kolicina
   ELSE
     nIzlK:=_Kolicina
   ENDIF
   IF _D_P="1"
      nDug:=_Iznos
   ELSE
      nPot:=_Iznos
   ENDIF

   select mat_suban
   skip; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use
MsgC()

MsgO("mat_anal")
select mat_anal
#ifndef C50
set order to tag "2"
#else
set order to 2
#endif
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
 skip; nRec:=recno(); skip -1
 dbdelete2()
 go nRec
enddo
use
MsgC()


MsgO("mat_sint")
select mat_sint
#ifndef C50
set order to tag "2"
#else
set order to 2
#endif
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
 skip; nRec:=recno(); skip -1
 dbdelete2()
 go nRec
enddo
use
MsgC()

MsgO("mat_nalog")
select mat_nalog
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip; nRec:=recno(); skip -1
  dbdelete2()
  go nRec
enddo
use
MsgC()
closeret
return


// ----------------------------------------------
// generacija dokumenta pocetnog stanja
// ----------------------------------------------
function mat_prenos_podataka()

O_mat_pripr

if reccount2()<>0
	MsgBeep("mat_priprema mora biti prazna !!!")
  	closeret
	return
endif

zap
set order to
index on idfirma+idkonto+idpartner+idroba to "PRIPTMP"
GO TOP

Box(,5,60)
	nMjesta := 3
  	dDatDo := DATE()
  	@ m_x+3, m_y+2 SAY "Datum do kojeg se promet prenosi" GET dDatDo
  	read
	ESC_BCR
BoxC()

start print cret

O_mat_subanX

// ovo je bio stari indeks, stari prenos bez partnera
//set order to tag "3"
// "3" - "IdFirma+IdKonto+IdRoba+dtos(DatDok)"

set order to tag "5"
// "5" - "IdFirma+IdKonto+IdPartner+IdRoba+dtos(DatDok)"

? "Prolazim kroz bazu...."
select mat_suban
go top

// idfirma, idkonto, idpartner, idroba, datdok
do while !eof()

  nRbr := 0
  cIdFirma := idfirma
 
  do while !eof() .and. cIdFirma == IdFirma
      
      cIdKonto := IdKonto
      select mat_suban
      
      nDin:=0
      nDem:=0
      
      do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto
        
	cIdPartner := idpartner

	do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdPartner==cIdPartner
	
	   cIdRoba:=IdRoba
        
	   ? "Konto:", cIdKonto, ", partner:", cIdPartner, ", roba:", cIdRoba
        
	   do while !eof() .and. cIdFirma==IdFirma .and. cIdKonto==IdKonto .and. IdRoba==cIdRoba
         
	 	select mat_pripr
         
	 	hseek mat_suban->(idfirma + idkonto + idpartner + idroba)
         
	 	if !found()

           		append blank
           		
			replace idfirma with cIdFirma
                   	replace idkonto with cIdkonto
			replace idpartner with cIdPartner
                   	replace idRoba  with cIdRoba
                   	replace datdok with dDatDo + 1
                   	replace datkurs with dDatDo + 1
                   	replace idvn with "00"
			replace idtipdok with "00"
                   	replace brnal with "0001"
                  	replace d_p with "1"
                   	replace u_i with "1"
                   	replace rbr with "9999"
                   	replace kolicina with ;
				iif(mat_suban->U_I=="1", mat_suban->kolicina, ;
				-mat_suban->kolicina)
                   	replace iznos with ;
				iif(mat_suban->D_P=="1", mat_suban->iznos, ;
				-mat_suban->iznos)
                   	replace iznos2 with ;
				iif(mat_suban->D_P=="1", mat_suban->iznos2, ;
				-mat_suban->iznos2)
         	
		else
           
	   		replace kolicina with ;
				kolicina + iif(mat_suban->U_I=="1", ;
				mat_suban->kolicina, -mat_suban->kolicina)
                     	
			replace iznos with ;
				iznos + iif(mat_suban->D_P=="1", ;
				mat_suban->iznos,-mat_suban->iznos)
                     	
			replace iznos2 with ;
				iznos2 + iif(mat_suban->D_P=="1", ;
				mat_suban->iznos2,-mat_suban->iznos2)
         
		endif
         
	 	select mat_suban
         	skip
        
	    enddo //  roba

	enddo // partner

      enddo // konto
  
  enddo // firma

enddo // eof

select mat_pripr
// set order to 0
set order to
go top
do while !eof()
	if round(iznos,2)==0 .and. round(iznos2,2)==0 .and. ;
		round(kolicina,3) == 0
      		dbdelete2()
  	endif
  	skip
enddo
__dbpack()

set order to tag "1"
go top

nTrec := 0

do while !eof()
	cIdFirma := idfirma
  	nRbr := 0
  	do while !eof() .and. cIdFirma==IdFirma
    		skip 
		nTrec := recno()
		skip -1
    		replace rbr with str(++nRbr,4)
            	replace cijena with iif(Kolicina<>0,Iznos/Kolicina,0)
    		go nTrec
  	enddo
enddo
close all

end print

if !EMPTY( gSezonDir ) .and. ;
	Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
	
	O_mat_priprRP
  	O_mat_pripr
  	select mat_priprrp
  	append from mat_pripr
  	select mat_pripr
	zap
  	close all
  	if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
      		URadPodr()
  	endif
endif

closeret

return




