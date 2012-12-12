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


#include "kalk.ch"

function PocStProd()
LLP(.t.)
if !empty(goModul:oDataBase:cSezonDir) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
	O_KALK_PRIPRRP
          O_KALK_PRIPR
          if reccount2()<>0
           select kalk_priprrp
           append from kalk_pripr
           select kalk_pripr; zap
           close all
          endif
endif
close all

return nil





