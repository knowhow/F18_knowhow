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
function fisc_rpt( low_level )
local _dev_id := 0
local _m_x
local _m_y

private izbor := 1
private opc := {}
private opcexe := {}

if low_level == NIL
	low_level := .f.
endif

// vrati mi fiskalni uredjaj....
__device_id := get_fiscal_device( my_user() )
// setuj parametre uredjaja
__device_params := get_fiscal_device_params( __device_id, my_user() )

do case 

  // FLINK opcije
  case ALLTRIM( gFc_type ) == "FLINK"

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
  case ALLTRIM(gFc_type) == "FPRINT"

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
    	AADD(opcexe,{|| auto_plu( .t., nil, __device_params["id"] ) })

    	AADD(opc,"12. non-fiscal racun - test")
   	 	AADD(opcexe,{|| fprint_nf_txt( __device_params, "ČčĆćŽžĐđŠš") })

    	AADD(opc,"13. test email")
    	AADD(opcexe,{|| f18_email_test() })

    endif

  // za HCP uredjaje
  case ALLTRIM(gFc_type) == "HCP" 
   
   	if !low_level 
    	
		AADD(opc,"------ izvjestaji -----------------------")
    	AADD(opcexe,{|| .f. })
    	AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    	AADD(opcexe,{|| hcp_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    	AADD(opc,"2. presjek stanja (X rep.)    ")
    	AADD(opcexe,{|| hcp_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    	AADD(opc,"3. periodicni izvjestaj (Z rep.)    ")
   	 	AADD(opcexe,{|| hcp_s_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })

   	endif
  
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    
    AADD(opc,"5. kopija racuna    ")
    AADD(opcexe,{|| hcp_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"6. polog u uredjaj    ")
    AADD(opcexe,{|| hcp_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"7. posalji cmd.ok    ")
    AADD(opcexe,{|| hcp_s_cmd( ALLTRIM(gFC_path) ) })

   	if !low_level
    
    	AADD(opc,"8. izbaci stanje racuna    ")
    	AADD(opcexe,{|| hcp_fisc_no( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFC_error ) })
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })
   
   	endif

    // za TREMOL uredjaje
  case ALLTRIM(gFc_type) == "TREMOL" 
    
	if !low_level

    	AADD(opc,"------ izvjestaji -----------------------")
    	AADD(opcexe,{|| .f. })
    
    	AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
   	 	AADD(opcexe,{|| trm_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    	AADD(opc,"2. izvjestaj po artiklima (Z rep.)    ")
   	 	AADD(opcexe,{|| trm_z_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
    	AADD(opc,"3. presjek stanja (X rep.)    ")
   	 	AADD(opcexe,{|| trm_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
 
   	 	AADD(opc,"4. izvjestaj po artiklima (X rep.)    ")
    	AADD(opcexe,{|| trm_x_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    	AADD(opc,"5. periodicni izvjestaj (Z rep.)    ")
    	AADD(opcexe,{|| trm_p_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
	endif

    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })

    AADD(opc,"K. kopija racuna    ")
    AADD(opcexe,{|| trm_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })

	if !low_level

    	AADD(opc,"R. reset artikala    ")
    	AADD(opcexe,{|| fc_trm_rplu( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })

	endif

    AADD(opc,"P. polog u uredjaj    ")
    AADD(opcexe,{|| trm_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })

	if !low_level    
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })
	endif

  case ALLTRIM(gFc_type) == "TRING" 
    
	if !low_level
    
		AADD(opc,"------ izvjestaji ---------------------------------")
    	AADD(opcexe,{|| .f. })
    	AADD(opc,"1. dnevni izvjestaj                               ")
    	AADD(opcexe,{|| trg_daily_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    	AADD(opc,"2. periodicni izvjestaj")
    	AADD(opcexe,{|| trg_per_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    	AADD(opc,"3. presjek stanja")
    	AADD(opcexe,{|| trg_x_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })

	endif

    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| trg_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| trg_double( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"7. zatvori (ponisti) racun ")
    AADD(opcexe,{|| trg_close_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })

	if !low_level

    	AADD(opc,"8. inicijalizacija ")
    	AADD(opcexe,{|| trg_init( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
    		"1", "" ) })
    	AADD(opc,"10. reset zahtjeva na PU serveru ")
    	AADD(opcexe,{|| trg_reset( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    
    	AADD(opc,"11. reset PLU ")
    	AADD(opcexe,{|| auto_plu( .t., nil, nDevice ) })

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


