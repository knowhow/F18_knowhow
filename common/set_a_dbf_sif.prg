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

#include "fmk.ch"

function set_a_dbf_sif()


// tabele sa strukturom sifarnika (id je primarni ključ)
set_a_dbf_sifarnik("adres"      , "ADRES"     , F_ADRES      )

set_a_dbf_sifarnik("f18_rules"  , "FMKRULES"  , F_FMKRULES   )
set_a_dbf_sifarnik("ops"        , "OPS"       , F_OPS        )
set_a_dbf_sifarnik("banke"      , "BANKE"     , F_BANKE      )
set_a_dbf_sifarnik("refer"      , "REFER"     , F_REFER      )
set_a_dbf_sifarnik("partn"      , "PARTN"     , F_PARTN      )
set_a_dbf_sifarnik("tnal"       , "TNAL"      , F_TNAL       )
set_a_dbf_sifarnik("tdok"       , "TDOK"      , F_TDOK       )
set_a_dbf_sifarnik("trfp"       , "TRFP"      , F_TRFP       )
set_a_dbf_sifarnik("trfp2"      , "TRFP2"     , F_TRFP2      )
set_a_dbf_sifarnik("trfp3"      , "TRFP3"     , F_TRFP3      )

set_a_dbf_sifarnik("ld_radn"    , "RADN"      , F_RADN       )
set_a_dbf_sifarnik("ld_rj"      , "LD_RJ"     , F_LD_RJ      )
set_a_dbf_sifarnik("por"        , "POR"       , F_POR        )
set_a_dbf_sifarnik("dopr"       , "DOPR"      , F_DOPR       )
set_a_dbf_sifarnik("tippr"      , "TIPPR"     , F_TIPPR      )
set_a_dbf_sifarnik("tippr2"     , "TIPPR2"    , F_TIPPR2     )
set_a_dbf_sifarnik("kred"       , "KRED"      , F_KRED       )
set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
set_a_dbf_sifarnik("vposla"     , "VPOSLA"    , F_VPOSLA     )
set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
set_a_dbf_sifarnik("kbenef"     , "KBENEF"    , F_KBENEF     )
set_a_dbf_sifarnik("rj"         , "RJ"        , F_RJ         )

set_a_dbf_sifarnik("roba"       , "ROBA"      , F_ROBA       )
set_a_dbf_sifarnik("sast"       , "SAST"      , F_SAST       )
set_a_dbf_sifarnik("tarifa"     , "TARIFA"    , F_TARIFA     )
set_a_dbf_sifarnik("konto"      , "KONTO"     , F_KONTO      )
set_a_dbf_sifarnik("koncij"     , "KONCIJ"    , F_KONCIJ     )
set_a_dbf_sifarnik("tokval"     , "TOKVAL"    , F_TOKVAL     )
set_a_dbf_sifarnik("vrstep"     , "VRSTEP"    , F_VRSTEP     )
set_a_dbf_sifarnik("vprih"      , "VPRIH"     , F_VPRIH      )
set_a_dbf_sifarnik("pkonto"     , "PKONTO"    , F_PKONTO     )
set_a_dbf_sifarnik("valute"     , "VALUTE"    , F_VALUTE     )



return


