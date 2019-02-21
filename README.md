
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!--   home: !r Sys.getenv("PERLBREW_HOME") -->
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

`local::lib` library access
---------------------------

Perlbrew supports [`local::lib`](https://metacpan.org/pod/local::lib) libraries for further controlling which modules are installed. `perlbrewr` supports loading these also.

``` r
perlbrew(version = "5.26.0", lib = "example")
#> [1] TRUE
Sys.getenv("PERL5LIB")
#> [1] "/tmp/RtmpTpLnsP/.perlbrew/libs/perl-5.26.0@example/lib/perl5"
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

`perlbrew_list` and `perlbrew_lib_create`
-----------------------------------------

`perlbrew_list` returns a listing of the available versions of perl and any `local::lib` libraries. If a version or library is in use, the `active` object attribute is also set.

``` r
perlbrew_list()
#> [1] "perl-5.26.0"         "perl-5.26.0@example"
#> attr(,"active")
#> [1] "perl-5.26.0@example"
```

A new library is created with `perlbrew_lib_create`.

``` r
perlbrew_lib_create(version = "5.26.0", lib = "foobar")
#> [1] TRUE
perlbrew_list()
#> [1] "perl-5.26.0"         "perl-5.26.0@example" "perl-5.26.0@foobar" 
#> attr(,"active")
#> [1] "perl-5.26.0@example"
```
