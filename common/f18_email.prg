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


#include "fmk.ch"
#include "simpleio.ch"


// ---------------------------------------------------------
// centralna funkcija za slanje email-a
// 
// mail_params = hb_hash()
// attachments = {}
//
//   koristi se na sljedeci nacin:
//   -------------------------------------------------------
//   // priprema podataka za slanje na osnovu parametara f18
//   // sve sto ne navedemo bit ce dafault iz postavki 
//
//   _mail_params := f18_email_prepare( subject, body )
//
//   // fajlovi za slanje
//
//   _attach := { fajl1, fajl2, fajl3 } ili nil 
//
//   // glavna funkcija koja salje email na destinaciju
//
//   f18_email_send( _mail_params, _attach )
//
//
// ---------------------------------------------------------
function f18_email_send( mail_params, attach )
// default parametri
// koje necemo setovati
local _pop_srv := ""
local _smtp_pass := ""
local _pop_auth := .f.
local _no_auth := NIL
local _timeout := NIL
local _tls := .f.
local _encoding := ""
local _charset := ""
local _priority := NIL
local _read := NIL
local _trace := .f.
local _ret := .f.
local _files := NIL
local _server, _port, _user, _pass, _from, _to, _cc, _bcc, _repl_to, _body, _subject

// parametri iz mail matrice
_server := mail_params["server"]
_port := mail_params["port"]
_user := mail_params["user_name"]
_pass := mail_params["user_password"]
_from := mail_params["mail_from"]
_to := mail_params["mail_to"]
_cc := mail_params["mail_cc"]
_bcc := mail_params["mail_bcc"]
_repl_to := mail_params["mail_reply_to"]
_body := mail_params["mail_body"]
_subject := mail_params["mail_subject"]
_trace := mail_params["trace"]
_smtp_pass := mail_params["smtp_password"]
_no_auth := mail_params["no_auth"]

if attach <> NIL .and. LEN( attach ) <> 0
	_files := attach
endif

// posalji email
if hb_sendmail( _server, ;
				_port, ;
				_from, ;
				_to, ;
				_cc, ;
				_bcc, ;
				_body, ;
				_subject, ;
				_files, ;
				_user, ;
				_pass, ;
				_pop_srv, ;
				_priority, ;
				_read, ;
				_trace, ;
				_pop_auth, ;
				_no_auth, ;
				_timeout, ;
				_repl_to, ;
				_tls, ;
				_smtp_pass, ;
				_charset, ;
				_encoding )

	_ret := .t.

else

	Alert( "Email pristup ne radi !!!" )
	_ret := .f.

endif

return _ret



// -----------------------------------------------------------------
// iscitaj porametre i pripremi za slanje email-a
// -----------------------------------------------------------------
function f18_email_prepare( subject, body, m_from, m_to, m_cc, m_bcc, m_reply )
local _mail_params := hb_hash()

// ucitaj parametre F18
_mail_params["trace"] := .f.
_mail_params["no_auth"] := NIL
_mail_params["server"] := ALLTRIM( fetch_metric( "email_server", my_user(), "" ) )
_mail_params["port"] := fetch_metric( "email_port", my_user(), 25 )
_mail_params["user_name"] := ALLTRIM( fetch_metric( "email_user_name", my_user(), "" ) )
_mail_params["user_password"] := ALLTRIM( fetch_metric( "email_user_pass", my_user(), "" ) )
_mail_params["smtp_password"] := ""

// sve ostalo setuj default, ako ne postoji
// ili proslijedi iz funkcije

if m_from == NIL
	_mail_params["mail_from"] := ALLTRIM( fetch_metric( "email_from", my_user(), "" ) )
else
	_mail_params["mail_from"] := m_from
endif

if m_to == NIL
	_mail_params["mail_to"] := { ALLTRIM( fetch_metric( "email_to_default", my_user(), "" ) ) }
else
	_mail_params["mail_to"] := get_email_array( m_to )
endif

if m_cc == NIL
	_mail_params["mail_cc"] := { ALLTRIM( fetch_metric( "email_cc_default", my_user(), "" ) ) }
else
	_mail_params["mail_cc"] := get_email_array( m_cc )
endif

if m_bcc == NIL
	_mail_params["mail_bcc"] := ""
else
	_mail_params["mail_bcc"] := get_email_array( m_bcc )
endif

if m_reply == NIL
	_mail_params["mail_reply_to"] := ""
else
	_mail_params["mail_reply_to"] := m_reply
endif

if body == NIL
	_mail_params["mail_body"] := "empty body"
else
	_mail_params["mail_body"] := body
endif

if subject == NIL
	_mail_params["mail_subject"] := "empty subject"
else
	_mail_params["mail_subject"] := subject
endif

return _mail_params



// ---------------------------------------------------------
// vraca array email-ova na osnovu stringa
// ---------------------------------------------------------
static function get_email_array( email_string )
local _arr := {}
_arr := TokToNiz( email_string, "," )
return _arr



// --------------------------------------------------------
// testiranje slanja email-a
// --------------------------------------------------------
function f18_email_test()
local _mail_params
local _subject := "Test email generated by Harbour"
local _body := "Test email generated by Harbour & F18"
local _to := fetch_metric( "fakt_dokument_na_email", my_user(), "" )
local _attach := nil

if EMPTY( _to )
    MsgBeep("Nije podesen primaoc u fakt/parametri/razno !!!")
    return
endif 

_mail_params := f18_email_prepare( _subject, _body, NIL, _to )

f18_email_send( _mail_params, _attach )

return


