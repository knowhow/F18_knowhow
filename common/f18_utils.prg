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
   QUIT
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


 public gaDBFs:={ ;
{ F_PARAMS  ,  "PARAMS"   , "params"  },;
{ F_GPARAMS , "GPARAMS"  , "gparams"  },;
{ F_KPARAMS , "KPARAMS"  , "kparams"  },;
{ F_SECUR  , "SECUR"  , "secur"  },;
{ F_TOKVAL  , "TOKVAL"  , "tokval"  },;
{ F_SIFK  , "SIFK"  , "sifk"  },;
{ F_SIFV , "SIFV"  , "sifv"  },;
{ F_OPS , "OPS"  , "opstine"  },;
{ F_BANKE , "BANKE"  , "banke"  },;
{ F_BARKOD , "BARKOD"  , "barkod"  },;
{ F_STRINGS , "STRINGS"  , "strings"  },;
{ F_RNAL , "RNAL"  , "rnal"  },;
{ F_LOKAL , "LOKAL"  , "lokal"  },;
{ F_DOKSRC , "DOKSRC"  , "doksrc"  },;
{ F_P_DOKSRC , "P_DOKSRC"  , "p_doksrc"  },;
{ F_RELATION , "RELATION"  , "relation"  },;
{ F_FMKRULES , "FMKRULES"  , "f18_rules"  },;
{ F_RULES , "RULES"  , "rules"  },;
{ F_P_UPDATE , "P_UPDATE"  , "p_update"  },;
{ F__ROBA , "_ROBA"  , "_roba"  },;
{ F_TRFP , "TRFP"  , "trfp"  },;
{ F_SAST , "SAST"  , "sast"  },;
{ F_VRSTEP , "VRSTEP"  , "vrstep"  },;
{ F_PRIPR  ,  "PRIPR"   , "fin_pripr"  },;
{ F_FIPRIPR , "PRIPR"   , "fin_pripr"  },;
{ F_BBKLAS ,  "BBKLAS"  , "fin_bblkas"  },;
{ F_IOS    ,  "IOS"     , "fin_ios"  },;
{ F_PNALOG ,  "PNALOG"  , "fin_pnalog"  },;
{ F_PSUBAN ,  "PSUBAN"  , "fin_psuban"  },;
{ F_PANAL  ,  "PANAL"   , "fin_panal"  },;
{ F_PSINT  ,  "PSINT"   , "fin_psint"  },;
{ F_PRIPRRP,  "PRIPRRP" , "fin_priprrp"  },;
{ F_FAKT   ,  "FAKT"    , "fakt_fakt"  },;
{ F_FINMAT ,  "FINMAT"  , "fin_mat"  },;
{ F_OSTAV  ,  "OSTAV"   , "fin_ostav"  },;
{ F_OSUBAN ,  "OSUBAN"  , "fin_osuban"  },;
{ F__KONTO ,  "_KONTO"  , "fin__konto"  },;
{ F__PARTN ,  "_PARTN"  , "fin__partn"  },;
{ F_POM    ,  "POM"     , "fin_pom"  },;
{ F_POM2   ,  "POM2"    , "fin_pom2"  },;
{ F_KUF    ,  "KUF"     , "fin_kuf"   },;
{ F_KIF    ,  "KIF"     , "fin_kif"   },;
{ F_SUBAN  ,  "SUBAN"   , "fin_suban" ,  {|dDatDok| fin_suban_from_sql_server(dDatDok) } },;
{ F_ANAL   ,  "ANAL"    , "fin_anal"   },;
{ F_SINT   ,  "SINT"    , "fin_sint"   },;
{ F_NALOG  ,  "NALOG"   , "fin_nalog"  },;
{ F_RJ     ,  "RJ"      , "fin_rj"   },;
{ F_FUNK   ,  "FUNK"    , "fin_funk"  },;
{ F_BUDZET ,  "BUDZET"  , "fin_budzet"  },;
{ F_PAREK  ,  "PAREK"   , "fin_parek"   },;
{ F_FOND   ,  "FOND"    , "fin_fond"   },;
{ F_KONIZ  ,  "KONIZ"   , "fin_koniz"   },;
{ F_IZVJE  ,  "IZVJE"   , "fin_izvje"   },;
{ F_ZAGLI  ,  "ZAGLI"   , "fin_zagli"   },;
{ F_KOLIZ  ,  "KOLIZ"   , "fin_koliz"   },;
{ F_BUIZ   ,  "BUIZ"    , "fin_buiz"   },;
{ F_TDOK   ,  "TDOK"    , "tdok"   },;
{ F_KONTO  ,  "KONTO"   , "konto"  },;
{ F_VPRIH  ,  "VPRIH"   , "vpprih"   },;
{ F_PARTN  ,  "PARTN"   , "partn"   },;
{ F_TNAL   ,  "TNAL"    , "tnal"   },;
{ F_PKONTO ,  "PKONTO"  , "pkonto"   },;
{ F_VALUTE ,  "VALUTE"  , "valute"   },;
{ F_ROBA   ,  "ROBA"    , "roba"   },;
{ F_TARIFA ,  "TARIFA"  , "tarifa"  },;
{ F_KONCIJ ,  "KONCIJ"  , "koncij"   },;
{ F_TRFP2  ,  "TRFP2"   , "trfp2"  },;
{ F_TRFP3  ,  "TRFP3"   , "trfp3"   },;
{ F_VKSG   ,  "VKSG"    , "vksg"   },;
{ F_ULIMIT ,  "ULIMIT"  , "ulimit"  };
}

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
