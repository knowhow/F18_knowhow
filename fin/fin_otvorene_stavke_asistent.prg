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



// -------------------------------------------------------------
// provjera duplih partnera pri pomoci asistenta
// -------------------------------------------------------------
FUNCTION ProvDuplePartnere( cIdP, cIdK, cDp, lAsist, lSumirano )

   IF gOAsDuPartn == "N"
      RETURN 0
   ENDIF

   SELECT fin_pripr
   GO TOP

   nCnt := 0
   nSuma := 0

   IF fNovi
      nTot := 0
   ELSE
      nTot := 1
   ENDIF

   DO WHILE !Eof()
      IF field->idpartner == cIdP .AND. field->idkonto == cIdK .AND. field->d_p == cDp
         ++ nCnt
         nSuma += field->iznosbhd
      ENDIF
      SKIP
   ENDDO

   IF ( nCnt > nTot ) .AND. Pitanje(, "Spojiti duple uplate za partnera?", "D" ) == "D"
      GO TOP
      DO WHILE !Eof()
         IF field->idpartner == cIdP .AND. field->idkonto == cIdK .AND. field->d_p == cDp
            my_delete()
         ENDIF
         SKIP
      ENDDO
      lSumirano := .T.
   ELSE
      lAsist := .F.
      RETURN nSuma
   ENDIF

   RETURN nSuma



// brisanje zapisa idfirma "XX"
STATIC FUNCTION _del_nal_xx()

   LOCAL nTArea := Select()
   LOCAL nTREC := RecNo()

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   SEEK "XX"

   DO WHILE !Eof() .AND. field->idfirma == "XX"

      IF field->rbr == "000"
         my_delete()
      ENDIF

      SKIP
   ENDDO

   SELECT ( nTArea )
   GO ( nTRec )

   RETURN .T.


// -----------------------------------------------------------
// kreiranje tabele ostav za otvorene stavke
// -----------------------------------------------------------
STATIC FUNCTION _cre_ostav()

   LOCAL _dbf
   LOCAL _ret := .T.
   LOCAL _table := "ostav"

   // formiraj datoteku ostav
   _dbf := {}
   AAdd( _dbf, { 'DATDOK', 'D',   8,  0 } )
   AAdd( _dbf, { 'DATVAL', 'D',   8,  0 } )
   AAdd( _dbf, { 'DATZPR', 'D',   8,  0 } )
   AAdd( _dbf, { 'BRDOK', 'C',   10,  0 } )
   AAdd( _dbf, { 'D_P', 'C',   1,  0 } )
   AAdd( _dbf, { 'IZNOSBHD', 'N',  21,  2 } )
   AAdd( _dbf, { 'UPLACENO', 'N',  21,  2 } )
   AAdd( _dbf, { 'M2', 'C',  1, 0 } )

   dbCreate( my_home() + _table + ".dbf", _dbf )

   SELECT ( F_OSTAV )
   USE

   my_use_temp( "OSTAV", my_home() + _table, .F., .T. )

   INDEX ON DToS( DatDok ) + DToS( iif( Empty( datval ), datdok, datval ) ) + brdok TAG "1"

   RETURN _ret


// --------------------------------------------------------------------------------------------------
// sredjivanje otvorenih stavki pri knjizenju, poziv na polju strane valute<a+O>
// --------------------------------------------------------------------------------------------------
FUNCTION konsultos( xEdit )

   LOCAL fgenerisano
   LOCAL nNaz := 1
   LOCAL nRec := RecNo()
   LOCAL _col, _row
   LOCAL _rec, _i

   lAsist := .T.
   lSumirano := .F.
   nZbir := 0
   nZbir := ProvDuplePartnere( _idpartner, _idkonto, _d_p, @lAsist, @lSumirano )

   IF nZbir > 0 .AND. !lAsist
      MsgBeep( "Na dokumentu postoje dvije ili vise uplata#za istog kupca. Asistent onemogucen!" )
      RETURN ( NIL )
   ENDIF

   cIdFirma := gFirma
   cIdPartner := _idpartner

   IF gOAsDuPartn == "D" .AND. ( nZbir <> 0 )
      IF fNovi
         nIznos := _iznosbhd + nZbir
      ELSE
         nIznos := nZbir
      ENDIF
   ELSE
      nIznos := _iznosbhd
   ENDIF

   cDugPot := _d_p
   cOpis := _Opis

   IF gRJ == "D"
      cIdRj := _idrj
   ENDIF

   IF gTroskovi == "D"
      cFunk := _Funk
      cFond := _Fond
   ENDIF

   picD := FormPicL( "9 " + gPicBHD, 14 )
   picDEM := FormPicL( "9 " + gPicDEM, 9 )

   cIdKonto := _idkonto

   cIdFirma := Left( cIdFirma, 2 )

   SELECT ( F_SUBAN )
   USE
   O_SUBAN

   SELECT suban
   SET ORDER TO TAG "1"
   // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

   GO TOP

   Box(, 20, 77 )

   @ m_x, m_y + 25 SAY "KONSULTOVANJE OTVORENIH STAVKI"

#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif

   _cre_ostav() // kreiraj tabelu ostav

   nUkDugBHD := 0
   nUkPotBHD := 0

   SELECT suban
   SET ORDER TO TAG "3"

   SEEK cIdfirma + cIdkonto + cIdpartner

   dDatDok := CToD( "" )

   cPrirkto := "1"
   // priroda konta

   SELECT ( F_TRFP2 )
   IF !Used()
      O_TRFP2
   ENDIF

   HSEEK "99 " + Left( cIdKonto, 1 )

   DO WHILE !Eof() .AND. field->idvd == "99" .AND. Trim( field->idkonto ) != Left( cIdKonto, Len( Trim( field->idkonto ) ) )
      SKIP 1
   ENDDO

   IF field->idvd == "99" .AND. Trim( field->idkonto ) == Left( cIdKonto, Len( Trim( field->idkonto ) ) )
      cPrirkto := field->d_p
   ELSE
      IF cIdKonto = "21"
         cPrirkto := "1"
      ELSE
         cPrirkto := "2"
      ENDIF
   ENDIF

   SELECT suban

   nUDug2 := 0
   nUPot2 := 0
   nUDug := 0
   nUPot := 0

   fPrviprolaz := .T.

   DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. cIdKonto == field->idkonto .AND. cIdPartner == field->idpartner

      cBrDok := field->brdok
      cOtvSt := field->otvst
      dDatDok := Max( field->datval, field->datdok )

      nDug2 := 0
      nPot2 := 0
      nDug := 0
      nPot := 0

      aFaktura := { CToD( "" ), CToD( "" ), CToD( "" ) }

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. cIdKonto == field->idkonto .AND. cIdPartner == field->idpartner ;
            .AND. field->brdok == cBrDok

         dDatDok := Min( Max( field->datval, field->datdok ), dDatDok )

         IF field->d_p == "1"
            nDug += field->IznosBHD
            nDug2 += field->IznosDEM
         ELSE
            nPot += field->IznosBHD
            nPot2 += field->IznosDEM
         ENDIF

         IF field->d_p == cPrirkto
            aFaktura[ 1 ] := field->DATDOK
            aFaktura[ 2 ] := field->DATVAL
         ENDIF

         IF aFaktura[ 3 ] < field->DatDok
            // datum zadnje promjene
            aFaktura[ 3 ] := field->DatDok
         ENDIF

         SKIP

      ENDDO

      IF Round( nDug - nPot, 2 ) <> 0

         SELECT ostav

         my_flock()

         APPEND BLANK

         REPLACE field->iznosbhd with ( nDug - nPot )
         REPLACE field->datdok WITH aFaktura[ 1 ]
         REPLACE field->datval WITH aFaktura[ 2 ]
         REPLACE field->datzpr WITH aFaktura[ 3 ]
         REPLACE field->brdok WITH cBrDok

         IF ( cDugPot == "2" )
            REPLACE field->d_p WITH "1"
         ELSE
            REPLACE field->d_p WITH "2"
            REPLACE field->iznosbhd WITH -iznosbhd
         ENDIF

         my_unlock()

         SELECT suban

      ENDIF

   ENDDO

   ImeKol := {}

   AAdd( ImeKol, { "Br.Veze",     {|| BrDok }                          } )
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }                         } )
   AAdd( ImeKol, { "Dat.Val.",   {|| DatVal }                         } )
   AAdd( ImeKol, { "Dat.ZPR.",   {|| DatZPR }                         } )
   AAdd( ImeKol, { PadR( "Duguje " + AllTrim( ValDomaca() ), 14 ), {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 14, 2 ) }     } )
   AAdd( ImeKol, { PadR( "Potraz." + AllTrim( ValDomaca() ), 14 ), {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 14, 2 ) }     } )
   AAdd( ImeKol, { PadR( "Uplaceno", 14 ), {|| Str( uplaceno, 14, 2 ) }     } )

   Kol := {}

   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   _row := MAXROWS() - 15
   _col := MAXCOLS() - 6

   Box(, _row, _col, .T. )

   SET CURSOR ON

   @ m_x + _row - 2, m_y + 1 SAY '<Enter> Izaberi/ostavi stavku'
   @ m_x + _row - 1, m_y + 1 SAY '<F10>   Asistent'
   @ m_x + _row,    m_y + 1 SAY ""

   ?? "  IZNOS Koji zatvaramo: " + IF( cDugPot == "1", "duguje", "potrazuje" ) + " " + AllTrim( Str( nIznos ) )

   PRIVATE cPomBrDok := Space( 10 )

   SELECT ostav
   GO TOP

   my_db_edit( "KOStav", _row, _col, {|| EdKonsRos() }, "", "Otvorene stavke.", , , , {|| field->m2 = '3' }, 3 )

   Boxc()

   SELECT ostav

   nNaz := Kurs( _datdok )

   fM3 := .F.

   GO TOP

   DO WHILE !Eof()
      IF field->m2 = "3"
         fm3 := .T.
         EXIT
      ENDIF
      SKIP
   ENDDO

   fGenerisano := .F.

   IF fM3 .AND. Pitanje( "", "Izgenerisati stavke u nalogu za knjizenje ?", "D" ) == "D"

      SELECT ( F_OSTAV )
      GO TOP

      SELECT ostav

      DO WHILE !Eof()

         IF field->m2 == "3"

            my_rlock()
            REPLACE field->m2 WITH ""
            my_unlock()

            SELECT ( F_FIN_PRIPR )

            IF fgenerisano
               APPEND BLANK
            ELSE
               IF !fNovi
                  IF lSumirano
                     APPEND BLANK
                  ELSE
                     GO nRec
                  ENDIF
               ELSE
                  APPEND BLANK
               ENDIF

               // prvi put
               fGenerisano := .T.

            ENDIF

            Scatter( "w" )

            widfirma  := cidfirma
            widvn     := _idvn
            wbrnal    := _brnal
            widtipdok := _idtipdok
            wdATvAL   := CToD( "" )
            wdatdok   := _datdok
            wopis     := ""
            wIdkonto  := cidkonto
            widpartner := cidpartner
            wOpis     := cOpis
            wk1       := _k1
            wk2       := _k2
            wk3       := K3U256( _k3 )
            wk4       := _k4
            wm1       := _m1

            IF gRJ == "D"
               widrj     := cIdRj
            ENDIF

            IF gTroskovi == "D"
               wFunk := cFunk
               wFond := cFond
            ENDIF

            wrbr      := Str( nRBr, 4 )
            nRbr ++
            wd_p      := _D_p
            wIznosBhd := ostav->uplaceno

            IF ostav->uplaceno <> ostav->iznosbhd
               wOpis := Trim( cOpis ) + ", DIO"
            ENDIF

            wBrDok    := ostav->brdok
            wiznosdem := if( Round( nNaz, 4 ) == 0, 0, wiznosbhd / nNaz )

            my_rlock()
            Gather( "w" )
            my_unlock()

            SELECT ( F_OSTAV )

         ENDIF

         SKIP 1

      ENDDO

   ENDIF

   BoxC()

   IF fGenerisano

      -- nRbr

      SELECT ( F_FIN_PRIPR )

      // uzmi posljednji slog
      Scatter()

      IF fNovi
         my_delete()
      ELSE
         // pa ga za svaki slucaj pohrani
         my_rlock()
         Gather()
         my_unlock()
      ENDIF

      _k3 := K3Iz256( _k3 )

      ShowGets()

   ENDIF

   SELECT ( F_OSTAV )
   USE

   SELECT ( F_FIN_PRIPR )

   IF !fGenerisano
      IF !Used()
         o_fin_edit()
         SELECT ( F_FIN_PRIPR )
      ENDIF
      GO nRec
   ENDIF

   RETURN ( NIL )


// -----------------------------------------------------------------
// key handler
// -----------------------------------------------------------------
STATIC FUNCTION EdKonsROS()

   LOCAL oBrDok := ""
   LOCAL cBrdok := ""
   LOCAL nTrec
   LOCAL cDn := "N"
   LOCAL nRet := DE_CONT
   LOCAL GetList := {}
   LOCAL _rec

   DO CASE

   CASE Ch == K_F2

      IF pitanje(, "Izvrsiti ispravku broja veze u SUBAN ?", "N" ) == "D"

         oBrDok := BRDOK
         cBrDok := BRDOK

         Box(, 2, 60 )
         @ m_x + 1, m_Y + 2 SAY "Novi broj veze:" GET cBRDok
         READ
         BoxC()

         IF LastKey() <> K_ESC

            SELECT suban
            PushWA()
            SET ORDER TO TAG "3"
            SEEK _idfirma + _idkonto + _idpartner + obrdok

            DO WHILE !Eof() .AND. _idfirma + _idkonto + _idpartner + obrdok == idfirma + idkonto + idpartner + brdok

               SKIP
               nTrec := RecNo()
               SKIP -1

               _rec := dbf_get_rec()
               _rec[ "brdok" ] := cBrDok

               update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

               GO nTRec

            ENDDO

            PopWa()

            SELECT ostav
            _rec := dbf_get_rec()
            _rec[ "brdok" ] := cBrDok
            dbf_update_rec( _rec )

            nRet := DE_ABORT

            MsgBeep( "Nakon ispravke morate ponovo pokrenuti asistenta sa <a-O>  !" )

         ENDIF

      ELSE

         nRet := DE_REFRESH

      ENDIF

   CASE Ch == K_CTRL_T

      IF Pitanje(, "Izbrisati stavku ?", "N" ) == "D"
         my_delete()
         nRet := DE_REFRESH
      ELSE
         nRet := DE_CONT
      ENDIF

   CASE Ch == K_ENTER

      IF uplaceno = 0
         _uplaceno := iznosbhd
      ELSE
         _uplaceno := uplaceno
      ENDIF

      Box(, 2, 60 )
      @ m_x + 1, m_y + 2 SAY "Uplaceno po ovom dokumentu:" GET _uplaceno PICT "999999999.99"
      READ
      Boxc()

      IF LastKey() <> K_ESC
         IF _uplaceno <> 0
            RREPLACE m2 WITH "3", uplaceno WITH _uplaceno
         ELSE
            RREPLACE m2 WITH "", uplaceno WITH 0
         ENDIF
      ENDIF

      nRet := DE_REFRESH

   CASE Ch = K_F10

      SELECT ostav
      GO TOP

      IF Pitanje(, "Asistent zatvara stavke ?", "D" ) == "D"

         nPIznos := nIznos
         // iznos uplate npr

         GO TOP
         my_flock()
         DO WHILE !Eof()
            IF cDugPot <> d_p .AND. nPIznos > 0
               _Uplaceno := Min( field->iznosbhd, nPIznos )
               REPLACE m2 WITH "3"
               REPLACE uplaceno WITH _uplaceno
               nPIznos -= _uplaceno
            ELSE
               REPLACE m2 WITH ""
            ENDIF
            SKIP 1
         ENDDO
         my_unlock()
         GO TOP

         IF nPIznos > 0

            // ostao si u avansu
            APPEND BLANK
            Scatter( "w" )
            wbrdok := PadR( "AVANS", 10 )

            IF cDugPot == "1"
               wd_p := "1"
            ELSE
               wd_p := "2"
            ENDIF

            wiznosbhd := npiznos
            wuplaceno := npiznos
            wdatdok := Date()
            wm2 := "3"

            Box(, 2, 60 )
            @ m_x + 1, m_y + 2 SAY  "Ostatak sredstava knjiziti na dokument:" GET wbrdok
            READ
            Boxc()

            gather( "w" )

         ENDIF

      ENDIF

      nRet := DE_REFRESH

   ENDCASE

   RETURN nRet
