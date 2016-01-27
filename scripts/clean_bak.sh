#!/bin/sh

find . -name "*.bak" -exec echo \{\} \; -exec rm \{\} \;

