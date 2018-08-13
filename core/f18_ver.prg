/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18_ver.ch"

FUNCTION f18_ver()

   RETURN F18_VER

FUNCTION f18_ver_date()

   RETURN F18_VER_DATE


FUNCTION f18_lib_ver()

   RETURN F18_LIB_VER


FUNCTION f18_dev_period()

   RETURN F18_DEV_PERIOD


FUNCTION f18_template_ver()

   RETURN F18_TEMPLATE_VER


FUNCTION server_db_ver_major()

   RETURN SERVER_DB_VER_MAJOR


FUNCTION server_db_ver_minor()

   RETURN SERVER_DB_VER_MINOR


FUNCTION server_db_ver_patch()

   RETURN SERVER_DB_VER_PATCH
