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


#include "f18.ch"



FUNCTION kalk_pripr9View()

   PRIVATE aUslFirma := gFirma
   PRIVATE aUslDok := Space( 50 )
   PRIVATE dDat1 := CToD( "" )
   PRIVATE dDat2 := Date()

   Box(, 10, 60 )
   @ 1 + m_x, 2 + m_y SAY "Uslovi pregleda smeca:" COLOR "I"
   @ 3 + m_x, 2 + m_y SAY "Firma (prazno-sve)" GET aUslFirma PICT "@S40"
   @ 4 + m_x, 2 + m_y SAY "Vrste dokumenta (prazno-sve)" GET aUslDok PICT "@S20"
   @ 5 + m_x, 2 + m_y SAY "Datum od" GET dDat1
   @ 5 + m_x, 20 + m_y SAY "do" GET dDat2
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   ka_pripr9_set_filter( aUslFirma, aUslDok, dDat1, dDat2 )

   PRIVATE gVarijanta := "2"

   PRIVATE PicV := "99999999.9"
   ImeKol := { ;
      { "F.", {|| IdFirma                  }, "IdFirma"     },;
      { "VD", {|| IdVD                     }, "IdVD"        },;
      { "BrDok", {|| BrDok                    }, "BrDok"       },;
      { "Dat.Kalk", {|| DatDok                   }, "DatDok"      },;
      { "K.zad. ", {|| IdKonto                  }, "IdKonto"     },;
      { "K.razd.", {|| IdKonto2                 }, "IdKonto2"    },;
      { "Br.Fakt", {|| brfaktp                  }, "brfaktp"     }, ;
      { "Partner", {|| idpartner                }, "idpartner"   }, ;
      { "E", {|| error                    }, "error"       } ;
      }

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 77 )
   @ m_x + 17, m_y + 2 SAY "<c-T>  Brisi stavku                              "
   @ m_x + 18, m_y + 2 SAY "<c-F9> Brisi sve     "
   @ m_x + 19, m_y + 2 SAY "<P> Povrat dokumenta u pripremu "
   @ m_x + 20, m_y + 2 SAY "               "

   IF gCijene == "1" .AND. gMetodaNC == " "
      Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 23, 14 )
   ENDIF

   PRIVATE lAutoAsist := .F.

   ObjDbedit( "KALK_PRIPR9", 20, 77, {|| ka_pripr9_key_handler() }, "<P>-povrat dokumenta u pripremu", "Pregled smeca...", , , , , 4 )
   BoxC()

   RETURN


/*! \fn ka_pripr9_key_handler()
 *  \brief Opcije pregleda smeca
 */
FUNCTION ka_pripr9_key_handler()

   // {
   DO CASE
   CASE Ch == K_CTRL_T // brisanje dokumenta iz kalk_pripr9
      ErPripr9( idfirma, idvd, brdok )
      RETURN DE_REFRESH
   CASE Ch == K_CTRL_F9 // brisanje kompletnog kalk_pripr9
      ErP9All()
      RETURN DE_REFRESH
   CASE Chr( Ch ) $ "pP" // povrat dokumenta u kalk_pripremu
      PovPr9()
      ka_pripr9_set_filter( aUslFirma, aUslDok, dDat1, dDat2 )
      RETURN DE_REFRESH
   ENDCASE

   RETURN DE_CONT

   RETURN
// }


/*! \fn PovPr9()
 *  \brief povrat dokumenta iz kalk_pripr9
 */
STATIC FUNCTION PovPr9()

   // {
   LOCAL nArr
   nArr := Select()

   kalk_povrat_dokumenta_iz_pripr9( idfirma, idvd, brdok )

   SELECT ( nArr )

   RETURN DE_CONT
// }


/*! \fn ka_pripr9_set_filter(aUslFirma, aUslDok, dDat1, dDat2)
 *  \brief Postavlja filter na tabeli kalk_pripr9
 */
STATIC FUNCTION ka_pripr9_set_filter( aUslFirma, aUslDok, dDat1, dDat2 )

   // {
   O_KALK_PRIPR9
   SET ORDER TO TAG "1"

   // obavezno postavi filter po rbr
   cFilter := "rbr = '  1'"

   IF !Empty( aUslFirma )
      cFilter += " .and. idfirma='" + aUslFirma + "'"
   ENDIF

   IF !Empty( aUslDok )
      aUslDok := Parsiraj( aUslDok, "idvd" )
      cFilter += " .and. " + aUslDok
   ENDIF

   IF !Empty( dDat1 )
      cFilter += " .and. datdok >= " + Cm2Str( dDat1 )
   ENDIF

   IF !Empty( dDat2 )
      cFilter += " .and. datdok <= " + Cm2Str( dDat2 )
   ENDIF

   SET FILTER to &cFilter

   GO TOP

   RETURN


// ------------------------------------------------------------------
// ------------------------------------------------------------------
FUNCTION ErPripr9( cIdF, cIdVd, cBrDok )

   IF Pitanje(, "Sigurno zelite izbrisati dokument?", "N" ) == "N"
      RETURN
   ENDIF

   SELECT kalk_pripr9
   SEEK cIdF + cIdVd + cBrDok
   my_flock()
   DO WHILE !Eof() .AND. cIdF == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SKIP 1
      nRec := RecNo()
      SKIP -1
      my_delete()
      GO nRec
   ENDDO
   my_unlock()

   RETURN


// ------------------------------------------------------------------
// ------------------------------------------------------------------
FUNCTION ErP9All()

   IF Pitanje(, "Sigurno zelite izbrisati sve zapise?", "N" ) == "N"
      RETURN
   ENDIF

   SELECT kalk_pripr9
   GO TOP
   my_dbf_zap()

   RETURN
