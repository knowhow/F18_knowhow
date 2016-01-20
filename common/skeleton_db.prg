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

#include "hbclass.ch"

FUNCTION TDBNew( oDesktop, cDirPriv, cDirKum, cDirSif )

   LOCAL oObj

CLASS TDB

   DATA oDesktop
   DATA oApp
   DATA cName
	
   DATA cSezona
   DATA cRadimUSezona
	
   DATA cSezonDir
   DATA cBase
   DATA cDirPriv
   DATA cDirKum
   DATA cDirSif
   DATA cUser
   DATA nPassword
   DATA nGroup1
   DATA nGroup2
   DATA nGroup3
   DATA lAdmin

   METHOD New()
   METHOD setDirPriv
   METHOD setDirSif
   METHOD setDirKum
   METHOD setUser
   METHOD setPassword
   METHOD setGroup1
   METHOD setGroup2
   METHOD setGroup3
	
ENDCLASS


METHOD New( oDesktop, cDirPriv, cDirKum, cDirSif )  CLASS TDB

   ::oDesktop := oDesktop
   ::cDirPriv := cDirPriv
   ::cDirKum := cDirKum
   ::cDirSif := cDirSif
   ::lAdmin := .F.
   ::cSezona := AllTrim( Str( Year( Date() ) ) )

   RETURN self



METHOD setDirPriv( cDir ) CLASS TDB

   LOCAL cPom

   // dosadasnja vrijednost varijable
   cPom := ::cDirPriv

   cDir := AllTrim( cDir )

   IF ( gKonvertPath == "D" )
      KonvertPath( @cDir )
   ENDIF

   ::cDirPriv := ToUnix( cDir )

   // setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
   cDirPriv := ::cDirPriv

   RETURN cPom


METHOD setDirSif( cDir ) CLASS TDB

   LOCAL cPom

   // dosadasnja vrijednost varijable
   cPom := ::cDirSif

   cDir := AllTrim( cDir )
   IF ( gKonvertPath == "D" )
      KonvertPath( @cDir )
   ENDIF
   ::cDirSif := ToUnix( cDir )

   // setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
   cDirSif := ::cDirSif

   RETURN cPom


METHOD setDirKum( cDir ) CLASS TDB

   LOCAL cPom

   // dosadasnja vrijednost varijable
   cPom := ::cDirKum
   cDir := AllTrim( cDir )
   IF ( gKonvertPath == "D" )
      KonvertPath( @cDir )
   ENDIF
   ::cDirKum := ToUnix( cDir )

   // setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu

   cDirKum := ::cDirKum
   cDirRad := ::cDirKum

   SET( _SET_DEFAULT, Trim( cDir ) )

   RETURN cPom

METHOD setUser( cUser ) CLASS TDB

   LOCAL cPom

   // dosadasnja vrijednost varijable
   cPom := ::cUser
   ::cUser := cUser

   RETURN cPom

METHOD setPassword( nPassword ) CLASS TDB

   LOCAL nPom

   // dosadasnja vrijednost varijable
   nPom := ::nPassword
   ::nPassword := nPassword

   RETURN nPom



// string TDB::setGroup1(integer nGroup)

METHOD setGroup1( nGroup ) CLASS TDB

   LOCAL nPom

   // dosadasnja vrijednost varijable
   nPom := ::nGroup1
   ::nGroup1 := nGroup

   RETURN nPom



// string TDB::setGroup2(integer nGroup)

METHOD setGroup2( nGroup ) CLASS TDB

   LOCAL nPom

   // dosadasnja vrijednost varijable
   nPom := ::nGroup2
   ::nGroup2 := nGroup

   RETURN nPom


METHOD setGroup3( nGroup ) CLASS TDB

   LOCAL nPom

   // dosadasnja vrijednost varijable
   nPom := ::nGroup3
   ::nGroup3 := nGroup

   RETURN nPom
