
[![Travis build status](https://travis-ci.org/kiwiroy/perlbrewr.svg?branch=master)](https://travis-ci.org/kiwiroy/perlbrewr) [![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!--   home: !r Sys.getenv("PERLBREW_HOME") -->
perlbrewr
=========

The goal of perlbrewr is to assist the loading of a [perlbrew](https://perlbrew.pl) perl and optionally a library with the aim of improving reproducibility. The central task that perlbrewr performs is management of the environment variables in the same manner as perlbrew itself, by calling perlbrew commands and translating the changes there into R function calls that achieve the same outcome. Primarily, these are `Sys.setenv` and `Sys.unsetenv`.

Dependencies
------------

### R

-   R (&gt;= 3.3.0)
-   magrittr
-   stringr

### Non R

-   [perlbrew](https://perlbrew.pl)

Installation
------------

You can install the released version of perlbrewr from [GitHub](https://github.com/kiwiroy/perlbrewr) with:

``` r
devtools::install_github("kiwiroy/perlbrewr")
```

Example
-------

This is a basic example of usage to load a perlbrew environment:

``` r
library(perlbrewr)
result <- perlbrew(root = Sys.getenv("PERLBREW_ROOT"), version = "5.24.0")
```

The brewed version of perl is now the default.

``` r
Sys.which("perl")
#>                                                             perl 
#> "/software/programming/perlbrew-0.76/perls/perl-5.24.0/bin/perl"
```

This is also the case in `bash` shell blocks.

``` bash
which perl
#> /software/programming/perlbrew-0.76/perls/perl-5.24.0/bin/perl
```

By configuring `knitr` - this happens automatically by default.

``` r
knitr::opts_chunk$set(engine.path = list(perl = Sys.which("perl")[["perl"]]))
```

Perl code in `perl` blocks run the same interpreter.

``` perl
print "$^X\n";
#> /software/programming/perlbrew-0.76/perls/perl-5.24.0/bin/perl
```

### local::lib library access

Perlbrew supports [`local::lib`](https://metacpan.org/pod/local::lib) libraries for further controlling which modules are installed. `perlbrewr` supports loading these also.

``` r
perlbrew(version = "5.24.0", lib = "example")
#> [1] TRUE
Sys.getenv("PERL5LIB")
#> [1] "/tmp/RtmpfeCTTa/.perlbrew/libs/perl-5.24.0@example/lib/perl5"
```

Within this `local::lib` modules may be installed with [`cpanm`](https://metacpan.org/pod/App::cpanminus).

``` bash
cpanm -n -q --installdeps .
#> Successfully installed Mojolicious-8.12
#> 1 distribution installed
```

Since `perlbrewr::perlbrew` sets the `PERL5LIB` environment variable perl code relying on the dependencies is now sucessful.

``` perl
use Mojo::Base -strict;
use Mojo::File;
say Mojo::File->new('cpanfile')->slurp;
#> requires "Mojolicious" => 8.0;
```

### listing and creating libraries

`perlbrew_list` returns a listing of the available versions of perl and any `local::lib` libraries. If a version or library is in use, the `active` object attribute is also set.

``` r
perlbrew_list()
#> [1] "perl-5.24.0"         "perl-5.24.0@example" "perl-5.26.0"        
#> attr(,"active")
#> [1] "perl-5.24.0@example"
```

A new library is created with `perlbrew_lib_create`.

``` r
perlbrew_lib_create(version = "5.24.0", lib = "foobar")
#> [1] TRUE
perlbrew_list()
#> [1] "perl-5.24.0"         "perl-5.24.0@example" "perl-5.24.0@foobar" 
#> [4] "perl-5.26.0"        
#> attr(,"active")
#> [1] "perl-5.24.0@example"
```

### knitr

The knitr chunk options `engine.path` and `engine.opts` are set automatically so that each `engine="perl"` chunk will use the correct `perl` interpreter and `PERL5LIB`. Any `engine.opts` for perl that have already been set should remain in the list. For this to work correctly the `list()` version of the `engine.opts` should be used. i.e.

``` r
knitr::opts_chunk$set(engine.opts = list(perl = "-CS", bash = "--norc"))
```
