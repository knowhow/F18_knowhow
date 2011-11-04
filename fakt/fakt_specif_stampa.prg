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


#include "fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \fn StViseDokMenu(cVarijanta)
 *  \brief Menij stampe vise dokumenata
 *  \param cVarijanta   - varijanta
 */
 
function StViseDokMenu(cVarijanta)
*{
  STATIC nPom:=0
  LOCAL aPom:={}, cKljuc:="", i:=0, nD1:=0, nD2:=0, nD3:=0

  IF "U" $ TYPE("lSSIP99") .or. !VALTYPE(lSSIP99)=="L"; lSSIP99:=.f.; ENDIF

  IF cVarijanta==NIL; cVarijanta:="STAMPANJE"; ENDIF

  select fakt_pripr; GO TOP
  DO WHILE !EOF()
    cKljuc:=IDFIRMA+IDTIPDOK+LEFT(BRDOK,LEN(BRDOK)-1)+CHR(ASC(RIGHT(BRDOK,1))+1)
    AADD(aPom,IDFIRMA+"-"+IDTIPDOK+"-"+BRDOK)
    SEEK cKljuc
  ENDDO

  IF LEN(aPom)==0; gFiltNov:=""; RETURN .f.; ENDIF

  nD1:=LEN(IDFIRMA); nD2:=LEN(IDTIPDOK); nD3:=LEN(BRDOK)

  FOR i:=1 TO LEN(aPom)
   IF LEN(h)<i; AADD(h,""); ENDIF
  NEXT

  IF cVarijanta=="BRISI"
    IF nPom==0; nPom:=1; ENDIF
    IF nPom>LEN(aPom); nPom:=LEN(aPom); ENDIF
  ELSE
    ++nPom
    IF nPom>LEN(aPom); nPom:=1; ENDIF
  ENDIF

  IF !lSSIP99
    Box(,LEN(aPom)+4,18+IF(cVarijanta=="BRISI",1,0))
     IF cVarijanta=="BRISI"
       @ m_x+1, m_y+2 SAY "IZABERITE DOKUMENT "
       @ m_x+2, m_y+2 SAY "KOJI ZELITE BRISATI"
       @ m_x+3, m_y+2 SAY "컴컴컴컴컴컴컴컴컴�"
     ELSE
       @ m_x+1, m_y+2 SAY "IZABERITE DOKUMENT"
       @ m_x+2, m_y+2 SAY "   ZA STAMPANJE   "
       @ m_x+3, m_y+2 SAY "컴컴컴컴컴컴컴컴컴"
     ENDIF
     nPom:=Menu2(m_x+3,m_y+3,aPom,nPom)
    BoxC()
  ENDIF

  IF nPom>0
    gFiltNov:=LEFT(aPom[nPom],nD1)+SUBSTR(aPom[nPom],nD1+2,nD2)+RIGHT(aPom[nPom],nD3)
    SEEK gFiltNov
  ELSE
    gFiltNov:=""
  ENDIF

return IF(nPom=LEN(aPom).and.cVarijanta!="BRISI".or.nPom==0,.f.,.t.)
*}


/*! \fn FilterPrNovine()
 *  \brief Postavlja filter na zadani dokument sa gFiltNov
 *  \todo Pregledati gdje se koristi, izgleda da je vezano samo za ZIPS ili Opresu
 */
 
function FilterPrNovine()
*{
SET FILTER TO IDFIRMA+IDTIPDOK+BRDOK=gFiltNov
GO TOP
return
*}


