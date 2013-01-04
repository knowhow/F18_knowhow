
#include "fmk.ch"

// -------------------------------------------------------------------
// setovanje temporary tabela koje koriste svi moduli
// -------------------------------------------------------------------
function set_a_dbf_temporary()
local _rec

set_a_dbf_temp("doksrc"     ,  "DOKSRC"      , F_DOKSRC     )
set_a_dbf_temp("p_doksrc"   ,  "P_DOKSRC"    , F_P_DOKSRC   )
set_a_dbf_temp("p_update"   ,  "P_UPDATE"    , F_P_UPDATE   )
set_a_dbf_temp("finmat"     ,  "FINMAT"      , F_FINMAT     )
set_a_dbf_temp("r_export"   ,  "R_EXPORT"    , F_R_EXP      )
set_a_dbf_temp("pom2"       ,  "POM2"        , F_POM2       )
set_a_dbf_temp("dracun"     ,  "DRN"         , F_DRN        )
set_a_dbf_temp("racun"      ,  "RN"          , F_RN         )
set_a_dbf_temp("dracuntext" ,  "DRNTEXT"     , F_DRNTEXT    )

return


