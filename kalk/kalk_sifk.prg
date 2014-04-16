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


#include "kalk.ch"


function MPSifk()
cUvijek:="N"
qqIdVD:=padr("10;81;",20)

cSezona:="20001"
cNemojMinuse:="D"

cRPolje:=padr("SEZ",4)
dDatOd:=dDatDo:=date()
Box(,9,70)
  @ m_x+1,m_y+2 SAY "Markiraj u sif. robe robu u dokumentima : "
  @ m_x+1,col()+2 GET cRPolje pict "@!"
  @ m_x+2,m_y+2 SAY "Vrste dok:" GET qqIdVD
  @ m_x+3,m_y+2 SAY "Period od:" GET dDatOD
  @ m_x+3,col()+2 SAY "do:" GET dDatDO

  @ m_x+5,m_y+2 SAY "Markirati one kod kojih vec postoji oznaka ?:" GET cUvijek pict "@!" valid cUvijek $ "DN"
  @ m_x+7,m_y+2 SAY "Oznaka sezone:" GET cSezona
  @ m_x+9,m_y+2 SAY "Preskaci storna tj. negativne kolicine? (D/N)" GET cNemojMinuse pict "@!" valid cNemojMinuse $ "DN"
  read; ESC_BCR

  private aUsl1:=Parsiraj(qqIDVD,"idvd")
BoxC()

O_SIFK
O_SIFV
O_ROBA
O_KALK

save screen to cScr
clear
select kalk
private cFilt1:= aUsl1 + ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2Str(dDatDo)
set filter to &cFilt1
go top
do while !eof()
  ? idfirma, idvd, brdok, datdok, idroba
  if cNemojMinuse=="D" .and. (kolicina - GKolicina - GKolicin2)<0
    skip 1
    loop
  endif
  if cUvijek=="D" .or. empty(IzSifkRoba( cRPolje, kalk->idroba, .f.))
    USifk("ROBA", cRPolje, kalk->idroba, Unicode():New( cSezona, .F. ))
  endif
  select kalk
  skip
enddo
set filter to
my_close_all_dbf()
restore screen from cscr
return
*}


/*! \fn DobUSifk()
 *  \brief Popunjava SIFK-karakteristiku sifrarnika robe DOB (dobavljac)
 */

function DobUSifk()
cUvijek:="N"
qqIdVD:=padr("10;81;",20)

cRPolje:=padr("DOB",4)
dDatOd:=dDatDo:=date()
Box(,7,75)
  @ m_x+1,m_y+2 SAY "U sifrarnik robe ubaci partnera iz dokumenata u polje:"
  @ m_x+1,col()+2 GET cRPolje pict "@!"
  @ m_x+2,m_y+2 SAY "Vrste dok:" GET qqIdVD
  @ m_x+3,m_y+2 SAY "Period od:" GET dDatOD
  @ m_x+3,col()+2 SAY "do:" GET dDatDO

  @ m_x+5,m_y+2 SAY "Zamijeniti ako vec postoje ?:" GET cUvijek pict "@!" valid cUvijek $ "DN"
  read; ESC_BCR

  private aUsl1:=Parsiraj(qqIDVD,"idvd")
BoxC()

O_SIFK
O_SIFV
O_ROBA
O_KALK

save screen to cScr
clear
select kalk
private cFilt1:= aUsl1 + ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2Str(dDatDo)
set filter to &cFilt1
go top
do while !eof()
  ? idfirma, idvd, brdok, datdok, idroba, idpartner
  if cUvijek=="D" .or. empty(IzSifkRoba(cRPolje, kalk->idroba, .f.))
    USifk("ROBA", cRPolje,kalk->idroba, Unicode():New( KALK->idpartner, .F. ))
  endif
  select kalk
  skip
enddo
set filter to
my_close_all_dbf()
restore screen from cscr
return


