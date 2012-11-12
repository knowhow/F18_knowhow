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

#include "fin.ch"

/*! \fn IzvodBanke()
 *  \brief Formira nalog u pripremi na osnovu txt-izvoda iz banke
 */
 
function IzvodBanke()
*{
 LOCAL nIF:=1, cBrNal:=""
 PRIVATE cLFSpec := "A:\ZEN*.", cIdVn:="99"

 O_NALOG
 O_FIN_PRIPR
 if reccount2()<>0
   Msg("Priprema mora biti prazna !")
   closeret
 endif

 Box(,20,75); old_m_x := m_x; old_m_y := m_y

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" ",aHistory:={}
    RPar("f1",@cLFSpec)
     RPar("f2",@cIdVn)
      SELECT PARAMS; USE

  cLFSpec:=PADR(cLFSpec,50)
  @ m_x+2, m_y+2 SAY "Lokacija i specifikacija fajla-izvoda banke" GET cLFSpec PICT "@!S30"
  @ m_x+3, m_y+2 SAY "Vrsta naloga koji se formira (prazno-ne formiraj nalog):" GET cIdVn
  READ; ESC_BCR
  cLFSpec:=TRIM(cLFSpec)

  O_PARAMS
   PRIVATE cSection:="7",cHistory:=" "; aHistory:={}
    WPar("f1",cLFSpec)
     WPar("f2",cIdVn)
      SELECT PARAMS; USE

  aFajlovi := DIRECTORY(cLFSpec)
  IF LEN(aFajlovi)<1
    MsgBeep("Na izabranoj lokaciji ne postoji nijedan specificirani fajl!")
    BoxC(); CLOSERET
  ENDIF

  FOR i:=1 TO LEN(aFajlovi); aFajlovi[i]:=PADR(aFajlovi[i,1],20); NEXT
  nIF := Menu("IBan",aFajlovi,nIF,.f.)
  IF nIF<1
    BoxC(); CLOSERET
  ELSE
    // zatvaranje prozora menija
    // -------------------------
    Menu("IBan",aFajlovi,0,.f.)
  ENDIF
  cIme := LEFT(cLFSpec,2)+"\"+TRIM(aFajlovi[nIF])
  m_x := old_m_x; m_y := old_m_y
  @ m_x+4, m_y+2 SAY "Izabran fajl:"
  @ m_x+4, col()+2 SAY cIme COLOR INVERT

  nH   := fopen(cIme)
  nRBr := 0
  cBrNal := fin_novi_broj_dokumenta( gFirma, cIdvn )
  
  StartPrint(.t.)

  P_COND2
  ? "ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
  ? "³R.BR³ DATUM  ³ZIRO-RACUN      ³POSILJAOC: NAZIV, ADRESA I MJESTO                                                         ³POZIV NA BROJ                     ³"
  ? "ÃÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÁÂÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´"
  ? "³SIFRA I OPIS SVRHE DOZNAKE                                     ³     IZNOS    ³D/P³MAT.BROJ     ³VR.UPL.³VR.PRIH.³ DAT.OD ³ DAT.DO ³OP³ P.NA BR. ³BUDZ.ORG.³"
  ? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ"

  DO WHILE .T.

    cString := Freadln(nH,1,268)
    cString := STRTRAN( cString , CHR(0) , " " )

    IF LEN(TRIM(cString)) < 2
      EXIT
    ENDIF

    w_DatDok := CTOD( SUBSTR( cString , 1 , 2 ) + "." +;
                      SUBSTR( cString , 3 , 2 ) + "." +;
                      SUBSTR( cString , 5 , 2 ) )

    w_ZiroR  := SUBSTR( cString ,   7 , 16 )
    w_SaljeN := SUBSTR( cString ,  23 , 30 )
    w_SaljeA := SUBSTR( cString ,  53 , 30 )
    w_SaljeM := SUBSTR( cString ,  83 , 30 )
    w_PNABR  := SUBSTR( cString , 113 , 26 )
    w_SifDoz := SUBSTR( cString , 139 ,  3 )
    w_SvrDoz := SUBSTR( cString , 142 , 60 )

    w_Iznos  := VAL( SUBSTR( cString , 202 , 10 )+"."+;
                     SUBSTR( cString , 212 ,  2 ) )

    w_DugPot := SUBSTR( cString , 214 ,  1 )
    w_MatBr  := SUBSTR( cString , 215 , 13 )
    w_VrUpl  := SUBSTR( cString , 228 ,  1 )
    w_VrPrih := SUBSTR( cString , 229 ,  6 )

    w_DatOd  := CTOD( SUBSTR( cString , 235 , 2 ) + "." +;
                      SUBSTR( cString , 237 , 2 ) + "." +;
                      SUBSTR( cString , 239 , 2 ) )

    w_DatDo  := CTOD( SUBSTR( cString , 241 , 2 ) + "." +;
                      SUBSTR( cString , 243 , 2 ) + "." +;
                      SUBSTR( cString , 245 , 2 ) )

    w_Opcina := SUBSTR( cString , 247 ,  3 )
    w_PNABR2 := SUBSTR( cString , 250 , 10 )
    w_BudOrg := SUBSTR( cString , 260 ,  7 )

    ++nRBr

    // TEST:
    // ? nRBr, w_datdok, w_ziror, w_opcina, w_pnabr2, w_budorg

    IF prow()>60
      FF
      ? "ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
      ? "³R.BR³ DATUM  ³ZIRO-RACUN      ³POSILJAOC: NAZIV, ADRESA I MJESTO                                                         ³POZIV NA BROJ                     ³"
      ? "ÃÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÁÂÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´"
      ? "³SIFRA I OPIS SVRHE DOZNAKE                                     ³     IZNOS    ³D/P³MAT.BROJ     ³VR.UPL.³VR.PRIH.³ DAT.OD ³ DAT.DO ³OP³ P.NA BR. ³BUDZ.ORG.³"
      ? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ"
    ENDIF


    ? " "+STR(nRBR,4), w_DatDok, w_ZiroR, PADR(TRIM(w_SaljeN)+", "+TRIM(w_SaljeA)+", "+TRIM(w_SaljeM),90), w_PNABR
    ? " "+w_SifDoz, w_SvrDoz, w_Iznos, IF(w_DugPot=="1","dug","pot"), w_MatBr
    ?? " "+PADR(w_VrUpl,7), PADR(w_VrPrih,8), w_DatOd, w_DatDo, w_Opcina, w_PNABR2, w_BudOrg
    ? REPL("-",160)

    IF !EMPTY(cIdVn)
      select fin_pripr
      APPEND BLANK
      REPLACE idfirma   with  gFirma      ,;
              idvn      with  cIdVn       ,;
              brnal     with  cBrNal      ,;
              datdok    with  w_datdok    ,;
              d_p       with  w_DugPot    ,;
              iznosbhd  with  w_iznos     ,;
              rbr       with  str(nRBr,4) ,;
              idkonto   with  w_VrPrih    ,;
              opis      with  w_SvrDoz
    ENDIF

  ENDDO

  FClose(nH)

  FF
  EndPrint()

  IF !EMPTY(cIdVn)
    MsgBeep("Preuzimanje izvoda zavrseno. Vratite se u pripremu tipkom <Esc>!")
  ELSE
    MsgBeep("Pregled izvoda zavrsen. Vratite se u pripremu tipkom <Esc>!")
  ENDIF

 BoxC()
CLOSERET
return
*}



