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


#include "ld.ch"

STATIC __var_obr



FUNCTION RekapLd( cId, nGodina, nMjesec, nIzn1, nIzn2, cIdPartner, cOpis, cOpis2, lObavDodaj, cIzdanje )

   IF lObavDodaj == nil
      lObavDodaj := .F.
   ENDIF

   IF cIdPartner = NIL
      cIdPartner = ""
   ENDIF

   IF cOpis = nil
      cOpis = ""
   ENDIF

   IF cOpis2 = nil
      cOpis2 = ""
   ENDIF

   IF cIzdanje == nil
      cIzdanje := ""
   ENDIF

   pushwa()

   SELECT rekld
   IF lObavDodaj
      APPEND BLANK
   ELSE
      SEEK Str( nGodina, 4 ) + Str( nMjesec, 2 ) + cId + " "
      IF !Found()
         APPEND BLANK
      ENDIF
   ENDIF

   REPLACE godina WITH Str( nGodina, 4 ), mjesec WITH Str( nMjesec, 2 ), ;
      id    WITH  cId, ;
      iznos1 WITH nIzn1, iznos2 WITH nIzn2, ;
      idpartner WITH cIdPartner, ;
      opis WITH cOpis,;
      opis2 WITH cOpis2


   popwa()

   RETURN



FUNCTION ORekap()

   O_POR
   O_DOPR
   O_PAROBR
   O_LD_RJ
   O_RADN
   O_STRSPR
   O_KBENEF
   O_VPOSLA
   O_OPS
   O_RADKR
   O_KRED
   O_LD

   tipprn_use()

   RETURN




FUNCTION BoxRekSvi()

   LOCAL nArr

   nArr := Select()

   Box(, 10 + IF( IsRamaGlas(), 1, 0 ), 75 )
   DO WHILE .T.

      @ m_x + 2, m_y + 2 SAY "Vrsta djelatnosti: "  GET cRTipRada ;
            VALID val_tiprada( cRTipRada ) PICT "@!"

      @ m_x + 3, m_y + 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
      @ m_x + 4, m_y + 2 SAY "Za mjesece od:"  GET  cmjesec  PICT "99" VALID {|| cMjesecDo := cMjesec, .T. }
      @ m_x + 4, Col() + 2 SAY "do:"  GET  cMjesecDo  PICT "99" VALID cMjesecDo >= cMjesec
      @ m_x + 4, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      @ m_x + 5, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
      @ m_x + 7, m_y + 2 SAY "Strucna Sprema: "  GET  cStrSpr PICT "@!" VALID Empty( cStrSpr ) .OR. P_StrSpr( @cStrSpr )
      @ m_x + 8, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
      @ m_x + 9, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )

      READ

      ClvBox()
      ESC_BCR
      aUsl1 := Parsiraj( qqRJ, "IDRJ" )
      aUsl2 := Parsiraj( qqRJ, "ID" )
      IF aUsl1 <> NIL .AND. aUsl2 <> nil
         EXIT
      ENDIF
   ENDDO
   BoxC()

   SELECT ( nArr )

   RETURN


FUNCTION BoxRekJ()

   LOCAL nArr

   nArr := Select()

   Box(, 8 + IF( IsRamaGlas(), 1, 0 ), 75 )
   @ m_x + 1, m_y + 2 SAY "Vrsta djelatnosti: "  GET cRTipRada ;
         VALID val_tiprada( cRTipRada ) PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Radna jedinica: "  GET cIdRJ
   @ m_x + 3, m_y + 2 SAY "Za mjesece od:"  GET  cmjesec  PICT "99" VALID {|| cMjesecDo := cMjesec, .T. }
   @ m_x + 3, Col() + 2 SAY "do:"  GET  cMjesecDo  PICT "99" VALID cMjesecDo >= cMjesec
   @ m_x + 3, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ m_x + 4, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 6, m_y + 2 SAY "Strucna Sprema: "  GET  cStrSpr PICT "@!" VALID Empty( cStrSpr ) .OR. P_StrSpr( @cStrSpr )
   @ m_x + 7, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
   @ m_x + 8, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )
   READ
   ClvBox()
   ESC_BCR
   BoxC()

   SELECT ( nArr )

   RETURN


FUNCTION CreRekLD()

   aDbf := { { "GODINA",  "C",  4, 0 },;
      { "MJESEC",  "C",  2, 0 },;
      { "ID",  "C", 40, 0 },;
      { "opis",  "C", 100, 0 },;
      { "opis2",  "C", 100, 0 },;
      { "iznos1",  "N", 25, 4 },;
      { "iznos2",  "N", 25, 4 },;
      { "idpartner",  "C",  6, 0 } }


   DBCREATE2( KUMPATH + "REKLD", aDbf )

   SELECT ( F_REKLD )
   my_usex( "rekld" )

   INDEX ON  godina + mjesec + id TAG "1"

   SET ORDER TO TAG "1"
   USE

   RETURN


FUNCTION CreOpsLD()

   aDbf := { { "ID","C", 1, 0 }, ;
      { "PORID","C", 2, 0 }, ;
      { "IDOPS","C", 4, 0 }, ;
      { "IZNOS","N", 25, 4 }, ;
      { "IZNOS2", "N", 25, 4 }, ;
      { "IZNOS3", "N", 25, 4 }, ;
      { "IZNOS4", "N", 25, 4 }, ;
      { "IZNOS5", "N", 25, 4 }, ;
      { "IZNOS6", "N", 25, 4 }, ;
      { "IZNOS7", "N", 25, 4 }, ;
      { "BR_OSN", "N", 25, 4 }, ;
      { "IZN_OST", "N", 25, 4 }, ;
      { "T_ST_1", "N", 5, 2 }, ;
      { "T_ST_2", "N", 5, 2 }, ;
      { "T_ST_3", "N", 5, 2 }, ;
      { "T_ST_4", "N", 5, 2 }, ;
      { "T_ST_5", "N", 5, 2 }, ;
      { "T_IZ_1", "N", 25, 4 }, ;
      { "T_IZ_2", "N", 25, 4 }, ;
      { "T_IZ_3", "N", 25, 4 }, ;
      { "T_IZ_4", "N", 25, 4 }, ;
      { "T_IZ_5", "N", 25, 4 }, ;
      { "LJUDI","N", 10, 0 } }


   IF File( PRIVPATH + "OPSLD.DBF" )
      FErase( PRIVPATH + "OPSLD.DBF" )
      FErase( PRIVPATH + "OPSLD.CDX" )
   ENDIF

   DBCreate2( "opsld", aDbf )
   SELECT( F_OPSLD )
   my_usex( "opsld" )

   INDEX ON PORID + ID + IDOPS TAG "1"
   USE

   RETURN


FUNCTION PopuniOpsLD( cTip, cPorId, aPorezi )

   LOCAL nT_st_1 := 0
   LOCAL nT_st_2 := 0
   LOCAL nT_st_3 := 0
   LOCAL nT_st_4 := 0
   LOCAL nT_st_5 := 0
   LOCAL nT_iz_1 := 0
   LOCAL nT_iz_2 := 0
   LOCAL nT_iz_3 := 0
   LOCAL nT_iz_4 := 0
   LOCAL nT_iz_5 := 0
   LOCAL i
   LOCAL nPom
   LOCAL nOsnovica := 0
   LOCAL nOstalo := 0
   LOCAL nBrOsnova := 0
   LOCAL nOsnov5 := 0
   LOCAL nOsnov4 := 0

   IF cTip == nil
      cTip := ""
   ENDIF

   IF cPorId == nil
      cPorId := Space( 2 )
   ENDIF

   IF aPorezi == nil
      aPorezi := {}
   ENDIF

   IF cTip == "S"

      cPrObr := get_pr_obracuna()

      IF cPrObr == "N" .OR. cPrObr == " " .OR. cPrObr == "B"
         nOsnovica := _oosnneto
      ELSEIF cPrObr == "2"
         nOsnovica := _oosnostalo
      ELSEIF cPrObr == "P"
         nOsnovica := ( _oosnneto + _oosnostalo )
      ENDIF

      FOR i := 1 TO Len( aPorezi )

         IF i == 1
            nT_st_1 := aPorezi[ i, 5 ]
            nT_iz_1 := aPorezi[ i, 6 ]
         ENDIF

         IF i == 2
            nT_st_2 := aPorezi[ i, 5 ]
            nT_iz_2 := aPorezi[ i, 6 ]
         ENDIF
         IF i == 3
            nT_st_3 := aPorezi[ i, 5 ]
            nT_iz_3 := aPorezi[ i, 6 ]
         ENDIF
         IF i == 4
            nT_st_4 := aPorezi[ i, 5 ]
            nT_iz_4 := aPorezi[ i, 6 ]
         ENDIF
         IF i == 5
            nT_st_5 := aPorezi[ i, 5 ]
            nT_iz_5 := aPorezi[ i, 6 ]
         ENDIF
      NEXT
   ELSE
      cPorId := "  "
      nOsnovica := _ouneto
      nOsnov3 := nPorOsnova
      nOsnov4 := _oosnneto
      nOsnov5 := nPorNROsnova
      nOstalo := _uodbici
      nBrOsnova := nMRadn_bo
   ENDIF

   SELECT ops
   SEEK radn->idopsst
   SELECT opsld

   // po opc.stanovanja
   SEEK cPorId + "1" + radn->idopsst

   IF Found()

      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE br_osn WITH br_osn + nBrOsnova
      REPLACE ljudi WITH ljudi + 1

      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ELSE
      APPEND BLANK
      REPLACE id WITH "1"
      REPLACE porid WITH cPorId
      REPLACE idops WITH radn->idopsst
      REPLACE iznos WITH nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE izn_ost WITH nOstalo
      REPLACE ljudi WITH 1

      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   // po kantonu
   SEEK cPorId + "3" + ops->idkan

   IF Found()
      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH ljudi + 1

      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF
   ELSE
      APPEND BLANK
      REPLACE id WITH "3"
      REPLACE porid WITH cPorId
      REPLACE idops WITH ops->idkan
      REPLACE iznos WITH nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE izn_ost WITH nOstalo
      REPLACE ljudi WITH 1

      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   // po idn0
   SEEK cPorId + "5" + ops->idn0
   IF Found()

      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH ljudi + 1

      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ELSE
      APPEND BLANK
      REPLACE id WITH "5"
      REPLACE porid WITH cPorId
      REPLACE idops WITH ops->idn0
      REPLACE iznos WITH nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE izn_ost WITH nOstalo
      REPLACE ljudi WITH 1

      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   SELECT ops
   SEEK radn->idopsrad
   SELECT opsld

   // po opc.rada
   SEEK cPorId + "2" + radn->idopsrad
   IF Found()

      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH ljudi + 1

      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF


   ELSE
      APPEND BLANK
      REPLACE id WITH "2"
      REPLACE porid WITH cPorId
      REPLACE idops WITH radn->idopsrad
      REPLACE iznos WITH nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE izn_ost WITH nOstalo
      REPLACE ljudi WITH 1

      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   // po kantonu
   SEEK cPorId + "4" + ops->idkan
   IF Found()

      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH ljudi + 1

      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ELSE
      APPEND BLANK
      REPLACE id WITH "4"
      REPLACE porid WITH cPorId
      REPLACE idops WITH ops->idkan
      REPLACE iznos WITH nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE izn_ost WITH nOstalo
      REPLACE ljudi WITH 1

      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   // po idn0
   SEEK cPorId + "6" + ops->idn0
   IF Found()

      REPLACE iznos WITH iznos + nOsnovica
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH ljudi + 1

      REPLACE izn_ost WITH izn_ost + nOstalo
      REPLACE t_iz_1 WITH t_iz_1 + nT_iz_1
      REPLACE t_iz_2 WITH t_iz_2 + nT_iz_2
      REPLACE t_iz_3 WITH t_iz_3 + nT_iz_3
      REPLACE t_iz_4 WITH t_iz_4 + nT_iz_4
      REPLACE t_iz_5 WITH t_iz_5 + nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ELSE
      APPEND BLANK
      REPLACE id WITH "6"
      REPLACE porid WITH cPorId
      REPLACE idops WITH ops->idn0
      REPLACE iznos WITH nOsnovica
      REPLACE izn_ost WITH nOstalo
      REPLACE iznos2 WITH iznos2 + nPorOl
      REPLACE iznos3 WITH iznos3 + nOsnov3
      REPLACE iznos4 WITH iznos4 + nOsnov4
      REPLACE iznos5 WITH iznos5 + nOsnov5
      REPLACE br_osn WITH br_osn + nBrOsnova

      REPLACE ljudi WITH 1
      REPLACE t_iz_1 WITH nT_iz_1
      REPLACE t_iz_2 WITH nT_iz_2
      REPLACE t_iz_3 WITH nT_iz_3
      REPLACE t_iz_4 WITH nT_iz_4
      REPLACE t_iz_5 WITH nT_iz_5

      IF nT_st_1 > t_st_1
         REPLACE t_st_1 WITH nT_st_1
      ENDIF

      IF nT_st_2 > t_st_2
         REPLACE t_st_2 WITH nT_st_2
      ENDIF

      IF nT_st_3 > t_st_3
         REPLACE t_st_3 WITH nT_st_3
      ENDIF

      IF nT_st_4 > t_st_4
         REPLACE t_st_4 WITH nT_st_4
      ENDIF

      IF nT_st_5 > t_st_5
         REPLACE t_st_5 WITH nT_st_5
      ENDIF

   ENDIF

   SELECT ld

   RETURN



// -----------------------------------------------------
// napravi obracun
// -----------------------------------------------------
FUNCTION napr_obracun( lSvi, a_benef )

   LOCAL i
   LOCAL cTpr
   LOCAL _bn_osnova, _bn_stepen

   nPorOl := 0
   nUPorOl := 0
   aNetoMj := {}
   nRadn_bo := 0
   nMRadn_bo := 0

   DO WHILE !Eof() .AND. Eval( bUSlov )

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      SELECT radn
      hseek _idradn
      SELECT vposla
      hseek _idvposla

      IF ( ( !Empty( cOpsSt ) .AND. cOpsSt <> radn->idopsst ) ) ;
            .OR. ( ( !Empty( cOpsRad ) .AND. cOpsRad <> radn->idopsrad ) )

         SELECT ld
         SKIP 1
         LOOP

      ENDIF

      IF ( IsRamaGlas() .AND. cK4 <> "S" )

         IF ( cK4 = "P" .AND. !radn->k4 = "P" .OR. cK4 = "N" .AND. radn->k4 = "P" )
            SELECT ld
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      _ouneto := Max( _uneto, PAROBR->prosld * gPDLimit / 100 )

      _oosnneto := 0
      _oosnostalo := 0

      // vrati osnovicu za neto i ostala primanja
      FOR i := 1 TO cLDPolja

         cTprField := PadL( AllTrim( Str( i ) ), 2, "0" )
         cTpr := "_I" + cTprField

         if &cTpr == 0
            LOOP
         ENDIF

         SELECT tippr
         SEEK cTprField
         SELECT ld

         IF tippr->( FieldPos( "TPR_TIP" ) ) <> 0
            IF tippr->tpr_tip == "N"

               // osnovica neto
               _oosnneto += &cTpr

            ELSEIF tippr->tpr_tip == "2"

               // osnovica ostalo
               _oosnostalo += &cTpr

            ELSEIF tippr->tpr_tip == " "

               IF tippr->uneto == "D"

                  // osnovica ostalo
                  _oosnneto += &cTpr

               ELSEIF tippr->uneto == "N"

                  // osnovica ostalo
                  _oosnostalo += &cTpr

               ENDIF
            ENDIF
         ELSE
            IF tippr->uneto == "D"
               // osnovica ostalo
               _oosnneto += &cTpr
            ELSEIF tippr->uneto == "N"
               // osnovica ostalo
               _oosnostalo += &cTpr
            ENDIF
         ENDIF
      NEXT

      // obradi poreze....

      SELECT por
      GO TOP

      nPor := 0
      nPorOl := 0

      DO WHILE !Eof()

         // porezi

         cAlgoritam := get_algoritam()

         PozicOps( POR->poopst )

         IF !ImaUOp( "POR", POR->id )
            SKIP 1
            LOOP
         ENDIF

         aPor := obr_por( por->id, _oosnneto, _oosnostalo )

         // samo izracunaj total, ne ispisuj porez
         nPor += isp_por( aPor, cAlgoritam, "", .F. )

         // nPor += round2(max(dlimit,iznos/100*_oUNeto),gZaok2)

         IF cAlgoritam == "S"
            PopuniOpsLd( cAlgoritam, por->id, aPor )
         ENDIF

         SELECT por

         SKIP

      ENDDO

      IF radn->porol <> 0 .AND. gDaPorOl == "D" .AND. !Obr2_9()
         // poreska olaksica

         IF AllTrim( cVarPorOl ) == "2"
            nPorOl := RADN->porol
         ELSEIF AllTrim( cVarPorol ) == "1"
            nPorOl := Round( parobr->prosld * radn->porol / 100, gZaok )
         ELSE
            nPorOl := &( "_I" + cVarPorol )
         ENDIF

         IF nPorOl > nPor
            // poreska olaksica ne moze biti veca od poreza
            nPorOl := nPor
         ENDIF

         nUPorOl += nPorOl
      ENDIF


      nPom := AScan( aNeta, {| x| x[ 1 ] == vposla->idkbenef } )

      IF nPom == 0
         AAdd( aNeta, { vposla->idkbenef, _oUNeto } )
      ELSE
         aNeta[ nPom, 2 ] += _oUNeto
      ENDIF

      FOR i := 1 TO cLDPolja

         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr
         SEEK cPom
         SELECT ld
         aRekap[ i, 1 ] += _s&cPom  // sati
         nIznos := _i&cPom

         aRekap[ i, 2 ] += nIznos  // iznos

         IF tippr->uneto == "N" .AND. nIznos <> 0

            IF nIznos > 0
               nUOdbiciP += nIznos
            ELSE
               nUOdbiciM += nIznos
            ENDIF

         ENDIF
      NEXT

      ++ nLjudi

      nUSati += _USati   // ukupno sati
      nUNeto += _UNeto  // ukupno neto iznos

      nULOdbitak += ( gOsnLOdb * radn->klo )

      nUNetoOsnova += _oUNeto
      // ukupno neto osnova

      nDoprOsnova += _oosnneto
      // neto osnova za obracun doprinosa

      nDoprOsnOst += _oosnostalo
      // ostalo - osonova za obracun doprinosa

      IF UBenefOsnovu()

         _bn_osnova := _oUNeto - if( !Empty( gBFForm ), &gBFForm, 0 )
         nUBNOsnova += _bn_osnova

         _bn_stepen := BenefStepen()
         add_to_a_benef( @a_benef, AllTrim( radn->k3 ), _bn_stepen, _bn_osnova )

      ENDIF

      cTR := IF( RADN->isplata $ "TR#SK", RADN->idbanka, ;
         Space( Len( RADN->idbanka ) ) )

      IF Len( aUkTR ) > 0 .AND. ( nPomTR := AScan( aUkTr, {| x| x[ 1 ] == cTR } ) ) > 0
         aUkTR[ nPomTR, 2 ] += _uiznos
      ELSE
         AAdd( aUkTR, { cTR, _uiznos } )
      ENDIF

      nUIznos += _UIznos  // ukupno iznos
      nUOdbici += _UOdbici  // ukupno odbici

      IF cMjesec <> cMjesecDo

         nPom := AScan( aNetoMj, {| x| x[ 1 ] == mjesec } )

         IF nPom > 0
            aNetoMj[ nPom, 2 ] += _uneto
            aNetoMj[ nPom, 3 ] += _usati
         ELSE
            nTObl := Select()
            nTRec := PAROBR->( RecNo() )
            ParObr( mjesec, godina, IF( lViseObr, cObracun, ), IF( !lSvi, cIdRj, ) )
            // samo pozicionira bazu PAROBR na odgovarajui zapis
            AAdd( aNetoMj, { mjesec, _uneto, _usati, PAROBR->k3, PAROBR->k1 } )
            SELECT PAROBR
            GO ( nTRec )
            SELECT ( nTObl )
         ENDIF
      ENDIF

      PopuniOpsLD()

      IF RADN->isplata == "TR"  // isplata na tekuci racun
         Rekapld( "IS_" + RADN->idbanka, cgodina, cmjesecDo,_UIznos, 0, RADN->idbanka, RADN->brtekr, RADNIK, .T. )
      ENDIF

      SELECT ld
      SKIP
   ENDDO

   RETURN


// ----------------------------------------
// ----------------------------------------
FUNCTION ZaglSvi()

   SELECT por
   GO TOP
   O_LD_RJ
   SELECT ld_rj
   P_10CPI

   ?? Lokal( "Obuhvacene radne jedinice: " )
   IF !Empty( qqRJ )
      SET FILTER TO &aUsl2
      GO TOP
      DO WHILE !Eof()
         ?? id + " - " + naz
         ? Space( 27 )
         SKIP 1
      ENDDO
   ELSE
      ?? "SVE"
      ?
   ENDIF

   B_ON

   IF cMjesec == cMjesecDo
      ? Lokal( "Firma:" ), gNFirma, "  " + Lokal( "Mjesec:" ), Str( cmjesec, 2 ) + IspisObr()
      ?? "    " + Lokal( "Godina:" ), Str( cGodina, 4 )
      B_OFF
      ? IF( gBodK == "1", Lokal( "Vrijednost boda:" ), Lokal( "Vr.koeficijenta:" ) ), Transform( parobr->vrbod, "99999.99999" )
   ELSE
      ? Lokal( "Firma:" ), gNFirma, "  " + Lokal( "Za mjesece od:" ), Str( cmjesec, 2 ), "do", Str( cmjesecDo, 2 ) + IspisObr()
      ?? "    " + Lokal( "Godina:" ), Str( cGodina, 4 )
      B_OFF
   ENDIF
   ?

   RETURN


// ----------------------------
// ----------------------------
FUNCTION ZaglJ()

   O_LD_RJ
   SELECT ld_rj
   hseek cIdRj
   SELECT por
   GO TOP
   SELECT ld

   ?
   B_ON
   IF cMjesec == cMjesecDo
      ? Lokal( "RJ:" ), cIdRj, ld_rj->naz, Space( 2 ) + Lokal( "Mjesec:" ), Str( cmjesec, 2 ) + IspisObr()
      ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 4 )
      B_OFF
      ? if( gBodK == "1", Lokal( "Vrijednost boda:" ), Lokal( "Vr.koeficijenta:" ) ), Transform( parobr->vrbod, "99999.99999" )
   ELSE
      ? Lokal( "RJ:" ), cidrj, ld_rj->naz, "  " + Lokal( "Za mjesece od:" ), Str( cmjesec, 2 ), "do", Str( cmjesecDo, 2 ) + IspisObr()
      ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 4 )
      B_OFF
   ENDIF

   ?

   RETURN


FUNCTION IspisTP( lSvi )

   LOCAL cTipPrElem := ld_tip_primanja_el_nepogode()

   cUNeto := "D"

   FOR i := 1 TO cLDPolja
      IF PRow() > 55 + gPStranica
         FF
      ENDIF
      cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
      _s&cPom := aRekap[ i, 1 ]   // nafiluj ove varijable radi prora~una dodatnih stavki
      _i&cPom := aRekap[ i, 2 ]

      cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
      SELECT tippr
      SEEK cPom
      IF tippr->uneto == "N" .AND. cUneto == "D"
         cUneto := "N"
         ? cLinija
         IF !lPorNaRekap
            ? Lokal( "Ukupno:" )
            @ PRow(), nC1 + 8  SAY Str( nUSati, 12, 2 )
            ?? Space( 1 ) + Lokal( "sati" )
            @ PRow(), 60 SAY nUNeto PICT gpici
            ?? "", gValuta
         ELSE
            ? Lokal( "Ukupno:" )
            @ PRow(), nC1 + 5  SAY Str( nUSati, 12, 2 )
            ?? Space( 1 ) + Lokal( "sati" )
            @ PRow(), 42 SAY nUNeto PICT gpici; ?? "", gValuta
            @ PRow(), 60 SAY nUNeto * ( por->iznos / 100 ) PICT gpici
            ?? "", gValuta
         ENDIF
         _UNeto := nUNeto
         _USati := nUSati
         ? cLinija
      ENDIF

      IF tippr->( Found() ) .AND. tippr->aktivan == "D" .AND. ( aRekap[ i, 2 ] <> 0 .OR. aRekap[ i, 1 ] <> 0 )
         cTPNaz := tippr->naz
         ? tippr->id + "-" + cTPNaz
         nC1 := PCol()
         IF !lPorNaRekap
            IF tippr->fiksan $ "DN"
               @ PRow(), PCol() + 8 SAY Str( aRekap[ i, 1 ], 12, 2 )
               ?? " s"
               @ PRow(), 60 SAY aRekap[ i, 2 ]      PICT gpici
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 8 SAY aRekap[ i, 1 ] / nLjudi PICT "999.99%"
               @ PRow(), 60 SAY aRekap[ i, 2 ]        PICT gpici
            ELSEIF tippr->fiksan == "C"
               @ PRow(), 60 SAY aRekap[ i, 2 ]        PICT gpici
            ELSEIF tippr->fiksan == "B"
               @ PRow(), PCol() + 8 SAY aRekap[ i, 1 ] PICT "999999"; ?? " b"
               @ PRow(), 60 SAY aRekap[ i, 2 ]      PICT gpici
            ENDIF
         ELSE
            IF tippr->fiksan $ "DN"
               @ PRow(), PCol() + 5 SAY Str( aRekap[ i, 1 ], 12, 2 )
               ?? " s"
               @ PRow(), 42 SAY aRekap[ i, 2 ]      PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 4 SAY aRekap[ i, 1 ] / nLjudi PICT "999.99%"
               @ PRow(), 42 SAY aRekap[ i, 2 ]        PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "C"
               @ PRow(), 42 SAY aRekap[ i, 2 ]        PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "B"
               @ PRow(), PCol() + 4 SAY aRekap[ i, 1 ] PICT "999999"; ?? " b"
               @ PRow(), 42 SAY aRekap[ i, 2 ]      PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ENDIF
         ENDIF

         IF !EMPTY( cTipPrElem ) .AND. cPom == cTipPrElem
            aRekap[ i, 2 ] := ABS( aRekap[ i, 2 ] )
         ENDIF

         IF cMjesec == cMjesecDo
            Rekapld( "PRIM" + tippr->id, cgodina, cmjesec, aRekap[ i, 2 ], aRekap[ i, 1 ] )
         ELSE
            Rekapld( "PRIM" + tippr->id, cgodina, cMjesecDo, aRekap[ i, 2 ], aRekap[ i, 1 ] )
         ENDIF

         IspisKred( lSvi )
      ENDIF

   NEXT

   RETURN


FUNCTION IspisKred( lSvi )

   LOCAL _kr_partija
   LOCAL _found := .F.

   IF "SUMKREDITA" $ tippr->formula

      IF gReKrOs == "X"

         ? cLinija
         ? "  ", Lokal( "Od toga pojedinacni krediti:" )

         SELECT RADKR
         SET ORDER TO TAG "3"
         SET FILTER TO Str( cGodina, 4 ) + Str( cMjesec, 2 ) <= Str( godina, 4 ) + Str( mjesec, 2 ) .AND. ;
            Str( cGodina, 4 ) + Str( cMjesecDo, 2 ) >= Str( godina, 4 ) + Str( mjesec, 2 )
         GO TOP

         DO WHILE !Eof()

            cIdKred := IDKRED

            SELECT KRED
            HSEEK cIdKred

            SELECT RADKR
            nUkKred := 0

            DO WHILE !Eof() .AND. IDKRED == cIdKred

               cNaOsnovu := NAOSNOVU
               cIdRadnKR := IDRADN

               SELECT RADN
               HSEEK cIdRadnKR

               SELECT RADKR
               cOpis2 := RADNIK
               nUkKrRad := 0

               DO WHILE !Eof() .AND. IDKRED == cIdKred .AND. cNaOsnovu == NAOSNOVU .AND. cIdRadnKR == IDRADN

                  mj := mjesec

                  _found := .F.

                  IF lSvi
                     // rekap za sve rj
                     SELECT ld
                     SET ORDER TO tag ( TagVO( "2" ) )
                     hseek Str( cGodina, 4 ) + Str( mj, 2 ) + cObracun + radkr->idradn

                     _t_rec := RecNo()
                     DO WHILE !Eof() .AND. godina == cGodina .AND. mjesec == cMjesec .AND. ;
                           obr == cObracun .AND. idradn == radkr->idradn
                        IF ld->i30 <> 0
                           _found := .T.
                           EXIT
                        ENDIF
                        SKIP
                     ENDDO
                     GO ( _t_rec )

                  ELSE
                     // rekap za jednu rj
                     SELECT ld
                     hseek  Str( cGodina, 4 ) + cIdrj + Str( mj, 2 ) + IF( !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                     // ako ima radnika i ako mu je podatak kredita unesen na obracunu
                     IF Found() .AND. ld->i30 <> 0
                        _found := .T.
                     ENDIF
                  ENDIF

                  SELECT radkr

                  IF _found
                     nUkKred  += iznos
                     nUkKrRad += iznos
                  ENDIF

                  SKIP 1

               ENDDO

               IF nUkKrRad <> 0

                  _kr_partija := AllTrim( kred->zirod )

                  RekapLD( "KRED" + cIdKred + cNaOsnovu, cGodina, cMjesecDo, nUkKrRad, 0, ;
                     cIdkred, cNaosnovu, AllTrim( cOpis2 ) + ", " + _kr_partija, .T. )

               ENDIF

            ENDDO

            IF nUkKred <> 0
               // ispisati kreditora
               IF PRow() > 55 + gPStranica
                  FF
               ENDIF

               ? "  ", cidkred, Left( kred->naz, 22 )
               @ PRow(), 58 SAY nUkKred  PICT "(" + gpici + ")"
            ENDIF
         ENDDO

      ELSE

         ? cLinija
         ? "  ", Lokal( "Od toga pojedinacni krediti:" )
         cOpis2 := ""
         SELECT radkr
         SET ORDER TO TAG "3"
         GO TOP

         DO WHILE !Eof()

            SELECT kred
            hseek radkr->idkred
            SELECT radkr
            PRIVATE cidkred := idkred, cNaOsnovu := naosnovu
            SELECT radn
            hseek radkr->idradn
            SELECT radkr
            cOpis2 := RADNIK
            SEEK cidkred + cnaosnovu
            PRIVATE nUkKred := 0

            DO WHILE !Eof() .AND. idkred == cidkred .AND. ( cnaosnovu == naosnovu .OR. gReKrOs == "N" )

               _found := .F.

               IF lSvi
                  SELECT ld
                  SET ORDER TO tag ( TagVO( "2" ) )
                  hseek  Str( cGodina, 4 ) + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
               ELSE
                  SELECT ld
                  hseek  Str( cGodina, 4 ) + cidrj + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
               ENDIF

               IF Found()
                  _found := .T.
               ENDIF

               SELECT radkr

               IF _found .AND. godina == cGodina .AND. mjesec == cMjesec
                  nUkKred += iznos
               ENDIF

               IF cMjesecDo > cMjesec
                  FOR mj := cMjesec + 1 TO cMjesecDo
                     IF lSvi
                        SELECT ld
                        SET ORDER TO tag ( TagVO( "2" ) )
                        hseek  Str( cGodina, 4 ) + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                        // "LDi2","str(godina)+str(mjesec)+idradn"
                     ELSE
                        SELECT ld
                        hseek  Str( cGodina, 4 ) + cidrj + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                     ENDIF // lSvi

                     SELECT radkr

                     IF ld->( Found() ) .AND. godina == cgodina .AND. mjesec = mj
                        nUkKred += iznos
                     ENDIF
                  NEXT
               ENDIF

               SKIP
            ENDDO

            IF nukkred <> 0

               IF PRow() > 55 + gPStranica
                  FF
               ENDIF

               ? "  ", cidkred, Left( kred->naz, 22 ), IF( gReKrOs == "N", "", cnaosnovu )

               @ PRow(), 58 SAY nUkKred  PICT "(" + gpici + ")"

               _kr_partija := AllTrim( kred->zirod )

               IF cMjesec == cMjesecDo
                  Rekapld( "KRED" + cIdkred + cNaOsnovu, cGodina, cMjesec, nUkKred, 0, ;
                     cIdKred, cNaosnovu, AllTrim( cOpis2 ) + ", " + _kr_partija )
               ELSE
                  Rekapld( "KRED" + cIdKred + cNaosnovu, cGodina, cMjesecDo, nUkkred, 0, ;
                     cIdKred, cNaosnovu, AllTrim( cOpis2 ) + ", " + _kr_partija )
               ENDIF

            ENDIF
         ENDDO

         SELECT ld
      ENDIF
   ENDIF

   RETURN


FUNCTION PoTekRacunima()

   ? cLinija
   ? Lokal( "ZA ISPLATU:" )
   ? "-----------"

   nMArr := Select()
   SELECT KRED
   ASort( aUkTr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
   FOR i := 1 TO Len( aUkTR )
      IF Empty( aUkTR[ i, 1 ] )
         ? PadR( Lokal( "B L A G A J N A" ), Len( aUkTR[ i, 1 ] + KRED->naz ) + 1 )
      ELSE
         HSEEK aUkTR[ i, 1 ]
         ? aUkTR[ i, 1 ], KRED->naz
      ENDIF
      @ PRow(), 60 SAY aUkTR[ i, 2 ] PICT gpici; ?? "", gValuta
   NEXT
   SELECT ( nMArr )

   RETURN


// ----------------------------------------------
// ispis tipova primanja....
// ----------------------------------------------
FUNCTION ProizvTP()

   // proizvoljni redovi pocinju sa "9"

   SELECT tippr
   SEEK "9"

   DO WHILE !Eof() .AND. Left( id, 1 ) = "9"
      IF PRow() > 55 + gPStranica
         FF
      ENDIF
      ? tippr->id + "-" + tippr->naz
      cPom := tippr->formula
      IF !lPorNaRekap
         @ PRow(), 60 SAY round2( &cPom, gZaok2 ) PICT gpici
      ELSE
         @ PRow(), 42 SAY round2( &cPom, gZaok2 ) PICT gpici
      ENDIF
      IF cMjesec == cMjesecDo
         Rekapld( "PRIM" + tippr->id, cgodina, cmjesec, round2( &cpom, gZaok2 ), 0 )
      ELSE
         Rekapld( "PRIM" + tippr->id, cgodina, cMjesecDo, round2( &cpom, gZaok2 ), 0 )
      ENDIF

      SKIP

      IF Eof() .OR. !Left( id, 1 ) = "9"
         ? cLinija
      ENDIF
   ENDDO

   RETURN



FUNCTION PrikKBO()

   nBO := 0
   ? Lokal( "Koef. Bruto osnove (KBO):" ), Transform( parobr->k3, "999.99999%" )
   ?? Space( 1 ), Lokal( "BRUTO OSNOVA = NETO OSNOVA*KBO =" )
   @ PRow(), PCol() + 1 SAY nBo := round2( parobr->k3 / 100 * nUNetoOsnova, gZaok2 ) PICT gpici
   ?

   RETURN
