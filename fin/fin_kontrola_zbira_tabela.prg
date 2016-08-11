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
FUNCTION fin_kontrola_zbira( bDat, lSilent )

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


   IF !lSilent

      Box( "KZD", 11, 77, .F. )

      SET CURSOR OFF

      _line := Replicate( "=", 10 ) + " " + Replicate( "=", 16 ) + " " + ;
         Replicate( "=", 16 ) + " " + Replicate( "=", 16 ) + " " + Replicate( "=", 16 )

      @ m_x + 1, m_y + 11 SAY "|" + PadC( "NALOZI", 16 ) + ;
         "|" + PadC( "SINTETIKA", 16 ) + ;
         "|" + PadC( "ANALITIKA", 16 ) + ;
         "|" + PadC( "SUBANALITIKA", 16 )

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
            @ m_x + j, m_y + i SAY "|"
         NEXT
      NEXT

      picBHD := FormPicL( "9 " + gPicBHD, 16 )
      picDEM := FormPicL( "9 " + gPicDEM, 16 )

   ENDIF

   fin_kzb_nalog()
   IF !lSilent
      IF LastKey() == K_ESC
         BoxC()
         CLOSERET
      ENDIF
      @ m_x + 3, m_y + 12 SAY duguje PICTURE picBHD
      @ m_x + 4, m_y + 12 SAY potrazuje PICTURE picBHD
      @ m_x + 5, m_y + 12 SAY duguje - potrazuje PICTURE picBHD
      @ m_x + 7, m_y + 12 SAY duguje2 PICTURE picDEM
      @ m_x + 8, m_y + 12 SAY potrazuje2 PICTURE picDEM
      @ m_x + 9, m_y + 12 SAY duguje2 - potrazuje2 PICTURE picDEM
   ENDIF

   fin_kzb_sint()
   IF !lSilent
      ESC_BCR
      @ m_x + 3, m_y + 29 SAY duguje PICTURE picBHD
      @ m_x + 4, m_y + 29 SAY potrazuje PICTURE picBHD
      @ m_x + 5, m_y + 29 SAY duguje - potrazuje PICTURE picBHD
      @ m_x + 7, m_y + 29 SAY duguje2 PICTURE picDEM
      @ m_x + 8, m_y + 29 SAY potrazuje2 PICTURE picDEM
      @ m_x + 9, m_y + 29 SAY duguje2 - potrazuje2 PICTURE picDEM
   ENDIF

   fin_kzb_anal()
   IF !lSilent
      ESC_BCR


      @ m_x + 3, m_y + 46 SAY duguje PICTURE picBHD
      @ m_x + 4, m_y + 46 SAY potrazuje PICTURE picBHD
      @ m_x + 5, m_y + 46 SAY duguje - potrazuje PICTURE picBHD
      @ m_x + 7, m_y + 46 SAY duguje2 PICTURE picDEM
      @ m_x + 8, m_y + 46 SAY potrazuje2 PICTURE picDEM
      @ m_x + 9, m_y + 46 SAY duguje2 - potrazuje2 PICTURE picDEM
   ENDIF


   fin_kzb_suban()
   IF !lSilent
      ESC_BCR

      @ m_x + 3, m_y + 63 SAY duguje PICTURE picBHD
      @ m_x + 4, m_y + 63 SAY potrazuje PICTURE picBHD
      @ m_x + 5, m_y + 63 SAY duguje - potrazuje PICTURE picBHD
      @ m_x + 7, m_y + 63 SAY duguje2 PICTURE picDEM
      @ m_x + 8, m_y + 63 SAY potrazuje2 PICTURE picDEM
      @ m_x + 9, m_y + 63 SAY duguje2 - potrazuje2 PICTURE picDEM

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

   lKzbOk := fin_kontrola_zbira( nil, .T. )

   IF !lKzbOk
      MsgBeep( "Kontrola zbira datoteka je pronasla greske!#Pregledajte greske..." )
      fin_kontrola_zbira()
   ENDIF

   SELECT ( nTArea )

   RETURN .T.




FUNCTION fin_kzb_suban()

   LOCAL cTable := "SUBAN"
   LOCAL cSql :=  "select "

   cSql += "sum(CASE WHEN d_p='1' THEN iznosbhd ELSE 0 END) as duguje,"
   cSql += "sum(CASE WHEN d_p='2' THEN iznosbhd ELSE 0 END) as potrazuje,"
   cSql += "sum(CASE WHEN d_p='1' THEN iznosdem ELSE 0 END) as duguje2,"
   cSql += "sum(CASE WHEN d_p='2' THEN iznosdem ELSE 0 END) as potrazuje2"
   cSql += " from fmk.fin_suban"

   RETURN use_sql( cTable, cSql )

FUNCTION fin_kzb_anal()

   LOCAL cTable := "ANAL"
   LOCAL cSql :=  "select "

   cSql += "coalsece(sum(dugbhd),0) as duguje,"
   cSql += "coalsece(sum(potbhd),0) as potrazuje,"
   cSql += "coalsece(sum(dugdem),0) as duguje2,"
   cSql += "coalsece(sum(potdem),0) as potrazuje2"
   cSql += " from fmk.fin_anal"

   RETURN use_sql( cTable, cSql )


FUNCTION fin_kzb_sint()

   LOCAL cTable := "SINT"
   LOCAL cSql :=  "select "

   cSql += "coalsece(sum(dugbhd),0) as duguje,"
   cSql += "coalsece(sum(potbhd),0) as potrazuje,"
   cSql += "coalsece(sum(dugdem),0) as duguje2,"
   cSql += "coalsece(sum(potdem),0) as potrazuje2"
   cSql += " from fmk.fin_sint"

   RETURN use_sql( cTable, cSql )

FUNCTION fin_kzb_nalog()

   LOCAL cTable := "NALOG"
   LOCAL cSql :=  "select "

   cSql += "coalsece(sum(dugbhd),0) as duguje,"
   cSql += "coalsece(sum(potbhd),0) as potrazuje,"
   cSql += "coalsece(sum(dugdem),0) as duguje2,"
   cSql += "coalsece(sum(potdem),0) as potrazuje2"
   cSql += " from fmk.fin_nalog"

   RETURN use_sql( cTable, cSql )
