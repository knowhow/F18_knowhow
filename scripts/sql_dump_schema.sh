#!/bin/bash

pg_dump --schema=fmk -s f18test_2018 > F18_fmk_schema.sql
pg_dump --schema=public -s f18test_2018 > F18_public_schema.sql
