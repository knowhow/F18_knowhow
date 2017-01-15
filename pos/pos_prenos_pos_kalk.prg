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



STATIC FUNCTION _get_vd( tip_dokumenta )

   LOCAL _ret := "16"

   DO CASE
   CASE tip_dokumenta $ "11#80#81"
      _ret := "16"
   CASE tip_dokumenta $ "19"
      _ret := "NI"
   CASE tip_dokumenta $ "IP"
      _ret := "IN"
   ENDCASE

   RETURN _ret



FUNCTION pos_preuzmi_iz_kalk( tip_dok, br_dok, rs_dbf )

   LOCAL _imp_table := ""
   LOCAL _destination := ""
   LOCAL _br_dok
   LOCAL _val_otpremnica
   LOCAL _val_zaduzenje
   LOCAL _val_inventura
   LOCAL _val_nivelacija
   LOCAL _id_pos, _prodajno_mjesto
   LOCAL lOk := .T.

   _id_pos := gIdPos
   _prodajno_mjesto := Space( 2 )
   _val_otpremnica := "95"
   _val_zaduzenje := "11#12#13#80#81"
   _val_inventura := "IP"
   _val_nivelacija := "19"

   _destination := AllTrim( gKalkDest )

   SET CURSOR ON
   O_PRIPRZ

   _br_dok := Space( Len( field->brdok ) )

   IF priprz->( RecCount2() ) == 0 .AND. Pitanje( , "Preuzeti dokumente iz KALK-a", "N" ) == "N"
      RETURN .F.
   ENDIF

   IF !get_import_file( _br_dok, @_destination, @_imp_table )
      RETURN .F.
   ENDIF

   SELECT ( F_TMP_KATOPS )
   my_use_temp( "KATOPS", _imp_table )

   _id_tip_dok := _get_vd( katops->idvd )
   tip_dok := _id_tip_dok

   SELECT pos_doks
   SET ORDER TO TAG "1"

   _br_dok := pos_novi_broj_dokumenta( _id_pos, tip_dok )
   br_dok := _br_dok

   SELECT katops
   GO TOP

   MsgO( "kalk -> priprema, update roba " )

   DO WHILE !Eof()
      IF ( katops->idpos == _id_pos )
         IF import_row( _id_tip_dok, _br_dok, "" ) == 0
            lOk := .F.
            EXIT
         ENDIF
      ENDIF
      SELECT katops
      SKIP
   ENDDO

   SELECT katops
   USE

   MsgC()

   IF !lOk
      MsgBeep( "Procedura importa nije uspješna !" )
   ENDIF

   IF lOk
      _brisi_fajlove_importa( _imp_table )
   ENDIF

   RETURN .T.


STATIC FUNCTION _brisi_fajlove_importa( import_file )

   FileDelete( import_file )
   FileDelete( StrTran( import_file, ".dbf", ".txt" ) )

   RETURN .T.


STATIC FUNCTION uslovi_za_insert_ispunjeni()

   LOCAL lOk := .T.

   IF Abs( katops->mpc ) - Abs( Val( Str( katops->mpc, 8, 3 ) ) ) <> 0
      MsgBeep( "Cijena artikla: " + AllTrim( katops->idroba ) + " van dozvoljenog ranga: " + AllTrim( Str( katops->mpc ) ) )
      lOk := .F.
   ENDIF

   RETURN lOk


STATIC FUNCTION import_row( id_vd, br_dok, id_odj )

   LOCAL nDbfArea := Select()

   IF !uslovi_za_insert_ispunjeni()
      RETURN 0
   ENDIF

   SELECT priprz
   APPEND BLANK

   REPLACE idroba WITH katops->idroba
   REPLACE cijena WITH katops->mpc

   REPLACE kolicina WITH katops->kolicina

   IF id_vd == "NI"
      REPLACE ncijena WITH katops->mpc2
   ENDIF

   IF id_vd == "IN"
      REPLACE kolicina WITH katops->kol2
      REPLACE kol2 WITH katops->kolicina
   ENDIF

   REPLACE idtarifa WITH katops->idtarifa
   REPLACE jmj WITH katops->jmj
   REPLACE robanaz WITH katops->naziv
   REPLACE k1 WITH katops->k1
   REPLACE k2 WITH katops->k2
   REPLACE k7 WITH katops->k7
   REPLACE k8 WITH katops->k8
   REPLACE k9 WITH katops->k9
   REPLACE n1 WITH katops->n1
   REPLACE n2 WITH katops->n2
   REPLACE barkod WITH katops->barkod
   REPLACE PREBACEN WITH OBR_NIJE
   REPLACE IDRADNIK WITH gIdRadnik
   REPLACE IdPos WITH KATOPS->IdPos
   REPLACE IdOdj WITH id_odj
   REPLACE IdVd WITH id_vd
   REPLACE Smjena WITH gSmjena
   REPLACE BrDok WITH br_dok
   REPLACE DATUM WITH gDatum

   SELECT ( nDbfArea )

   RETURN 1


STATIC FUNCTION get_import_file( br_dok, destinacija, import_fajl )

   LOCAL _filter
   LOCAL _prodajno_mjesto, _id_pos, cPrefixLocal
   LOCAL _imp_files := {}
   LOCAL _opc := {}
   LOCAL _h, nI
   LOCAL _izbor
   LOCAL _prenesi

   _filter := 2
   _prodajno_mjesto := GetPm( gIdPos )

   IF !Empty( _prodajno_mjesto )
      _id_pos := _prodajno_mjesto
      cPrefixLocal := ( Trim( _prodajno_mjesto ) ) + SLASH
   ELSE
      cPrefixLocal := ""
   ENDIF

   destinacija := AllTrim( gKalkDest ) + cPrefixLocal

   BrisiSFajlove( destinacija )

   _imp_files := Directory( destinacija + "kt*.dbf" )

   ASort( _imp_files,,, {| x, y| DToS( x[ 3 ] ) + x[ 4 ] > DToS( y[ 3 ] ) + y[ 4 ] } )

   AEval( _imp_files, {| elem| AAdd( _opc, PadR( elem[ 1 ], 15 ) + UChkPostoji() + " " + DToC( elem[ 3 ] ) + " " + elem[ 4 ] ) }, 1 )

   ASort( _opc,,, {| x, y| Right( x, 17 ) > Right( y, 17 ) } )

   _h := Array( Len( _opc ) )
   FOR nI := 1 TO Len( _h )
      _h[ nI ] := ""
   NEXT

   IF Len( _opc ) == 0
      MsgBeep( "U direktoriju za prenos nema podataka /P" )
      CLOSE ALL
      RETURN .F.
   ENDIF


   _izbor := 1
   _prenesi := .F.
   DO WHILE .T.
      _izbor := meni_0( "k2p", _opc, _izbor, .F. )
      IF _izbor == 0
         EXIT
      ELSE
         import_fajl := Trim( destinacija ) + Trim( Left( _opc[ _izbor ], 15 ) )
         IF Pitanje(, "Želite li izvršiti prenos podataka (D/N) ?", "D" ) == "D"
            _prenesi := .T.
            _izbor := 0
         ENDIF
      ENDIF
   ENDDO

   IF !_prenesi
      RETURN .F.
   ENDIF

   RETURN .T.


STATIC FUNCTION GetPm( id_pos )

   LOCAL _pm

   _pm := AllTrim( id_pos )

   RETURN _pm



STATIC FUNCTION _o_real_table()

   O_ROBA
   O_KASE
   o_pos_pos()
   o_pos_doks()

   RETURN .T.



FUNCTION pos_prenos_inv_2_kalk( id_pos, id_vd, dat_dok, br_dok )

   LOCAL _r_br, hRec
   LOCAL _kol
   LOCAL _iznos
   LOCAL nDbfArea := Select()
   LOCAL _count

   IF id_vd <> VD_INV
      RETURN .F.
   ENDIF

   _cre_pom_table()

   _o_real_table()

   IF !pos_dokument_postoji( id_pos, id_vd, dat_dok, br_dok )
      MsgBeep( "Dokument: " + id_pos + "-" + id_vd + "-" + PadL( br_dok, 6 ) + " ne postoji !" )
      RETURN .F.
   ENDIF

   _r_br := 0
   _kol := 0
   _iznos := 0

   SELECT pos
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF !Found()
      MsgBeep( "POS tabela nema stavki !" )
      SELECT ( nDbfArea )
      RETURN .F.
   ENDIF

   MsgO( "Eksport dokumenta u toku ..." )

   DO WHILE !Eof() .AND. field->idpos == id_pos .AND. field->idvd == id_vd .AND. ;
         field->datum == dat_dok .AND. field->brdok == br_dok

      cIdRoba := field->idroba

      SELECT roba
      HSEEK cIdRoba

      SELECT pom
      APPEND BLANK

      hRec := dbf_get_rec()

      hRec[ "idpos" ] := pos->idpos
      hRec[ "idvd" ] := pos->idvd
      hRec[ "datum" ] := pos->datum
      hRec[ "brdok" ] := pos->brdok
      hRec[ "kolicina" ] := pos->kolicina
      hRec[ "idroba" ] := pos->idroba
      hRec[ "idtarifa" ] := pos->idtarifa
      hRec[ "kol2" ] := pos->kol2
      hRec[ "mpc" ] := pos->cijena
      hRec[ "stmpc" ] := pos->ncijena
      hRec[ "barkod" ] := roba->barkod
      hRec[ "robanaz" ] := roba->naz
      hRec[ "jmj" ] := roba->jmj

      dbf_update_rec( hRec )

      ++ _r_br

      SELECT pos
      SKIP

   ENDDO

   MsgC()

   IF _r_br == 0
      MsgBeep( "Ne postoji niti jedna stavka u eksport tabeli !" )
      SELECT ( nDbfArea )
      RETURN
   ENDIF

   SELECT pom
   USE

   _file := tops_kalk_create_topska( id_pos, dat_dok, dat_dok, id_vd, "tk_p" )
   MsgBeep( "Kreiran fajl " + _file + "#broj stavki: " + AllTrim( Str( _r_br ) ) )


   SELECT ( nDbfArea )

   RETURN .T.




FUNCTION pos_prenos_pos_kalk( dDateOd, dDateDo, cIdVd, cIdPM )

   LOCAL _usl_roba := Space( 150 )
   LOCAL _usl_mark := "U"
   LOCAL aPom := {}
   LOCAL i
   LOCAL _r_br
   LOCAL cIdPos := gIdPos
   LOCAL _dat_od, _dat_do, _file
   LOCAL _tmp
   LOCAL _auto_prenos := .F.
   LOCAL hRec

   IF cIdPM <> NIL
      _auto_prenos := .T.
   ENDIF

   IF ( cIdVd == NIL )
      cIdVd := "42"
   ENDIF

   IF ( ( dDateOd == NIL ) .AND. ( dDateDo == NIL ) )
      _dat_od := Date()
      _dat_do := Date()
   ELSE
      _dat_od := dDateOd
      _dat_do := dDateDo
   ENDIF

   _o_real_table()

   SET CURSOR ON

   IF !_auto_prenos

      Box(, 4, 70, .F., " PRENOS REALIZACIJE POS->KALK   " )

      @ m_x + 1, m_y + 2 SAY "Prodajno mjesto " GET cIdPos PICT "@!" VALID !Empty( cIdPos ) .OR. P_Kase( @cIdPos, 5, 20 )
      @ m_x + 2, m_y + 2 SAY "Prenos za period" GET _dat_od
      @ m_x + 2, Col() + 2 SAY "-" GET _dat_do
      @ m_x + 3, m_y + 2 SAY "Uslov po artiklima:" GET _usl_roba PICT "@S40"
      @ m_x + 4, m_y + 2 SAY8 "Artikle (U)ključi / (I)sključi iz prenosa:" GET _usl_mark PICT "@!" VALID _usl_mark $ "UI"

      READ
      ESC_BCR

      BoxC()

   ELSE
      cIdPos := cIdPM
   ENDIF

   gIdPos := cIdPos

   _cre_pom_table()
   _o_real_table()

   SELECT pos_doks
   SET ORDER TO TAG "2"
   GO TOP
   SEEK cIdVd + DToS( _dat_od )

   EOF CRET

   _r_br := 0
   _kol := 0
   _iznos := 0

   IF !Empty( _usl_roba ) .AND. Right( AllTrim( _usl_roba ) ) <> ";"
      _usl_roba := AllTrim( _usl_roba ) + ";"
   ENDIF

   DO WHILE !Eof() .AND. pos_doks->IdVd == cIdVd .AND. pos_doks->Datum <= _dat_do

      IF !Empty( cIdPos ) .AND. pos_doks->IdPos <> cIdPos
         SKIP
         LOOP
      ENDIF

      SELECT pos
      SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + Brdok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

         IF !Empty( _usl_roba )
            _tmp := Parsiraj( _usl_roba, "idroba" )
            if &_tmp

               IF _usl_mark == "I"
                  SKIP
                  LOOP
               ENDIF

            ELSE
               IF _usl_mark == "U"
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF

         SELECT roba
         SET ORDER TO TAG "ID"
         HSEEK pos->idroba

         SELECT pom
         SET ORDER TO TAG "1"
         GO TOP
         SEEK pos->idpos + pos->idroba + Str( pos->cijena, 13, 4 ) + Str( pos->ncijena, 13, 4 )

         _kol += pos->kolicina
         _iznos += ( pos->kolicina * pos->cijena )

         IF !Found() .OR. IdTarifa <> POS->IdTarifa .OR. MPC <> POS->Cijena

            APPEND BLANK

            REPLACE IdPos WITH POS->IdPos, ;
               IdRoba WITH POS->IdRoba, ;
               Kolicina WITH POS->Kolicina, ;
               IdTarifa WITH POS->IdTarifa, ;
               mpc WITH POS->Cijena, ;
               IdCijena WITH POS->IdCijena, ;
               Datum WITH _dat_do, ;
               DatPos WITH pos->datum, ;
               brdok WITH pos->brdok, ;
               idvd WITH POS->IdVd, ;
               StMPC WITH pos->ncijena, ;
               barkod WITH roba->barkod, ;
               robanaz WITH roba->naz

            IF !Empty( pos_doks->idgost )
               REPLACE idpartner WITH pos_doks->idgost
            ENDIF

            ++ _r_br
         ELSE

            hRec := dbf_get_rec()
            hRec[ "kolicina" ] := hRec[ "kolicina" ] + pos->kolicina
            dbf_update_rec( hRec )

         ENDIF

         SELECT pos
         SKIP

      ENDDO

      SELECT pos_doks
      SKIP

   ENDDO

   SELECT pom
   USE

   my_close_all_dbf()

   IF !_auto_prenos
      _print_report( _dat_od, _dat_do, _kol, _iznos, _r_br )
      _file := tops_kalk_create_topska( cIdPos, _dat_od, _dat_do, cIdVd )
      MsgBeep( "Kreiran fajl " + _file + "#broj stavki: " + AllTrim( Str( _r_br ) ) )

   ENDIF

   RETURN .T.


STATIC FUNCTION _print_report( datum_od, datum_do, kolicina, iznos, broj_stavki )

   START PRINT CRET

   ?
   ? "PRENOS PODATAKA TOPS->KALK za ", DToC( Date() )
   ?
   ? "Datumski period od", DToC( datum_od ), "do", DToC( datum_do )
   ? "Broj stavki:", AllTrim( Str( broj_stavki ) )
   ?
   ?U "Ukupna količina:", AllTrim( Str( kolicina, 12, 2 ) )
   ? "  Ukupan iznos:", AllTrim( Str( iznos, 12, 2 ) )

   FF
   ENDPRINT

   RETURN .T.


STATIC FUNCTION _cre_pom_table()

   LOCAL aDbf := {}

   AAdd( aDBF, { "IdPos",    "C",   2, 0 } )
   AAdd( aDBF, { "IDROBA",   "C",  10, 0 } )
   AAdd( aDBF, { "ROBANAZ",  "C", 250, 0 } )
   AAdd( aDBF, { "kolicina", "N",  13, 4 } )
   AAdd( aDBF, { "kol2",     "N",  13, 4 } )
   AAdd( aDBF, { "MPC",      "N",  13, 4 } )
   AAdd( aDBF, { "STMPC",    "N",  13, 4 } )
   AAdd( aDBF, { "IDTARIFA", "C",   6, 0 } )
   AAdd( aDBF, { "IDCIJENA", "C",   1, 0 } )
   AAdd( aDBF, { "IDPARTNER", "C",  10, 0 } )
   AAdd( aDBF, { "DATUM",    "D",   8, 0 } )
   AAdd( aDBF, { "DATPOS",   "D",   8, 0 } )
   AAdd( aDBF, { "IdVd",     "C",   2, 0 } )
   AAdd( aDBF, { "BRDOK",    "C",  10, 0 } )
   AAdd( aDBF, { "M1",       "C",   1, 0 } )
   AAdd( aDBF, { "BARKOD",   "C",  13, 0 } )
   AAdd( aDBF, { "JMJ",      "C",   3, 0 } )

   SELECT pos_doks

   pos_cre_pom_dbf( aDbf )

   SELECT ( F_POM )
   IF Used()
      USE
   ENDIF

   my_use_temp( "POM", my_home() + "pom", .F., .T. )

   INDEX on ( idpos + idroba + Str( mpc, 13, 4 ) + Str( stmpc, 13, 4 ) ) TAG "1"

   SET ORDER TO TAG "1"

   RETURN .T.




/*
 kreira izlazni fajl za multi prodajna mjesta režim
*/

STATIC FUNCTION tops_kalk_create_topska( id_pos, datum_od, datum_do, v_dok, cPrefix )

   LOCAL cPrefixLocal := "tk"
   LOCAL cExportDirektorij
   LOCAL cTableName
   LOCAL _table_path
   LOCAL cFajlDestinacija := ""
   LOCAL _bytes := 0
   LOCAL cIdPM

   IF cPrefix != NIL
      cPrefixLocal := cPrefix
   ENDIF

   IF Right( AllTrim( gKalkDest ), 1 ) <> SLASH
      gKalkDest := AllTrim( gKalkDest ) + SLASH
   ENDIF

   direktorij_kreiraj_ako_ne_postoji( AllTrim( gKalkDest ) )

   cIdPM := GetPm( id_pos )

   cExportDirektorij := AllTrim( gKalkDest ) + cIdPM + SLASH

   direktorij_kreiraj_ako_ne_postoji( AllTrim( cExportDirektorij ) )

   DirChange( my_home() )

   cTableName := get_tops_kalk_export_file( "1", cExportDirektorij, datum_do, cPrefix )

   cFajlDestinacija := cExportDirektorij + cTableName + ".dbf"

   IF FileCopy( my_home() + "pom.dbf", cFajlDestinacija ) > 0
      FileCopy( my_home() + OUTF_FILE, StrTran( cFajlDestinacija, ".dbf", ".txt" ) )
   ELSE
      MsgBeep( "Problem sa kopiranjem fajla na lokaciju #" + cExportDirektorij )
   ENDIF

   RETURN cFajlDestinacija
