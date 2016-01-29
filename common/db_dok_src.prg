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


// ------------------------------------------------------
// kreiranje tabela DOKSRC i P_DOKSRC
// ------------------------------------------------------
FUNCTION cre_doksrc( ver )

   LOCAL aDbf := {}
   LOCAL cDokSrcName := "DOKSRC"
   LOCAL cPDokSrcName := "P_" + cDokSrcName
   LOCAL nBrDokLen := 8

   AAdd( aDBf, { "idfirma", "C",   2,  0 } )
   AAdd( aDBf, { "idvd", "C",   2,  0 } )
   AAdd( aDBf, { "brdok", "C",  nBrDokLen,  0 } )
   AAdd( aDBf, { "datdok", "D",   8,  0 } )
   AAdd( aDBf, { "src_modul", "C",  10,  0 } )
   AAdd( aDBf, { "src_idfirm", "C",   2,  0 } )
   AAdd( aDBf, { "src_idvd", "C",   2,  0 } )
   AAdd( aDBf, { "src_brdok", "C",   8,  0 } )
   AAdd( aDBf, { "src_datdok", "D",   8,  0 } )
   AAdd( aDBf, { "src_kto_ra", "C",   7,  0 } )
   AAdd( aDBf, { "src_kto_za", "C",   7,  0 } )
   AAdd( aDBf, { "src_partne", "C",   6,  0 } )
   AAdd( aDBf, { "src_opis", "C",  30,  0 } )

   IF !File( f18_ime_dbf( cDokSrcName ) )
      DBCREATE2( cDokSrcName + ".dbf", aDbf )
   ENDIF

   // indexi....
   CREATE_INDEX( "1", "idfirma+idvd+brdok+DTOS(datdok)+src_modul+src_idfirm+src_idvd+src_brdok+DTOS(src_datdok)", cDokSrcName )
   CREATE_INDEX( "2", "src_modul+src_idfirm+src_idvd+src_brdok+DTOS(src_datdok)", cDokSrcName )

   // kreiraj u PRIVPATH
   IF !File( f18_ime_dbf( cPDokSrcName ) )
      DBCREATE2( PRIVPATH + cPDokSrcName + ".DBF", aDbf )
   ENDIF
   // indexi....
   CREATE_INDEX( "1", "idfirma+idvd+brdok+DTOS(datdok)+src_modul+src_idfirm+src_idvd+src_brdok+DTOS(src_datdok)", PRIVPATH + cPDokSrcName )
   CREATE_INDEX( "2", "src_modul+src_idfirm+src_idvd+src_brdok+DTOS(src_datdok)", PRIVPATH + cPDokSrcName )

   cre_p_update()

   RETURN

// ------------------------------------------------------
// dodaj novi zapis u p_doksrc
// ------------------------------------------------------
FUNCTION add_p_doksrc( cFirma, cTD, cBrDok, dDatDok, ;
      cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, ;
      dSrcDatDok, cSrcKto1, cSrcKto2, cSrcPartn, ;
      cSrcOpis, cPath )

   LOCAL nTArea := Select()

   // ako ne postoji doksrc, ne radi nista!
   IF !is_doksrc()
      RETURN
   ENDIF

   cSrcModName := PadR( cSrcModName, 10 )
   cSrcBrDok := PadR( AllTrim( cSrcBrDok ), 8 )

   // ako postoji zapis source-a u tabeli... preskoci
   IF seek_p_src( cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, dSrcDatDok )
      SELECT ( nTArea )
      RETURN
   ENDIF

   o_p_doksrc( cPath )

   SELECT p_doksrc
   APPEND BLANK

   REPLACE field->idfirma    WITH cFirma
   REPLACE field->idvd       WITH cTD
   REPLACE field->brdok      WITH cBrDok
   REPLACE field->datdok     WITH dDatDok
   REPLACE field->src_modul  WITH cSrcModName
   REPLACE field->src_idfirm WITH cSrcFirma
   REPLACE field->src_idvd   WITH cSrcTD
   REPLACE field->src_brdok  WITH cSrcBrDok
   REPLACE field->src_datdok WITH dSrcDatDok
   REPLACE field->src_kto_ra WITH cSrcKto1
   REPLACE field->src_kto_za WITH cSrcKto2
   REPLACE field->src_partne WITH cSrcPartn
   REPLACE field->src_opis   WITH cSrcOpis

   SELECT p_doksrc
   USE

   SELECT ( nTArea )

   RETURN


// ---------------------------------------
// otvaranje tabele p_doksrc
// ---------------------------------------
FUNCTION o_p_doksrc( cPath )

   O_P_DOKSRC

   RETURN


// --------------------------------------
// otvaranje tabele doksrc
// --------------------------------------
FUNCTION o_doksrc( cPath )

   O_DOKSRC

   RETURN


// -----------------------------------
// zapuje p_doksrc
// -----------------------------------
FUNCTION zap_p_doksrc( cPath )

   LOCAL nTArea := Select()

   // ako postoji tabela...
   IF is_doksrc()
      o_p_doksrc( cPath )
      SELECT p_doksrc
      zapp()
      SELECT p_doksrc
      USE
      SELECT ( nTArea )
   ENDIF

   RETURN


// --------------------------------------------------
// vrati iz kumulativa u pripr
// --------------------------------------------------
STATIC FUNCTION doksrc_to_p( cFirma, cIdVd, cBrDok, dDatDok )

   LOCAL nTArea := Select()
   LOCAL cSeek := ""
   LOCAL _rec

   O_P_DOKSRC
   O_DOKSRC

   zap_p_doksrc()

   SELECT doksrc
   SET ORDER TO TAG "1"
   GO TOP

   cSeek := cFirma + cIdVd + cBrDok
   IF dDatDok <> nil
      cSeek += DToS( dDatDok )
   ENDIF

   SEEK cSeek

   DO WHILE !Eof() .AND. field->idfirma == cFirma ;
         .AND. field->idvd == cIdVd ;
         .AND. field->brdok == cBrDok ;
         .AND. IF( dDatDok <> nil, field->datdok == dDatDok, .T. )


      _rec := dbf_get_rec()

      SELECT p_doksrc
      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT doksrc
      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN

// ---------------------------------------------------
// brisanje zapisa iz tabele DOKSRC
// ---------------------------------------------------
FUNCTION d_doksrc( cFirma, cIdVd, cBrDok, dDatDok )

   LOCAL nTArea := Select()
   LOCAL cSeek := ""

   O_DOKSRC
   SELECT doksrc
   SET ORDER TO TAG "1"
   GO TOP

   cSeek := cFirma + cIdVd + cBrDok
   IF dDatDok <> nil
      cSeek += DToS( dDatDok )
   ENDIF

   SEEK cSeek

   // izbrisi iz doksrc
   DO WHILE !Eof() .AND. field->idfirma == cFirma ;
         .AND. field->idvd == cIdVd ;
         .AND. field->brdok == cBrDok ;
         .AND. IF( dDatDok <> nil, field->datdok == dDatDok, .T. )
      DELETE
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN

// -----------------------------------------------------
// povrat doksrc...
// -----------------------------------------------------
FUNCTION povrat_doksrc( cFirma, cIdVd, cBrDok, dDatDok )

   // doksrc -> p_doksrc
   doksrc_to_p( cFirma, cIdVd, cBrDok, dDatDok )
   // brisi doksrc
   d_doksrc( cFirma, cIdVd, cBrDok, dDatDok )

   RETURN



// -----------------------------------------
// provjerava da li postoje tabele DOKSRC
// -----------------------------------------
FUNCTION is_doksrc()

   LOCAL lRet := .F.

   IF File( "DOKSRC.DBF" )
      lRet := .T.
   ENDIF

   RETURN lRet


// ------------------------------------------------------
// azuriraj p_doksrc -> doksrc
// cPPath - privpath
// cKPath - kumpath
// ------------------------------------------------------
FUNCTION p_to_doksrc( cPPath, cKPath )

   LOCAL nTArea := Select()
   LOCAL nTRecNR := ( nTArea )->( RecNo() )

   // ako ne postoji doksrc, ne radi nista!
   IF !is_doksrc()
      RETURN
   ENDIF

   IF cPPath == nil
      cPPath := PRIVPATH
   ENDIF
   IF cKPath == nil
      cKPath := KUMPATH
   ENDIF

   o_p_doksrc( cPPath )
   o_doksrc( cKPath )

   SELECT p_doksrc
   GO TOP

   // provjeri broj zapisa...
   IF p_doksrc->( RecCount2() ) == 0
      SELECT ( nTArea )
      RETURN
   ENDIF

   // izbrisi ako vec postoji taj dokument...
   d_doksrc( p_doksrc->idfirma, p_doksrc->idvd, p_doksrc->brdok, p_doksrc->datdok )

   SELECT p_doksrc
   GO TOP

   MsgO( "Azuriram DOKSRC...." )

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      SELECT doksrc

      APPEND BLANK

      update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )

      SELECT p_doksrc

      SKIP
   ENDDO

   MsgC()

   SELECT p_doksrc
   zapp()

   SELECT p_doksrc
   USE
   SELECT doksrc
   USE

   SELECT ( nTArea )

   RETURN


// ----------------------------------------------------
// seekuj p_doksrc za dokumentom, da li postoji
// ----------------------------------------------------
STATIC FUNCTION seek_p_dok( cFirma, cIdVd, cBrDok, dDatum )

   LOCAL nTArea := Select()
   LOCAL cSeek
   LOCAL lReturn := .F.

   O_P_DOKSRC
   SELECT p_doksrc
   SET ORDER TO TAG "1"
   GO TOP

   cSeek := cFirma

   IF cIdVD <> nil
      cSeek += cIdVd
   ENDIF
   IF cBrDok <> nil
      cSeek += cBrDok
   ENDIF
   IF dDatum <> nil
      cSeek += DToS( dDatum )
   ENDIF

   SEEK cSeek

   IF Found()
      lReturn := .T.
   ENDIF

   SELECT ( nTArea )

   RETURN lReturn



// ----------------------------------------------------
// seekuj p_doksrc za src dokumentom, da li postoji
// ----------------------------------------------------
STATIC FUNCTION seek_p_src( cModul, cFirma, cIdVd, cBrDok, dDatum )

   LOCAL nTArea := Select()
   LOCAL cSeek
   LOCAL lReturn := .F.

   O_P_DOKSRC
   SELECT p_doksrc
   SET ORDER TO TAG "2"
   GO TOP

   cSeek := cModul + cFirma

   IF cIdVD <> nil
      cSeek += cIdVd
   ENDIF

   IF cBrDok <> nil
      cSeek += cBrDok
   ENDIF

   IF dDatum <> nil
      cSeek += DToS( dDatum )
   ENDIF

   SEEK cSeek

   IF Found()
      lReturn := .T.
   ENDIF

   SET ORDER TO TAG "1"

   SELECT ( nTArea )

   RETURN lReturn



// ----------------------------------------------------------
// kreiranje tabele P_UPDATE
//
// tabela se non-stop puni informacijama pri svakom skeniranju
// iz kalk-a ili update-a iz TOPS-a
// skeniranje se u kalk-u pokrece ako je p_updated = "N"
// te se pri zavrsetku setuje na "D"
// svaki import u TOPSK puni p_updated = "N"
//
// | modul | idkonto | p_updated | p_up_date | p_up_time |
// | TOPS  | 13270   |    N      | 02.10.06  | 13:22:01  |
// | TOPS  | 13280   |    D      | 03.10.06  | 15:10:22  |
// itd...
// ----------------------------------------------------------

FUNCTION cre_p_update()

   LOCAL aDBF := {}
   LOCAL cDbfName := "P_UPDATE"

   AAdd( aDBf, { "modul", "C",  10,  0 } )
   AAdd( aDBf, { "idkonto", "C",   7,  0 } )
   AAdd( aDBf, { "p_updated", "C",   1,  0 } )
   AAdd( aDBf, { "p_up_date", "D",   8,  0 } )
   AAdd( aDBf, { "p_up_time", "C",  10,  0 } )

   // kreiraj u KUMPATH
   IF !File( f18_ime_dbf( cDbfName ) )
      DBCREATE2( cDbfName + ".DBF", aDbf )
   ENDIF
   // indexi....
   CREATE_INDEX( "1", "modul+idkonto+p_updated", cDbfName )

   RETURN


// -----------------------------------------
// otvoranje tabele p_update
// -----------------------------------------
FUNCTION o_p_update( cPath )

   LOCAL nTArea := Select()

   IF ( cPath == nil )
      cPath := KUMPATH
   ENDIF

   cPath := AllTrim( cPath )

   AddBS( @cPath )

   IF !File( ToUnix( cPath + "P_UPDATE.DBF" ) )
      SELECT ( nTArea )
      RETURN 0
   ENDIF

   SELECT ( 240 )
   USE ( cPath + "P_UPDATE" ) ALIAS p_update
   SET ORDER TO TAG "1"

   SELECT ( nTArea )

   RETURN 1



// -----------------------------------
// zatvaranje tabele p_update
// -----------------------------------
FUNCTION c_p_update()

   SELECT p_update
   USE

   RETURN 1


// -----------------------------------------------
// skenira tabelu update za cKonto
// lReturn - .t. - treba skenirati
// lReturn - .f. - ne treba skenirati
// -----------------------------------------------
FUNCTION scan_p_update( cModul, cKonto, cPath )

   LOCAL lReturn := .F.
   LOCAL nTArea := Select()

   // otvori update
   IF o_p_update( cPath ) == 0
      RETURN
   ENDIF

   SELECT p_update
   SET ORDER TO TAG "1"
   GO TOP
   SEEK PadR( cModul, 10 ) + cKonto

   IF Found()
      IF field->p_updated == "N"
         lReturn := .T.
      ENDIF
   ENDIF

   // zatvori p_update
   c_p_update()

   SELECT ( nTArea )

   RETURN lReturn


// -----------------------------------------------
// dodaje zapis u tabelu p_update
// -----------------------------------------------
FUNCTION add_p_update( cModul, cKonto, cUpd, cPath )

   LOCAL nTArea := Select()

   // otvori p_update
   IF o_p_update( cPath ) == 0
      RETURN
   ENDIF

   SELECT p_update
   SET ORDER TO TAG "1"
   GO TOP
   SEEK PadR( cModul, 10 ) + cKonto

   IF !Found()
      APPEND BLANK
   ENDIF

   REPLACE modul WITH cModul
   REPLACE idkonto WITH cKonto
   REPLACE p_updated WITH cUpd
   REPLACE p_up_date WITH Date()
   REPLACE p_up_time WITH Time()

   // zatvori p_update
   c_p_update()

   SELECT ( nTArea )

   RETURN
