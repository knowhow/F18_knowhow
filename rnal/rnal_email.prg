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




#include "rnal.ch"
#include "simpleio.ch"


function send_email_test()
// podaci servera
local _server := "smtp.gmail.com"
local _port := 465
local _user := ""
local _pass := ""
local _pop_srv := ""
local _smtp_pass := ""
local _pop_auth := .f.
local _no_auth := nil
local _timeout := nil
local _tls := .t.
local _encoding := ""
local _charset := ""
// podaci email-a
local _from := ""
local _to := ""
local _cc := ""
local _repl_to := nil
local _body := "test test test"
local _subject := "test from harbour"
local _priority := nil
local _read := nil
local _trace := .t.
// fajlovi
local _files := nil


if hb_sendmail( _server, _port, _from, ;
		_to, _cc, {}, _body, ;
		_subject, _files, _user, _pass, ;
		_pop_srv, _priority, _read, _trace, ;
		_pop_auth, _no_auth, _timeout, ;
		_repl_to, _tls, _smtp_pass, _charset, ;
		_encoding )

	MsgBeep("ok")

else

	Alert("Email pristup ne radi !!!")

endif

return




