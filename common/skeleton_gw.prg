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

#include "f18.ch"
#include "fileio.ch"

  
*string
static GW_STRING
*;

/*! \fn Gw(cStr, nHandle, cAkcija)
 *  \param cStr - string koji prosljedjujemo gateway-u
 *  \param nHandle - ne koristi se, izbaciti !
 *  \param cAkcija = A - azuriraj odmah, default value; P - pocetak; D - dodaj;  Z- zavrsi; L - upisi direktno u log fajl (ne salji gateway-u)
 */
function Gw(cStr, nHandle, cAkcija)
local nHgw
local cBaza
local cBazaInOut

// F18 sinhronizaciju treba rijesiti putem semafora

return ""


/*! \fn GwOdgovor(cBazaInOut)
 *  \param cBazaInOut  - c:/sigma
 */
static function GwOdgovor(cBazaInOut)

local nGwSec

// F18 sinhronizaciju treba rijesiti putem semafora
return ""



/*! \fn TimeOutIzaci(nGwSec)
 */
 
static function TimeOutIzaci(nGwSec)

private cKom

// F18 sinhronizaciju treba rijesiti putem semafora
return .f.

/*! \fn GwStaMai(nBroji2)
 *  \brief
 *  \param nBroji2
 * Svakih 10 sekundi uzima stanje od gateway-a (iz c:/sigma/out)
 *
 */
function GwStaMai(nBroji2)

// F18 sinhronizaciju treba rijesiti putem semafora
return ""


// ------------------------------------------------------------
// ------------------------------------------------------------
static function cmdHocuSynchro(cRezultat, GW_STATUS, ZGwPoruka)

return



static function cmdHocuShutdown(cRezultat, GW_STATUS, ZGwPoruka)
return


static function cmdImportStat(cRezultat,GW_STATUS, ZGwPoruka)
return


static function cmdNaCekiSql(cRezultat, GW_STATUS, ZGwPoruka)
return


static function cmdZavrsenaSyn(cRezultat, GW_STATUS, ZGwPoruka)
return



static function cmdImpSqlError(cRezultat, GW_STATUS, ZGwPoruka)
return


function ZGwPoruka()

// uzmi trenutno stanje ...
GwStamai(-1)
return ZGwPoruka


function GW_STRING()
return GW_STRING

/*! \fn GwDirektno(cSql)
 *  \brief Upisuje SQL komandu u log fajl direktno
 */

function GwDirektno(cSql)
return ""


static function OpenLog(cLogName)
return

function GwDiskFree()
return 0

