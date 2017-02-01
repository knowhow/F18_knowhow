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



// ----------------------------------
// pregled destinacije
// ----------------------------------
FUNCTION P_Destin( cId, cPartId, dx, dy )

   LOCAL GetList := {}
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}
   PRIVATE cLastOznaka := " "
   PRIVATE cIdTek := cPartId
   PRIVATE nArr := Select()

   SELECT DEST
   SET ORDER TO TAG "ID"

   HSEEK cIdTek + cId

   SET SCOPE TO cIdTek

   ImeKol := { ;
      { "OZNAKA", {|| OZNAKA },  "OZNAKA"  }, ;
      { "NAZIV", {|| NAZ    },  "NAZ"     }, ;
      { "NAZIV2", {|| NAZ2   },  "NAZ2"    }, ;
      { "PTT", {|| PTT    },  "PTT"     }, ;
      { "MJESTO", {|| MJESTO },  "MJESTO"  }, ;
      { "ADRESA", {|| ADRESA },  "ADRESA"  }, ;
      { "TELEFON", {|| TELEFON },  "TELEFON" }, ;
      { "FAX", {|| FAX    },  "FAX"     }, ;
      { "MOBTEL", {|| MOBTEL },  "MOBTEL"  };
      }
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   p_sifra( F_DEST, "ID", 10, 70, "Destinacije za:" + cIdTek + "-" + Ocitaj( F_PARTN, cIdTek, "naz" ), , , , {| Ch| EdDestBlok( Ch ) },,,, .F. )

   cId := cLastOznaka
   SET scope TO
   SELECT ( nArr )

   RETURN .T.

// --------------------------------
// key handler
// --------------------------------
FUNCTION EdDestBlok( Ch, cDest )

   LOCAL GetList := {}
   LOCAL nRet := DE_CONT

   DO CASE
   CASE Ch == K_F2  .OR. Ch == K_CTRL_N

      sID       := cIdTek
      sOZNAKA   := IF( Ch == K_CTRL_N, cDest, OZNAKA )
      sNAZ      := IF( Ch == K_CTRL_N, Ocitaj( F_PARTN, cIdTek, "naz" ), NAZ )
      sNAZ2     := IF( Ch == K_CTRL_N, Ocitaj( F_PARTN, cIdTek, "naz2" ), NAZ2 )
      sPTT      := PTT
      sMJESTO   := MJESTO
      sADRESA   := ADRESA
      sTELEFON  := TELEFON
      sFAX      := FAX
      sMOBTEL   := MOBTEL

      Box(, 11, 75, .F. )
      @ m_x + 2, m_y + 2 SAY "Oznaka destinacije" GET sOZNAKA   PICT "@!"
      @ m_x + 3, m_y + 2 SAY "NAZIV             " GET sNAZ
      @ m_x + 4, m_y + 2 SAY "NAZIV2            " GET sNAZ2
      @ m_x + 5, m_y + 2 SAY "PTT broj          " GET sPTT      PICT "@!"
      @ m_x + 6, m_y + 2 SAY "Mjesto            " GET sMJESTO   PICT "@!"
      @ m_x + 7, m_y + 2 SAY "Adresa            " GET sADRESA   PICT "@!"
      @ m_x + 8, m_y + 2 SAY "Telefon           " GET sTELEFON  PICT "@!"
      @ m_x + 9, m_y + 2 SAY "Fax               " GET sFAX      PICT "@!"
      @ m_x + 10, m_y + 2 SAY "Mobitel           " GET sMOBTEL   PICT "@!"
      READ
      BoxC()
      IF Ch == K_CTRL_N .AND. LastKey() <> K_ESC
         APPEND BLANK
         REPLACE id WITH sid
      ENDIF
      IF LastKey() <> K_ESC
         REPLACE OZNAKA   WITH sOZNAKA,;
            NAZ      WITH sNAZ,;
            NAZ2     WITH sNAZ2,;
            PTT      WITH sPTT,;
            MJESTO   WITH sMJESTO,;
            ADRESA   WITH sADRESA,;
            TELEFON  WITH sTELEFON,;
            FAX      WITH sFAX,;
            MOBTEL   WITH sMOBTEL
      ENDIF
      nRet := DE_REFRESH
   CASE Ch == K_CTRL_T
      IF Pitanje(, "Izbrisati stavku ?", "N" ) == "D"
         DELETE
      ENDIF
      nRet := DE_DEL
   CASE Ch == K_ESC .OR. Ch == K_ENTER
      cLastOznaka := DEST->OZNAKA

   ENDCASE

   RETURN nRet
