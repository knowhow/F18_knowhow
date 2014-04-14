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

 

function kalk_pripr9View()

private aUslFirma := gFirma
private aUslDok := SPACE(50)
private dDat1 := CToD("")
private dDat2 := DATE()

Box(,10, 60)
	@ 1+m_x, 2+m_y SAY "Uslovi pregleda smeca:" COLOR "I"
	@ 3+m_x, 2+m_y SAY "Firma (prazno-sve)" GET aUslFirma PICT "@S40"
	@ 4+m_x, 2+m_y SAY "Vrste dokumenta (prazno-sve)" GET aUslDok PICT "@S20"
	@ 5+m_x, 2+m_y SAY "Datum od" GET dDat1 
	@ 5+m_x, 20+m_y SAY "do" GET dDat2 
	read
BoxC()

if LastKey()==K_ESC
	return
endif

ka_pripr9_set_filter(aUslFirma, aUslDok, dDat1, dDat2)

private gVarijanta:="2"

private PicV:="99999999.9"
ImeKol:={ ;
          { "F."        , {|| IdFirma                  }, "IdFirma"     } ,;
          { "VD"        , {|| IdVD                     }, "IdVD"        } ,;
          { "BrDok"     , {|| BrDok                    }, "BrDok"       } ,;
          { "Dat.Kalk"  , {|| DatDok                   }, "DatDok"      } ,;
          { "K.zad. "   , {|| IdKonto                  }, "IdKonto"     } ,;
          { "K.razd."   , {|| IdKonto2                 }, "IdKonto2"    } ,;
          { "Br.Fakt"   , {|| brfaktp                  }, "brfaktp"     }, ;
          { "Partner"   , {|| idpartner                }, "idpartner"   }, ;
          { "E"         , {|| error                    }, "error"       } ;
        }

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
@ m_x+17,m_y+2 SAY "<c-T>  Brisi stavku                              "
@ m_x+18,m_y+2 SAY "<c-F9> Brisi sve     "
@ m_x+19,m_y+2 SAY "<P> Povrat dokumenta u pripremu "
@ m_x+20,m_y+2 SAY "               "

if gCijene=="1" .and. gMetodaNC==" "
	Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},23,14)
endif

private lAutoAsist:=.f.

ObjDbedit("KALK_PRIPR9",20,77,{|| ka_pripr9_key_handler()},"<P>-povrat dokumenta u pripremu","Pregled smeca...", , , , ,4)
BoxC()


return


/*! \fn ka_pripr9_key_handler()
 *  \brief Opcije pregleda smeca
 */
function ka_pripr9_key_handler()
*{
do case
	case Ch==K_CTRL_T // brisanje dokumenta iz kalk_pripr9
		ErPripr9(idfirma, idvd, brdok)
      	return DE_REFRESH
	case Ch==K_CTRL_F9 // brisanje kompletnog kalk_pripr9
		ErP9All()
		return DE_REFRESH
	case chr(Ch) $ "pP" // povrat dokumenta u kalk_pripremu
		PovPr9()
		ka_pripr9_set_filter(aUslFirma, aUslDok, dDat1, dDat2)
     	return DE_REFRESH
endcase
return DE_CONT

return
*}


/*! \fn PovPr9()
 *  \brief povrat dokumenta iz kalk_pripr9
 */
static function PovPr9()
*{
local nArr
nArr:=SELECT()

Povrat9(idfirma, idvd, brdok)

select (nArr)

return DE_CONT
*}


/*! \fn ka_pripr9_set_filter(aUslFirma, aUslDok, dDat1, dDat2)
 *  \brief Postavlja filter na tabeli kalk_pripr9
 */
static function ka_pripr9_set_filter(aUslFirma, aUslDok, dDat1, dDat2)
*{
O_KALK_PRIPR9
set order to tag "1"

// obavezno postavi filter po rbr
cFilter:="rbr = '  1'"

if !Empty(aUslFirma)
	cFilter += " .and. idfirma='" + aUslFirma + "'"
endif

if !Empty(aUslDok)
	aUslDok := Parsiraj(aUslDok, "idvd")
	cFilter += " .and. " + aUslDok
endif

if !Empty(dDat1)
	cFilter += " .and. datdok >= " + Cm2Str(dDat1)
endif

if !Empty(dDat2)
	cFilter += " .and. datdok <= " + Cm2Str(dDat2)
endif

set filter to &cFilter

go top

return


// ------------------------------------------------------------------
// ------------------------------------------------------------------
function ErPripr9(cIdF, cIdVd, cBrDok)

if Pitanje(,"Sigurno zelite izbrisati dokument?","N")=="N"
    return
endif

select kalk_pripr9
seek cIdF+cIdVd+cBrDok
my_flock()
do while !eof() .and. cIdF==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
    skip 1
    nRec:=RecNo()
    skip -1
    my_delete()
    go nRec
enddo
my_unlock()
return


// ------------------------------------------------------------------
// ------------------------------------------------------------------
function ErP9All()

if Pitanje(,"Sigurno zelite izbrisati sve zapise?","N")=="N"
    return
endif

select kalk_pripr9
go top
my_dbf_zap()

return


