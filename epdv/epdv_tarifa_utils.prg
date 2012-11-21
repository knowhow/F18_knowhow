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


#include "epdv.ch"


// ----------------------------
// napuni sifrarnik tarifa sa 
function epdv_set_sif_tarifa()

SELECT (F_TARIFA)
if !used()
	O_TARIFA
endif

if !f18_lock_tables({"tarifa"})
    return .f.
endif                            

sql_table_update( nil, "BEGIN" )

// nabavka od pdv obveznika, standardna prodaja
cPom := PADR( "PDV17" , 6 ) 
_append_tarifa( cPom, "PDV 17%", 17 )

// zasticene cijene
cPom := PADR( "PDV17Z" , 6 ) 
_append_tarifa( cPom, "PDV 17% ZASTICENA CIJENA", 17 )

// stopa 0
cPom := PADR( "PDV0", 6 ) 
_append_tarifa( cPom, "PDV 0%", 0 )

// nabavka od poljoprivrednika oporezivi dio 5%
cPom := PADR ( "PDV7PO", 6 )
_append_tarifa( cPom, "POLJOPR., OPOR. DIO PDV 17%", 17 )

// nabavka od poljoprivrednika neopoprezivi dio 95%
cPom := PADR( "PDV0PO", 6 )
_append_tarifa( cPom, "POLJOPR., NEOPOR. DIO PDV 0%", 0 )

// uvoz  oporezivo
cPom := PADR( "PDV7UV", 6 )
_append_tarifa( cPom, "UVOZ OPOREZIVO, PDV 17%", 17 )

// uvoz neoporezivo
cPom := PADR( "PDV0UV", 6 )
_append_tarifa( cPom, "UVOZ NEOPOREZIVO, PDV 0%", 0 )

// nabavka neposlovne svrhe - ne priznaje se ul. porez kao odbitak
// isporuka neposlovne svrhe - izl. pdv standardno
cPom := PADR( "PDV7NP", 6 )
_append_tarifa( cPom, "NEPOSLOVNE SVRHE, NAB/ISP", 17 )

// nabavka i prodaja avansne fakture
cPom := PADR( "PDV7AV", 6 )
_append_tarifa( cPom, "AVANSNE FAKTURE, PDV 17%", 17 )

// nabavka i prodaja avansne fakture neoporezive
cPom := PADR( "PDV0AV", 6 )
_append_tarifa( cPom, "AVANSNE FAKTURE, PDV 0%", 0 )

// isporuke, izvoz
cPom := PADR( "PDV0IZ", 6 )
_append_tarifa( cPom, "IZVOZ, PDV 0%", 0 )

f18_free_tables({"tarifa"})
sql_table_update( nil, "END" )

return


// ----------------------------------------------------------
// ubaci tarifu u sifranik
// ----------------------------------------------------------
static function _append_tarifa( tar_id, naziv, iznos )
local _rec

select tarifa
go top
seek tar_id

if !FOUND()

	append blank
	_rec := dbf_get_rec()
    _rec["id"] := tar_id
	_rec["naz"] := naziv
	_rec["opp"] := iznos
    update_rec_server_and_dbf( "tarifa", _rec, 1, "CONT" )

endif

return



