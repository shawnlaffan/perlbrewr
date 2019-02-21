
<!-- README.md is generated from README.Rmd. Please edit that file -->
perlbrewr
=========

The goal of perlbrewr is to assist the loading of a [perlbrew](https://perlbrew.pl) perl and optionally a library with the aim of improving reproducibility.

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
#> Loading required package: magrittr
#> Loading required package: stringr
result <- perlbrew(root = Sys.getenv("PERLBREW_ROOT"), version = "5.26.0")
```

The brewed version of perl is now the default.

``` r
Sys.which("perl")
#>                                                             perl 
#> "/software/programming/perlbrew-0.76/perls/perl-5.26.0/bin/perl"
```

This is also the case in `bash` shell blocks.

``` bash
which perl
#> /software/programming/perlbrew-0.76/perls/perl-5.26.0/bin/perl
```

By configuring `knitr`

``` r
knitr::opts_chunk$set(engine.path = list(perl = Sys.which("perl")[["perl"]]))
```

Perl code in `perl` blocks run the same interpreter.

``` perl
print "$^X\n";
#> /software/programming/perlbrew-0.76/perls/perl-5.26.0/bin/perl
```
