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

/*

FUNCTION TKaLagMNew()

   LOCAL oObj

   oObj := TKaLagM():new()

   oObj:nTUlazK := 0
   oObj:nTIzlazK := 0
   oObj:nTVpvU := 0
   oObj:nTVpvI := 0
   oObj:nTNvU := 0
   oObj:nTNvI := 0
   oObj:nTRabat := 0

   oObj:nStr := 0
   oObj:nStrLen := 63

   oObj:self := oObj

   oObj:cUslRobaNaz := ""
   oObj:nRbr := 0

   RETURN oObj

CREATE CLASS TKaLagM

   EXPORTED:

   VAR nStr
   VAR nStrLen
   VAR cLinija

   VAR self
   VAR dDatOd
   VAR dDatDo

   VAR cIdKonto
   VAR cUslTarifa
   VAR cUslIdVd
   VAR cUslPartner
   VAR cUslRobaNaz
   VAR cUslRoba
   VAR cExportDBF

   // row varijable (za IdRoba)
   VAR nUlazK
   VAR nIzlazK
   VAR nVpvU
   VAR nVpvI
   VAR nNvU
   VAR nNvI
   VAR nRabat
   VAR nRbr

   // row varijable (za IdRoba)
   VAR nTUlazK
   VAR nTIzlazK
   VAR nTVpvU
   VAR nTVpvI
   VAR nTNvU
   VAR nTNvI
   VAR nTRabat


   VAR cSort

   // varijante izvjestaja

   // "N", "P"
   VAR cNabIliProd
   VAR cPrikKolNula

   // kreiraj pomocnu tabelu
   METHOD creTmpTbl
   METHOD addTmpRec

   // prodji kroz bazu podataka
   METHOD openDb
   METHOD closeDb

   METHOD setFiltDb
   METHOD setFiltDbTmp

   METHOD skipRec
   METHOD calcRec

   METHOD calcRec
   METHOD sortTmpTbl
   METHOD getVars

   METHOD setLinija
   METHOD printHeader
   METHOD printDetail
   METHOD printFooter

   METHOD calcTotal
   METHOD printTotal

   METHOD export2DBF

END CLASS



FUNCTION KaLagM()


   LOCAL cIdRoba
   LOCAL cIdTarifa
   LOCAL nRec
   LOCAL oRpt := TKaLagMNew()

   DO WHILE .T.
      oRpt:creTmpTbl()
      IF ( oRpt:getVars() == 0 )
         oRpt:closeDB()
         RETURN
      ENDIF
      oRpt:openDb()
      IF ( oRpt:setFiltDb() == 0 )
         oRpt:closeDb()
         LOOP
      ELSE
         EXIT
      ENDIF
   ENDDO



   SELECT kalk
  -- SEEK self_organizacija_id() + oRpt:cIdKonto
   EOF CRET

   nRec := 0
   MsgO( "Kreiram pomocnu tabelu ..." )
   DO WHILE ( !Eof() .AND. oRpt:cIdKonto == field->mKonto )
      IF ( oRpt:skipRec() == 1 )
         LOOP
      ENDIF

      oRpt:nUlazK := 0
      oRpt:nIzlazK := 0
      oRpt:nVpvU := 0
      oRpt:nVpvI := 0
      oRpt:nNvU := 0
      oRpt:nNvI := 0
      oRpt:nRabat := 0

      cIdRoba := field->idRoba
      cIdTarifa := field->idTarifa
      DO WHILE ( !Eof() .AND. cIdRoba == field->idRoba .AND. cIdTarifa == field->idTarifa )
         ++nRec
         ShowKorner( nRec, 1 )
         oRpt:calcRec()
         SKIP
      ENDDO
      oRpt:addTmpRec( cIdRoba, cIdTarifa )
      SELECT kalk
   ENDDO
   MsgC()


   -- start_print() // rpt_tmp je gotova, formiramo izvjestaj
   SELECT rpt_tmp
   oRpt:setFiltDbTmp()
   oRpt:sortTmpTbl()
   GO TOP

   oRpt:nStr := 0
   oRpt:setLinija()
   oRpt:printHeader()
   nRec := 0
   DO WHILE !Eof()
      ShowKorner( nRec, 1 )
      ++nRec
      oRpt:printDetail()
      oRpt:calcTotal()
      SKIP
   ENDDO
   oRpt:printTotal()
   oRpt:printFooter()

   oRpt:closeDb()

   end_print()

   IF oRpt:cExportDBF == "D"
      oRpt:export2DBF()
   ENDIF

   RETURN .T.


METHOD openDb

   o_tarifa()
//   o_roba()
   o_tarifa()
   o_konto()
   o_kalk_doks()
   -- o_kalk()

   // "3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD
   SELECT kalk
   SET ORDER TO TAG "3"

   GO TOP

   RETURN



METHOD closeDb

   my_close_all_dbf()

   RETURN
// }

METHOD addTmpRec( cIdRoba, cIdTarifa )

   SELECT rpt_tmp
--   SEEK cIdRoba

   my_flock()

   IF !Found()
      APPEND BLANK
      REPLACE idRoba WITH cIdRoba
      // tarifu cu uzeti iz sifrarnika tarifa
      REPLACE idTarifa WITH roba->idTarifa
   ENDIF

   REPLACE idPartner WITH kalk->idPartner
   REPLACE ulazK WITH field->ulazK + ::nUlazK
   REPLACE izlazK WITH field->izlazK + ::nIzlazK

   IF ( ::cNabIliProd == "P" )
      REPLACE ulazF WITH field->ulazF + ::nVpvU
      REPLACE izlazF WITH field->izlazF + ::nVpvI
   ELSE
      REPLACE ulazF WITH field->ulazF + ::nNvU
      REPLACE izlazF WITH field->izlazF + ::nNvI
   ENDIF

   REPLACE robaNaz WITH roba->naz
   REPLACE jmj WITH roba->jmj

   my_unlock()

   RETURN


METHOD calcRec()

   LOCAL nKolicina

   IF ( field->mu_i == "1" )

      IF !( kalk->idVd $ "12#22#94" )
         nKolicina := field->kolicina - field->gkolicina - field->gkolicin2
         ::nUlazK += nKolicina
         ::nVpvU += Round( field->vpc * ( field->kolicina - field->gkolicina - field->gkolicin2 ), gZaokr )
         ::nNvU += Round( field->nc * ( field->kolicina - field->gkolicina - field->gkolicin2 ), gZaokr )
      ELSE
         nKolicina := -field->kolicina
         ::nIzlazK += nKolicina
         ::nVpvI -= Round( field->vpc * field->kolicina, gZaokr )
         ::nNvI -= Round( field->nc * field->kolicina, gZaokr )
      ENDIF

   ELSEIF ( field->mu_i == "5" )
      nKolicina := field->kolicina
      ::nIzlazK += nKolicina
      ::nVpvI += Round( field->vpc * field->kolicina, gZaokr )
      ::nRabat += Round( field->rabatv / 100 * field->vpc * field->kolicina, gZaokr )
      ::nNvI += field->nc * field->kolicina

   ELSEIF ( field->mu_i == "3" )
      // nivelacija
      ::nVpvU += Round( field->vpc * field->kolicina, gZaokr )

   ELSEIF ( field->mu_i == "8" )
      nKolicina := -field->kolicina
      ::nIzlazK += nKolicina
      ::nVpvI += Round( field->vpc * nKolicina, gZaokr )
      ::nRabat += Round( field->rabatv / 100 * field->vpc * nKolicina, gZaokr )
      ::nNvI += nc * nKolicina
      nKolicina := -field->kolicina
      ::nUlazK += nKolicina
      ::nVpvU += Round( field->vpc * nKolicina, gZaokr )
      ::nNvU += nc * nKolicina
   ENDIF

   RETURN
// }

METHOD getVars

   LOCAL cKto

   ::dDatOd := CToD( "" )
   ::dDatDo := Date()

   o_kalk_pripr()
   ::cIdKonto := PadR( "1310", Len( kalk_pripr->mKonto ) )
   USE

   ::cUslRoba := Space( 60 )
   ::cUslPartner := Space( 60 )
   ::cUslTarifa := Space( 60 )
   ::cUslIdVd := Space( 60 )
   ::cExportDBF := "N"

   Box( nil, 20, 70 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Datum " GET ::dDatOd
   @ box_x_koord() + 1, Col() + 2 SAY "-" GET ::dDatDo

   o_konto()

   ::cSort := "R"
   ::cNabIliProd := "P"
   ::cPrikKolNula := "D"

   cKto := ::cIdKonto
   @ box_x_koord() + 3, box_y_koord() + 2 SAY "Magacinski konto  " GET cKto VALID P_Konto( @cKto )

   @ box_x_koord() + 5, box_y_koord() + 2 SAY "Uslovi:"
   @ box_x_koord() + 6, box_y_koord() + 2 SAY "- za robu     :" GET ::cUslRoba    PICT "@!S40"
   @ box_x_koord() + 7, box_y_koord() + 2 SAY "- za partnera :" GET ::cUslPartner PICT "@!S40"
   @ box_x_koord() + 8, box_y_koord() + 2 SAY "- za tarife   :" GET ::cUslTarifa  PICT "@!S40"
   @ box_x_koord() + 9, box_y_koord() + 2 SAY "- vrste dok.  :" GET ::cUslIdVd    PICT "@!S40"

   @ box_x_koord() + 11, box_y_koord() + 2 SAY "Sortirati:"
   @ box_x_koord() + 12, box_y_koord() + 2 SAY "- po partneru (P)"
   @ box_x_koord() + 13, box_y_koord() + 2 SAY "- po tarifi   (T)"
   @ box_x_koord() + 14, box_y_koord() + 2 SAY "- po id roba  (R)"
   @ box_x_koord() + 15, box_y_koord() + 2 SAY "- po jed.mj.  (J)"
   @ box_x_koord() + 16, box_y_koord() + 2 SAY "- po naz roba (N)" GET ::cSort VALID ::cSort $ "KPTMRNJ" PICT "@!"

   @ box_x_koord() + 18, box_y_koord() + 2 SAY "(N)abavna / (P)rodajna vrijednost " GET ::cNabIliProd PICT "@!" VALID ::cNabIliProd $ "NP"
   @ box_x_koord() + 19, box_y_koord() + 2 SAY "Prikazati sve (i kolicina 0) " GET ::cPrikKolNula PICT "@!" VALID ::cPrikKolNula $ "DN"
   @ box_x_koord() + 20, box_y_koord() + 2 SAY --"Export izvjestaja (D/N)?" GET ::cExportDBF PICT "@!" VALID ::cExportDBF $ "DN"

   READ

   ::cIdKonto := cKto

   BoxC()

  -- SELECT konto
   USE

   IF ( LastKey() == K_ESC )
      RETURN 0
   ENDIF

   RETURN 1
// }


METHOD creTmpTbl

   LOCAL aTbl

   cTbl := my_home() + "rpt_tmp.dbf"

   aTbl := {}
   AAdd( aTbl, { "idRoba",  "C", 10, 0 } )
   AAdd( aTbl, { "RobaNaz", "C", 250, 0 } )
   AAdd( aTbl, { "idTarifa", "C", 6, 0 } )
   AAdd( aTbl, { "idPartner", "C", 6, 0 } )
   AAdd( aTbl, { "jmj",     "C", 3, 0 } )
   AAdd( aTbl, { "ulazK",   "N", 15, 4 } )
   AAdd( aTbl, { "izlazK",  "N", 15, 4 } )
   AAdd( aTbl, { "ulazF",   "N", 16, 4 } )
   AAdd( aTbl, { "izlazF",  "N", 16, 4 } )
   AAdd( aTbl, { "rabatF",  "N", 16, 4 } )

   DBCREATE2( cTbl, aTbl )
   CREATE_INDEX( "idRoba", "idRoba+idTarifa", cTbl, .F. )
   CREATE_INDEX( "RobaNaz", "LEFT(RobaNaz,40)+idTarifa", cTbl, .F. )
   CREATE_INDEX( "idTarifa", "idTarifa+idRoba", cTbl, .F. )
   CREATE_INDEX( "jmj", "jmj+idRoba+idTarifa", cTbl, .F. )
   CREATE_INDEX( "idPartner", "idPartner+idroba+idTarifa", cTbl, .F. )

   my_close_all_dbf()

   O_RPT_TMP
   SET ORDER TO TAG "idRoba"

   RETURN
// }

METHOD setFiltDb

   LOCAL cPom

   PRIVATE cFilter

   cFilter := ".t."

   cPom := Parsiraj( ::cUslRoba, "IdRoba" )
   IF ( cPom == nil )
      RETURN 0
   ENDIF

   IF ( cPom <> ".t." )
      cFilter += ".and." + cPom
   ENDIF

   cPom := Parsiraj( ::cUslTarifa, "IdTarifa" )
   IF ( cPom == nil )
      RETURN 0
   ENDIF

   IF ( cPom <> ".t." )
      cFilter += ".and." + cPom
   ENDIF

   cPom := Parsiraj( ::cUslIdVd, "IdVd" )
   IF ( cPom == nil )
      RETURN 0
   ENDIF

   IF ( cPom <> ".t." )
      cFilter += ".and." + cPom
   ENDIF

   cPom := Parsiraj( ::cUslPartner, "IdPartner" )
   IF ( cPom == nil )
      RETURN 0
   ENDIF

   IF ( cPom <> ".t." )
      cFilter += ".and." + cPom
   ENDIF

   IF ( !Empty( ::dDatOd ) .OR. !Empty( ::dDatDo ) )
      cFilter += ".and. DatDok>=" + dbf_quote( ::dDatOd ) + ".and. DatDok<=" + dbf_quote( ::dDatDo )
   ENDIF

   SET FILTER TO &cFilter
   GO TOP

   RETURN 1


METHOD skipRec

   LOCAL lPreskoci

   // preskoci slogove koji ne zadovoljavaju uslov
   // a nisu mogli biti obuhvaceni u fitleru

   PRIVATE cWFilter

   cWFilter := Parsiraj( ::cUslRobaNaz, "naz" )

  == SELECT roba
  -- HSEEK kalk->idRoba

   lPreskoci := .F.
   IF !( &cWFilter )
      lPreskoci := .T.
   ENDIF

   SELECT kalk
   IF ( lPreskoci )
      SKIP
      RETURN 1
   ENDIF

   IF roba->tip $ "TU"
      SKIP
      RETURN 1
   ENDIF

   RETURN 0
// }

METHOD sortTmpTbl

   DO CASE
   CASE ( ::cSort == "P" )
      SET ORDER TO TAG "idPartner"
   CASE ( ::cSort == "T" )
      SET ORDER TO TAG "idTarifa"
   CASE ( ::cSort == "R" )
      SET ORDER TO TAG "idRoba"
   CASE ( ::cSort == "N" )
      SET ORDER TO TAG "RobaNaz"
   CASE ( ::cSort == "J" )
      SET ORDER TO TAG "jmj"
   END CASE

   RETURN

METHOD setFiltDbTmp

   LOCAL cPom

   // postavi filter na pomocnoj tabeli
   // ako ima potrebe

   RETURN


METHOD setLinija

   LOCAL i

   ::cLinija := ""

   ::cLinija += Replicate( "-", 6 ) + " "
   ::cLinija += Replicate( "-", Len( field->idRoba ) ) + " "
   ::cLinija += Replicate( "-", Len( field->idTarifa ) ) + " "
   ::cLinija += Replicate( "-", 40 ) + " "


   ::cLinija += Replicate( "-", Len( kalk_pic_kolicina_bilo_gpickol() ) )

   FOR i := 1 TO 3
      ::cLinija += " " + Replicate( "-", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   NEXT

   RETURN
// }

METHOD printHeader

   LOCAL cHeader

   ::nStr++
   ?
   P_COND
   @ PRow(), 100 SAY "Str." + Str( ::nStr, 3 )
   ? "Preduzece: ", self_organizacija_naziv(),
   ?
   PushWA()

  -- SELECT konto
--   SEEK ::cIdKonto
   ? "Magacinski konto:", ::cIdKonto, konto->naz
   PopWa()
   ?
   ? ::cLinija

   cHeader := ""
   cHeader := PadC( "Rbr", 5 ) + " "
   cHeader += PadC( "idRoba", Len( field->idRoba ) ) + " "
   cHeader += PadC( "Tar.", Len( field->idTarifa ) ) + " "
   cHeader += PadC( " Naziv artikla", 40 ) + " "
   cHeader += PadC( "kolicina", Len( kalk_pic_kolicina_bilo_gpickol() ) ) + " "
   IF ( ::cNabIliProd == "P" )
      cHeader += PadC( "Vpv Ul.", Len( kalk_pic_kolicina_bilo_gpickol() ) ) + " "
      cHeader += PadC( "Vpv Izl.", Len( kalk_pic_kolicina_bilo_gpickol() ) ) + " "
      cHeader += PadC( "VPV", Len( kalk_pic_kolicina_bilo_gpickol() ) )
   ELSE
      cHeader += PadC( "Nv Ul.", Len( kalk_pic_kolicina_bilo_gpickol() ) ) + " "
      cHeader += PadC( "Nv Izl.", Len( kalk_pic_kolicina_bilo_gpickol() ) ) + " "
      cHeader += PadC( "Nab.vr", Len( kalk_pic_kolicina_bilo_gpickol() ) )
   ENDIF

   ? cHeader
   ? ::cLinija

   RETURN
// }

METHOD printFooter
   RETURN
// }

METHOD printDetail

   IF ( ::cPrikKolNula == "N" )
      IF ( Round( field->ulazK - field->izlazK, 4 ) == 0 )
         RETURN
      ENDIF
   ENDIF

   IF ( PRow() > ::nStrLen - 1 )
      FF
      ::printHeader()
   ENDIF
   ? Str( ++::nRbr, 4 ) + ". "
   @ PRow(), PCol() + 1 SAY field->idRoba
   @ PRow(), PCol() + 1 SAY field->idTarifa
   @ PRow(), PCol() + 1 SAY Left( field->robaNaz, 40 )
   @ PRow(), PCol() + 1 SAY field->ulazK - field->izlazK PICT kalk_pic_kolicina_bilo_gpickol()
   @ PRow(), PCol() + 1 SAY field->ulazF PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY field->izlazF PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY field->ulazF - field->izlazF PICT kalk_pic_iznos_bilo_gpicdem()

   RETURN
// }

METHOD calcTotal

   IF ( ::cPrikKolNula == "N" )
      IF ( Round( field->ulazK - field->izlazK, 4 ) == 0 )
         RETURN
      ENDIF
   ENDIF


   ::nTUlazK += field->ulazK
   ::nTIzlazK += field->izlazK

   IF ( ::cNabIliProd == "P" )
      ::nTVpvU += field->ulazF
      ::nTVpvI += field->izlazF
   ELSE
      ::nTNvU += field->ulazF
      ::nTNvI += field->izlazF
   ENDIF

   RETURN
// }

METHOD printTotal

   IF ( PRow() > ::nStrLen - 3 )
      FF
      ::printHeader()
   ENDIF

   ? ::cLinija
   ? PadR( " ", 6 )
   @ PRow(), PCol() + 1 SAY Space( Len( field->idRoba ) )
   @ PRow(), PCol() + 1 SAY Space( Len( field->idTarifa ) )
   @ PRow(), PCol() + 1 SAY Space( 40 )

   @ PRow(), PCol() + 1 SAY ::nTUlazK - ::nTIzlazK PICT kalk_pic_kolicina_bilo_gpickol()

   IF ( ::cNabIliProd == "P" )
      @ PRow(), PCol() + 1 SAY ::nTVpvU PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY ::nTVpvI PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY ::nTVpvU - ::nTVpvI PICT kalk_pic_iznos_bilo_gpicdem()
   ELSE
      @ PRow(), PCol() + 1 SAY ::nTNvU PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY ::nTNvI PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY ::nTNvU - ::nTNvI PICT kalk_pic_iznos_bilo_gpicdem()
   ENDIF

   ? ::cLinija

   RETURN

// export podataka u dbf
METHOD export2DBF

   LOCAL aExpFields
   LOCAL nK_ulaz := 0
   LOCAL nK_izlaz := 0
   LOCAL nI_ulaz := 0
   LOCAL nI_izlaz := 0
   LOCAL nI_rabat := 0

   // exportuj report....
   aExpFields := g_exp_fields()

   create_dbf_r_export( aExpFields )

   // kopiraj sve iz rpt_tmp u r_export
   O_RPT_TMP
   o_r_export()
   SELECT rpt_tmp
   GO TOP

   DO WHILE !Eof()

      SELECT r_export
      APPEND BLANK
      REPLACE field->idroba WITH rpt_tmp->idroba
      REPLACE field->robanaz WITH rpt_tmp->robanaz
      REPLACE field->idtarifa WITH rpt_tmp->idtarifa
      REPLACE field->idpartner WITH rpt_tmp->idpartner
      REPLACE field->jmj WITH rpt_tmp->jmj
      REPLACE field->ulaz WITH rpt_tmp->ulazk
      REPLACE field->izlaz WITH rpt_tmp->izlazk
      REPLACE field->stanje with ( field->ulaz - field->izlaz )
      REPLACE field->i_ulaz WITH rpt_tmp->ulazf
      REPLACE field->i_izlaz WITH rpt_tmp->izlazf
      REPLACE field->i_stanje with ( field->i_ulaz - field->i_izlaz )
      REPLACE field->rabat WITH rpt_tmp->rabatf

      nK_ulaz += field->ulaz
      nK_izlaz += field->izlaz
      nI_ulaz += field->i_ulaz
      nI_izlaz += field->i_izlaz
      nI_rabat += field->rabat

      SELECT rpt_tmp
      SKIP

   ENDDO

   // dodaj total u tabelu
   SELECT r_export
   APPEND BLANK
   REPLACE field->idroba WITH "UKUPNO"
   REPLACE field->ulaz WITH nK_ulaz
   REPLACE field->izlaz WITH nK_izlaz
   REPLACE field->stanje WITH nK_ulaz - nK_izlaz
   REPLACE field->i_ulaz WITH nI_ulaz
   REPLACE field->i_izlaz WITH nI_izlaz
   REPLACE field->i_stanje WITH nI_ulaz - nI_izlaz
   REPLACE field->rabat WITH nI_rabat

   open_r_export_table()

   RETURN


// vrati polja za export tabelu
STATIC FUNCTION g_exp_fields()

   LOCAL aTbl := {}

   AAdd( aTbl, { "idRoba",  "C", 10, 0 } )
   AAdd( aTbl, { "RobaNaz", "C", 250, 0 } )
   AAdd( aTbl, { "idTarifa", "C", 6, 0 } )
   AAdd( aTbl, { "idPartner", "C", 6, 0 } )
   AAdd( aTbl, { "jmj",     "C", 3, 0 } )
   AAdd( aTbl, { "ulaz",   "N", 15, 4 } )
   AAdd( aTbl, { "izlaz",  "N", 15, 4 } )
   AAdd( aTbl, { "stanje",  "N", 15, 4 } )
   AAdd( aTbl, { "i_ulaz",   "N", 16, 4 } )
   AAdd( aTbl, { "i_izlaz",  "N", 16, 4 } )
   AAdd( aTbl, { "i_stanje",  "N", 16, 4 } )
   AAdd( aTbl, { "rabat",  "N", 16, 4 } )

   RETURN aTbl

*/
