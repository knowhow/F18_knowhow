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

#include "fmk.ch"

function SetgaSDBFs()

PUBLIC gaSDBFs :={ ;
 {F_GPARAMS  , "GPARAMS",  P_ROOTPATH },; 
 {F_GPARAMSP , "GPARAMS",  P_PRIVPATH},;
 {F_PARAMS   , "PARAMS"  , P_PRIVPATH},;
 {F_KORISN   , "KORISN"  , P_TEKPATH },;
 {F_MPARAMS  , "MPARAMS" , P_TEKPATH },;
 {F_KPARAMS  , "KPARAMS" , P_KUMPATH },;
 {F_SECUR    , "SECUR"   , P_KUMPATH },;
 {F_ADRES    , "ADRES"   , P_SIFPATH },;
 {F_SIFK     , "SIFK"    , P_SIFPATH },;
 {F_SIFV     , "SIFV"    , P_SIFPATH  },;
 {F_TMP      , "TMP"     , P_PRIVPATH},;
 {F_SQLPAR   , "SQLPAR"  , P_KUMSQLPATH};
}
return

/*! \fn PreuzSezSPK(cSif)
 *  \brief Preuzimanje sifre iz sezone
 *  \param cSif
 */
 
function PreuzSezSPK(cSif)
*{
*static string
static cSezNS:="1998"
*;
 LOCAL nObl:=SELECT()
 Box(,3,70)
  cSezNS:=PADR(cSezNS,4)
  @ m_x+1,m_y+2 SAY "Sezona:" GET cSezNS PICT "9999"
  READ
  cSezNS:=ALLTRIM(cSezNS)
 BoxC()
 IF cSif=="P"
   USE (TRIM(cDirSif)+"\"+cSezNS+"\PARTN") ALIAS PARTN2 NEW
   SELECT PARTN2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idpartner
   IF FOUND()
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PARTN2->id,;
            naz WITH PARTN2->naz,;
         mjesto WITH PARTN2->mjesto
   ELSE
     SELECT PARTN
     APPEND BLANK
     REPLACE id WITH PSUBAN->idpartner
   ENDIF
   SELECT PARTN2; USE
 ELSE
   USE (TRIM(cDirSif)+"\"+cSezNS+"\KONTO") ALIAS KONTO2 NEW
   SELECT KONTO2
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK PSUBAN->idkonto
   IF FOUND()
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH KONTO2->id, naz WITH KONTO2->naz
   ELSE
     SELECT KONTO
     APPEND BLANK
     REPLACE id WITH PSUBAN->idkonto
   ENDIF
   SELECT KONTO2; USE
 ENDIF
 SELECT (nObl)
RETURN

