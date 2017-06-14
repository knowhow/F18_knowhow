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


/* CreInt1DB()
 *  Kreiranje tabela dinteg1 i integ1
 */
FUNCTION CreDIntDB()

   ChkDTbl()

   // kreiraj tabelu errors
   cre_tbl_errors()

   // provjeri da li postoji tabela DINTEG1
   IF !File( KUMPATH + "DINTEG1.DBF" ) .OR. !File( KUMPATH + "DINTEG2.DBF" )
      // kreiraj tabelu DINTEG1/2

      // definicija tabele DINTEG1/2
      aDbf := {}
      AAdd( aDbf, { "ID", "N", 20, 0 } )
      AAdd( aDbf, { "DATUM", "D", 8, 0 } )
      AAdd( aDbf, { "VRIJEME", "C", 8, 0 } )
      AAdd( aDbf, { "CHKDAT", "D", 8, 0 } )
      AAdd( aDbf, { "CHKOK", "C", 1, 0 } )
      AAdd( aDbf, { "CSUM1", "N", 20, 5 } )
      AAdd( aDbf, { "CSUM2", "N", 20, 5 } )
      AAdd( aDbf, { "CSUM3", "N", 20, 0 } )
      // + spec.OID polja
      IF gSql == "D"
         AddOidFields( @aDbf )
      ENDIF
      // kreiraj tabelu DINTEG1/2
      IF !File( KUMPATH + "DINTEG1.DBF" )
         DBcreate2( KUMPATH + "DINTEG1.DBF", aDbf )
      ENDIF
      IF !File( KUMPATH + "DINTEG2.DBF" )
         DBcreate2( KUMPATH + "DINTEG2.DBF", aDbf )
      ENDIF
   ENDIF

   // provjeri da li postoji tabela INTEG1
   IF !File( KUMPATH + "INTEG1.DBF" )
      // kreiraj tabelu INTEG1

      // definicija tabele
      aDbf := {}
      AAdd( aDbf, { "ID", "N", 20, 0 } )
      AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
      AAdd( aDbf, { "OIDROBA", "N", 12, 0 } )
      AAdd( aDbf, { "IDTARIFA", "C", 6, 0 } )
      AAdd( aDbf, { "STANJEK", "N", 20, 5 } )
      AAdd( aDbf, { "STANJEF", "N", 20, 5 } )
      AAdd( aDbf, { "KARTCNT", "N", 6, 0 } )
      AAdd( aDbf, { "SIFROBACNT", "N", 15, 0 } )
      AAdd( aDbf, { "ROBACIJENA", "N", 15, 5 } )
      AAdd( aDbf, { "KALKKARTCNT", "N", 6, 0 } )
      AAdd( aDbf, { "KALKKSTANJE", "N", 20, 5 } )
      AAdd( aDbf, { "KALKFSTANJE", "N", 20, 5 } )
      AAdd( aDbf, { "N1", "N", 12, 0 } )
      AAdd( aDbf, { "N2", "N", 12, 0 } )
      AAdd( aDbf, { "N3", "N", 12, 0 } )
      AAdd( aDbf, { "C1", "C", 20, 0 } )
      AAdd( aDbf, { "C2", "C", 20, 0 } )
      AAdd( aDbf, { "C3", "C", 20, 0 } )
      AAdd( aDbf, { "DAT1", "D", 8, 0 } )
      AAdd( aDbf, { "DAT2", "D", 8, 0 } )
      AAdd( aDbf, { "DAT3", "D", 8, 0 } )
      // + spec.OID polja
      IF gSql == "D"
         AddOidFields( @aDbf )
      ENDIF
      // kreiraj tabelu INTEG1
      DBcreate2( KUMPATH + "INTEG1.DBF", aDbf )
   ENDIF

   // provjeri da li postoji tabela INTEG2
   IF !File( "INTEG2.DBF" )
      // kreiraj tabelu INTEG2

      // definicija tabele
      aDbf := {}
      AAdd( aDbf, { "ID", "N", 20, 0 } )
      AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
      AAdd( aDbf, { "OIDROBA", "N", 12, 0 } )
      AAdd( aDbf, { "IDTARIFA", "C", 6, 0 } )
      AAdd( aDbf, { "STANJEF", "N", 20, 5 } )
      AAdd( aDbf, { "STANJEK", "N", 20, 5 } )
      AAdd( aDbf, { "SIFROBACNT", "N", 15, 0 } )
      AAdd( aDbf, { "ROBACIJENA", "N", 15, 5 } )
      AAdd( aDbf, { "N1", "N", 12, 0 } )
      AAdd( aDbf, { "N2", "N", 12, 0 } )
      AAdd( aDbf, { "N3", "N", 12, 0 } )
      AAdd( aDbf, { "C1", "C", 20, 0 } )
      AAdd( aDbf, { "C2", "C", 20, 0 } )
      AAdd( aDbf, { "C3", "C", 20, 0 } )
      AAdd( aDbf, { "DAT1", "D", 8, 0 } )
      AAdd( aDbf, { "DAT2", "D", 8, 0 } )
      AAdd( aDbf, { "DAT3", "D", 8, 0 } )
      // + spec.OID polja
      IF gSql == "D"
         AddOidFields( @aDbf )
      ENDIF
      // kreiraj tabelu INTEG2
      DBcreate2( "INTEG2.DBF", aDbf )
   ENDIF

   // kreiraj index za tabelu DINTEG1/2
   CREATE_INDEX ( "1", "DTOS(DATUM)+VRIJEME+STR(ID)", "DINTEG1" )
   CREATE_INDEX ( "2", "ID", "DINTEG1" )
   CREATE_INDEX ( "1", "DTOS(DATUM)+VRIJEME+STR(ID)", "DINTEG2" )
   CREATE_INDEX ( "2", "ID", "DINTEG2" )

   // kreiraj index za tabelu INTEG1
   CREATE_INDEX ( "1", "STR(ID)+IDROBA", "INTEG1" )
   CREATE_INDEX ( "2", "ID", "INTEG1" )

   // kreiraj index za tabelu INTEG2
   CREATE_INDEX ( "1", "STR(ID)+IDROBA", "INTEG2" )
   CREATE_INDEX ( "2", "ID", "INTEG2" )

   // OID indexi
   CREATE_INDEX( "OID", "_oid_", "DOKS" )
   CREATE_INDEX( "OID", "_oid_", "POS" )
   CREATE_INDEX( "OID", "_oid_", "ROBA" )

   RETURN
// }


// kreiranje tabele errors
FUNCTION cre_tbl_errors()

   // provjeri da li postoji tabela ERRORS.DBF
   IF !File( my_home() + "ERRORS.DBF" )
      aDbf := {}
      AAdd( aDbf, { "TYPE", "C", 10, 0 } )
      AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
      AAdd( aDbf, { "DOKS", "C", 50, 0 } )
      AAdd( aDbf, { "OPIS", "C", 100, 0 } )
      DBcreate2( "ERRORS.DBF", aDbf )
   ENDIF

   // kreiraj index za tabelu ERRORS
   CREATE_INDEX ( "1", "IDROBA+TYPE", "ERRORS" )

   RETURN



/* ChkDTbl()
 *
 */
FUNCTION ChkDTbl()

   // {
   IF File( KUMPATH + "INTEG1.DBF" )
      O_INTEG1
      // ako nema polja N1 pobrisi tabele i generisi nove tabele
      IF integ1->( FieldPos( "N1" ) ) == 0
         // trala lalalalall
         USE
         FErase( KUMPATH + "\INTEG1.DBF" )
         FErase( KUMPATH + "\INTEG1.CDX" )
         FErase( KUMPATH + "\INTEG2.DBF" )
         FErase( KUMPATH + "\INTEG2.CDX" )
         FErase( KUMPATH + "\DINTEG1.DBF" )
         FErase( KUMPATH + "\DINTEG1.CDX" )
         FErase( KUMPATH + "\DINTEG2.DBF" )
         FErase( KUMPATH + "\DINTEG2.CDX" )
      ENDIF
   ENDIF

   RETURN
// }


/* DInt1NextID()
 *     Vrati sljedeci zapis polja ID za tabelu DINTEG1
 */
FUNCTION DInt1NextID()

   // {
   LOCAL nArr
   nArr := Select()

   O_DINTEG1
   SELECT dinteg1

   nId := NextDIntID()

   SELECT ( nArr )

   RETURN nId


/* DInt2NextID()
 *     Vrati sljedeci zapis polja ID za tabelu DINTEG2
 */
FUNCTION DInt2NextID()


   LOCAL nArr
   nArr := Select()

   O_DINTEG2
   SELECT dinteg2

   nId := NextDIntID()

   SELECT ( nArr )

   RETURN nId


/* NextDIntID()
 *     Vraca sljedeci ID broj za polje ID
 */
FUNCTION NextDIntID()

   nId := 0
   SET ORDER TO TAG "2"
   GO BOTTOM
   nId := field->id
   nId := nId + 1

   RETURN nID
// }
