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


#include "fmk.ch"

static __device_id
static __device_params


// ---------------------------------------------------------
// fiskalni izvjestaji i komande
// ---------------------------------------------------------
function fisc_rpt( low_level, from_pos )
local _dev_id := 0
local _dev_drv
local _m_x
local _m_y

private izbor := 1
private opc := {}
private opcexe := {}

if low_level == NIL
	low_level := .f.
endif

if from_pos == NIL
    from_pos := .f.
endif

// vrati mi fiskalni uredjaj....
__device_id := get_fiscal_device( my_user(), NIL, from_pos )

if __device_id == 0
    return
endif

// setuj parametre uredjaja
__device_params := get_fiscal_device_params( __device_id, my_user() )

_dev_drv := __device_params["drv"]

do case 

  // FLINK opcije
  case _dev_drv == "FLINK"

    AADD(opc,"------ izvjestaji ---------------------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni izvjestaj  (Z-rep / X-rep)          ")
    AADD(opcexe,{|| fl_daily( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    	nDevice ) })
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| fl_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. ponisti otvoren racun      ")
    AADD(opcexe,{|| fl_reset( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })

  // za FPRINT uredjaje (NSC)
  case _dev_drv == "FPRINT"

    if !low_level

    	AADD(opc,"------ izvjestaji ---------------------------------")
    	AADD(opcexe,{|| nil })

    	AADD(opc,"1. dnevni izvjestaj  (Z-rep / X-rep)          ")
    	AADD(opcexe,{|| fprint_daily_rpt( __device_params ) })

    	AADD(opc,"2. periodicni izvjestaj")
    	AADD(opcexe,{|| fprint_per_rpt( __device_params ) })

    	AADD(opc,"3. pregled artikala ")
    	AADD(opcexe,{|| fprint_sold_plu( __device_params ) })
   
    endif
    
	AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| nil })

    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| fprint_polog( __device_params ) })

    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| fprint_double( __device_params ) })

    AADD(opc,"7. zatvori racun (cmd 56)       ")
    AADD(opcexe,{|| fprint_rn_close( __device_params ) })

    AADD(opc,"8. zatvori nasilno racun (cmd 301) ")
    AADD(opcexe,{|| fprint_void( __device_params ) })

    if !low_level

    	AADD(opc,"9. proizvoljna komanda ")
    	AADD(opcexe,{|| fprint_manual_cmd( __device_params ) })
    
    	if __device_params["type"] == "P"

    		AADD(opc,"10. brisanje artikala iz uredjaja (cmd 107)")
    		AADD(opcexe, {|| fprint_delete_plu( __device_params, .f. ) })
    	endif

    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, __device_params ) })

    	AADD(opc,"12. non-fiscal racun - test")
   	 	AADD(opcexe,{|| fprint_nf_txt( __device_params, "ČčĆćŽžĐđŠš") })

    	AADD(opc,"13. test email")
    	AADD(opcexe,{|| f18_email_test() })

    endif

  // za HCP uredjaje
  case _dev_drv == "HCP" 
   
   	if !low_level 
    	
		AADD(opc,"------ izvjestaji -----------------------")
    	AADD(opcexe,{|| .f. })
    	AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    	AADD(opcexe,{|| hcp_z_rpt( __device_params ) })
    	AADD(opc,"2. presjek stanja (X rep.)    ")
    	AADD(opcexe,{|| hcp_x_rpt( __device_params ) })
    
    	AADD(opc,"3. periodicni izvjestaj (Z rep.)    ")
   	 	AADD(opcexe,{|| hcp_s_rpt( __device_params ) })

   	endif
  
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    
    AADD(opc,"5. kopija racuna    ")
    AADD(opcexe,{|| hcp_rn_copy( __device_params ) })
    AADD(opc,"6. polog u uredjaj    ")
    AADD(opcexe,{|| hcp_polog( __device_params ) })
    AADD(opc,"7. posalji cmd.ok    ")
    AADD(opcexe,{|| hcp_create_cmd_ok( __device_params ) })

   	if !low_level
    
    	AADD(opc,"8. izbaci stanje racuna    ")
    	AADD(opcexe,{|| hcp_fisc_no( __device_params ) })
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, __device_params ) })
   
   	endif

    // za TREMOL uredjaje
  case _dev_drv == "TREMOL" 
    
	if !low_level

    	AADD(opc,"------ izvjestaji -----------------------")
    	AADD(opcexe,{|| .f. })
    
    	AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
   	 	AADD(opcexe,{|| tremol_z_rpt( __device_params ) })
    
    	AADD(opc,"2. izvjestaj po artiklima (Z rep.)    ")
   	 	AADD(opcexe,{|| tremol_z_item( __device_params ) })
   
    	AADD(opc,"3. presjek stanja (X rep.)    ")
   	 	AADD(opcexe,{|| tremol_x_rpt( __device_params ) })
 
   	 	AADD(opc,"4. izvjestaj po artiklima (X rep.)    ")
    	AADD(opcexe,{|| tremol_x_item( __device_params ) })
    
    	AADD(opc,"5. periodicni izvjestaj (Z rep.)    ")
    	AADD(opcexe,{|| tremol_per_rpt( __device_params ) })
   
	endif

    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })

    AADD(opc,"K. kopija racuna    ")
    AADD(opcexe,{|| tremol_rn_copy( __device_params ) })

	if !low_level

    	AADD(opc,"R. reset artikala    ")
    	AADD(opcexe,{|| tremol_reset_plu( __device_params ) })

	endif

    AADD(opc,"P. polog u uredjaj    ")
    AADD(opcexe,{|| tremol_polog( __device_params ) })

	if !low_level    
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, __device_params ) })
	endif



  case _dev_drv == "TRING" 
    
	if !low_level
    
		AADD(opc,"------ izvjestaji ---------------------------------")
    	AADD(opcexe,{|| .f. })
    	AADD(opc,"1. dnevni izvjestaj                               ")
    	AADD(opcexe,{|| tring_daily_rpt( __device_params ) })
    	AADD(opc,"2. periodicni izvjestaj")
    	AADD(opcexe,{|| tring_per_rpt( __device_params ) })
    	AADD(opc,"3. presjek stanja")
    	AADD(opcexe,{|| tring_x_rpt( __device_params ) })

	endif

    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| tring_polog( __device_params ) })
    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| tring_double( __device_params ) })
    AADD(opc,"7. zatvori (ponisti) racun ")
    AADD(opcexe,{|| tring_close_rn( __device_params ) })

	if !low_level

    	AADD(opc,"8. inicijalizacija ")
    	AADD(opcexe,{|| tring_init( __device_params, "1", "" ) })
    	AADD(opc,"10. reset zahtjeva na PU serveru ")
    	AADD(opcexe,{|| tring_reset( __device_params ) })
     
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, __device_params ) })

	endif

  // ostali uredjaji
  otherwise
   
   AADD(opc," ---- nema dostupnih opcija ------ ")
   AADD(opcexe,{|| .f. })

endcase

_m_x := m_x
_m_y := m_y

Menu_SC("izvf")

m_x := _m_x
m_y := _m_y

return


