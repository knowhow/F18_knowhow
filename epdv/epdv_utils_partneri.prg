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


#include "epdv.ch"


FUNCTION s_partner( cIdPartn )

   LOCAL cPom
   LOCAL cIdBroj

   PushWa()

   o_partn()

   SELECT PARTN
   SET ORDER TO TAG "ID"
   SEEK cIdPartn

   cPom := ""

   cPom += AllTrim( naz )
   cMjesto := AllTrim( mjesto )
   IF Empty( cMjesto )
      cMjesto := "-NEP.MJ-"
   ENDIF

   IF !Empty( ptt )
      cMjesto := AllTrim( ptt ) + " " + cMjesto
   ENDIF

   cPom += ", " + cMjesto

   cIdBroj := firma_pdv_broj( cIdPartn )

   IF EMPTY( cIdBroj )
       cIdBroj := firma_id_broj( cIdPartn ) 
   ENDIF

   IF Empty( cIdBroj )
      cIdBroj := "-NEP.ID-"
   ENDIF

   cPom += ", " + cIdBroj

   PopWa()

   RETURN cPom


// -----------------------------------------------
// podaci o mojoj firmi ubaceni u partnera "10"

// lRetArray - .t. - vrati matricu
// .f. - vrati string, default
// -----------------------------------------------
FUNCTION my_firma( lRetArray )

   LOCAL lNepopunjeno := .F.
   LOCAL cNaziv
   LOCAL cMjesto
   LOCAL cIdBroj
   LOCAL cPtt
   LOCAL cPom := gNFirma
   LOCAL _fields

   PushWa()

   IF lRetArray == nil
      lRetArray := .F.
   ENDIF

   o_partn()

   SELECT partn
   SET ORDER TO TAG "ID"
   SEEK gFirma

   IF !Found()
      APPEND BLANK
      _fields := dbf_get_rec()
      _fields[ "id" ] := gFirma
      update_rec_server_and_dbf( "partn", _fields, 1, "FULL" )
   ENDIF

   cNaziv := naz
   cMjesto := mjesto
   cIdBroj := firma_pdv_broj( gFirma )
   cAdresa := adresa
   cPtt := ptt

   IF  Empty( cNaziv ) .OR. Empty( cMjesto ) .OR. Empty( cIdBroj ) .OR. Empty( cPTT ) .OR. Empty( cAdresa )
      lNepopunjeno := .T.
   ENDIF


   IF lNepopunjeno
      IF get_my_firma( @cNaziv, @cIdBroj, @cMjesto, @cAdresa, @cPtt )

         _fields           := dbf_get_rec()
         _fields[ "naz" ]    := cNaziv
         _fields[ "mjesto" ] := cMjesto
         _fields[ "adresa" ] := cAdresa
         _fields[ "ptt" ]    := cPTT

         update_rec_server_and_dbf( nil, _fields, 1, "FULL" )

         USifK( "PARTN", "REGB", gFirma, Unicode():New( cIdBroj, .F. ) )

      ELSE
         MsgBeep( "Nepopunjeni podaci o matičnoj firmi !" )
      ENDIF
			
   ENDIF

   cPom := Trim( cNaziv ) + ", Id.br: " + cIdBroj + " , " + cPtt + " " + AllTrim( cMjesto )
   cPom += " , " + AllTrim( cAdresa )

   PopWa()

   IF lRetArray
      RETURN { cNaziv, cIdBroj, cPtt, cMjesto, cAdresa }
   ELSE
      RETURN cPom
   ENDIF


   // --------------------------------
   // --------------------------------

FUNCTION get_my_firma( cNaziv, cIdBroj, cMjesto, cAdresa, cPtt )

   Box (, 7, 60 )

   @ m_x + 1, m_y + 2 SAY "Podaci o maticnooj firmi: "
   @ m_x + 2, m_y + 2 SAY Replicate( "-", 40 )
   @ m_x + 3, m_y + 2 SAY "Naziv   " GET cNaziv PICT "@S40"
   @ m_x + 4, m_y + 2 SAY "Id.broj " GET cIdBroj
   @ m_x + 5, m_y + 2 SAY "Mjesto  " GET cMjesto
   @ m_x + 6, m_y + 2 SAY "Adresa  " GET cAdresa
   @ m_x + 7, m_y + 2 SAY "PTT     " GET cPtt

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF

   // -----------------------------------------------
   // ger rejon partnera
   // - 1 ili " " federacija
   // - 2 - rs
   // - 3 - brcko district
   // -----------------------------------------------

FUNCTION part_rejon( cIdPart )

   LOCAL cRejon

   PushWa()

   o_partn()
   GO TOP
   SEEK gFirma

   cRejon := IzSifKPartn( "REJO", Unicode():New( cIdPart, .F. ), .F. )

   PopWa()

   RETURN cRejon


// -------------------------------------
// sifrarnik partnera sa sifk/sifv
// -------------------------------------
FUNCTION o_partn()

   SELECT F_PARTN
   USE
   SELECT F_SIFK
   USE
   SELECT F_SIFV
   USE
   
   O_SIFK
   O_SIFV
   O_PARTN

   RETURN

// ---------------------------------------------
// da li se radi o specijalnom partneru
// - upravi za indirektno oporezivanje
// ---------------------------------------------
FUNCTION IsUIO( cIdPartner )
   RETURN IsProfil( cIdPartner, "UIO" )
