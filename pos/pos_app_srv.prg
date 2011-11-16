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


#include "pos.ch"

function PosRunAppSrv(oApp)
local cLog

? "Pokrecem RunAppSrv"

if mpar37("/ISQLLOG",oApp)
   if LEFT(oApp:cP5,3)=="/L="
       cLog:=SUBSTR(oApp:cP5,4)
       AS_ISQLLog(cLog)
   endif
endif

if mpar37("/IALLMSG",oApp) 
	? "Pokrecem POS: importovanje poruka" 
	InsertIntoAMessage()
	goModul:quit()
endif


return

 
function AS_ISQLLog(cLog)

O_KASE

seek gIdPos
? "vrsim import sql-loga", cLog
? "Kasa ", gIdPos, kase->naz

O_Log()
? Iz_SQL_Log(VAL(cLog))
goModul:quit()

return

