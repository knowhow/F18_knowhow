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



function kadev_read_params()

gTrPromjena := fetch_metric("kadev_tekuca_promjena", nil, gTrPromjena )
gnLMarg := fetch_metric( "kadev_rpt_lmarg", nil, gnLMarg )
gnTMarg := fetch_metric( "kadev_rpt_tmarg", nil, gnTMarg )
gTabela := fetch_metric( "kadev_tabela_tip", nil, gTabela )
gA43 := fetch_metric( "kadev_rpt_a4a3", nil, gA43 )
gnRedova := fetch_metric( "kadev_rpt_broj_redova", nil, gnRedova )
gOstr := fetch_metric( "kadev_rpt_ostranicavanje", nil, gOstr )
gPostotak := fetch_metric( "kadev_rpt_postotak", nil, gPostotak )
gDodKar1 := fetch_metric( "kadev_k1", nil, gDodKar1 )
gDodKar2 := fetch_metric( "kadev_k2", nil, gDodKar2 )
gCentOn := fetch_metric( "kadev_rpt_cent_on", nil, gCentOn )
gVojEvid := fetch_metric( "kadev_vojna_evidencija", nil, gVojEvid )
return


function kadev_write_params()
set_metric("kadev_tekuca_promjena", nil, gTrPromjena )
set_metric( "kadev_rpt_lmarg", nil, gnLMarg )
set_metric( "kadev_rpt_tmarg", nil, gnTMarg )
set_metric( "kadev_tabela_tip", nil, gTabela )
set_metric( "kadev_rpt_a4a3", nil, gA43 )
set_metric( "kadev_rpt_broj_redova", nil, gnRedova )
set_metric( "kadev_rpt_ostranicavanje", nil, gOstr )
set_metric( "kadev_rpt_postotak", nil, gPostotak )
set_metric( "kadev_k1", nil, gDodKar1 )
set_metric( "kadev_k2", nil, gDodKar2 )
set_metric( "kadev_rpt_cent_on", nil, gCentOn )
set_metric( "kadev_vojna_evidencija", nil, gVojEvid )
return



// ------------------------------------------
// menij parametara
// ------------------------------------------
function kadev_params_menu()

kadev_read_params()

private aPars := {}

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

if LastKey() <> K_ESC
    kadev_write_params()
endif

if gCentOn == "D"
	SET CENTURY ON
else
  	SET CENTURY OFF
endif

return


