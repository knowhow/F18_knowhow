#include "fmk.ch"


// --------------------------------------------------------
// kreiranje tabele fin_mat
// --------------------------------------------------------
function cre_fin_mat()
local aDbf

aDbf:={}
AADD(aDBf,{ "IDFIRMA"          , "C" ,   2 ,  0 })
AADD(aDBf,{ "IDKONTO"          , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDKONTO2"         , "C" ,   7 ,  0 })
AADD(aDBf,{ "IDTARIFA"         , "C" ,   6 ,  0 })
AADD(aDBf,{ "IDPARTNER"        , "C" ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ'          , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'         , 'C' ,   6 ,  0 })
AADD(aDBf,{ "IDVD"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "BRDOK"            , "C" ,   8 ,  0 })
AADD(aDBf,{ "DATDOK"           , "D" ,   8 ,  0 })
AADD(aDBf,{ "BRFAKTP"          , "C" ,  10 ,  0 })
AADD(aDBf,{ "DATFAKTP"         , "D" ,   8 ,  0 })
AADD(aDBf,{ "DATKURS"          , "D" ,   8 ,  0 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPVSAP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PRUCMP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PORPOT'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ "FV"               , "N" ,  20 ,  8 })
AADD(aDBf,{ "GKV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "GKV2"             , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR1"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR2"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR3"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR4"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR5"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "TR6"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "NV"               , "N" ,  20 ,  8 })
AADD(aDBf,{ "RABATV"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZV"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "MARZA"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "VPV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "MPV"              , "N" ,  20 ,  8 })
AADD(aDBf,{ "MARZA2"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ2"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "POREZ3"           , "N" ,  20 ,  8 })
AADD(aDBf,{ "MPVSAPP"          , "N" ,  20 ,  8 })
AADD(aDBf,{ "IDROBA"           , "C" ,  10 ,  0 })
AADD(aDBf,{ "KOLICINA"         , "N" ,  19 ,  7 })
AADD(aDBf,{ "GKol"             , "N" ,  19 ,  7 })
AADD(aDBf,{ "GKol2"            , "N" ,  19 ,  7 })
AADD(aDBf,{ "PORVT"            , "N" ,  20 ,  8 })
AADD(aDBf,{ "UPOREZV"          , "N" ,  20 ,  8 })

if !FILE(f18_ime_dbf("finmat"))
    	DBcreate2( "FINMAT", aDbf )
endif
	
CREATE_INDEX("1","idFirma+IdVD+BRDok",PRIVPATH+"FINMAT")

return



