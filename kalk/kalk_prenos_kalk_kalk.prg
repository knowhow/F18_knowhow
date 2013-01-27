/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "kalk.ch"

/*! \file fmk/kalk/razdb/1g/ka_ka.prg
 *  \brief Preuzimanje kalkulacije iz druge firme
 */


/*! \fn IzKalk2f()
 *  \brief Preuzimanje kalkulacije iz druge firme
 */

function IzKalk2f()
 LOCAL cDir:=KUMPATH, cF
 cDir := ""
 IF RIGHT(cDir,1)!="\"; cDir+="\"; ENDIF
 cDir:=UPPER(cDir)
 cF:=RIGHT(cDir,3); cF:=LEFT(cF,2); cF:=IF(cF="M",RIGHT(cF,1),cF)

 cFirma:="  "

 O_KONTO
 O_PARTN
 O_KALK_PRIPR
 IF RECCOUNT2()>0
   MsgBeep("Prvo ispraznite tabelu pripreme!")
   CLOSERET
 ENDIF

 // otvorimo DOKS
 // -------------
 MY_USE ("KALK_DOKS", .t., "NEW")

 Box("#PRENOS KALK DOKUMENTA IZ FIRME "+cF,10,75)
  DO WHILE .t.

    // biraj magacin (IDFIRMA)
    // -----------------------
    @ m_x+2, m_y+2 SAY "Oznaka firme/magacina" GET cFirma PICT "@!"
    READ
    IF LASTKEY()==K_ESC; EXIT; ENDIF

    // nadi najstariju KALK koja nikad nije prenoçena (marker<>"PP")
    // -------------------------------------------------------------
    SELECT KALK_DOKS
    SET ORDER TO TAG "3" // IdFirma+dtos(datdok)+podbr+idvd+brdok
    HSEEK cFirma
    DO WHILE !EOF() .and. idfirma==cFirma
      IF podbr<>"PP"
        EXIT
      ENDIF
      SKIP 1
    ENDDO

    IF EOF()
      MsgBeep("Za firmu/magacin '"+cFirma+"' ne postoji nijedan dokument "+;
              "koji nije vec prenosen!#Ukucajte sami broj kalkulacije koju "+;
              "zelite ponovo prenijeti!")
      cIDVD:="  "; cBrDok:=SPACE(8)
    ELSE
      cIDVD:=idvd; cBrDok:=brdok
    ENDIF

    // potvrdi ponuÐeni ili unesi broj kalkulacije idfirma-idvd-brkalk
    // ---------------------------------------------------------------
    @ m_x+2, m_y+27 SAY "-" GET cIdVd
    @ m_x+2, m_y+32 SAY "-" GET cBrDok
    READ
    IF LASTKEY()==K_ESC; EXIT; ENDIF

    // provjeri ima li takva kalkulacija i ako je vec prenosena daj upozorenje
    // -----------------------------------------------------------------------
    SET ORDER TO TAG "1"  // IdFirma+idvd+brdok
    HSEEK cFirma+cIdVd+cBrDok
    IF !FOUND()
      MsgBeep("Zadana kalkulacija ne postoji!")
      LOOP
    ELSE
      cMKONTO    := MKONTO
      cPKONTO    := PKONTO
      cIDPARTNER := IDPARTNER
      cPom:=" "
      // provjeri da li su ispravni konto i partner
      @ m_x+4, m_y+2 SAY "Provjerite sljedece sifre i ako treba ispravite ih:"
      @ m_x+5, m_y+2 SAY "Magacinski konto " GET cMKONTO    VALID P_Konto(@cMKONTO)
      @ m_x+6, m_y+2 SAY "Prodavnicki konto" GET cPKONTO    VALID P_Konto(@cPKONTO)
      @ m_x+7, m_y+2 SAY "Partner          " GET cIDPARTNER VALID P_Firma(@cIDPARTNER)
      @ m_x+8, m_y+2 SAY "--------<Esc> prekid-----<Enter> nastavak-------" GET cPom
      READ
      IF LASTKEY()==K_ESC; EXIT; ENDIF
    ENDIF

    // poçto je utvrÐeno da postoji, otvaramo KALK radi prenosa
    // --------------------------------------------------------
    my_use ("KALK", .t., "NEW")
    SET ORDER TO TAG "1" // idFirma+IdVD+BrDok+RBr
    HSEEK cFirma+cIdVd+cBrDok

    DO WHILE !EOF() .and. cFirma+cIdVd+cBrDok==IdFirma+IdVd+BrDok
      Scatter()
      SELECT KALK_PRIPR
      APPEND BLANK
      Gather()
      SELECT KALK
      SKIP 1
    ENDDO

    // u DOKS stavimo marker "PP" da je kalkulacija vec jednom prenoçena
    // -----------------------------------------------------------------
    SELECT KALK
     USE
    SELECT KALK_DOKS
     Scatter()
     _podbr:="PP"
     Gather()
     USE

    // utvrdimo broj nove kalkulacije
    // ------------------------------
    cBrDokI := kalk_brdok_0(gFirma, cIdVD, DATE())

    SELECT KALK_PRIPR; SET ORDER TO
    GO TOP
    DO WHILE !EOF()
      Scatter()
       _idfirma   := gFirma
       _brdok     := cBrDokI

       IF _idkonto==_mkonto
         _idkonto := cMKONTO
       ELSEIF _idkonto==_pkonto
         _idkonto := cPKONTO
       ENDIF

       IF _idkonto2==_mkonto
         _idkonto2 := cMKONTO
       ELSEIF _idkonto2==_pkonto
         _idkonto2 := cPKONTO
       ENDIF

       _mkonto    := cMKONTO
       _pkonto    := cPKONTO
       _idpartner := cIDPARTNER
      Gather()
      SKIP 1
    ENDDO

    MsgBeep("Dokument je prenesen. Predjite u tabelu pripreme!")
    EXIT

  ENDDO
 BoxC()

CLOSERET
return
*}

