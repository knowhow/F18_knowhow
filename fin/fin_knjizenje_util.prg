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

/*! \fn SetDatUPripr()
 *  \brief Postavi datum u pripremi
 */
function SetDatUPripr()
local _rec

  PRIVATE cTDok:="00"
  PRIVATE dDatum:=CTOD("01.01." + STR(YEAR(DATE()),4))
  IF !VarEdit({ {"Postaviti datum dokumenta","dDatum",,,},;
                {"Promjenu izvrsiti u nalozima vrste","cTDok",,,} }, 10,0,15,79,;
              'SETOVANJE NOVOG DATUMA DOKUMENTA I PREBACIVANJE STAROG U DATUM VALUTE',;
              "B1")
    CLOSERET
  ENDIF

  O_FIN_PRIPR
  GO TOP
  DO WHILE !EOF()
    IF IDVN<>cTDok
       SKIP 1
       LOOP
    ENDIF
    _rec := dbf_get_rec()
    IF EMPTY(_rec["datval"])
      _rec["datval"] := _rec["datdok"]
    ENDIF
    _rec["datdok"] := dDatum
    dbf_update_rec(_rec)
    SKIP 1
  ENDDO

CLOSERET
return

/*! \fn K3Iz256(cK3)
 *  \brief 
 *  \param cK3
 */
 
function K3Iz256(cK3)
*{
 LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    IF !EMPTY(cK3)
      FOR i:=LEN(cK3) TO 1 STEP -1
        d += ASC(SUBSTR(cK3,i,1)) * 256^(LEN(cK3)-i)
      NEXT
      cK3:=""
      DO WHILE .t.
        c := INT(d/11)
        o := d%11
        cK3 := aC[o+1] + cK3
        IF c=0; EXIT; ENDIF
        d := c
      ENDDO
    ENDIF
    cK3:=PADL(cK3,3)
  ENDIF
RETURN cK3
*}


/*! \fn K3U256(cK3)
 *  \brief
 *  \cK3
 */
 
function K3U256(cK3)
*{
LOCAL i,c,o,d:=0,aC:={" ","0","1","2","3","4","5","6","7","8","9"}
  IF !EMPTY(cK3) .and. IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
    FOR i:=1 TO LEN(cK3)
      p := ASCAN( aC , SUBSTR(cK3,i,1) ) - 1
      d += p * 11^(LEN(cK3)-i)
    NEXT
    cK3:=""
    DO WHILE .t.
      c := INT(d/256)
      o := d%256
      cK3 := CHR(o) + cK3
      IF c=0; EXIT; ENDIF
      d := c
    ENDDO
    cK3:=PADL(cK3,2,CHR(0))
  ENDIF
RETURN cK3



