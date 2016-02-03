#!/bin/bash

F18_DB=rg_2015
GODINA=2015
VRSTA_DOK=NP
ROUND_NUM=0
FILE_NAME="rnal_1.csv"
PSQL_USER=postgres

SQL=""
SQL="$SQL select"
SQL="$SQL rnal_articles.art_id, rnal_articles.art_desc, rnal_articles.art_full_d,"
SQL="$SQL  round( sum(rnal_doc_it.doc_it_qtt * rnal_doc_it.doc_it_wid * rnal_doc_it.doc_it_hei), $ROUND_NUM) as uk_povrsina_m2"
SQL="$SQL  from fmk.rnal_docs"
SQL="$SQL  join fmk.rnal_doc_it  ON rnal_doc_it.doc_no = rnal_docs.doc_no"
SQL="$SQL  left join fmk.rnal_articles ON fmk.rnal_doc_it.art_id = fmk.rnal_articles.art_id"
SQL="$SQL  where rnal_docs.doc_type='$VRSTA_DOK' AND EXTRACT(year from fmk.rnal_docs.doc_date ) = $GODINA"
SQL="$SQL  group by rnal_articles.art_id, rnal_articles.art_desc, rnal_articles.art_full_d"
SQL="$SQL  order by art_desc"

echo "sql=$SQL"

echo "\\copy ( $SQL ) TO '$FILE_NAME' CSV HEADER QUOTE '\"'" | psql -H $F18_DB -U $PSQL_USER

echo created: 
ls -l $FILE_NAME
