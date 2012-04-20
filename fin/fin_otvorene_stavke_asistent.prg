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



/*! \fn KonsultOS()
 *  \brief Sredjivanje otvorenih stavki pri knjizenju, poziv na polju strane valute<a+O>
 */
 
function KonsultOS(xEdit)

local fgenerisano
local nNaz:=1
local nRec:=RECNO()

lAsist := .t.
lSumirano := .f.
nZbir := 0
nZbir := ProvDuplePartnere(_idpartner, _idkonto, _d_p, @lAsist, @lSumirano)

if nZbir > 0 .and. !lAsist
	MsgBeep("Na dokumentu postoje dvije ili vise uplata#za istog kupca. Asistent onemogucen!")
	return (NIL)
endif


cIdFirma:=gFirma
cIdPartner:=_idpartner

if gOAsDuPartn == "D" .and. (nZbir <> 0)
	if fNovi	
		nIznos:=_iznosbhd + nZbir
	else
		nIznos:=nZbir
	endif
else
	nIznos:=_iznosbhd
endif

cDugPot:=_d_p
cOpis:=_Opis

IF gRJ=="D"
  cIdRj := _idrj
ENDIF

if gTroskovi=="D"
  cFunk := _Funk
  cFond := _Fond
endif

picD:=FormPicL("9 "+gPicBHD,14)
picDEM:=FormPicL("9 "+gPicDEM,9)

cIdKonto:=_idkonto

cIdFirma:=left(cIdFirma,2)

SELECT (F_SUBAN)
IF !USED()
  O_SUBAN
ENDIF

select SUBAN
set order to tag "1" // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

GO TOP

Box(, 20, 77)
@ m_x, m_y + 25 SAY "KONSULTOVANJE OTVORENIH STAVKI"

// formiraj datoteku
aDbf:={}
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATVAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATZPR'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   10 ,  0 })
AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IZNOSBHD'            , 'N' ,  21 ,  2 })
AADD(aDBf,{ 'UPLACENO'            , 'N' ,  21 ,  2 })
AADD(aDBf,{ 'M2'                  , 'C' ,  1 , 0 })

DBCREATE(my_home() + 'ostav.dbf', aDbf )

select ( F_OSTAV )

my_use_temp("OSTAV", my_home() + "ostav", .f., .t. )

index on dtos(DatDok) + DTOS(iif(empty(datval), datdok, datval)) + Brdok  tag "1"

nUkDugBHD:=0
nUkPotBHD:=0
select suban
set order to tag "3"

seek cIdfirma + cIdkonto + cIdpartner

dDatDok:=ctod("")

cPrirkto:="1"   // priroda konta
select (F_TRFP2)
if !used()
	O_TRFP2
endif

HSEEK "99 "+LEFT(cIdKonto,1)

DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
	SKIP 1
ENDDO

IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
  cPrirkto:=D_P
ELSE
  if cidkonto="21"
     cPrirkto:="1"
  else
     cPrirkto:="2"
  endif
ENDIF

select suban

nUDug2:=nUPot2:=0
nUDug:=nUPot:=0
fPrviprolaz:=.t.
DO WHILE !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner

      cBrDok:=BrDok; cOtvSt:=otvst
      dDatDok:=max(datval,datdok)
      nDug2:=nPot2:=0
      nDug:=nPot:=0
      aFaktura:={CTOD(""),CTOD(""),CTOD("")}
      DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
                 .and. brdok==cBrDok
         dDatDok:=min(max(datval,datdok),dDatDok)
         IF D_P=="1"
            nDug+=IznosBHD
            nDug2+=IznosDEM
         ELSE
            nPot+=IznosBHD
            nPot2+=IznosDEM
         ENDIF

         IF D_P==cPrirkto
           aFaktura[1]:=DATDOK
           aFaktura[2]:=DATVAL
         ENDIF
	 
         if afaktura[3]<DatDok  // datum zadnje promjene
            aFaktura[3]:=DatDok
         endif

         skip
      enddo


      if round(ndug-npot,2)<>0
          select ostav
          append blank
          //replace iznosbhd with (ndug-npot), datdok with dDatDok, brdok with cbrdok
          replace iznosbhd with ( nDug - nPot )
          replace datdok with aFaktura[1]
          replace datval with aFaktura[2]
          replace datzpr with aFaktura[3]
          replace brdok with cbrdok
          
	  if (cDugPot == "2")
	  	replace d_p with "1"
	  else
	  	replace d_p with "2"
		replace iznosbhd with -iznosbhd
	  endif
	  
	  select suban
	  
       endif
enddo // partner


ImeKol:={}
AADD(ImeKol,{ "Br.Veze",     {|| BrDok}                          })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                         })
AADD(ImeKol,{ "Dat.Val.",   {|| DatVal}                         })
AADD(ImeKol,{ "Dat.ZPR.",   {|| DatZPR}                         })
AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="1",iznosbhd,0)),14,2)}     })
AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),14), {|| str((iif(D_P=="2",iznosbhd,0)),14,2)}     })
AADD(ImeKol,{ PADR("Uplaceno",14), {|| str(uplaceno,14,2)}     })

Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

Box(,15, 74,.t.)
set cursor on
@ m_x+13, m_y+1 SAY '<Enter> Izaberi/ostavi stavku'
@ m_x+14, m_y+1 SAY '<F10>   Asistent'
@ m_x+15, m_y+1 SAY ""; ?? "  IZNOS Koji zatvaramo: "+IF(cDugPot=="1","duguje","potrazuje")+" "+ALLTRIM(STR(nIznos))

private cPomBrDok:=SPACE(10)

select ostav
go top

ObjDbedit("KOStav",15,74,{|| EdKonsRos()},"","Otvorene stavke.", , , ,{|| m2='3'} ,3)

Boxc()


select ostav

nNaz:=Kurs(_datdok)

fM3:=.f.
go top
do while !eof()
  if m2="3"
    fm3:=.t.
    exit
  endif
  skip
enddo

fGenerisano:=.f.
IF fm3 .and. Pitanje("","Izgenerisati stavke u nalogu za knjizenje ?","D")=="D"  // napraviti stavke?

  SELECT (F_OSTAV)
  go top

  select ostav

  DO WHILE !EOF()
    IF m2=="3"
      replace m2 with ""
      SELECT (F_FIN_PRIPR)
      if fgenerisano
         APPEND BLANK
      else
        if !fnovi
		if lSumirano
			append blank
		else
			go nRec
		endif
 	else
		append blank
	endif
        // prvi put
        fGenerisano:=.t.
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

      if gRJ=="D"
        widrj     := cIdRj
      endif

      if gTroskovi=="D"
        wFunk := cFunk
        wFond := cFond
      endif

      wrbr      := STR(nRBr,4)
      nRbr++
      wd_p      :=_D_p
      wIznosBhd := ostav->uplaceno
      if ostav->uplaceno<>ostav->iznosbhd
        wOpis:=trim(cOpis)+", DIO"
      endif

      wBrDok    := ostav->brdok

      wiznosdem := if( round(nNaz,4)==0 , 0 , wiznosbhd/nNaz )
      Gather("w")
      SELECT (F_OSTAV)
    ENDIF // m2="3"
    SKIP 1

  ENDDO
ENDIF
BoxC()

if fgenerisano
  --nRbr
  select (F_FIN_PRIPR)
  Scatter()  // uzmi posljednji slog
  if fnovi
    MY_DELETE // izbrisi
  else
    Gather()   // pa ga za svaki slucaj pohrani
  endif
  _k3 := K3Iz256(_k3)
  ShowGets()
endif

select F_OSTAV
use

select F_FIN_PRIPR

if !fGenerisano
   if !USED()
      o_fin_edit()
      SELECT F_FIN_PRIPR
   endif
   go nRec
endif



RETURN (NIL)



/*! \fn EdKonsROS()
 *  \brief Ispravka broja veze u SUBAN
 */
 
function EdKonsROS()

local oBrDok:=""
local cBrdok:=""
local nTrec
local cDn:="N",nRet:=DE_CONT
LOCAL GetList:={}           // OK?
do case
  case Ch==K_F2
     if pitanje(,"Izvrsiti ispravku broja veze u SUBAN ?","N")=="D"
        oBrDok:=BRDOK
        cBrDok:=BRDOK
        Box(,2,60)
          @ m_x+1,m_Y+2 SAY "Novi broj veze:" GET cBRDok
          read
        BoxC()
        if lastkey()<>K_ESC
           select suban; PushWa()
           set order to tag "3"
           seek _idfirma+_idkonto+_idpartner+obrdok
           do while !eof() .and. _idfirma+_idkonto+_idpartner+obrdok==idfirma+idkonto+idpartner+brdok
             skip; nTrec:=recno(); skip -1
             replace brdok with cBrDok
             go nTRec
           enddo
           PopWa()
           select ostav
           replace brdok with cBrdok
           nRet:=DE_ABORT
           MsgBeep("Nakon ispravke morate ponovo pokrenuti asistenta sa <a-O>  !")
        endif
     else
       nRet:=DE_REFRESH
     endif
  case Ch==K_CTRL_T
     if pitanje(,"Izbrisati stavku ?","N")=="D"
        MY_DELETE
        nRet:=DE_REFRESH
     else
       nRet:=DE_CONT
     endif
  case Ch==K_ENTER
     if uplaceno=0
      _Uplaceno:=iznosbhd
     else
      _uplaceno:=uplaceno
     endif
     Box(,2,60)
        @ m_x+1,m_y+2 SAY "Uplaceno po ovom dokumentu:" GET _uplaceno pict "999999999.99"
        read
     Boxc()
     if lastkey()<>K_ESC
       if _uplaceno<>0
          replace m2 with "3", uplaceno with _uplaceno
       else
          replace m2 with "", uplaceno with 0
       endif
     endif

     nRet:=DE_REFRESH
  case Ch=K_F10
        
	select ostav
	go top

        if Pitanje(,"Asistent zatvara stavke ?","D")=="D"
	     nPIznos:=nIznos  // iznos uplate npr
             go top
             DO WHILE !EOF()
               IF cDugPot<>d_p .and. nPIznos>0
                 _Uplaceno:=min(iznosbhd,nPIznos)
                 replace m2 with "3", uplaceno with _uplaceno
                 nPIznos-=_uplaceno
               ELSE
                 replace m2 with ""
               ENDIF
               SKIP 1
            ENDDO
            go top
            if nPIznos>0  // ostao si u avansu
               	append blank
               	Scatter("w")
               	wbrdok:=padr("AVANS",10)
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



