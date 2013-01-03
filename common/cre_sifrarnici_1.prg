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

// -----------------------------------
// kreiranje tabela - svi moduli 
// -----------------------------------
function cre_sifrarnici_1(ver)
local _created, _table_name, _alias

_table_name := "rj"
_alias := "RJ"
_created := .f.

if !FILE(f18_ime_dbf( _table_name ))
    aDBf:={}
    AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
    add_f_mcode(@aDbf)
    AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
    AADD(aDBf,{ 'TIP'                 , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'KONTO'               , 'C' ,   7 ,  0 })

    DBCREATE2( "rj", aDbf )
	_created := .t.

endif

// 0.8.7
if ver["current"] < 0807
    modstru( { "*" + _table_name, "A TIP C 2 0", "A KONTO C 7 0" } )
endif

if _created
    reset_semaphore_version( _table_name )
    my_use( _table_name )
    close all 
endif

CREATE_INDEX( "ID", "id", _table_name )
CREATE_INDEX( "NAZ", "NAZ", _table_name )
index_mcode( KUMPATH, _table_name )



if !file(f18_ime_dbf("konto"))
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  57 ,  0 })
   AADD(aDBf,{ "POZBILU"             , "C" ,   3 ,  0 })
   AADD(aDBf,{ "POZBILS"             , "C" ,   3 ,  0 })

   dbcreate2('konto', aDbf)

   reset_semaphore_version("konto")
   my_use("konto")
   close all
endif

CREATE_INDEX("ID","id", "konto")
CREATE_INDEX("NAZ","naz", "konto")
index_mcode(SIFPATH, "KONTO")


cIme := f18_ime_dbf("valute")
if !file(cIme)
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
        add_f_mcode(@aDbf)
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
        AADD(aDBf,{ 'NAZ2'                , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'DATUM'               , 'D' ,   8 ,  0 })
        AADD(aDBf,{ 'KURS1'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS2'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'KURS3'               , 'N' ,  10 ,  5 })
        AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
        dbcreate2("valute", aDbf)

        reset_semaphore_version("valute")
        my_use("valute")
        close all
    
        // upisi default valute ako ne postoje
        fill_tbl_valute()

endif

CREATE_INDEX("ID","id", "valute")
CREATE_INDEX("NAZ","tip+id+dtos(datum)", "valute")
CREATE_INDEX("ID2","id+dtos(datum)", "valute")
index_mcode(cIme)

// TNAL
if !file(f18_ime_dbf("tnal"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        add_f_mcode(@aDbf)
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  29 ,  0 })
        dbcreate2('tnal',aDbf)
        reset_semaphore_version("tnal")
        my_use("tnal")
        close all
endif
CREATE_INDEX("ID","id", "tnal")  
CREATE_INDEX("NAZ","naz", "tnal")
index_mcode(SIFPATH, "TNAL")

if !file(f18_ime_dbf("tdok"))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
        add_f_mcode(@aDbf)
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  13 ,  0 })
        dbcreate2(f18_ime_dbf('tdok'), aDbf)
        reset_semaphore_version("tdok")
        my_use("tdok")
        close all
endif
CREATE_INDEX("ID","id", "TDOK") 
CREATE_INDEX("NAZ","naz", "TDOK")
index_mcode(SIFPATH, "TDOK")

if !file(f18_ime_dbf("ops"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IDJ'                 , 'C' ,   3 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'ZIPCODE'             , 'C' ,   5 ,  0 })
   AADD(aDBf,{ 'PUCCANTON'           , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'PUCCITY'             , 'C' ,   5 ,  0 })
   AADD(aDBf,{ 'REG'              , 'C' ,   1 ,  0 })
   DBCREATE2('ops', aDbf)
   reset_semaphore_version("ops")
   my_use("ops")
   close all
endif

CREATE_INDEX("ID","id", "ops")
CREATE_INDEX("IDJ","idj", "ops")
CREATE_INDEX("IDKAN","idKAN", "ops")
CREATE_INDEX("IDN0","IDN0", "ops")
CREATE_INDEX("NAZ","naz", "ops")
index_mcode(SIFPATH, "ops")

cIme:="banke"
if !file(f18_ime_dbf(cIme) )
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   3 ,  0 })
        add_f_mcode(@aDbf)
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  45 ,  0 })
        AADD(aDBf,{ 'Mjesto'              , 'C' ,  20 ,  0 })
        AADD(aDBf,{ 'Adresa'              , 'C' ,  30 ,  0 })
        DBCREATE2("BANKE" , aDbf)
        reset_semaphore_version("banke")
        my_usex("banke")
        close all
endif
CREATE_INDEX("ID","id", cIme)
CREATE_INDEX("NAZ","naz", cIme)
index_mcode(SIFPATH, cIme)

// referenti
if !file( f18_ime_dbf("refer"))
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'IDOPS'               , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  40 ,  0 })
   DBCREATE2( 'REFER', aDbf )
   reset_semaphore_version("refer")
   my_use("refer")
   close all
endif
CREATE_INDEX("ID","id", "refer") 
CREATE_INDEX("NAZ","naz", "refer")

if !FILE(f18_ime_dbf("vrstep"))
    aDbf:={}
	AADD(aDbf,{"ID" ,"C", 2,0})
	AADD(aDbf,{"NAZ","C",20,0})
	DBcreate2( "VRSTEP", aDbf )
    reset_semaphore_version("vrstep")
    my_use("vrstep")
    close all
endif	
CREATE_INDEX("ID", "Id", "VRSTEP")


// ------------------------------------------------
// KONCIJ
// ------------------------------------------------
_created := .f.
_table_name := "koncij"
_alias := "KONCIJ"

if !FILE(f18_ime_dbf( _table_name ))

    aDbf:={}

    AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
    add_f_mcode(@aDbf)
    AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'NAZ'                 , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'IDPRODMJES'          , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'REGION'              , 'C' ,   2 ,  0 })

    DBcreate2( _alias, aDbf )
    _created := .t.

endif

// 0.4.7
if ver["current"] < 0407
    modstru( { "*" + _table_name, "A SUFIKS C 3 0" } )
endif

if _created
    reset_semaphore_version( _table_name )
    my_use( _table_name )
    close all
endif

CREATE_INDEX("ID","id", _alias )
index_mcode( NIL, _alias )


//PKONTO
if !FILE(f18_ime_dbf("pkonto"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  7  ,  0 })
    AADD(aDBf,{ "TIP"                 , "C" ,  1 ,   0 })
    DBcreate2( "PKONTO", aDbf )
    reset_semaphore_version("pkonto")
    my_use("pkonto")    
    close all
endif
CREATE_INDEX("ID","ID", "PKONTO" )
CREATE_INDEX("NAZ","TIP", "PKONTO" )


// TRFP
if !FILE(f18_ime_dbf("trfp"))
    aDbf:={}
    AADD(aDBf,{ 'ID'                  , 'C' ,  60 ,  0 })
    add_f_mcode(@aDbf)
    AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
    AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
    AADD(aDBf,{ 'DOKUMENT'            , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'PARTNER'             , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'ZNAK'                , 'C' ,   1 ,  0 })
    AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
    DBCREATE2("TRFP", aDbf)
    reset_semaphore_version("trfp")
    my_use("trfp")
    close all
endif
CREATE_INDEX("ID", "idvd+shema+Idkonto+id+idtarifa+idvn+naz", "TRFP")
index_mcode(NIL, "TRFP")


//TRFP2
if !FILE(f18_ime_dbf("trfp2"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  60 ,  0 })
    AADD(aDBf,{ "SHEMA"               , "C" ,   1 ,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,  20 ,  0 })
    AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
    AADD(aDBf,{ "DOKUMENT"            , "C" ,   1 ,  0 })
    AADD(aDBf,{ "PARTNER"             , "C" ,   1 ,  0 })
    AADD(aDBf,{ "D_P"                 , "C" ,   1 ,  0 })
    AADD(aDBf,{ "ZNAK"                , "C" ,   1 ,  0 })
    AADD(aDBf,{ "IDVD"                , "C" ,   2 ,  0 })
    AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
    AADD(aDBf,{ "IDTARIFA"            , "C" ,   6 ,  0 })
    DBcreate2( "TRFP2", aDbf ) 
    reset_semaphore_version("trfp2")
    my_use("trfp2")
    close all
endif
CREATE_INDEX("ID","idvd+shema+Idkonto+id+idtarifa+idvn+naz", "TRFP2")

//TRFP3    
if !FILE(f18_ime_dbf("trfp3"))
    aDbf:={}
    AADD(aDBf,{ "ID"                  , "C" ,  60 ,  0 })
    AADD(aDBf,{ "SHEMA"               , "C" ,   1 ,  0 })
    AADD(aDBf,{ "NAZ"                 , "C" ,  20 ,  0 })
    AADD(aDBf,{ "IDKONTO"             , "C" ,   7 ,  0 })
    AADD(aDBf,{ "D_P"                 , "C" ,   1 ,  0 })
    AADD(aDBf,{ "ZNAK"                , "C" ,   1 ,  0 })
    AADD(aDBf,{ "IDVN"                , "C" ,   2 ,  0 })
    DBcreate2("TRFP3",aDbf)
    reset_semaphore_version("trfp3")
    my_use("trfp3")
    close all
endif
CREATE_INDEX("ID","shema+Idkonto","TRFP3")


// kamate - sifrarnik kamata
if !FILE( f18_ime_dbf("ks") )
    aDbf:={}
    AADD(aDBf,{ "ID"        , "C" ,   3 ,  0 })
    AADD(aDBf,{ "NAZ"       , "C" ,   2 ,  0 })
    AADD(aDBf,{ "DATOD"     , "D" ,   8 ,  0 })
    AADD(aDBf,{ "DATDO"     , "D" ,   8 ,  0 })
    AADD(aDBf,{ "STREV"     , "N" ,   8 ,  4 })
    AADD(aDBf,{ "STKAM"     , "N" ,   8 ,  4 })
    AADD(aDBf,{ "DEN"       , "N" ,  15 ,  6 })
    AADD(aDBf,{ "TIP"       , "C" ,   1 ,  0 })
    AADD(aDBf,{ "DUZ"       , "N" ,   4 ,  0 })

    DBCREATE2( "KS", aDbf)
    reset_semaphore_version("ks")
    my_use("ks")
    close all
endif
CREATE_INDEX("ID", "Id", "ks") 
CREATE_INDEX("2", "dtos(datod)", "ks") 


// objekti
if !FILE(f18_ime_dbf("objekti"))
    aDbf:={}
    AADD(aDbf, {"id","C",2,0})
    AADD(aDbf, {"naz","C",10,0}) 
    AADD(aDbf, {"IdObj","C", 7,0})
	DBCREATE2("OBJEKTI", aDbf)
    reset_semaphore_version( "objekti" )
    my_use( "objekti" )
    close all
endif
CREATE_INDEX("ID", "ID", "OBJEKTI")
CREATE_INDEX("NAZ", "NAZ", "OBJEKTI")
CREATE_INDEX("IdObj", "IdObj", "OBJEKTI")


nArea := nil

// kreiraj lokal tabelu : LOKAL
cre_lokal(F_LOKAL)

// kreiraj tabele dok_src : DOK_SRC
cre_doksrc()

// kreiraj relacije : RELATION
cre_relation()

// kreiraj pravila : RULES
cre_fmkrules()

// kreiranje tabela ugovora
db_cre_ugov()

return .t.


// ----------------------------------------
// ----------------------------------------
function fill_tbl_valute()
local _rec
local _id

close all
my_use ('valute')

_id := "000"
hseek _id

if !FOUND()
    append blank
    _rec := dbf_get_rec()
    _rec["id"]    := "000" 
    _rec["naz"]   := "KONVERTIBILNA MARKA"
    _rec["naz2"]  := "KM"
    _rec["datum"] := CTOD("01.01.04")
    _rec["tip"]   := "D"
    _rec["kurs1"] := 1
    _rec["kurs2"] := 1
    _rec["kurs3"] := 1
    update_rec_server_and_dbf('valute', _rec, 1, "FULL")
endif

select valute 
go top
_id := "978"
hseek _id

if !FOUND()
    append blank
    _rec := dbf_get_rec()
    _rec["id"]    := "978" 
    _rec["naz"]   := "EURO"
    _rec["naz2"]  := "EUR"
    _rec["datum"] := CTOD("01.01.04")
    _rec["tip"]   := "P"
    _rec["kurs1"] := 0.51128
    _rec["kurs2"] := 0.51128
    _rec["kurs3"] := 0.51128
    update_rec_server_and_dbf('valute', _rec, 1, "FULL")
endif

close all

return .t.


