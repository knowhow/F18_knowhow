
// --------------------------------------------------------
// sql_table_empty("tnal") => .t. ako je sql tabela prazna
// ---------------------------------------------------------
function   sql_table_empty(alias)
local _a_dbf_rec := get_a_dbf_rec(alias, .t.)

if _a_dbf_rec["temp"] 
   return .t.
endif

return table_count("fmk." + _a_dbf_rec["table"]) == 0


