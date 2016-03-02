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


/* fn CreRabDB()
 *  brief Kreira tabelu rabat u SIFPATH
 */

FUNCTION CreRabDB()

   aDbf := {}
   AAdd( aDbf, { "IDRABAT", "C", 10, 0 } )
   AAdd( aDbf, { "TIPRABAT", "C", 10, 0 } )
   AAdd( aDbf, { "DATUM", "D",  8, 0 } )
   AAdd( aDbf, { "DANA", "N",  5, 0 } )
   AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
   AAdd( aDbf, { "IZNOS1", "N",  8, 2 } )
   AAdd( aDbf, { "IZNOS2", "N",  8, 2 } )
   AAdd( aDbf, { "IZNOS3", "N",  8, 2 } )
   AAdd( aDbf, { "IZNOS4", "N",  8, 2 } )
   AAdd( aDbf, { "IZNOS5", "N",  8, 2 } )
   AAdd( aDbf, { "SKONTO", "N",  8, 2 } )

   IF !File( f18_ime_dbf( "rabat" ) )
      DbCreate2( "rabat", aDbf )
   ENDIF

   CREATE_INDEX( "1", "IDRABAT+TIPRABAT+IDROBA", SIFPATH + "rabat.dbf", .T. )
   CREATE_INDEX( "2", "IDRABAT+TIPRABAT+DTOS(DATUM)", SIFPATH + "rabat.dbf", .T. )

   RETURN .T.


/*! \fn GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
 *  \brief Vraca iznos rabata za dati artikal
 *  \param cIdRab - id rabat
 *  \param nTekIznos - tekuce polje iznosa
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost rabata
 */
FUNCTION GetRabForArticle( cIdRab, cTipRab, cIdRoba, nTekIznos )

   LOCAL nArr
   nArr := Select()

   cIdRab := PadR( cIdRab, 10 )
   cTipRab := PadR( cTipRab, 10 )

   O_RABAT
   SELECT rabat
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdRab + cTipRab + cIdRoba

   // vrati iznos rabata za tekucu vriijednost polja IZNOSn
   nRet := GetRabIznos( nTekIznos )

   SELECT ( nArr )

   RETURN nRet



/*! \fn GetDaysForRabat(cIdRab, cTipRab)
 *  \brief Vraca broj dana (rok placanja) za odredjeni tip rabata
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \return nRet - vrijednost dana
 */
FUNCTION GetDaysForRabat( cIdRab, cTipRab )


   LOCAL nArr
   nArr := Select()

   cIdRab := PadR( cIdRab, 10 )
   cTipRab := PadR( cTipRab, 10 )

   O_RABAT
   SELECT rabat
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdRab + cTipRab
   nRet := field->dana
   SELECT ( nArr )

   RETURN nRet



/*! \fn GetRabIznos(cTekIzn)
 *  \brief Vraca iznos rabata za zadati cTekIznos (vrijednost polja)
 *  \param cTekIzn - tekuce polje koje se uzima
 */
FUNCTION GetRabIznos( cTekIzn )

   // {
   IF ( cTekIzn == nil )
      cTekIzn := "1"
   ENDIF

   // primjer: "iznos" + cTekIzn
   // iznos1 ili iznos3
   cField := "iznos" + AllTrim( cTekIzn )
   // izvrsi macro evaluaciju
   nRet := field->&cField

   RETURN nRet
// }


/*! \fn GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
 *  \brief Vraca iznos skonto za dati artikal
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost skonto
 */
FUNCTION GetSkontoArticle( cIdRab, cTipRab, cIdRoba )

   // {
   LOCAL nArr
   nArr := Select()

   cIdRab := PadR( cIdRab, 10 )
   cTipRab := PadR( cTipRab, 10 )
   O_RABAT
   SELECT rabat
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cIdRab + cTipRab + cIdRoba
   nRet := field->skonto
   SELECT ( nArr )

   RETURN nRet
// }


// ------------------------------------
// dodaj match_code u browse
// ------------------------------------
FUNCTION add_mcode( aKolona )

   IF FieldPos( "MATCH_CODE" ) <> 0
      AAdd( aKolona, { PadC( "MATCH CODE", 10 ), {|| match_code }, "match_code" } )
   ENDIF

   RETURN
