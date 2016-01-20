/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


function UnosSiht()
local cidradn,cIdRj,nGodina,nMjesec

MsgBeep("http://redmine.bring.out.ba/issues/25986")
return .f.

Private GetList:={}
DO WHILE .T. // G.PETLJA

nGodina:=_Godina
nMjesec:=_Mjesec
cIDradn:=_Idradn
cIDrj:=_IdRj

O_NORSIHT   // sifrarnik normi koje se koriste u sihtarici
O_TPRSIHT   // tipovi primanja koji se unose u kroz sihtarice


select (F_RADSIHT)
if !used(); O_RADSIHT; endif

Scatter()
_Godina:=nGodina
_Mjesec:=nmjesec
eIdradn:=cIdRAdn
_IdRj:=cIdRj
_Dan:=1
_DanDio:=" "


if _BrBod=0
 _BrBod:=radn->brbod
endif

Box(,6 ,68)
@ m_x+0,m_y+2 SAY "SIHTARICA:"

 nDan:=1
 do while .t.

 @ m_x+1,m_Y+2 SAY "Dan" GET _dan pict "99"
 @ m_x+1,col()+2 SAY "Dio dana" GET _dandio valid _dandio$" 12345678" pict "@!"
 @ m_x+1,col()+2 SAY "Broj bodova" GET _BrBod pict "99999.999"  ;
    when {|| _BrBod:=BodovaNaDan(ngodina,nmjesec,cidradn,cidrj,_dan,_dandio),;
              _Brbod:=iif(_BrBod=0,radn->brbod,_BrBod), .t.}
 read

    if lastkey()=K_ESC; exit; endif
 if _Dan>31 .or. _dan=0; exit; endif


 select TPRSiht; go top; _idtippr:=ID
 do while .t.

    @ m_x+2,m_y+2 SAY "   Primanje" GET _idtippr ;
            valid  empty(_idtippr) .or. P_TPRSiht(@_idtippr,2,25) pict "@!"

    read
    if lastkey()=K_ESC; exit; endif
    select RADSIHT
    seek str(_godina,4)+str(_mjesec,2)+_IdRadn+_IdRj+str(_dan,2)+_dandio+_idtippr
    if found() // uzmi tekuce vrijednosti
      _izvrseno:=izvrseno
      _bodova:=bodova
      _idnorsiht:=idnorsiht
    else
      _bodova:=0
      _izvrseno:=0
      _idnorsiht:=space(4)
    endif
    select TPRSiht; hseek _idtippr
    if tprSiht->k1="F"
     @ m_x+3,m_y+2 SAY "Sifra Norme" GET _IdNorSiht ;
             valid  P_NorSiht(@_idNorSiht)

    else
      _IdNorSiht:=space(4)
       @ m_x+3,m_y+2 SAY space(25)
    endif


    @ m_x+3,m_y+40 SAY "    Izvrseno" GET _Izvrseno  pict "999999.999" ;
            when !empty(_idtippr)

    @ m_x+5,m_y+40 SAY "Ukupno bodova" GET _Bodova pict "99999999.99" ;
          when   {|| _Bodova:=_BrBod*_izvrseno/iif(TPRSiht->k1="F",NorSiht->Iznos,1), .f.}

    read

    if empty(_idtippr)
       // ako je primanje prazno - prevrni na slijedeci dan
       exit
    endif
    select RADSIHT
    seek str(_godina,4)+str(_mjesec,2)+_IdRadn+_IdRj+str(_dan,2)+_dandio+_idtippr

    if round(_izvrseno,4)<>0 .or. round(_Bodova,4)<>0   // nije nulirano
       if !found(); append blank; endif
       Gather()
    else
       if found() // a sadr§aj je 0
          my_delete()
       endif
    endif

    select TPRSiht;seek _idtippr; skip; _idtippr:=id
    if eof(); exit; endif
 enddo
    ++_Dan ; if _Dan>31 .or. _dan=0; exit; endif
 enddo

Boxc()

// zavrseno azuriranje RADSIHT
***************************************************************
START PRINT CRET
P_12CPI
? gTS + ":", gnFirma
?? "; Radna jedinica:",cIdRj
?
? "Godina:",str(ngodina,4),"/",str(nmjesec,2)
?
? "*** Pregled Sihtarice za:"
?? cIDradn,radn->naz
?
P_COND2

Linija()
?
select TPRSiht; go top
?? space(3)+" "+space(6)+" "
fPrvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc(id,22)
  skip
enddo
select TPRSiht; go top
?
?? space(3)+" "+space(6)+" "
fPRvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc(alltrim(naz),22)
  skip
enddo
?
?? space(3)+" "+space(6)+" "
select TPRSiht; go top
fPRvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc("izvrseno/bodova",22)
  skip
enddo

Linija()

private aSihtUk:={}

for i:=1 to TPRSiht->(reccount2())
 AADd(aSihtUk,0)
next

for nDan:=1  to 31

 for nDanDio:=0 to 8
  cDanDio:=IF(nDanDio==0," ",STR(nDanDio,1))


  _BrBod:=BodovaNaDan(ngodina,nmjesec,cidradn,cidrj,ndan,cDanDio)

  IF _brbod==0 .and. !EMPTY(cDanDio)
    LOOP
  ENDIF

  IF cDanDio==" "
    ? str(ndan,3)
  ELSE
    ? " /"+cDanDio
  ENDIF
  ?? str(_BrBod,6,2)

  ?? " "

  select TPRSiht; go top
  fPRvi:=.t.

  nPozicija:=0
  do while !eof()
    ++nPozicija

    select RADSIHT
    seek str(ngodina,4)+str(nmjesec,2)+cIdRadn+cIdRj+str(ndan,2)+cDanDio+tprsiht->id

    // utvrdi çifru norme za dan
    if fprvi   // odstampaj sifru norme
      if  dan=ndan .and. dandio==cDanDio .and. idtippr="01"
       ?? idNorSiht+" "
      else
       ?? space(4)+" "
      endif
      fPRvi:=.f.
    endif

    if found()
      Scatter()
      ?? str(_Izvrseno,10,2),str(_Bodova,10,2)+" "
      aSihtUk[nPozicija]+=_Bodova
    else
      ?? space(22)
      aSihtUk[nPozicija]+=0
    endif

    select TPRSiht;  skip
  enddo
 next
next

Linija()
?
?? space(3)+" "+space(6)+" "
select TPRSiht; go top
fPRvi:=.t.
i:=0
_BrBod:=radn->brbod
if _brbod=0
   MsgBeep("U sifrarniku radnika definisite broj bodova za radnika !")
endif

do while !eof()
  ++i
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? space(10), str(aSihtUk[i],10,2)
  cPom:=id  // napuni Karticu radnika !!!!!
  if _Brbod<>0
    _s&cPom:=aSihtUk[i]/_Brbod
  endif
  skip
enddo
Linija()
FF
END PRINT

if pitanje(,"Zavrsili ste unos sihtarice ?","D")=="D"
   exit
endif


ENDDO // glavna petlja

select TPRSiht; use
//select RadSiht; use
select NorSiht; use

select ld

return (nil)


// --------------------------
// obrada sihtarice
// --------------------------
function UzmiSiht()

MsgBeep("http://redmine.bring.out.ba/issues/25986")
return .f.

O_PARAMS

private cZadnjiRadnik:=cIdRadn
private cSection:="S"

RPar("zr", @cZadnjiRAdnik)

select F_RADSIHT
if !used()
	O_RADSIHT
endif

select radsiht
seek str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj
if found() // ovaj je radnik fakat radjen
	seek str(_godina,4)+str(cmjesec,2)+cidradn+cIdRj
	if !found()
	// ako je ovaj radnik vec radjen ne pitaj nista za preuzimanje
		if pitanje(,'Zelite li preuzeti sihtaricu od radnika '+cZadnjiRadnik+' D/N','D')=='D'
			select radsiht
			seek str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj
			private nTSrec:=0
			do while !eof() .and. (str(godina,4)+str(mjesec,2)+idradn+IdRj)==(str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj)
				skip
				nTSrec:=recno()
				skip -1
				Scatter('w')
				wIdRadn:=cidradn  
				// sve je isto osim sifre radnika
				append blank
				Gather('w')
				go nTSrec
			enddo
		endif // pitanje
	endif
endif

Unossiht()

select params
private cSection:="S"
select radsiht
seek str(_godina,4)+str(cmjesec,2)+cIdRadn+cIdRj
if found()  // nesto je bilo u sihtarici
	select params
	cZadnjiRadnik:=cIdRadn
	WPar("zr",cZadnjiRAdnik)
endif

select params
use
select radsiht
use

return

//----------------------
//----------------------
static function Linija()

?
?? padc("---",3) + " " + replicate("-",6) + " "

fprvi:=.t.
select TPRSiht
go top
go top

do while !eof()
  if fprvi
     ?? replicate("-",4) + " "
     fprvi:=.f.
  endif
  ?? replicate("-",10) + " " + replicate("-",10) + " "
  skip
enddo

return (nil)


// -------------------------------
// -------------------------------
function P_TPRSiht(cId,dx,dy)
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_TPRSIHT)
if (!used())
	O_TPRSIHT
endif
select (nArr)

ImeKol:={ { padr("Id",4), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",30), {||  naz}, "naz" }                    , ;
          { padC("K1",3), {|| padc(K1,3)}, "k1"  }  ;
       }
Kol:={1,2,3}
return PostojiSifra(F_TPRSIHT,1,10,55,"Lista: Tipovi primanja u sihtarici",@cId,dx,dy)



