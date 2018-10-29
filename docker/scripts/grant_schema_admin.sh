#!/bin/bash

CMD="ALTER schema fmk OWNER TO admin;"
su postgres -c "psql proba_2018 -c \"$CMD\""


