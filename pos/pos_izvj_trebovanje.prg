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



// -----------------------------------------------
// trebovanje - stampa listica
// -----------------------------------------------
FUNCTION Trebovanja()

   LOCAL cNaz
   LOCAL cJmj

   IF gVodiTreb == "N"
      RETURN
   ENDIF

   SELECT _pos
   SET ORDER TO 3   // "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba"
   SEEK "42" + gIdRadnik + OBR_NIJE

   IF gRadniRac == "N"
      // gledaj samo kada nisu radni racuni
      IF !( _pos->M1 $ "ZS" )
         // zakljucen ili odstampan!!
         RETURN
      ENDIF
   ENDIF

   MsgO ( "GENERISANJE  TREBOVANJA ..." )

   DO WHILE !Eof() .AND. _POS->( IdVd + IdRadnik + GT ) == ( "42" + gIdRadnik + OBR_NIJE )
      IF !SPrint2( PortZaMT( _POS->IdDio, _POS->IdOdj ) )
         MsgBeep ( "Stampanje trebovanja nije uspjelo!!!#Ono ce biti odstampano nakon unosa sljedece narudzbe!!!!" )
         MsgC()
         RETURN
      ENDIF
      SELECT _pos
      Scatter()
      nMTslog := RecNo()
      ?
      ?? PadC( "TREBOVANJE", 40 )
      cTxt := ""
      SELECT odj
      HSEEK _IdOdj
      IF Found()
         cTxt := AllTrim( odj->Naz )
      ENDIF
      SELECT dio
      HSEEK _IdDio
      IF Found()
         cTxt += "-" + AllTrim( dio->Naz )
      ENDIF
      ? PadC( cTxt, 40 )
      ? "Kasa: " + _IdPos, Space( 3 ), iif( gColleg == "D", Day( _datum ), FormDat1( _Datum ) ), "", iif( gColleg == "D", "", Left( Time(), 5 ) ), PadL ( "Smjena:" + _Smjena, 9 )

      ? PadC ( AllTrim( gKorIme ), 40 )
      ?
      ? "Sifra/                JMJ  Kolic."
      ? "(Naziv)"
      ? "----------------------------------"

      SELECT _pos
      DO WHILE !Eof() .AND. _POS->( IdVd + IdRadnik + GT + IdDio + IdOdj ) == ( VD_RN + gIdRadnik + OBR_NIJE + _IdDio + _IdOdj )
         cNaz := _POS->RobaNaz
         cJmj := _POS->Jmj
         cIdRoba  := _POS->IdRoba
         nKolRobe := 0
         DO WHILE !Eof() .AND. _POS->( IdVd + IdRadnik + GT + IdDio + IdOdj + IdRoba ) == ( "42" + gIdRadnik + OBR_NIJE + _IdDio + _IdOdj + cIdRoba )
            // smjesti (dodaj) ovu stavku na trebovanje
            IF gRadniRac == "N" // samo ako nisu radni racuni
               IF !( _pos->m1 $ "ZS" )  // zakljucen ili odstampan!!
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF _idpos <> gidpos .OR. _datum <> gDatum
               // neznam kako, ali se mozda nadje
               // Seek2 (cIdPos+"42"+dtos(gDatum)+cRadRac)
               SKIP
               LOOP
            ENDIF
            nKolRobe += _POS->Kolicina
            SKIP
         ENDDO
         IF Len( Trim( cIdRoba ) ) > 8
            cRazmak := Space( 5 )
         ELSE
            cRazmak := Space( 10 )
         ENDIF
         ? cIdRoba, cRazmak, cJmj, Str( nKolRobe, 7, 2 )
         ? "(" + AllTrim( cNaz ) + ")"
      ENDDO

      // zavrsili smo s jednim mjestom trebovanja
      // posto smo odstampali trebovanje, mogu ga ukloniti
      // moram se vratiti na pocetni slog

      SELECT _POS
      GO nMTslog
      DO WHILE !Eof() .AND. _POS->( IdVd + IdRadnik + GT + IdDio + IdOdj ) == ( "42" + gIdRadnik + OBR_NIJE + _IdDio + _IdOdj )
         SKIP
         nNarRec := RecNo()
         SKIP -1
         REPLACE GT WITH OBR_JEST
         GO nNarRec
      ENDDO
      ? "----------------------------------"
      PaperFeed()
      ENDPRN2
   ENDDO

   MsgC()

   RETURN .T.
