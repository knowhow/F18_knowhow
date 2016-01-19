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

#command IF_NOT_FILE_DBF_CREATE => _created := .f. ; 
                                   ;if !FILE(f18_ime_dbf(_alias));
                                   ;  DBCREATE2(_alias, aDbf);
                                   ;   _created := .t. ;
                                   ;else;
                                   ;  my_use_semaphore_off();
                                   ;  my_use(_alias);
                                   ;  my_use_semaphore_on();
                                   ;  if reccount() == 0 .and. !sql_table_empty(_alias);
                                   ;       _created := .t.;
                                   ;  end;
                                   ;  use;
                                   ;end

#command IF_C_RESET_SEMAPHORE  => if _created ; reset_semaphore_version(_table_name) ;  my_use(_alias);  use ; end





