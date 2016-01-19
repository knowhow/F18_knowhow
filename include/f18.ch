/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#define F18_F18_DEFINED

/*

// NTX
#define NTX_INDICES
#undef  CDX_INDICES


#define INDEXEXT      "ntx"
#define OLD_INDEXEXT  "cdx"
#define DBFEXT        "dbf"
#define MEMOEXT       "dbt"

#define  INDEXEXTENS  "ntx"
#define  MEMOEXTENS   "dbt"


#define RDDENGINE "DBFNTX"
#define DBFENGINE "DBFNTX"

*/

// CDX
#define CDX_INDICES
#undef NTX_INDICES
#define INDEXEXT      "cdx"
#define OLD_INDEXEXT  "ntx"
#define DBFEXT        "dbf"
#define MEMOEXT       "fpt"

#define  INDEXEXTENS  "cdx"
#define  MEMOEXTENS   "fpt"


#define RDDENGINE "DBFCDX"
#define DBFENGINE "DBFCDX"
// CDX end


#define SEMAPHORE_LOCK_RETRY_IDLE_TIME 1
#define SEMAPHORE_LOCK_RETRY_NUM 50

#define SIFK_LEN_DBF     8
#define SIFK_LEN_OZNAKA  4
#define SIFK_LEN_IDSIF   15

//#define RPT_PAGE_LEN 60
#define RPT_PAGE_LEN fetch_metric( "rpt_duzina_stranice", my_user(), 60 )

#define F18_CLIENT_ID_INI_SECTION "client_id"
#define F18_SCREEN_INI_SECTION "F18_screen"
#define F18_DBF_INI_SECTION "F18_dbf"

#ifdef __PLATFORM__WINDOWS
    #define F18_TEMPLATE_LOCATION "c:" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#else
    #define F18_TEMPLATE_LOCATION SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#endif

#define F18_SECUR_WARRNING "Opcija nije dostupna za ovaj nivo !#Da bi koristili opciju potrebna podesenja privilegija"

#ifndef TEST
  #ifndef F18_RELEASE_DEFINED
      #include "f18_release.ch"
  #endif
#else
  #ifndef F18_TEST_DEFINED
      #include "f18_test.ch"
  #endif
#endif

// F18.log, F18_2.log, F18_3.log ...
#define F18_LOG_FILE "F18.log"
#define OUTF_FILE "outf.txt"
#define OUT_ODT_FILE "out.odt"
#define DATA_XML_FILE "data.xml"

#command QUIT_1                    => ErrorLevel(1); __Quit()

#command @ <row>, <col> SAY8 <exp> [PICTURE <pic>] [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOutPict( hb_utf8toStr( <exp> ), <pic> [, <clr>] )
#command @ <row>, <col> SAY8 <exp> [COLOR <clr>] => ;
         DevPos( <row>, <col> ) ; DevOut( hb_utf8toStr( <exp> ) [, <clr>] )

#command @ <row>, <col> SAY8 <say> [<sayexp,...>] GET <get> [<getexp,...>] => ;
         @ <row>, <col> SAY8 <say> [ <sayexp>] ;;
         @ Row(), Col() + 1 GET <get> [ <getexp>]


#command ?U  [<explist,...>]         => QOutU( <explist> ) 
#command ??U [<explist,...>]         => QQOutU( <explist> )


#command RREPLACE <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
      => my_rlock();
         ;   _FIELD-><f1> := <v1> [; _FIELD-><fN> := <vN>];
         ;my_unlock()


#include "hbclass.ch"

