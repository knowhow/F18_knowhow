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


function BrowseRn()
O_KALK
O_KONTO
cmkonto:=space(7)
cIdFirma:=gFirma
Box(,7,66,)
set cursor on

 @ m_x+1,m_y+2 SAY "ISPRAVKA BROJA VEZE - RADNI NALOZI"
 if gNW $ "DX"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Magacin Konto: " GET cMKonto   valid  P_Konto(@cMKonto)
 read; ESC_BCR

BoxC()

cIdFirma:=left(cIdFirma,2)

O_KALK_DOKS

select kalk_doks
set order to tag "2"
//CREATE_INDEX("DOKSi2","IdFirma+MKONTO+idzaduz2+idvd+brdok","DOKS")

Box(,19,77)

ImeKol:={}
AADD(ImeKol,{ "F",          {|| IdFirma}                          })
AADD(ImeKol,{ "VD  ",       {|| IdVD}                           })
AADD(ImeKol,{ "Broj  ",     {|| BrDok}                           })
AADD(ImeKol,{ "M.Konto",    {|| mkonto}                    })
AADD(ImeKol,{ "RN     ",    {|| IdZaduz2 }                    })
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                          })
AADD(ImeKol,{ "Nab.Vr",     {|| nv}                          })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+1,m_y+1 SAY "<F2> Ispravka dokumenta, <c-P> Print, <a-P> Print Br.Dok"
@ m_x+2,m_y+1 SAY "<ENTER> Postavi/Ukini zatvaranje"
@ m_x+3,m_y+1 SAY ""; ?? "Konto:",cMKonto
BrowseKey(m_x+4,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| EdBRN(Ch)},"idFirma+mkonto=cidFirma+cmkonto",cidFirma+cmkonto,2,,,{|| .f.})

BoxC()

closeret
return
*}





/*! \fn EdBrn(Ch)
 *  \brief Obrada opcija u browse-u radnih naloga
 */

function EdBrn(Ch)
*{
local cDn:="N",nRet:=DE_CONT
do case
  case Ch==K_F2
     cIdzaduz2:=Idzaduz2
     dDatDok:=datdok
     Box(,5,60,.f.)
       @ m_x+1,m_y+2 SAY "Broj RN:" GET cIdzaduz2 pict "@!"
       read
     BoxC()
     if lastkey()<>K_ESC
       replace idzaduz2 with cidzaduz2
     endif
     select kalk
     seek kalk_doks->(idfirma+idvD+brdok)
     do while  !eof() .and. idfirma+idvD+brdok==kalk_doks->(idfirma+idvD+brdok)
        skip; nTrec:=recno() ; skip -1
        replace idzaduz2  with cidzaduz2
        go nTrec
     enddo
     select doks

     nRet:=DE_REFRESH
 case Ch==K_CTRL_P
     PushWa()
     cSeek:=idfirma+idvd+brdok
     my_close_all_dbf()
     kalk_centr_stampa_dokumenta(.t.,cSeek)
     O_KALK
     O_KALK_DOKS
     PopWA()
     nRet:=DE_REFRESH
endcase
return nRet
*}




