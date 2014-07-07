
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


#include "kalk.ch"



FUNCTION kalk_azuriranje_tabele_pripr9()

   LOCAL lGen := .F.
   LOCAL cPametno := "D"
   LOCAL cIdFirma
   LOCAL cIdvd
   LOCAL cBrDok
   LOCAL _a_pripr
   LOCAL _i, _rec, _scan
   LOCAL _id_firma, _id_vd, _br_dok

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr
   GO TOP

   IF kalk_pripr->( RecCount() ) == 0
      RETURN
   ENDIF

   IF Pitanje( "p1", "Želite li pripremu prebaciti u smeće (D/N) ?", "N" ) == "N"
      RETURN
   ENDIF

   _a_pripr := kalk_dokumenti_iz_pripreme_u_matricu()

   postoji_li_dokument_u_pripr9( @_a_pripr )

   SELECT kalk_pripr
   GO TOP

   DO WHILE !Eof()

      _scan := AScan( _a_pripr, {|var| VAR[ 1 ] == field->idfirma .AND. ;
         VAR[ 2 ] == field->idvd .AND. ;
         VAR[ 3 ] == field->brdok } )

      IF _scan > 0 .AND. _a_pripr[ _scan, 4 ] == 0

         _id_firma := field->idfirma
         _id_vd := field->idvd
         _br_dok := field->brdok

         DO WHILE !Eof() .AND. field->idfirma + field->idvd + field->brdok == _id_firma + _id_vd + _br_dok

            _rec := dbf_get_rec()

            SELECT kalk_pripr9
            APPEND BLANK

            dbf_update_rec( _rec )

            SELECT kalk_pripr
            SKIP

         ENDDO

         log_write( "F18_DOK_OPER: kalk, prenos dokumenta iz pripreme u smece: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 2 )

      ENDIF

   ENDDO

   SELECT kalk_pripr
   my_dbf_zap()

   my_close_all_dbf()

   RETURN



FUNCTION kalk_povrat_dokumenta_iz_pripr9( cIdFirma, cIdVd, cBrDok )

   LOCAL nRec
   LOCAL _rec

   lSilent := .T.

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr9
   SET ORDER TO TAG "1"

   IF ( ( cIdFirma == nil ) .AND. ( cIdVd == nil ) .AND. ( cBrDok == nil ) )
      lSilent := .F.
   ENDIF

   IF !lSilent
      cIdFirma := gFirma
      cIdVD := Space( 2 )
      cBrDok := Space( 8 )
   ENDIF

   IF !lSilent
      Box( "", 1, 35 )
      @ m_x + 1, m_y + 2 SAY "Dokument:"
      IF gNW $ "DX"
         @ m_x + 1, Col() + 1 SAY cIdFirma
      ELSE
         @ m_x + 1, Col() + 1 GET cIdFirma
      ENDIF
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVD
      @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
      READ
      ESC_BCR
      BoxC()

      IF cBrDok = "."
         PRIVATE qqBrDok := qqDatDok := qqIdvD := Space( 80 )
         qqIdVD := PadR( cidvd + ";", 80 )
         Box(, 3, 60 )
         DO WHILE .T.
            @ m_x + 1, m_y + 2 SAY "Vrste dokum.   "  GET qqIdVD PICT "@S40"
            @ m_x + 2, m_y + 2 SAY "Broj dokumenata"  GET qqBrDok PICT "@S40"
            @ m_x + 3, m_y + 2 SAY "Datumi         " GET  qqDatDok PICT "@S40"
            READ
            PRIVATE aUsl1 := Parsiraj( qqBrDok, "BrDok", "C" )
            PRIVATE aUsl2 := Parsiraj( qqDatDok, "DatDok", "D" )
            PRIVATE aUsl3 := Parsiraj( qqIdVD, "IdVD", "C" )
            IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. ausl3 <> NIL
               EXIT
            ENDIF
         ENDDO
         Boxc()

         IF Pitanje(, "Povuci u pripremu dokumente sa ovim kriterijom ?", "N" ) == "D"
            SELECT kalk_pripr9
            PRIVATE cFilt1 := ""
            cFilt1 := "IDFIRMA==" + cm2str( cIdFirma ) + ".and." + aUsl1 + ".and." + aUsl2 + ".and." + aUsl3
            cFilt1 := StrTran( cFilt1, ".t..and.", "" )
            IF !( cFilt1 == ".t." )
               SET FILTER TO &cFilt1
            ENDIF

            GO TOP
            MsgO( "Prolaz kroz SMECE..." )

            DO WHILE !Eof()
               SELECT kalk_pripr9
               Scatter()
               SELECT kalk_pripr
               APPEND ncnl
               _ERROR := ""
               Gather2()
               SELECT kalk_pripr9
               SKIP
               nRec := RecNo()
               SKIP -1
               my_delete()
               GO nRec
            ENDDO
            MsgC()
         ENDIF
         my_close_all_dbf()
         RETURN
      ENDIF
   ENDIF

   IF Pitanje( "", "Iz smeca " + cIdFirma + "-" + cIdVD + "-" + cBrDok + " povuci u pripremu (D/N) ?", "D" ) == "N"
      IF !lSilent
         my_close_all_dbf()
         RETURN
      ELSE
         RETURN
      ENDIF
   ENDIF

   SELECT kalk_pripr9

   hseek cIdFirma + cIdVd + cBrDok
   EOF CRET

   MsgO( "PRIPREMA" )

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SELECT kalk_pripr9
      Scatter()
      SELECT kalk_pripr
      APPEND ncnl
      _ERROR := ""
      Gather2()
      SELECT kalk_pripr9
      SKIP
   ENDDO

   SELECT kalk_pripr9
   SEEK cidfirma + cidvd + cBrDok
   my_flock()
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SKIP 1
      nRec := RecNo()
      SKIP -1
      my_delete()
      GO nRec
   ENDDO
   my_unlock()
   USE
   MsgC()

   log_write( "F18_DOK_OPER: kalk, povrat dokumenta iz smeca: " + cIdFirma + "-" + cIdVd + "-" + cBrDok, 2 )

   IF !lSilent
      my_close_all_dbf()
      RETURN
   ENDIF

   O_KALK_PRIPR9
   SELECT kalk_pripr9

   RETURN



FUNCTION kalk_povrat_najstariji_dokument_iz_pripr9()

   LOCAL nRec

   O_KALK_PRIPR9
   O_KALK_PRIPR

   SELECT kalk_pripr9
   SET ORDER TO TAG "3"
   cidfirma := gfirma
   cIdVD := Space( 2 )
   cBrDok := Space( 8 )

   IF Pitanje(, "Povuci u pripremu najstariji dokument ?", "N" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   SELECT kalk_pripr9
   GO TOP

   cidfirma := idfirma
   cIdVD := idvd
   cBrDok := brdok

   MsgO( "PRIPREMA" )

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SELECT kalk_pripr9
      Scatter()
      SELECT kalk_pripr
      APPEND BLANK
      _ERROR := ""
      Gather()
      SELECT kalk_pripr9
      SKIP
   ENDDO

   SET ORDER TO TAG "1"
   SELECT kalk_pripr9
   SEEK cidfirma + cidvd + cBrDok

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
      SKIP 1
      nRec := RecNo()
      SKIP -1
      my_delete()
      GO nRec
   ENDDO
   USE
   MsgC()

   my_close_all_dbf()

   RETURN



STATIC FUNCTION postoji_li_dokument_u_pripr9( arr )

   LOCAL _i
   LOCAL _ctrl

   FOR _i := 1 TO Len( arr )

      _ctrl := arr[ _i, 1 ] + arr[ _i, 2 ] + arr[ _i, 3 ]

      SELECT kalk_pripr9
      SEEK _ctrl

      IF Found()
         arr[ _i, 4 ] := 1
      ENDIF

   NEXT

   RETURN



