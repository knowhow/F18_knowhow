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

#include "fmk.ch"

STATIC s_cId_taksa := "TAKGORI   "


STATIC FUNCTION is_modul_pos()
   IF goModul:oDataBase:cName == "POS"
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

FUNCTION valid_taksa_gorivo( cError, nGorivoKolicina, nTaksaKolicina )

   LOCAL nSelect := SELECT()
   LOCAL lRet := .T.

   IF is_modul_pos()
      SELECT _pos_pripr
   ELSE
      SELECT fakt_pripr
   ENDIF

   nGorivoKolicina := 0
   nTaksaKolicina := 0

   DO WHILE !Eof()
 
      IF artikal_je_gorivo( field->idroba )
         nGorivoKolicina += field->kolicina
      ENDIF

      IF field->idroba == s_cId_taksa
         nTaksaKolicina += field->kolicina
      ENDIF

      SKIP

   ENDDO

   SELECT ( nSelect )

   IF nGorivoKolicina <> nTaksaKolicina
      lRet := .F.
      cError := "Količina goriva na računu je " + AllTrim( Str( nGorivoKolicina ) ) + "#Dok je unesena taksa količina " + ;
               AllTrim( Str( nTaksaKolicina ) )
   ENDIF

   RETURN lRet



STATIC FUNCTION artikal_je_gorivo( cIdRoba )  

   LOCAL lRet := .F.
   LOCAL cSql, oQuery

   cSql := "SELECT k1 FROM fmk.roba WHERE id = " + _sql_quote( cIdRoba )
   oQuery := _sql_query( my_server(), cSql )

   IF query_row( oQuery, "k1" ) == "GORI"
      lRet := .T.
   ENDIF

   RETURN lRet 



FUNCTION treba_li_dodati_taksu_za_gorivo()
  
   LOCAL cError := ""
   LOCAL nGorivoKolicina := 0
   LOCAL nTaksaKolicina := 0
   LOCAL nDodajTakse := 0
   LOCAL lRet := .F.

   IF !valid_taksa_gorivo( @cError, @nGorivoKolicina, @nTaksaKolicina )
       MsgBeep( cError )
   ENDIF

   nDodajTakse := nGorivoKolicina - nTaksaKolicina

   IF nDodajTakse > 0
       lRet := .T.
       dodaj_taksu_za_gorivo( nDodajTakse )
   ENDIF

   RETURN lRet



FUNCTION dodaj_taksu_za_gorivo( nKolicina )

   LOCAL nSelect := SELECT()
   LOCAL lPos := .F.
   LOCAL hRec, hPrviRec

   O_ROBA
   hseek s_cId_taksa

   IF !FOUND()
      dodaj_sifru_takse_u_sifarnik_robe()
   ENDIF

   IF goModul:oDataBase:cName == "POS"
      lPos := .T.
   ENDIF

   IF lPos
      SELECT _pos_pripr
   ELSE
      SELECT fakt_pripr
   ENDIF

   GO TOP
   hPrviRec := dbf_get_rec()

   APPEND BLANK
   hRec := dbf_get_rec()

   hRec["idpos"] := hPrviRec["idpos"]
   hRec["idvd"] := hPrviRec["idvd"]
   hRec["brdok"] := hPrviRec["brdok"]
   hRec["datum"] := hPrviRec["datum"]
   hRec["sto"] := hPrviRec["sto"]
   hRec["smjena"] := hPrviRec["smjena"]
   hRec["idradnik"] := hPrviRec["idradnik"]
   hRec["idcijena"] := hPrviRec["idcijena"]
   hRec["prebacen"] := hPrviRec["prebacen"]
   hRec["mu_i"] := hPrviRec["mu_i"]

   hRec["idroba"] := s_cId_taksa
   hRec["kolicina"] := nKolicina
   hRec["cijena"] := roba->mpc
   hRec["idtarifa"] := roba->idtarifa

   dbf_update_rec( _rec ) 

   SELECT ( nSelect )

   RETURN




STATIC FUNCTION dodaj_sifru_takse_u_sifarnik_robe()

   LOCAL hRec
   LOCAL lOk := .T.
   LOCAL nNovi_plu := 0

   SELECT roba
   APPEND BLANK

   hRec := dbf_get_rec()
   hRec["id"] := s_cId_taksa

   gen_plu( @nNovi_plu )
   hRec["fisc_plu"] := nNovi_plu

   hRec["naz"] := "TAKSA ZA GORIVO 1 pf"
   hRec["idtarifa"] := PadR( "PDV0", 6 )
   hRec["mpc"] := 0.01

   lOk := update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )

   SELECT roba
   hseek s_cId_taksa

   RETURN lOk

