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

// ----------------------------------------------------------------
// xSemaphoreParam se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(cTable, cAlias, lNew, cRDD, xSemaphoreParam)
local nPos
local cF18Tbl
local nVersion

if lNew == NIL
   lNew := .f.
endif

/*
{ F_PRIPR  ,  "PRIPR"   , "fin_pripr"  },;
...
*/

// /home/test/suban.dbf => suban
cTable := FILEBASE(cTable)

// SUBAN
nPos:=ASCAN(gaDBFs,  { |x|  x[2]==UPPER(cTable)} )

if cAlias == NIL
   cAlias := gaDBFs[nPos, 2]
endif

if cRDD == NIL
  cRDD = "DBFCDX"
endif

if lNew
   SELECT NEW
endif


// mi otvaramo ovu tabelu ~/.F18/bringout/fin_pripr
//if gDebug > 9
// log_write( "LEN gaDBFs[" + STR(nPos) + "]" + STR(LEN(gADBFs[nPos])) + " USE (" + my_home() + gaDBFs[nPos, 3]  + " ALIAS (" + cAlias + ") VIA (" + cRDD + ") EXCLUSIVE")
//endif

if  LEN(gaDBFs[nPos])>3 

   if (cRDD != "SEMAPHORE")
        cF18Tbl := gaDBFs[nPos, 3]

        //if gDebug > 9
        //    log_write("F18TBL =" + cF18Tbl)
        //endif

        nVersion :=  get_semaphore_version(cF18Tbl)
        if gDebug > 9
          log_write("Tabela:" + cF18Tbl + " semaphore nVersion=" + STR(nVersion) + " last_semaphore_version=" + STR(last_semaphore_version(cF18Tbl)))
        endif

        if (nVersion == -1)
          // semafor je resetovan
          //if gDebug > 9
          //    log_write("prije eval from sql -1")
          //endif
          EVAL( gaDBFs[nPos, 4], NIL)

          update_semaphore_version(cF18Tbl)
        else
            // moramo osvjeziti cache
           if nVersion < last_semaphore_version(cF18Tbl)
             //if gDebug > 9
             // log_write("prije eval from sql < last_semaphore_version")
             //endif
             EVAL( gaDBFs[nPos, 4], NIL)
             update_semaphore_version(cF18Tbl)
           endif
        endif
   else
      // poziv is update from sql server procedure
      cRDD := "DBFCDX" 
   endif

endif

USE (my_home() + gaDBFs[nPos, 3]) ALIAS (cAlias) VIA (cRDD) EXCLUSIVE

return

/*
#command USEX <(db)>                                                   ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      =>  PreUseEvent(<(db)>,.f.,gReadOnly)				;
        ;  dbUseArea(                                                   ;
                    <.new.>, <rdd>, ToUnix(<(db)>), <(a)>,              ;
                     .f., gReadOnly       ;
                  )                                                     ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]


*/

function usex(cTable)
return my_use(cTable)

// ---------------------------
// ~/.F18/bringout1
// ~/.F18/rg1
// ~/.F18/test
// ---------------------------
function get_f18_home_dir(cDatabase)
local cHome

cHome := hb_DirSepAdd( GetEnv( "HOME" ) ) 
cHome := hb_DirSepAdd(cHome + ".F18")
cHome := hb_DirSepAdd(cHome + cDatabase)

return cHome


function f18_ime_dbf(cImeDbf)
local nPos

cImeDbf:=ToUnix(cImeDbf)
cImeDbf := FILEBASE(cImeDbf)
nPos:=ASCAN(gaDBFs,  { |x|  x[2]==UPPER(cImeDbf)} )

if nPos == 0
   ? "ajjoooj nemas u gaDBFs ovu stavku:", cImeDBF
   //QUIT
endif

cImeDbf := my_home() + gaDBFs[nPos, 3] + ".dbf"

return cImeDbf


/* ------------------------
  Vraca postgresql oServer 
  ------------------------- */
function init_f18_app(cHostName, cDatabase, cUser, cPassword, nPort, cSchema)
local oServer

REQUEST DBFCDX

? "setujem default engine ..." + RDDENGINE
RDDSETDEFAULT( RDDENGINE )

REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

HB_CDPSELECT("SL852")

if setmode(MAXROWS(), MAXCOLS())
   ? "hej mogu setovati povecani ekran !"
else
   ? "ne mogu setovati povecani ekran !"
   QUIT
endif

public gRj := "N"
public gReadOnly := .f.
public gSQL := "N"
public Invert := .f.

public gaDbfs := {}

// parametri
AADD( gaDbfs, { F_PARAMS  ,  "PARAMS"   , "params"  } )
AADD( gaDbfs, { F_GPARAMS , "GPARAMS"  , "gparams"  } )
AADD( gaDbfs, { F_KPARAMS , "KPARAMS"  , "kparams"  } )
AADD( gaDbfs, { F_SECUR  , "SECUR"  , "secur"  } )

// sifrarnici
AADD( gaDbfs, { F_TOKVAL  , "TOKVAL"  , "tokval"  } )
AADD( gaDbfs, { F_SIFK  , "SIFK"  , "sifk"  } )
AADD( gaDbfs, { F_SIFV , "SIFV"  , "sifv"  } )
AADD( gaDbfs, { F_OPS , "OPS"  , "opstine"  } )
AADD( gaDbfs, { F_BANKE , "BANKE"  , "banke"  } )
AADD( gaDbfs, { F_BARKOD , "BARKOD"  , "barkod"  } )
AADD( gaDbfs, { F_STRINGS , "STRINGS"  , "strings"  } )
AADD( gaDbfs, { F_RNAL , "RNAL"  , "rnal"  } )
AADD( gaDbfs, { F_LOKAL , "LOKAL"  , "lokal"  } )
AADD( gaDbfs, { F_DOKSRC , "DOKSRC"  , "doksrc"  } )
AADD( gaDbfs, { F_P_DOKSRC , "P_DOKSRC"  , "p_doksrc"  } )
AADD( gaDbfs, { F_RELATION , "RELATION"  , "relation"  } )
AADD( gaDbfs, { F_FMKRULES , "FMKRULES"  , "f18_rules"  } )
AADD( gaDbfs, { F_RULES , "RULES"  , "rules"  } )
AADD( gaDbfs, { F_P_UPDATE , "P_UPDATE"  , "p_update"  } )
AADD( gaDbfs, { F__ROBA , "_ROBA"  , "_roba"  } )
AADD( gaDbfs, { F_TRFP , "TRFP"  , "trfp"  } )
AADD( gaDbfs, { F_SAST , "SAST"  , "sast"  } )
AADD( gaDbfs, { F_VRSTEP , "VRSTEP"  , "vrstep"  } )
AADD( gaDbfs, { F_RJ     ,  "RJ"      , "rj"   } )
AADD( gaDbfs, { F_TDOK   ,  "TDOK"    , "tdok"   } )
AADD( gaDbfs, { F_KONTO  ,  "KONTO"   , "konto"  } )
AADD( gaDbfs, { F_VPRIH  ,  "VPRIH"   , "vpprih"   } )
AADD( gaDbfs, { F_PARTN  ,  "PARTN"   , "partn"   } )
AADD( gaDbfs, { F_TNAL   ,  "TNAL"    , "tnal"   } )
AADD( gaDbfs, { F_PKONTO ,  "PKONTO"  , "pkonto"   } )
AADD( gaDbfs, { F_VALUTE ,  "VALUTE"  , "valute"   } )
AADD( gaDbfs, { F_ROBA   ,  "ROBA"    , "roba"   } )
AADD( gaDbfs, { F_TARIFA ,  "TARIFA"  , "tarifa"  } )
AADD( gaDbfs, { F_KONCIJ ,  "KONCIJ"  , "koncij"   } )
AADD( gaDbfs, { F_TRFP2  ,  "TRFP2"   , "trfp2"  } )
AADD( gaDbfs, { F_TRFP3  ,  "TRFP3"   , "trfp3"   } )
AADD( gaDbfs, { F_VKSG   ,  "VKSG"    , "vksg"   } )
AADD( gaDbfs, { F_ULIMIT ,  "ULIMIT"  , "ulimit"  } )


// modul FIN
AADD( gaDbfs, { F_FIN_PRIPR  ,  "FIN_PRIPR"   , "fin_pripr"  } )
AADD( gaDbfs, { F_FIN_FIPRIPR , "FIN_PRIPR"   , "fin_pripr"  } )
AADD( gaDbfs, { F_BBKLAS ,  "BBKLAS"  , "fin_bblkas"  } )
AADD( gaDbfs, { F_IOS    ,  "IOS"     , "fin_ios"  } )
AADD( gaDbfs, { F_PNALOG ,  "PNALOG"  , "fin_pnalog"  } )
AADD( gaDbfs, { F_PSUBAN ,  "PSUBAN"  , "fin_psuban"  } )
AADD( gaDbfs, { F_PANAL  ,  "PANAL"   , "fin_panal"  } )
AADD( gaDbfs, { F_PSINT  ,  "PSINT"   , "fin_psint"  } )
AADD( gaDbfs, { F_FIN_PRIPRRP,  "FIN_PRIPRRP" , "fin_priprrp"  } )
AADD( gaDbfs, { F_FAKT   ,  "FAKT"    , "fakt_fakt"  } )
AADD( gaDbfs, { F_FINMAT ,  "FINMAT"  , "fin_mat"  } )
AADD( gaDbfs, { F_OSTAV  ,  "OSTAV"   , "fin_ostav"  } )
AADD( gaDbfs, { F_OSUBAN ,  "OSUBAN"  , "fin_osuban"  } )
AADD( gaDbfs, { F__KONTO ,  "_KONTO"  , "fin__konto"  } )
AADD( gaDbfs, { F__PARTN ,  "_PARTN"  , "fin__partn"  } )
AADD( gaDbfs, { F_POM    ,  "POM"     , "fin_pom"  } )
AADD( gaDbfs, { F_POM2   ,  "POM2"    , "fin_pom2"  } )
AADD( gaDbfs, { F_KUF    ,  "FIN_KUF"     , "fin_kuf"   } )
AADD( gaDbfs, { F_KIF    ,  "FIN_KIF"     , "fin_kif"   } )
AADD( gaDbfs, { F_SUBAN  ,  "SUBAN"   , "fin_suban" ,  {|dDatDok| fin_suban_from_sql_server(dDatDok) } } )
AADD( gaDbfs, { F_ANAL   ,  "ANAL"    , "fin_anal"   } )
AADD( gaDbfs, { F_SINT   ,  "SINT"    , "fin_sint"   } )
AADD( gaDbfs, { F_NALOG  ,  "NALOG"   , "fin_nalog"  } )
AADD( gaDbfs, { F_FIN_RJ ,  "FIN_RJ"  , "fin_rj"   } )
AADD( gaDbfs, { F_FUNK   ,  "FUNK"    , "fin_funk"  } )
AADD( gaDbfs, { F_BUDZET ,  "BUDZET"  , "fin_budzet"  } )
AADD( gaDbfs, { F_PAREK  ,  "PAREK"   , "fin_parek"   } )
AADD( gaDbfs, { F_FOND   ,  "FOND"    , "fin_fond"   } )
AADD( gaDbfs, { F_KONIZ  ,  "KONIZ"   , "fin_koniz"   } )
AADD( gaDbfs, { F_IZVJE  ,  "IZVJE"   , "fin_izvje"   } )
AADD( gaDbfs, { F_ZAGLI  ,  "ZAGLI"   , "fin_zagli"   } )
AADD( gaDbfs, { F_KOLIZ  ,  "KOLIZ"   , "fin_koliz"   } )
AADD( gaDbfs, { F_BUIZ   ,  "BUIZ"    , "fin_buiz"   } )

//modul KALK
AADD( gaDbfs, { F_KALK   ,"KALK"         , "kalk"     } )
AADD( gaDbfs, { F_KALKS  ,"KALKS"        , "kalks"    } )
AADD( gaDbfs, { F__KALK  ,"_KALK"        , "_kalk"    } )
AADD( gaDbfs, { F_PRIPR  ,"KALK_PRIPR"   , "kalk_pripr"    } )
AADD( gaDbfs, { F_PRIPR  ,"KALK_PRIPR2"  , "kalk_pripr2"   } )
AADD( gaDbfs, { F_PRIPR  ,"KALK_PRIPR9"  , "kalk_pripr9"   } )
AADD( gaDbfs, { F_FINMAT ,"KALK_FINMAT"  , "kalk_finmat"   } )
AADD( gaDbfs, { F_DOKS   ,"KALK_DOKS"    , "kalk_doks"     } )
AADD( gaDbfs, { F_DOKS2  ,"KALK_DOKS2"   , "kalk_doks2"    } )
AADD( gaDbfs, { F_PORMP  ,"PORMP"        , "pormp"     } )
AADD( gaDbfs, { F_TRFP   ,"TRFP"         , "trfp"      } )
AADD( gaDbfs, { F_DOKSRC ,"KALK_DOKSRC"  , "kalk_doksrc"    } )
AADD( gaDbfs, { F_P_DOKSRC,"P_KALK_DOKSRC", "p_kalk_doksrc"   } )
AADD( gaDbfs, { F_PPPROD ,"PPPROD"  , "ppprod"    } )
AADD( gaDbfs, { F_OBJEKTI,"OBJEKTI" , "objekti"     } )
AADD( gaDbfs, { F_OBJEKTI,"POBJEKTI" , "pobjekti"     } )
AADD( gaDbfs, { F_PRODNC, "PRODNC"  , "prodnc"     } )
AADD( gaDbfs, { F_RVRSTA, "RVRSTA"  , "rvrsta"     } )
AADD( gaDbfs, { F_K1     ,"K1"      , "k1"     } )
AADD( gaDbfs, { F_K1     ,"CACHE"      , "cache"     } )
AADD( gaDbfs, { F_K1     ,"PRIPT"      , "pript"     } )
AADD( gaDbfs, { F_K1     ,"REKAP1"      , "rekap1"     } )
AADD( gaDbfs, { F_K1     ,"REKAP2"      , "rekap2"     } )
AADD( gaDbfs, { F_K1     ,"REKA22"      , "reka22"     } )
AADD( gaDbfs, { F_K1     ,"R_UIO"       , "r_uio"     } )
AADD( gaDbfs, { F_K1     ,"RPT_TMP"     , "rpt_tmp"     } )


// modul FAKT
AADD( gaDbfs, { F_PRIPR, "FAKT_PRIPR" , "fakt_pripr"  } )
AADD( gaDbfs, { F_PRIPR2 ,"FAKT_PRIPR2"  , "fakt_pripr2"    } )
AADD( gaDbfs, { F_PRIPR2 ,"FAKT_PRIPR9"  , "fakt_pripr9"    } )
AADD( gaDbfs, { F_FDEVICE,"FDEVICE" , "fdevice"     } )
AADD( gaDbfs, { F_FINMAT ,"FAKT_FINMAT"  , "fakt_finmat"    } )
AADD( gaDbfs, { F_DOKS   ,"FAKT_DOKS"    , "fakt_doks"     } )
AADD( gaDbfs, { F_DOKS2  ,"FAKT_DOKS2"   , "fakt_doks2"     } )
AADD( gaDbfs, { F_PORMP  ,"PORMP"   , "pormp"    } )
AADD( gaDbfs, { F__ROBA  ,"_ROBA"   , "_fakt_roba"    } )
AADD( gaDbfs, { F__PARTN ,"_PARTN"  , "_fakt_partn"    } )
AADD( gaDbfs, { F_LOGK   ,"LOGK"    , "logk"     } )
AADD( gaDbfs, { F_LOGKD  ,"LOGKD"   , "logkd"     } )
AADD( gaDbfs, { F_BARKOD ,"BARKOD"  , "barkod"    } )
AADD( gaDbfs, { F_RJ     ,"RJ"      , "fakt_rj"     } )
AADD( gaDbfs, { F_UPL    ,"UPL"     , "upl"     } )
AADD( gaDbfs, { F_FTXT   ,"FTXT"    , "ftxt"     } )
AADD( gaDbfs, { F_FAKT   ,"FAKT"    , "fakt"     } )
AADD( gaDbfs, { F_FAKT   ,"FAKT_S_PRIPR"    , "fakt_pripr"     } )
AADD( gaDbfs, { F__FAKT  ,"_FAKT"   , "_fakt"    } )
AADD( gaDbfs, { F_FAPRIPR,"FAKT_faPRIPR"   , "fakt_fapripr"    } )
AADD( gaDbfs, { F_UGOV   ,"UGOV"    , "ugov"     } )
AADD( gaDbfs, { F_RUGOV  ,"RUGOV"   , "rugov"     } )
AADD( gaDbfs, { F_GEN_UG ,"GEN_UG"  , "gen_ug"     } )
AADD( gaDbfs, { F_G_UG_P, "GEN_UG_P", "gen_ug_p"     } )
AADD( gaDbfs, { F_RELAC  ,"RELAC"   , "relac"     } ) 
AADD( gaDbfs, { F_VOZILA ,"VOZILA"  , "vozila"     } )
AADD( gaDbfs, { F_DEST   ,"DEST"    , "dest"     } )
AADD( gaDbfs, { F_KALPOS ,"KALPOS"  , "kalpos"     } )
AADD( gaDbfs, { F_DRN ,   "DRN"     , "drn"     } )
AADD( gaDbfs, { F_DRN ,   "RN"     , "rn"     } )
AADD( gaDbfs, { F_DRN ,   "DRNTEXT"     , "drntext"     } )

// modul RNAL
AADD(gaDBFs, { F__DOCS, "_DOCS", "_docs"  } )
AADD(gaDBFs, { F__DOC_IT, "_DOC_IT", "_doc_it"  } )
AADD(gaDBFs, { F__DOC_IT2, "_DOC_IT2", "_doc_it2"  } )
AADD(gaDBFs, { F__DOC_OPS, "_DOC_OPS", "_doc_ops"  } )
AADD(gaDBFs, { F_DOCS, "DOCS", "docs" } )
AADD(gaDBFs, { F_DOC_IT, "DOC_IT", "doc_it"  } )
AADD(gaDBFs, { F_DOC_IT2, "DOC_IT2", "doc_it2"  } )
AADD(gaDBFs, { F_DOC_OPS, "DOC_OPS", "doc_ops"  } )
AADD(gaDBFs, { F_DOC_LOG, "DOC_LOG", "doc_log"  } )
AADD(gaDBFs, { F_DOC_LIT, "DOC_LIT", "doc_lit"  } )
AADD(gaDBFs, { F_E_GROUPS, "E_GROUPS", "e_groups" } )
AADD(gaDBFs, { F_E_GR_ATT, "E_GR_ATT", "e_gr_att" } )
AADD(gaDBFs, { F_E_GR_VAL, "E_GR_VAL", "e_gr_val" } )
AADD(gaDBFs, { F_AOPS, "AOPS", "aops" } )
AADD(gaDBFs, { F_AOPS_ATT, "AOPS_ATT", "aops_att" } )
AADD(gaDBFs, { F_ARTICLES, "ARTICLES", "articles" } )
AADD(gaDBFs, { F_ELEMENTS, "ELEMENTS", "elements" } )
AADD(gaDBFs, { F_E_AOPS, "E_AOPS", "e_aops" } )
AADD(gaDBFs, { F_E_ATT, "E_ATT", "e_att" } )
AADD(gaDBFs, { F_CUSTOMS, "CUSTOMS", "customs" } )
AADD(gaDBFs, { F_CONTACTS, "CONTACTS", "contacts" } )
AADD(gaDBFs, { F_OBJECTS, "OBJECTS", "objects" } )
AADD(gaDBFs, { F_RAL, "RAL", "ral" } )
AADD(gaDBFs, { F__FND_PAR, "_FND_PAR", "_fnd_par" } )

// modul EPDV
AADD(gaDBFs, { F_P_KIF, "P_KIF", "p_kif"  } )
AADD(gaDBFs, { F_P_KUF, "P_KUF", "p_kuf"  } )
AADD(gaDBFs, { F_KUF, "KUF", "kuf"  } )
AADD(gaDBFs, { F_KIF, "KIF", "kif"  } )
AADD(gaDBFs, { F_PDV, "PDV", "pdv"  } )
AADD(gaDBFs, { F_SG_KIF, "SG_KIF", "sg_kif" } )
AADD(gaDBFs, { F_SG_KUF, "SG_KUF", "sg_kuf" } )

// modul LD

AADD(gaDBFs, { F__RADKR ,"_RADKR"  , "_radkr"    } )
AADD(gaDBFs, { F__RADN  ,"_RADN"   , "_radn"     } )
AADD(gaDBFs, { F_LDSM   ,"LDSM"    , "ldsm"    } )
AADD(gaDBFs, { F_OPSLD  ,"OPSLD"   , "opsld"    } )
AADD(gaDBFs, { F_LD     ,"LD"      , "ld"     } )
AADD(gaDBFs, { F_LD     ,"REKLD"      , "rekld"     } )
AADD(gaDBFs, { F_RADKR  ,"RADKR"   , "radkr"     } )
AADD(gaDBFs, { F_RADN   ,"RADN"    , "radn"     } )
AADD(gaDBFs, { F_RADSIHT,"RADSIHT" , "radsiht"     } )
AADD(gaDBFs, { F_RJ     ,"LD_RJ"   , "ld_rj"     } )
AADD(gaDBFs, { F_NORSIHT,"NORSIHT" , "norsiht"     } )
AADD(gaDBFs, { F_TPRSIHT,"TPRSIHT" , "tprsiht"     } )
AADD(gaDBFs, { F_PK_RADN,"PK_RADN" , "pk_radn"     } )
AADD(gaDBFs, { F_PK_DATA,"PK_DATA" , "pk_data"     } )
AADD(gaDBFs, { F_OBRACUNI,"OBRACUNI", "obracuni"    } )
AADD(gaDBFs, { F_RADSAT ,"RADSAT"  , "radsat"    } )
AADD(gaDBFs, { F_POR    ,"POR"     , "por"    } )
AADD(gaDBFs, { F_DOPR   ,"DOPR"    , "dopr"     } )
AADD(gaDBFs, { F_PAROBR ,"PAROBR"  , "parobr"     } )
AADD(gaDBFs, { F_TIPPR  ,"TIPPR"   , "tippr"     } )
AADD(gaDBFs, { F_TIPPR2 ,"TIPPR2"  , "tippr2"     } )
AADD(gaDBFs, { F_KRED   ,"KRED"    , "kred"     } )
AADD(gaDBFs, { F_STRSPR ,"STRSPR"  , "strspr"     } )
AADD(gaDBFs, { F_KBENEF ,"KBENEF"  , "kbenef"     } )
AADD(gaDBFs, { F_VPOSLA ,"VPOSLA"  , "vposla"     } )

log_write(cHostName + " / " + cDatabase + " / " + cUser + " / " + cPassWord + " / " +  STR(nPort)  + " / " + cSchema)

oServer := TPQServer():New( cHostName, cDatabase, cUser, cPassWord, nPort, cSchema )
IF oServer:NetErr()
      log_write( oServer:ErrorMsg() )
      QUIT
ENDIF


return oServer 

// ---------------------------------------
// ---------------------------------------
function f18_help()
   
   ? "F18 parametri"
   ? "parametri"
   ? "-h hostname (default: localhost)"
   ? "-y port (default: 5432)"
   ? "-u user (default: root)"
   ? "-p password (default no password)"
   ? "-d name of database to use"
   ? "-e schema (default: public)"
   ? "-t fmk tables path"
   ? ""

RETURN

/* --------------------------
 setup ulazne parametre F18
 -------------------------- */

function set_f18_params()

//IF PCount() < 7
//    help()
//    QUIT
//ENDIF

i := 1

// setuj ulazne parametre
cParams := ""

DO WHILE i <= PCount()

    // ucitaj parametar
    cTok := hb_PValue( i++ )
     
    
    DO CASE

      CASE cTok == "--help"
          f18_help()
          QUIT
      CASE cTok == "-h"
         cHostName := hb_PValue( i++ )
         cParams += SPACE(1) + "hostname=" + cHostName
      CASE cTok == "-y"
         nPort := Val( hb_PValue( i++ ) )
         cParams += SPACE(1) + "port=" + ALLTRIM(STR(nPort))
      CASE cTok == "-d"
         cDataBase := hb_PValue( i++ )
         cParams += SPACE(1) + "database=" + cDatabase
      CASE cTok == "-u"
         cUser := hb_PValue( i++ )
         cParams += SPACE(1) + "user=" + cUser
      CASE cTok == "-p"
         cPassWord := hb_PValue( i++ )
         cParams += SPACE(1) + "password=" + cPassword
      CASE cTok == "-t"
         cDBFDataPath := hb_PValue( i++ )
         cParams += SPACE(1) + "dbf data path=" + cDBFDataPath
      CASE cTok == "-e"
         cSchema := hb_PValue( i++ )
         cParams += SPACE(1) + "schema=" + cSchema
      OTHERWISE
         //help()
         //QUIT
    ENDCASE

ENDDO

// ispisi parametre
? "Ulazni parametri:"
? cParams

return
