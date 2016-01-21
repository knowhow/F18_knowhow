/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// --------------------------------
// kontrola zbira naloga
// bDat = datumski uslov
// lSilent - ne prikazuj box
// vraca lRet - .t. ako je sve ok,
// .f. ako nije
// --------------------------------
FUNCTION KontrZb( bDat, lSilent )

   LOCAL lRet := .T.
   LOCAL nSaldo := 0
   LOCAL nSintD := 0
   LOCAL nSintP := 0
   LOCAL nSubD := 0
   LOCAL nSubP := 0
   LOCAL nNalD := 0
   LOCAL nNalP := 0
   LOCAL nAnalP := 0
   LOCAL nAnalD := 0
   LOCAL _line

   IF ( bDat == nil )
      bDat := .F.
   ENDIF

   IF ( lSilent == nil )
      lSilent := .F.
   ENDIF

   IF ( bDat )
      dDOd := CToD( "" )
      dDDo := Date()
      Box(, 1, 40 )
      @ 1 + m_x, 2 + m_y SAY "Datum od" GET dDOd
      @ 1 + m_x, 25 + m_y SAY "do" GET dDDo
      READ
      BoxC()
   ENDIF

   IF lSilent
      MsgO( "Provjeravam kontrolu zbira datoteka..." )
   ENDIF

   my_close_all_dbf()
   O_NALOG
   O_SUBAN
   O_SINT
   O_ANAL

   IF !lSilent

      Box( "KZD", 11, 77, .F. )

      SET CURSOR OFF

      _line := Replicate( "�", 10 ) + "�" + Replicate( "�", 16 ) + "�" + Replicate( "�", 16 ) + "�" + Replicate( "�", 16 ) + "�" + Replicate( "�", 16 )

      @ m_x + 1, m_y + 11 SAY "�" + PadC( "NALOZI", 16 ) + ;
         "�" + PadC( "SINTETIKA", 16 ) + ;
         "�" + PadC( "ANALITIKA", 16 ) + ;
         "�" + PadC( "SUBANALITIKA", 16 )

      @ m_x + 2, m_y + 1 SAY _line

      @ m_x + 3, m_y + 1 SAY "duguje " + ValDomaca()
      @ m_x + 4, m_y + 1 SAY "potraz." + ValDomaca()
      @ m_x + 5, m_y + 1 SAY "saldo  " + ValDomaca()
      @ m_x + 7, m_y + 1 SAY "duguje " + ValPomocna()
      @ m_x + 8, m_y + 1 SAY "potraz." + ValPomocna()
      @ m_x + 9, m_y + 1 SAY "saldo  " + ValPomocna()

      @ m_x + 10, m_y + 1 SAY _line

      @ m_x + 11, m_y + 1 SAY "ESC - izlaz"

      FOR i := 11 TO 65 STEP 17
         FOR j := 3 TO 9
            @ m_x + j, m_y + i SAY "�"
         NEXT
      NEXT
	
      picBHD := FormPicL( "9 " + gPicBHD, 16 )
      picDEM := FormPicL( "9 " + gPicDEM, 16 )

   ENDIF

   SELECT nalog
   GO TOP
	
   nDug := nPot := nDu2 := nPo2 := 0
   DO WHILE !Eof() .AND. Inkey() != 27
      IF ( bDat )
         IF ( field->datnal < dDOd .OR. field->datnal > dDDo )
            SKIP
            LOOP
         ENDIF
      ENDIF
      nDug += DugBHD
      nPot += PotBHD
      nDu2 += DugDEM
      nPo2 += PotDEM
      SKIP
   ENDDO

   nSaldo += nDug - nPot
   nNalD := nDug
   nNalP := nPot

   IF !lSilent
      IF LastKey() == K_ESC
         BoxC()
         CLOSERET
      ENDIF
      @ m_x + 3, m_y + 12 SAY nDug PICTURE picBHD
      @ m_x + 4, m_y + 12 SAY nPot PICTURE picBHD
      @ m_x + 5, m_y + 12 SAY nDug - nPot PICTURE picBHD
      @ m_x + 7, m_y + 12 SAY nDu2 PICTURE picDEM
      @ m_x + 8, m_y + 12 SAY nPo2 PICTURE picDEM
      @ m_x + 9, m_y + 12 SAY nDu2 - nPo2 PICTURE picDEM
   ENDIF

   SELECT SINT
   GO TOP
   nDug := nPot := nDu2 := nPo2 := 0
   GO TOP
   DO WHILE !Eof() .AND. Inkey() != 27
      IF ( bDat )
         IF ( field->datnal < dDOd .OR. field->datnal > dDDo )
            SKIP
            LOOP
         ENDIF
      ENDIF
      nDug += Dugbhd
      nPot += Potbhd
      nDu2 += Dugdem
      nPo2 += Potdem
      SKIP
   ENDDO

   nSaldo += nDug - nPot
   nSintD := nDug
   nSintP := nPot

   IF !lSilent
      ESC_BCR
      @ m_x + 3, m_y + 29 SAY nDug PICTURE picBHD
      @ m_x + 4, m_y + 29 SAY nPot PICTURE picBHD
      @ m_x + 5, m_y + 29 SAY nDug - nPot PICTURE picBHD
      @ m_x + 7, m_y + 29 SAY nDu2 PICTURE picDEM
      @ m_x + 8, m_y + 29 SAY nPo2 PICTURE picDEM
      @ m_x + 9, m_y + 29 SAY nDu2 - nPo2 PICTURE picDEM
   ENDIF

   SELECT ANAL
   GO TOP
   nDug := nPot := nDu2 := nPo2 := 0
   DO WHILE !Eof() .AND. Inkey() != 27
      IF ( bDat )
         IF ( field->datnal < dDOd .OR. field->datnal > dDDo )
            SKIP
            LOOP
         ENDIF
      ENDIF
      nDug += Dugbhd
      nPot += Potbhd
      nDu2 += Dugdem
      nPo2 += Potdem
      SKIP
   ENDDO

   nSaldo += nDug - nPot
   nAnalD := nDug
   nAnalP := nPot

   IF !lSilent
      ESC_BCR
      @ m_x + 3, m_y + 46 SAY nDug PICTURE picBHD
      @ m_x + 4, m_y + 46 SAY nPot PICTURE picBHD
      @ m_x + 5, m_y + 46 SAY nDug - nPot PICTURE picBHD
      @ m_x + 7, m_y + 46 SAY nDu2 PICTURE picDEM
      @ m_x + 8, m_y + 46 SAY nPo2 PICTURE picDEM
      @ m_x + 9, m_y + 46 SAY nDu2 - nPo2 PICTURE picDEM
   ENDIF

   SELECT SUBAN
   nDug := nPot := nDu2 := nPo2 := 0
   GO TOP

   DO WHILE !Eof() .AND. Inkey() != 27
      IF ( bDat )
         IF ( field->datdok < dDOd .OR. field->datdok > dDDo )
            SKIP
            LOOP
         ENDIF
      ENDIF
		
      IF D_P == "1"
         nDug += Iznosbhd
         nDu2 += Iznosdem
      ELSE
         nPot += Iznosbhd
         nPo2 += Iznosdem
      ENDIF
      SKIP
   ENDDO

   nSaldo += nDug - nPot
   nSubD := nDug
   nSubP := nPot

   IF !lSilent
      ESC_BCR
      @ m_x + 3, m_y + 63 SAY nDug PICTURE picBHD
      @ m_x + 4, m_y + 63 SAY nPot PICTURE picBHD
      @ m_x + 5, m_y + 63 SAY nDug - nPot PICTURE picBHD
      @ m_x + 7, m_y + 63 SAY nDu2 PICTURE picDEM
      @ m_x + 8, m_y + 63 SAY nPo2 PICTURE picDEM
      @ m_x + 9, m_y + 63 SAY nDu2 - nPo2 PICTURE picDEM
      WHILE Inkey( 0.1 ) != K_ESC
      END
      BoxC()
   ENDIF

   // provjeri da li su podaci tacni !
   IF ( Round( nSaldo, 2 ) > 0 ) .OR. ( Round( nSubD + nNalD + nAnalD + nSintD, 2 ) <> Round( nSubP + nNalP + nAnalP + nSintP, 2 ) )
      lRet := .F.
   ENDIF

   IF gnKZBdana > 0
      // upisi u params podatak o datumu povlacenja...
      set_metric( "fin_kontrola_zbira_datum", nil, Date() )
   ENDIF

   IF lSilent
      MsgC()
   ENDIF

   RETURN lRet


// -------------------------------------------------
// automatsko pokretanje kontrole zbira datoteka
// -------------------------------------------------
FUNCTION auto_kzb()

   LOCAL dDate := Date()
   LOCAL nTArea := Select()
   LOCAL lKzbOk
   LOCAL dLastDate := Date()
   PRIVATE cSection := "9"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   IF gnKZBdana == 0
      RETURN
   ENDIF

   // uzmi datum zadnjeg povlacenja kontrole zbira
   dLastDate := fetch_metric( "fin_kontrola_zbira_datum", nil, dLastdate )

   // ako je manje od KZBdana ne pozivaj opciju...
   IF ( dDate - dLastDate ) <= gnKZBdana
      SELECT ( nTArea )
      RETURN
   ENDIF

   lKzbOk := kontrzb( nil, .T. )

   IF !lKzbOk
      MsgBeep( "Kontrola zbira datoteka je pronasla greske!#Pregledajte greske..." )
      kontrzb()
   ENDIF

   SELECT ( nTArea )

   RETURN
