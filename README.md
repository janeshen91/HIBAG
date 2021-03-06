HLA Genotype Imputation with Attribute Bagging
======

Kernel Version: v1.3

![GPLv3](http://www.gnu.org/graphics/gplv3-88x31.png)
[GNU General Public License, GPLv3](http://www.gnu.org/copyleft/gpl.html)

[![Availability](http://www.bioconductor.org/shields/availability/release/HIBAG.svg)](http://www.bioconductor.org/packages/release/bioc/html/HIBAG.html)
[![Years-in-BioC](http://www.bioconductor.org/shields/years-in-bioc/HIBAG.svg)](http://www.bioconductor.org/packages/release/bioc/html/HIBAG.html)
[![Build Status](https://travis-ci.org/zhengxwen/HIBAG.png)](https://travis-ci.org/zhengxwen/HIBAG)
[![Build status](https://ci.appveyor.com/api/projects/status/v650qe8ap4bojxuf?svg=true)](https://ci.appveyor.com/project/zhengxwen/hibag)
[![codecov.io](https://codecov.io/github/zhengxwen/HIBAG/coverage.svg?branch=master)](https://codecov.io/github/zhengxwen/HIBAG?branch=master)


## Features

HIBAG is a state of the art software package for imputing HLA types using SNP data, and it relies on a training set of HLA and SNP genotypes. HIBAG can be used by researchers with published parameter estimates instead of requiring access to large training sample datasets. It combines the concepts of attribute bagging, an ensemble classifier method, with haplotype inference for SNPs and HLA types. Attribute bagging is a technique which improves the accuracy and stability of classifier ensembles using bootstrap aggregating and random variable selection.


## Bioconductor Package

Release Version: 1.12.0

[http://www.bioconductor.org/packages/release/bioc/html/HIBAG.html](http://www.bioconductor.org/packages/release/bioc/html/HIBAG.html)


### Changes in Bioconductor Version (since v1.3.0):

* optimize the calculation of hamming distance using SSE2 and hardware POPCNT instructions if available
* hardware POPCNT: 2.4x speedup for large-scale data, compared to the implementation in v1.2.4
* SSE2 popcount implementation without hardware POPCNT: 1.5x speedup for large-scale data, compared to the implementation in v1.2.4


## Package Author & Maintainer

Dr. Xiuwen Zheng ([zhengx@u.washington.edu](zhengx@u.washington.edu))


## Pre-fit Model Download

[http://zhengxwen.github.io/HIBAG/](http://zhengxwen.github.io/HIBAG/)

[http://zhengxwen.github.io/HIBAG/hibag_index.html](http://zhengxwen.github.io/HIBAG/hibag_index.html)

Platform-specific models: [http://zhengxwen.github.io/HIBAG/platforms.html](http://zhengxwen.github.io/HIBAG/platforms.html)

or [http://www.biostat.washington.edu/~bsweir/HIBAG/](http://www.biostat.washington.edu/~bsweir/HIBAG/)


## Citation

Zheng, X. *et al*. HIBAG-HLA genotype imputation with attribute bagging. *Pharmacogenomics Journal* 14, 192–200 (2014).
[http://dx.doi.org/10.1038/tpj.2013.18](http://dx.doi.org/10.1038/tpj.2013.18)


## Installation

* Bioconductor repository:
```R
source("http://bioconductor.org/biocLite.R")
biocLite("HIBAG")
```

* Development version from Github:
```R
library("devtools")
install_github("zhengxwen/HIBAG")
```
The `install_github()` approach requires that you build from source, i.e. `make` and compilers must be installed on your system -- see the [R FAQ](http://cran.r-project.org/faqs.html) for your operating system; you may also need to install dependencies manually.

* Install the package from the source code:
[download the source code](https://github.com/zhengxwen/HIBAG/tarball/master)
```sh
wget --no-check-certificate https://github.com/zhengxwen/HIBAG/tarball/master -O HIBAG_latest.tar.gz
## or ##
curl -L https://github.com/zhengxwen/HIBAG/tarball/master/ -o HIBAG_latest.tar.gz

## Install ##
R CMD INSTALL HIBAG_latest.tar.gz
```

* Install the package from the source code with the support of hardware POPCNT (requiring SSE4.2):
You have to customize the package compilation, see: [CRAN: Customizing-package-compilation](http://cran.r-project.org/doc/manuals/r-release/R-admin.html#Customizing-package-compilation)

Change `~/.R/Makevars` to, if your machine supports SSE4.2 or higher, assuming GNU Compilers (gcc/g++) or Clang compiler (clang++) are installed:
```sh
## for C code
CFLAGS=-g -O3 -march=native -mtune=native
## for C++ code
CXXFLAGS=-g -O3 -march=native -mtune=native
```
Or force to create hardware POPCNT code:
```sh
## for C code
CFLAGS=-g -O3 -mpopcnt
## for C++ code
CXXFLAGS=-g -O3 -mpopcnt
```

If the package compilation succeeds with hardware POPCNT instructions, you should see a welcome message after loading the package:
```
HIBAG (HLA Genotype Imputation with Attribute Bagging)
Kernel Version: v1.3
Supported by Streaming SIMD Extensions (SSE2 + hardware POPCNT)
```


## Archive

[https://github.com/zhengxwen/Archive/tree/master/HIBAG](https://github.com/zhengxwen/Archive/tree/master/HIBAG)
