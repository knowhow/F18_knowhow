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

#include "f18_color.ch"


FUNCTION f18_color_normal()

   IF in_tekuca_godina()
      RETURN F18_COLOR_NORMAL
   ENDIF

   RETURN F18_COLOR_NORMAL_STARA_SEZONA

FUNCTION f18_color_invert()
   RETURN hb_ColorIndex( f18_color_normal(), 4 ) + "," + hb_ColorIndex( f18_color_normal(), 3 ) + "," + hb_ColorIndex( f18_color_normal(), 2 ) + "," + hb_ColorIndex( f18_color_normal(), 1 ) + "," + hb_ColorIndex( f18_color_normal(), 0 )


FUNCTION f18_color_i()
   RETURN "I"
