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


#include "kadev.ch"


// ------------------------------------------
// menij parametara
// ------------------------------------------
function kadev_params_menu()

O_PARAMS
private cSection := "1"
private cHistory := " "
private aHistory := {}
private aPars := {}

// citaj parametre
RPar("tp", @gTrPromjena)
RPar("pr", @gnLMarg)
RPar("p1", @gnTMarg)
RPar("tb", @gTabela)
Rpar("a4", @gA43)
Rpar("rs", @gnRedova)
Rpar("os", @gOstr)
Rpar("po", @gPostotak)
Rpar("k1", @gDodKar1)
Rpar("k2", @gDodKar2)
Rpar("fi", @gNFirma)
Rpar("co", @gCentOn)
Rpar("ve", @gVojEvid)

UsTipke()

set cursor on

AADD(aPars, { "Lijeva margina pri stampanju", ;
	"gNLMarg", , "99", } )
AADD(aPars, { "Gornja margina pri stampanju", ;
	"gNTMarg", , "99", } )
AADD(aPars, { "Tip tabele  (0/1/2)", ;
	"gTabela", "gTabela>=0.and.gTabela<3", "9",  } )
AADD(aPars, {"Broj redova po stranici", ;
	"gnRedova", "gnRedova>0", "999", } )
AADD(aPars, {"Da li treba ostranicavanje (D/N) ?", ;
	"gOstr", "gOstr $ 'DN'", "@!", } )
AADD(aPars, {"Prikaz postotka uradjenog posla (D/N) ?", ;
	"gPostotak", "gPostotak $ 'DN'", "@!", } )
AADD(aPars, {"Format papira za ispis  ( 3 - A3 , 4 - A4 )", ;
	"gA43", "gA43 $ '43'", "9", } )
AADD(aPars, {"Dodatna karakteristika 1 (opis)", ;
	"gDodKar1", "", "",  } )
AADD(aPars, {"Dodatna karakteristika 2 (opis)", ;
	"gDodKar2", "", "",  } )
AADD(aPars, {"Sifra promjene za brzi pregled i unos", ;
	"gTrPromjena", "", "",  } )
AADD(aPars, {"U datumima prikazivati potpunu godinu (D/N) ?", ;
	 "gCentOn", "gCentOn$'DN'", "@!", } )
AADD(aPars, {"Vojna evidencija (D/N) ?", ;
	 "gVojEvid", "gVojEvid$'DN'", "@!", } )

VarEdit(aPars, 6, 1, 22, 78, "***** Parametri rada programa", "B1" )

BosTipke()

if LastKey() <> K_ESC
	WPar("tp",gTrPromjena)
  	WPar("pr",gnLMarg)
  	WPar("p2",gnTMarg)
  	WPar("tb",gTabela)
  	Wpar("a4",gA43)
  	Wpar("rs",gnRedova)
  	Wpar("os",gOstr)
  	Wpar("po",gPostotak)
  	Wpar("k1",gDodKar1)
  	Wpar("k2",gDodKar2)
  	Wpar("fi",gNFirma)
  	Wpar("co",gCentOn)
  	Wpar("ve",gVojEvid)
  	select params
	use
endif

if gCentOn=="D"
	SET CENTURY ON
else
  	SET CENTURY OFF
endif

return


