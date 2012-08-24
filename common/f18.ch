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

#define INDEXEXT      "ntx"
#define OLD_INDEXEXT  "cdx"
#define DBFEXT    "dbf"
#define MEMOEXT   "fpt"

#define  INDEXEXTENS "ntx"
#define  MEMOEXTENS  "fpt"


#define RDDENGINE "DBFNTX"
#define DBFENGINE "DBFNTX"

#define SEMAPHORE_LOCK_RETRY_IDLE_TIME 1
#define SEMAPHORE_LOCK_RETRY_NUM 50

#define SIFK_LEN_DBF     8
#define SIFK_LEN_OZNAKA  4
#define SIFK_LEN_IDSIF   15

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
