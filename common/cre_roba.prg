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

#include "fmk.ch"

//---------------------------------------------------
//---------------------------------------------------
function cre_roba(ver)
local _table_name, _alias
local _created

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'SIFRADOB'            , 'C' ,  20 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' , 250 ,  0 })
AADD(aDBf,{ 'STRINGS'             , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'JMJ'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'PLC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC3'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K7'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K8'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K9'                  , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'N1'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'N2'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MINK'                , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'Opis'                , 'C' , 250 ,  0 })
AADD(aDBf,{ 'BARKOD'              , 'C' ,  13 ,  0 })
AADD(aDBf,{ 'FISC_PLU'            , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'ZANIVEL'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'ZANIV2'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TROSK1'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK2'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK3'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK4'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'TROSK5'              , 'N' ,  15 ,  5 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  5 })

_created := .f.
_alias := "ROBA"
_table_name := "roba"

if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
    _created := .t.
endif

// 0.2.1
if ver["current"] < 00201
   modstru( {"*" + _table_name, "A IDKONTO C 7 0"})
endif

// 0.4.8
if ver["current"] < 00408
   modstru( {"*" + _table_name, "A MPC4 N 18 8", "A MPC5 N 18 8", "A MPC6 N 18 8", "A MPC7 N 18 8", "A MPC8 N 18 8", "A MPC9 N 18 8"})
endif

if _created 
  reset_semaphore_version(_table_name)
  my_usex(_alias)
  use
endif

if !file(f18_ime_dbf("_roba"))
	dbcreate2('_roba.dbf',aDbf)
endif

CREATE_INDEX("ID", "ID", "roba") 
index_mcode(SIFPATH, "roba")
CREATE_INDEX("NAZ","LEFT(naz,40)", "roba")
CREATE_INDEX("ID","id", "_roba") 
CREATE_INDEX("BARKOD","BARKOD", "roba") // roba, artikli
CREATE_INDEX("SIFRADOB","SIFRADOB","roba") // roba, artikli
CREATE_INDEX("ID_VSD","SIFRADOB",  "roba") // sifra dobavljaca
CREATE_INDEX("PLU","str(fisc_plu, 10)",  "roba") // sifra dobavljaca

close all
O_ROBA

if used()
    if fieldpos("KATBR")<>0
    select (F_ROBA)
    use
    CREATE_INDEX("KATBR","KATBR","roba") // roba, artikli
    endif
endif

// TARIFA
if !file(f18_ime_dbf("tarifa"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
        add_f_mcode(@aDbf)
	    AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
        AADD(aDBf,{ 'OPP'                 , 'N' ,   6 ,  2 })  // ppp
        AADD(aDBf,{ 'PPP'                 , 'N' ,   6 ,  2 })  // ppu
        AADD(aDBf,{ 'ZPP'                 , 'N' ,   6 ,  2 })  //nista
        AADD(aDBf,{ 'VPP'                 , 'N' ,   6 ,  2 })  // pnamar
        AADD(aDBf,{ 'MPP'                 , 'N' ,   6 ,  2 })  // pnamar MP
        AADD(aDBf,{ 'DLRUC'               , 'N' ,   6 ,  2 })  // donji limit RUC-a(%)
        dbcreate2( "TARIFA", aDbf)
		reset_semaphore_version("tarifa")
		my_use("tarifa")
		close all
endif
CREATE_INDEX("ID","id",  "TARIFA")
CREATE_INDEX("naz","naz", "TARIFA")
index_mcode(SIFPATH, "TARIFA")

// SAST
if !file(f18_ime_dbf("sast"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'R_BR'                , 'N' ,    4 ,  0 })
   AADD(aDBf,{ 'ID2'                 , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'KOLICINA'            , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'K1'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'K2'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'N1'                  , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'N2'                  , 'N' ,   20 ,  5 })
   dbcreate2('SAST', aDbf)
   reset_semaphore_version("sast")
   my_use("sast")
   close all
endif

CREATE_INDEX("ID", "ID+ID2", "SAST")

close all
O_SAST
if used()
    if sast->(fieldpos("R_BR"))<>0
        use
        CREATE_INDEX("IDRBR", "ID+STR(R_BR,4,0)+ID2",  "SAST")
    endif
    use
endif

CREATE_INDEX("NAZ", "ID2+ID",  "SAST")


_table_name := "barkod"

if !file(f18_ime_dbf(_table_name))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,   13 ,  0 })
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  250 ,  0 })
   AADD(aDBf,{ 'L1'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L2'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L3'                  , 'C' ,   40 ,  0})
   AADD(aDBf,{ 'VPC'                 , 'N' ,   12 ,  2 })
   AADD(aDBf,{ 'MPC'                 , 'N' ,   12 ,  2 })
   dbcreate2( _table_name, aDbf)
endif

CREATE_INDEX("1","barkod+id", _table_name)
CREATE_INDEX("ID","id+LEFT(naziv,40)", _table_name)
CREATE_INDEX("Naziv","LEFT(Naziv,40)+id", _table_name)

// kreiranje tabele strings
cre_strings()

cre_fin_mat()

return
