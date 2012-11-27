# F18 knowhowERP

[![Build
Status](https://secure.travis-ci.org/knowhow/F18_knowhow.png?branch=master)](https://travis-ci.org/knowhow/F18_knowhow)

## dev environment

<pre>
$ source scripts/(ubuntu | mac | win)_set_envars.sh
$
$ echo --- build debug ----
$ ./build.sh
$ ./F18
$ 
$ echo --- build test exe ---
$ ./build_test.sh
$ ./F18_test
$ .
$ echo --- build release (no debug) exe ---
$ ./build_release.sh
$ ./F18
</pre>


## After database upgrade

[travis](https://github.com/knowhow/F18_knowhow/blob/master/TRAVIS.md)
