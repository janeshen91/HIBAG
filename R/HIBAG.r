#######################################################################
#
# Package Name: HIBAG v1.1.0
#
# Description:
#   HIBAG -- HLA Genotype Imputation with Attribute Bagging
#
# Author: Xiuwen Zheng
# License: GPL-3
# Email: zhengx@u.washington.edu
#



#######################################################################
#
# the functions for SNP genotypes and haplotypes
#
#######################################################################

#
#
# hlaSNPGenoClass is a class of SNP genotypes
# list:
#     genotype -- a genotype matrix, ``# of SNPs'' X ``# of samples''
#     sample.id -- sample id
#     snp.id -- snp id
#     snp.position -- snp positions in basepair
#     snp.allele -- snp alleles, ``A allele/B allele''
#     assembly -- genome assembly, such like "hg19"
#
#
# hlaSNPHaploClass is a class of SNP haplotypes
# list:
#     haplotype -- a haplotype matrix, ``# of SNPs'' X ``2 x # of samples''
#     sample.id -- sample id
#     snp.id -- snp id
#     snp.position -- snp positions in basepair
#     snp.allele -- snp alleles, ``A allele/B allele''
#     assembly -- genome assembly, such like "hg19"
#
#


#######################################################################
# To create a "hlaSNPGenoClass" object (SNP genotype object)
#

hlaMakeSNPGeno <- function(genotype, sample.id, snp.id, snp.position,
	A.allele, B.allele, assembly=c("auto", "hg19", "hg18", "NCBI37", "NCBI36"))
{
	# check
	stopifnot(is.matrix(genotype))
	stopifnot(length(snp.id) == nrow(genotype))
	stopifnot(length(sample.id) == ncol(genotype))
	stopifnot(length(snp.id) == length(snp.position))
	stopifnot(length(snp.id) == length(A.allele))
	stopifnot(length(snp.id) == length(B.allele))
	stopifnot(is.character(A.allele))
	stopifnot(is.character(B.allele))

	assembly <- match.arg(assembly)
	if (assembly == "auto")
	{
		message("using the default genome assembly \"hg19\"")
		assembly <- "hg19"
	}

	rv <- list(genotype = genotype, sample.id = sample.id, snp.id = snp.id,
		snp.position = snp.position,
		snp.allele = paste(A.allele, B.allele, sep="/"),
		assembly = assembly)
	class(rv) <- "hlaSNPGenoClass"

    # valid SNP alleles
    flag <- !((A.allele %in% c("A", "T", "G", "C")) & (B.allele %in% c("A", "T", "G", "C")))
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with invalid alleles, and they have been removed.",
        	sum(flag)))
        rv <- hlaGenoSubset(rv, snp.sel=!flag)
    }
    # valid snp.id
    flag <- is.na(rv$snp.id)
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with missing SNP id, and they have been removed.",
        	sum(flag)))
        rv <- hlaGenoSubset(rv, snp.sel=!flag)
    }
    # valid snp.position
    flag <- is.na(rv$snp.position)
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with missing SNP positions, and they have been removed.",
        	sum(flag)))
        rv <- hlaGenoSubset(rv, snp.sel=!flag)
    }

	return(rv)
}


#######################################################################
# To create a "hlaSNPGenoClass" object (SNP genotype object)
#

hlaMakeSNPHaplo <- function(haplotype, sample.id, snp.id, snp.position,
	A.allele, B.allele, assembly=c("auto", "hg19", "hg18", "NCBI37", "NCBI36"))
{
	# check
	stopifnot(is.matrix(haplotype))
	stopifnot(length(snp.id) == nrow(haplotype))
	stopifnot(2*length(sample.id) == ncol(haplotype))
	stopifnot(length(snp.id) == length(snp.position))
	stopifnot(length(snp.id) == length(A.allele))
	stopifnot(length(snp.id) == length(B.allele))
	stopifnot(is.character(A.allele))
	stopifnot(is.character(B.allele))

	assembly <- match.arg(assembly)
	if (assembly == "auto")
	{
		message("using the default genome assembly \"hg19\"")
		assembly <- "hg19"
	}

	rv <- list(haplotype = haplotype, sample.id = sample.id, snp.id = snp.id,
		snp.position = snp.position,
		snp.allele = paste(A.allele, B.allele, sep="/"),
		assembly = assembly)
	class(rv) <- "hlaSNPHaploClass"

    # valid SNP alleles
    flag <- !((A.allele %in% c("A", "T", "G", "C")) & (B.allele %in% c("A", "T", "G", "C")))
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with invalid alleles, and they have been removed.",
        	sum(flag)))
        rv <- hlaHaploSubset(rv, snp.sel=!flag)
    }
    # valid snp.id
    flag <- is.na(rv$snp.id)
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with missing SNP id, and they have been removed.",
        	sum(flag)))
        rv <- hlaHaploSubset(rv, snp.sel=!flag)
    }
    # valid snp.position
    flag <- is.na(rv$snp.position)
    if (any(flag))
    {
        warning(sprintf("There are %d SNPs with missing SNP positions, and they have been removed.",
        	sum(flag)))
        rv <- hlaHaploSubset(rv, snp.sel=!flag)
    }

    return(rv)
}


#######################################################################
# To select a subset of SNP genotypes
#

hlaGenoSubset <- function(genoobj, samp.sel=NULL, snp.sel=NULL)
{
	# check
	stopifnot(inherits(genoobj, "hlaSNPGenoClass"))
	stopifnot(is.null(samp.sel) | is.logical(samp.sel) | is.integer(samp.sel))
	if (is.logical(samp.sel))
		stopifnot(length(samp.sel) == length(genoobj$sample.id))
	stopifnot(is.null(snp.sel) | is.logical(snp.sel) | is.integer(snp.sel))
	if (is.logical(snp.sel))
		stopifnot(length(snp.sel) == length(genoobj$snp.id))
	if (is.integer(samp.sel))
	{
		stopifnot(!any(is.na(samp.sel)))
		stopifnot(length(unique(samp.sel)) == length(samp.sel))
	}
	if (is.integer(snp.sel))
	{
		stopifnot(!any(is.na(snp.sel)))
		stopifnot(length(unique(snp.sel)) == length(snp.sel))
	}

	# subset
	if (is.null(samp.sel))
		samp.sel <- rep(TRUE, length(genoobj$sample.id))
	if (is.null(snp.sel))
		snp.sel <- rep(TRUE, length(genoobj$snp.id))
	rv <- list(genotype = genoobj$genotype[snp.sel, samp.sel],
		sample.id = genoobj$sample.id[samp.sel],
		snp.id = genoobj$snp.id[snp.sel],
		snp.position = genoobj$snp.position[snp.sel],
		snp.allele = genoobj$snp.allele[snp.sel],
		assembly = genoobj$assembly
	)
	class(rv) <- "hlaSNPGenoClass"
	return(rv)
}


#######################################################################
# To select a subset of SNP haplotypes
#

hlaHaploSubset <- function(haploobj, samp.sel=NULL, snp.sel=NULL)
{
	# check
	stopifnot(inherits(haploobj, "hlaSNPHaploClass"))
	stopifnot(is.null(samp.sel) | is.logical(samp.sel) | is.integer(samp.sel))
	if (is.logical(samp.sel))
		stopifnot(length(samp.sel) == length(haploobj$sample.id))
	stopifnot(is.null(snp.sel) | is.logical(snp.sel) | is.integer(snp.sel))
	if (is.logical(snp.sel))
		stopifnot(length(snp.sel) == length(haploobj$snp.id))
	if (is.integer(samp.sel))
		stopifnot(length(unique(samp.sel)) == length(samp.sel))
	if (is.integer(snp.sel))
		stopifnot(length(unique(snp.sel)) == length(snp.sel))

	# subset
	if (is.null(samp.sel))
		samp.sel <- rep(TRUE, length(haploobj$sample.id))
	if (is.numeric(samp.sel))
	{
		v <- samp.sel
		samp.sel <- rep(FALSE, length(haploobj$sample.id))
		samp.sel[v] <- TRUE
	}
	samp.sel <- rep(samp.sel, each=2)
	if (is.null(snp.sel))
		snp.sel <- rep(TRUE, length(haploobj$snp.id))

	rv <- list(haplotype = haploobj$haplotype[snp.sel, samp.sel],
		sample.id = haploobj$sample.id[samp.sel],
		snp.id = haploobj$snp.id[snp.sel],
		snp.position = haploobj$snp.position[snp.sel],
		snp.allele = haploobj$snp.allele[snp.sel],
		assembly = haploobj$genoobj
	)
	class(rv) <- "hlaSNPHaploClass"
	return(rv)
}


#######################################################################
# To select a subset of SNP genotypes
#

hlaHaplo2Geno <- function(hapobj)
{
	stopifnot(inherits(hapobj, "hlaSNPHaploClass"))
	n <- dim(hapobj$haplotype)[2]
	rv <- list(
		genotype = hapobj$haplotype[, seq(1,n,2)] + hapobj$haplotype[, seq(2,n,2)],
		sample.id = hapobj$sample.id,
		snp.id = hapobj$snp.id,
		snp.position = hapobj$snp.position,
		snp.allele = hapobj$snp.allele,
		assembly = hapobj$genoobj
	)
	class(rv) <- "hlaSNPGenoClass"
	return(rv)
}


#######################################################################
# To get the overlapping SNPs between target and template with
#   corrected strand.
#

hlaGenoSwitchStrand <- function(target, template, match.pos=TRUE, verbose=TRUE)
{
	# check
	stopifnot(inherits(target, "hlaSNPGenoClass") | inherits(target, "hlaSNPHaploClass"))
	stopifnot(inherits(template, "hlaSNPGenoClass") |
		inherits(template, "hlaSNPHaploClass") | inherits(template, "hlaAttrBagClass"))
	stopifnot(is.logical(match.pos))
	stopifnot(is.logical(verbose))

	# initialize
	s1 <- hlaSNPID(template, match.pos)
	s2 <- hlaSNPID(target, match.pos)
	s <- intersect(s1, s2)
	if (length(s) <= 0) stop("There is no common SNP.")
	I1 <- match(s, s1); I2 <- match(s, s2)

	# compute allele frequencies
	if (inherits(template, "hlaSNPGenoClass"))
	{
		template.afreq <- rowMeans(template$genotype, na.rm=TRUE) * 0.5
	} else if (inherits(template, "hlaSNPHaploClass")) {
		template.afreq <- rowMeans(template$haplotype, na.rm=TRUE)
	} else {
		template.afreq <- template$snp.allele.freq
	}
	if (inherits(target, "hlaSNPGenoClass"))
	{
		target.afreq <- rowMeans(target$genotype, na.rm=TRUE) * 0.5
	} else {
		target.afreq <- rowMeans(target$haplotype, na.rm=TRUE)
	}

	# call
	gz <- .C("HIBAG_AlleleStrand", template$snp.allele, template.afreq, I1,
		target$snp.allele, target.afreq, I2, length(s), out=logical(length(s)),
		out.n.ambiguity=integer(1), out.n.mismatching=integer(1),
		err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
	if (gz$err != 0) stop(hlaErrMsg())

	if (verbose)
	{
		# switched allele pairs
		x <- sum(gz$out)
		if (x > 0)
		{
			if (x > 1)
			{
				a <- "are"; s <- "s"
			} else {
				a <- "is"; s <- ""
			}
			cat(sprintf(
				"There %s %d variant%s in total whose allelic strand order%s %s switched.\n",
				a, x, s, s, a))
		} else {
			cat("No allelic strand orders are switched.\n")
		}

		# the number of ambiguity
		if (gz$out.n.ambiguity > 0)
		{
			if (gz$out.n.ambiguity > 1)
			{
				a <- "are"; s <- "s"
			} else {
				a <- "is"; s <- ""
			}
			cat(sprintf(
				"Due to stand ambiguity (such like C/G), the allelic strand order%s of %d variant%s %s determined by comparing allele frequencies.\n",
				s, gz$out.n.ambiguity, s, a))
		}

		# the number of mismatching
		if (gz$out.n.mismatching > 0)
		{
			if (gz$out.n.mismatching > 1)
			{
				a <- "are"; s <- "s"
			} else {
				a <- "is"; s <- ""
			}
			cat(sprintf(
				"Due to mismatching alleles, the allelic strand order%s of %d variant%s %s determined by comparing allele frequencies.\n",
				s, gz$out.n.mismatching, s, a))
		}
	}

	# result
	if (inherits(target, "hlaSNPGenoClass"))
	{
		geno <- target$genotype[I2, ]
		if (is.vector(geno))
			geno <- matrix(geno, ncol=1)
		for (i in which(gz$out)) geno[i, ] <- 2 - geno[i, ]
		rv <- list(genotype = geno)
		rv$sample.id <- target$sample.id
		rv$snp.id <- target$snp.id[I2]
		rv$snp.position <- target$snp.position[I2]
		rv$snp.allele <- template$snp.allele[I1]
		rv$assembly <- template$assembly
		class(rv) <- "hlaSNPGenoClass"

	} else {
		haplo <- target$haplotype[I2, ]
		if (is.vector(haplo))
			haplo <- matrix(haplo, ncol=1)
		for (i in which(gz$out)) haplo[i, ] <- 1 - haplo[i, ]
		rv <- list(haplotype = haplo)
		rv$sample.id <- target$sample.id
		rv$snp.id <- target$snp.id[I2]
		rv$snp.position <- target$snp.position[I2]
		rv$snp.allele <- template$snp.allele[I1]
		rv$assembly <- template$assembly
		class(rv) <- "hlaSNPHaploClass"
	}

	return(rv)
}


#######################################################################
# To get the information of SNP ID and position
#

hlaSNPID <- function(obj, with.pos=TRUE)
{
	stopifnot(inherits(obj, "hlaSNPGenoClass") | inherits(obj, "hlaSNPHaploClass") |
		inherits(obj, "hlaAttrBagClass") | inherits(obj, "hlaAttrBagObj"))
	if (with.pos)
	{
		paste(obj$snp.id, obj$snp.position, sep="-")
	} else {
		obj$snp.id
	}
}


#######################################################################
# To combine two SNP genotype dataset
#

hlaGenoCombine <- function(geno1, geno2, match.pos=TRUE, allele.check=TRUE)
{
    # check
    stopifnot(inherits(geno1, "hlaSNPGenoClass"))
    stopifnot(inherits(geno2, "hlaSNPGenoClass"))
	stopifnot(is.logical(match.pos))
	stopifnot(is.logical(allele.check))

	if (allele.check)
	{
	    tmp2 <- hlaGenoSwitchStrand(geno2, geno1, match.pos)
    	tmp1 <- hlaGenoSubset(geno1, snp.sel=
    		match(hlaSNPID(tmp2, match.pos), hlaSNPID(geno1, match.pos)))
    } else {
		s1 <- hlaSNPID(geno1, match.pos)
		s2 <- hlaSNPID(geno2, match.pos)
		set <- unique(intersect(s1, s2))
		tmp1 <- hlaGenoSubset(geno1, snp.sel=match(set, s1))
		tmp2 <- hlaGenoSubset(geno2, snp.sel=match(set, s2))
    }

    rv <- list(genotype = cbind(tmp1$genotype, tmp2$genotype),
        sample.id = c(tmp1$sample.id, tmp2$sample.id),
        snp.id = tmp1$snp.id, snp.position = tmp1$snp.position,
        snp.allele = tmp1$snp.allele,
        assembly = tmp1$assembly)
    class(rv) <- "hlaSNPGenoClass"

    return(rv)
}


#######################################################################
# Convert to PLINK PED format
#

hlaGeno2PED <- function(geno, out.fn)
{
	# check
	stopifnot(inherits(geno, "hlaSNPGenoClass"))
	stopifnot(is.character(out.fn))

	# MAP file
	rv <- data.frame(chr=rep(6, length(geno$snp.id)), rs=geno$snp.id,
		morgan=rep(0, length(geno$snp.id)), bp=geno$snp.position, stringsAsFactors=FALSE)
	write.table(rv, file=paste(out.fn, ".map", sep=""),
		row.names=FALSE, col.names=FALSE, quote=FALSE)

	# PED file
	n <- length(geno$sample.id)
	m <- matrix("", nrow=n, ncol=2*length(geno$snp.id))
	for (i in 1:length(geno$snp.id))
	{
		allele <- unlist(strsplit(geno$snp.allele[i], "/"))
		g <- geno$genotype[i, ] + 1
		m[, 2*(i-1)+1] <- allele[c(2, 1, 1)[g]]
		m[, 2*(i-1)+2] <- allele[c(2, 2, 1)[g]]
	}
	rv <- cbind(Family=geno$sample.id, Ind=geno$sample.id,
		Paternal=rep(0, n), Maternal=rep(0, n), Sex=rep(0, n), Pheno=rep(-9, n),
		m)
	write.table(rv, file=paste(out.fn, ".ped", sep=""),
		row.names=FALSE, col.names=FALSE, quote=FALSE)

	# return
	return(invisible(NULL))
}


#######################################################################
# Convert from PLINK BED format
#

hlaBED2Geno <- function(bed.fn, fam.fn, bim.fn, rm.invalid.allele=FALSE,
	import.chr="xMHC", assembly=c("auto", "hg19", "hg18", "NCBI37", "NCBI36"),
	verbose=TRUE)
{
	# check
	stopifnot(is.character(bed.fn) & (length(bed.fn)==1))
	stopifnot(is.character(fam.fn) & (length(fam.fn)==1))
	stopifnot(is.character(bim.fn) & (length(bim.fn)==1))
	stopifnot(is.character(import.chr))
	stopifnot(is.logical(rm.invalid.allele) & (length(rm.invalid.allele)==1))
	stopifnot(is.logical(verbose) & (length(verbose)==1))

	assembly <- match.arg(assembly)
	if (assembly == "auto")
	{
		message("using the default genome assembly \"hg19\"")
		assembly <- "hg19"
	}

	# detect bed.fn
	bed <- .C("HIBAG_BEDFlag", bed.fn, snporder=integer(1), err=integer(1),
		NAOK=TRUE, PACKAGE="HIBAG")
	if (bed$err != 0) stop(hlaErrMsg())
	if (verbose)
	{
		cat("Open \"", bed.fn, sep="")
		if (bed$snporder == 0)
			cat("\" in the individual-major mode.\n")
		else
			cat("\" in the SNP-major mode.\n")
	}

	# read fam.fn
	famD <- read.table(fam.fn, header=FALSE, stringsAsFactors=FALSE)
	names(famD) <- c("FamilyID", "InvID", "PatID", "MatID", "Sex", "Pheno")
	if (length(unique(famD$InvID)) == dim(famD)[1])
	{
		sample.id <- famD$InvID
	} else {
		sample.id <- paste(famD$FamilyID, famD$InvID, sep="-")
		if (length(unique(sample.id)) != dim(famD)[1])
			stop("IDs in PLINK bed are not unique!")
	}
	if (verbose)
		cat("Open \"", fam.fn, "\".\n", sep="")

	# read bim.fn
	bimD <- read.table(bim.fn, header=FALSE, stringsAsFactors=FALSE)
	names(bimD) <- c("chr", "snp.id", "map", "pos", "allele1", "allele2")

	# chromosome
	chr <- bimD$chr; chr[is.na(chr)] <- ""
	# position
	snp.pos <- bimD$pos
	snp.pos[!is.finite(snp.pos)] <- 0
	# snp.id
	snp.id <- bimD$snp.id
	# snp allele
	snp.allele <- paste(bimD$allele1, bimD$allele2, sep="/")
	if (verbose)
		cat("Open \"", bim.fn, "\".\n", sep="")

	# SNP selection
	if (length(import.chr) == 1)
	{
		if (import.chr == "xMHC")
		{
			if (assembly %in% c("hg18", "NCBI36"))
			{
				snp.flag <- (chr==6) & (25759242<=snp.pos) & (snp.pos<=33534827)
			} else if (assembly %in% c("hg19", "NCBI37"))
			{
				snp.flag <- (chr==6) & (25651242<=snp.pos) & (snp.pos<=33544122)
			} else {
				stop("Invalid genome assembly.")
			}
			n.snp <- as.integer(sum(snp.flag))
			if (verbose)
			{
				cat(sprintf("Import %d SNPs within the xMHC region on chromosome 6.\n",
					n.snp))
			}
			import.chr <- NULL
		} else if (import.chr == "")
		{
			n.snp <- length(snp.id)
			snp.flag <- rep(TRUE, n.snp)
			if (verbose)
				cat(sprintf("Import %d SNPs.\n", n.snp))
			import.chr <- NULL
		}
	}
	if (!is.null(import.chr))
	{
		snp.flag <- (chr %in% import.chr) & (snp.pos>0)
		n.snp <- as.integer(sum(snp.flag))
		if (verbose)
		{
			cat(sprintf("Import %d SNPs from chromosome %s.\n", n.snp,
				paste(import.chr, collapse=",")))
		}
	}
	if (n.snp <= 0) stop("There is no SNP imported.")

	# call the C function
	rv <- .C("HIBAG_ConvBED", bed.fn, length(sample.id), length(snp.id), n.snp,
		(bed$snporder==0), snp.flag, verbose,
		geno = matrix(as.integer(0), nrow=n.snp, ncol=length(sample.id)),
		err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())

	# result
	v <- list(genotype = rv$geno, sample.id = sample.id, snp.id = snp.id[snp.flag],
		snp.position = snp.pos[snp.flag], snp.allele = snp.allele[snp.flag],
		assembly = assembly)
	class(v) <- "hlaSNPGenoClass"

	# remove invalid snps
	if (rm.invalid.allele)
	{
		snp.allele <- v$snp.allele
		snp.allele[is.na(snp.allele)] <- "?/?"
		flag <- sapply(strsplit(snp.allele, "/"),
			function(x)
			{
				if (length(x) == 2)
				{
					all(x %in% c("A", "G", "C", "T"))
				} else {
					FALSE
				}
			}
		)
		if (any(!flag) & verbose)
			cat(sprintf("%d SNPs with invalid alleles have been removed.\n", sum(!flag)))

		# get a subset
		v <- hlaGenoSubset(v, snp.sel=flag)
	}

	return(v)
}






#######################################################################
# Summarize a "hlaSNPGenoClass" object
#

summary.hlaSNPGenoClass <- function(object, show=TRUE, ...)
{
	# check
	stopifnot(inherits(object, "hlaSNPGenoClass"))
	geno <- object

	fn <- function(x)
	{
		sprintf("min: %g, max: %g, mean: %g, median: %g, sd: %g",
			min(x, na.rm=TRUE), max(x, na.rm=TRUE),
			mean(x, na.rm=TRUE), median(x, na.rm=TRUE), sd(x, na.rm=TRUE))
	}

	rv <- list(mr.snp = hlaGenoMRate(geno), mr.samp = hlaGenoMRate_Samp(geno),
		maf = hlaGenoMFreq(geno),
		allele = table(geno$snp.allele))

	if (show)
	{
		cat("SNP genotypes: \n")
		cat(sprintf("\t%d samples X %d SNPs\n",
			length(geno$sample.id), length(geno$snp.id)))
		cat(sprintf("\tSNPs range from %dbp to %dbp",
			min(geno$snp.position, na.rm=TRUE), max(geno$snp.position, na.rm=TRUE)))
		if (!is.null(geno$assembly))
			cat(" on ", geno$assembly, "\n", sep="")
		else
			cat("\n")

		# missing rate for SNP
		cat(sprintf("Missing rate per SNP:\n\t%s\n", fn(rv$mr.snp)))
		# missing rate for sample
		cat(sprintf("Missing rate per sample:\n\t%s\n", fn(rv$mr.samp)))

		# minor allele frequency
		cat(sprintf("Minor allele frequency:\n\t%s\n", fn(rv$maf)))

		# allele information
		cat("Allele information:")
		print(rv$allele)
	}

	# return
	return(invisible(rv))
}


#######################################################################
# Summarize a "hlaSNPHaploClass" object
#

summary.hlaSNPHaploClass <- function(object, show=TRUE, ...)
{
	# check
	stopifnot(inherits(object, "hlaSNPHaploClass"))
	haplo <- object

	fn <- function(x)
	{
		sprintf("min: %g, max: %g, mean: %g, median: %g, sd: %g",
			min(x, na.rm=TRUE), max(x, na.rm=TRUE),
			mean(x, na.rm=TRUE), median(x, na.rm=TRUE), sd(x, na.rm=TRUE))
	}

	rv <- list(mr.snp = hlaGenoMRate(haplo), mr.samp = hlaGenoMRate_Samp(haplo),
		maf = hlaGenoMFreq(haplo),
		allele = table(haplo$snp.allele))

	if (show)
	{
		cat("SNP Haplotypes: \n")
		cat(sprintf("\t%d samples X %d SNPs\n",
			length(haplo$sample.id), length(haplo$snp.id)))
		cat(sprintf("\tSNPs range from %dbp to %dbp",
			min(haplo$snp.position, na.rm=TRUE), max(haplo$snp.position, na.rm=TRUE)))
		if (!is.null(haplo$assembly))
			cat(" on ", haplo$assembly, "\n", sep="")
		else
			cat("\n")

		# missing rate for SNP
		cat(sprintf("Missing rate per SNP:\n\t%s\n", fn(rv$mr.snp)))
		# missing rate for sample
		cat(sprintf("Missing rate per sample:\n\t%s\n", fn(rv$mr.samp)))

		# minor allele frequency
		cat(sprintf("Minor allele frequency:\n\t%s\n", fn(rv$maf)))

		# allele information
		cat("Allele information:")
		print(rv$allele)
	}

	# return
	return(invisible(rv))
}




#######################################################################
#
# the function list for genotypes and haplotypes
#
#######################################################################

#######################################################################
# To the allele frequencies from genotypes or haplotypes
#

hlaGenoAFreq <- function(obj)
{
	# check
	stopifnot(inherits(obj, "hlaSNPGenoClass") | inherits(obj, "hlaSNPHaploClass"))
    if (inherits(obj, "hlaSNPGenoClass"))
    {
        rowMeans(obj$genotype, na.rm=TRUE) * 0.5
    } else {
        rowMeans(obj$haplotype, na.rm=TRUE)
    }
}


#######################################################################
# To the minor allele frequencies from genotypes or haplotypes
#

hlaGenoMFreq <- function(obj)
{
	# check
	stopifnot(inherits(obj, "hlaSNPGenoClass") | inherits(obj, "hlaSNPHaploClass"))
    if (inherits(obj, "hlaSNPGenoClass"))
    {
        F <- rowMeans(obj$genotype, na.rm=TRUE) * 0.5
    } else {
        F <- rowMeans(obj$haplotype, na.rm=TRUE)
    }
    pmin(F, 1-F)
}


#######################################################################
# To the missing rates from genotypes or haplotypes per SNP
#

hlaGenoMRate <- function(obj)
{
	# check
	stopifnot(inherits(obj, "hlaSNPGenoClass") | inherits(obj, "hlaSNPHaploClass"))
    if (inherits(obj, "hlaSNPGenoClass"))
    {
		rowMeans(is.na(obj$genotype))
	} else {
		rowMeans(is.na(obj$haplotype))
	}
}


#######################################################################
# To the missing rates from genotypes or haplotypes per sample
#

hlaGenoMRate_Samp <- function(obj)
{
	# check
	stopifnot(inherits(obj, "hlaSNPGenoClass") | inherits(obj, "hlaSNPHaploClass"))
    if (inherits(obj, "hlaSNPGenoClass"))
    {
        colMeans(is.na(obj$genotype))
    } else {
        F <- colMeans(is.na(obj$haplotype))
        F[seq(1, length(F), 2)] + F[seq(2, length(F), 2)]
    }
}






#######################################################################
#
# the function list for HLA types
#
#######################################################################


#######################################################################
# To get the starting and ending positions in basepair for HLA loci
#

hlaLociInfo <- function(assembly=c("auto", "hg19", "hg18", "NCBI37", "NCBI36"))
{
	# check
	assembly <- match.arg(assembly)
	if (assembly == "auto")
	{
		message("using the default genome assembly \"hg19\"")
		assembly <- "hg19"
	}

	# the name of HLA genes
	ID <- c("A", "B", "C", "DRB1", "DRB5", "DQA1", "DQB1", "DPB1", "any")

	if (assembly %in% c("hg18", "NCBI36"))
	{
		# starting position
		pos.HLA.start <- as.integer(c(30018310, 31429628, 31344508, 32654527, 32593129,
			32713161, 32735635, 33151738, NA))

		# ending position
		pos.HLA.end <- as.integer(c(30021633, 31432914, 31347834, 32665559, 32605984,
			32719407, 32742444, 33162954, NA))
	} else if (assembly %in% c("hg19", "NCBI37"))
	{
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-A.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-B.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-C.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-DRB1.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-DQA1.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-DQB1.html
		# http://atlasgeneticsoncology.org/Genes/GC_HLA-DPB1.html

		# starting position
		pos.HLA.start <- as.integer(c(29910247, 31321649, 31236526, 32546547,
			32485154, 32605183, 32627241, 33043703, NA))

		# ending position
		pos.HLA.end <- as.integer(  c(29913661, 31324989, 31239913, 32557613,
			32498006, 32611429, 32634466, 33057473, NA))
	} else {
		stop("Invalid genome assembly!")
	}

	# length in basepair
	length.HLA <- (pos.HLA.end - pos.HLA.start)

	# the names of HLA genes
	names(pos.HLA.start) <- ID
	names(pos.HLA.end) <- ID
	names(length.HLA) <- ID

	# return
	return(list(loci = ID,
		pos.HLA.start = pos.HLA.start, pos.HLA.end = pos.HLA.end,
		length.HLA = length.HLA,
		assembly = assembly))
}


#######################################################################
# Limit the resolution of HLA alleles
#

hlaAlleleDigit <- function(obj, max.resolution="4-digit")
{
	# check
	stopifnot(inherits(obj, "hlaAlleleClass") | is.character(obj))
	if (is.character(obj))
		stopifnot(is.vector(obj))
	stopifnot(max.resolution %in% c("2-digit", "4-digit", "6-digit", "8-digit",
		"allele", "protein", "2", "4", "6", "8", "full", ""))

	if (!(max.resolution %in% c("full", "")))
	{
		if (is.character(obj))
		{
			len <- c(1, 2, 3, 4, 1, 2, 1, 2, 3, 4)
			names(len) <- c("2-digit", "4-digit", "6-digit", "8-digit",
				"allele", "protein", "2", "4", "6", "8")
			maxlen <- len[[as.character(max.resolution)]]

			obj <- sapply(strsplit(obj, ":"), FUN =
					function(s, idx) {
						if (any(is.na(s)))
						{
							NA
						} else {
							if (length(idx) < length(s)) s <- s[idx]
							paste(s, collapse=":")
						}
					},
				idx = 1:maxlen)
		} else {
			rv <- list(locus = obj$locus,
				pos.start = obj$pos.start, pos.end = obj$pos.end,
				value = data.frame(sample.id = obj$value$sample.id,
					allele1 = hlaAlleleDigit(obj$value$allele1, max.resolution),
					allele2 = hlaAlleleDigit(obj$value$allele2, max.resolution),
					stringsAsFactors=FALSE),
				assembly = obj$assembly
			)
			if ("prob" %in% names(obj$value))
				rv$value$prob <- obj$value$prob
			class(rv) <- "hlaAlleleClass"
			obj <- rv
		}
	}

	return(obj)
}


#######################################################################
# Get unique HLA alleles
#

hlaUniqueAllele <- function(hla)
{
	# check
	stopifnot(is.character(hla) | inherits(hla, "hlaAlleleClass"))

	if (is.character(hla))
	{
		hla <- hla[!is.na(hla)]
		hla <- unique(hla)
		rv <- .C("HIBAG_SortAlleleStr", length(hla), hla, out = character(length(hla)),
			err = integer(1), NAOK = TRUE, PACKAGE = "HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())
		rv$out
	} else {
		hlaUniqueAllele(as.character(c(hla$value$allele1, hla$value$allele2)))
	}
}


#######################################################################
# To make a class of HLA alleles
#

hlaAllele <- function(sample.id, H1, H2, max.resolution="", locus="any",
	assembly=c("auto", "hg19", "hg18", "NCBI37", "NCBI36"),
	locus.pos.start=NA, locus.pos.end=NA, prob=NULL, na.rm=TRUE)
{
	# check
	stopifnot(is.vector(sample.id))
	stopifnot(is.vector(H1) & is.character(H1))
	stopifnot(is.vector(H2) & is.character(H2))
	stopifnot(length(sample.id) == length(H1))
	stopifnot(length(sample.id) == length(H2))
	stopifnot(max.resolution %in% c("2-digit", "4-digit", "6-digit", "8-digit",
		"allele", "protein", "2", "4", "6", "8", "full", ""))

	HLAinfo <- hlaLociInfo(assembly)
	if (!is.null(prob))
		stopifnot(length(sample.id) == length(prob))

	# build
	H1[H1 == ""] <- NA
	H1 <- hlaAlleleDigit(H1, max.resolution)
	H2[H2 == ""] <- NA
	H2 <- hlaAlleleDigit(H2, max.resolution)

	if (locus %in% names(HLAinfo$pos.HLA.start))
	{
		if (!is.finite(locus.pos.start))
			locus.pos.start <- HLAinfo$pos.HLA.start[[locus]]
		if (!is.finite(locus.pos.end))
			locus.pos.end <- HLAinfo$pos.HLA.end[[locus]]
	}

	# remove missing values
	if (na.rm)
		flag <- (!is.na(H1)) & (!is.na(H2))
	else
		flag <- rep(TRUE, length(sample.id))

	# result
	rv <- list(locus = locus,
		pos.start = locus.pos.start, pos.end = locus.pos.end,
		value = data.frame(sample.id = sample.id[flag],
			allele1 = H1[flag], allele2 = H2[flag], stringsAsFactors=FALSE),
		assembly = HLAinfo$assembly
	)
	if (!is.null(prob))
		rv$value$prob <- prob[flag]
	class(rv) <- "hlaAlleleClass"
	return(rv)
}


#######################################################################
# To make a class of HLA alleles
#
# INPUT:
#   sample.id -- a vector of sample id
#   samp.sel -- a logical vector specifying selected samples
#

hlaAlleleSubset <- function(hla, samp.sel=NULL)
{
	# check
	stopifnot(inherits(hla, "hlaAlleleClass"))
	stopifnot(is.null(samp.sel) | is.logical(samp.sel) | is.integer(samp.sel))
	if (is.logical(samp.sel))
		stopifnot(length(samp.sel) == dim(hla$value)[1])
	if (is.integer(samp.sel))
		stopifnot(length(unique(samp.sel)) == length(samp.sel))

	# result
	if (is.null(samp.sel))
		samp.sel <- rep(TRUE, dim(hla$value)[1])
	rv <- list(locus = hla$locus,
		pos.start = hla$pos.start, pos.end = hla$pos.end,
		value = hla$value[samp.sel, ],
		assembly = hla$assembly
	)
	class(rv) <- "hlaAlleleClass"
	return(rv)
}


#######################################################################
# To combine two classes of HLA alleles
#
# INPUT:
#   H1 -- the first "hlaHLAAlleleClass" object
#   H2 -- the second "hlaHLAAlleleClass" object
#

hlaCombineAllele <- function(H1, H2)
{
	# check
	stopifnot(inherits(H1, "hlaAlleleClass"))
	stopifnot(inherits(H2, "hlaAlleleClass"))
	stopifnot(length(intersect(H1$sample.id, H2$sample.id)) == 0)
	stopifnot(H1$locus == H2$locus)
	stopifnot(H1$pos.start == H2$pos.start)
	stopifnot(H1$pos.end == H2$pos.end)

	id <- c("sample.id", "allele1", "allele2")

	# result
	rv <- list(locus = H1$locus,
		pos.start = H1$pos.start, pos.end = H1$pos.end,
		value = rbind(H1$value[, id], H2$value[, id]),
		assembly = H1$assembly
	)
	if (!is.null(H1$value$prob) & !is.null(H2$value$prob))
	{
		rv$value$prob <- c(H1$value$prob, H2$value$prob)
	}
	class(rv) <- "hlaAlleleClass"
	return(rv)
}


#######################################################################
# To compare HLA alleles
#

hlaCompareAllele <- function(TrueHLA, PredHLA, allele.limit=NULL,
	call.threshold=NaN, max.resolution="", output.individual=FALSE, verbose=TRUE)
{
	# check
	stopifnot(inherits(TrueHLA, "hlaAlleleClass"))
	stopifnot(inherits(PredHLA, "hlaAlleleClass"))
	stopifnot(is.null(allele.limit) | is.vector(allele.limit) |
		inherits(allele.limit, "hlaAttrBagClass") |
		inherits(allele.limit, "hlaAttrBagObj"))
	stopifnot(max.resolution %in% c("2-digit", "4-digit", "6-digit", "8-digit",
		"allele", "protein", "2", "4", "6", "8", "full", ""))
	stopifnot(is.logical(output.individual))
	stopifnot(is.logical(verbose))

	# get the common samples
	samp <- intersect(TrueHLA$value$sample.id, PredHLA$value$sample.id)
	if ((length(samp) != length(TrueHLA$value$sample.id)) |
		(length(samp) != length(PredHLA$value$sample.id)))
	{
		if (verbose)
		{
			message("Calling 'hlaCompareAllele': there are ", length(samp),
				" individuals in common.\n")
		}
	}
	# True HLA
	flag <- match(samp, TrueHLA$value$sample.id)
	if (length(samp) != length(TrueHLA$value$sample.id))
	{
		TrueHLA <- hlaAlleleSubset(TrueHLA, flag)
	} else {
		if (!all(flag == 1:length(TrueHLA$value$sample.id)))
			TrueHLA <- hlaAlleleSubset(TrueHLA, flag)
	}
	# Predicted HLA
	flag <- match(samp, PredHLA$value$sample.id)
	if (length(samp) != length(PredHLA$value$sample.id))
	{
		PredHLA <- hlaAlleleSubset(PredHLA, flag)
	} else {
		if (!all(flag == 1:length(PredHLA$value$sample.id)))
			PredHLA <- hlaAlleleSubset(PredHLA, flag)
	}

	# init
	flag <- !is.na(TrueHLA$value$allele1) & !is.na(TrueHLA$value$allele2) &
		!is.na(PredHLA$value$allele1) & !is.na(PredHLA$value$allele2)
	ts1 <- TrueHLA$value$allele1[flag]; ts2 <- TrueHLA$value$allele2[flag]
	ps1 <- PredHLA$value$allele1[flag]; ps2 <- PredHLA$value$allele2[flag]
	samp.id <- TrueHLA$value$sample.id[flag]

	# call threshold
	if (is.finite(call.threshold))
	{
		prob <- PredHLA$value$prob
		if (!is.null(prob)) prob <- prob[flag]
	} else {
		prob <- NULL
	}

	# allele limitation
	if (!is.null(allele.limit))
	{
		if (inherits(allele.limit, "hlaAttrBagClass") | inherits(allele.limit, "hlaAttrBagObj"))
		{
			allele <- hlaUniqueAllele(allele.limit$hla.allele)
			TrainFreq <- allele.limit$hla.freq
		} else {
			allele <- hlaUniqueAllele(as.character(allele.limit))
			TrainFreq <- NULL
		}
	} else {
		allele <- hlaUniqueAllele(c(ts1, ts2))
		TrainFreq <- NULL
	}

	# max resolution
	if (!(max.resolution %in% c("full", "")))
	{
		ts1 <- hlaAlleleDigit(ts1, max.resolution)
		ts2 <- hlaAlleleDigit(ts2, max.resolution)
		ps1 <- hlaAlleleDigit(ps1, max.resolution)
		ps2 <- hlaAlleleDigit(ps2, max.resolution)
		tmp <- hlaAlleleDigit(allele, max.resolution)
		allele <- hlaUniqueAllele(tmp)
		if ((length(tmp) != length(allele)) & !is.null(TrainFreq))
		{
			x <- rep(0, length(allele))
			for (i in 1:length(allele))
				x[i] <- sum(TrainFreq[tmp == allele[i]])
			TrainFreq <- x
		}
	}

	# allele filter
	flag <- (ts1 %in% allele) & (ts2 %in% allele)
	ts1 <- ts1[flag]; ts2 <- ts2[flag]
	ps1 <- ps1[flag]; ps2 <- ps2[flag]
	samp.id <- samp.id[flag]
	if (!is.null(prob)) prob <- prob[flag]

	# init ...
	cnt.ind <- 0; cnt.haplo <- 0; cnt.call <- 0
	n <- length(ts1)
	m <- length(allele)

	TrueNum <- rep(0, m); names(TrueNum) <- allele
	TrueNumAll <- rep(0, m); names(TrueNumAll) <- allele
	PredNum <- rep(0, m+1); names(PredNum) <- c(allele, "...")
	confusion <- matrix(0.0, nrow = m+1, ncol = m,
		dimnames = list(Predict=names(PredNum), True=names(TrueNum)))
	WrongTab <- NULL

	# for PredNum
	fn <- function(x, LT)
		{ if (x %in% LT) { return(x) } else { return("...") } }

	acc.array <- rep(NaN, n)
	ind.truehla <- character(n)
	ind.predhla <- character(n)

	if (n > 0)
	{
		for (i in 1:n)
		{
			# increase
			TrueNumAll[[ ts1[i] ]] <- TrueNumAll[[ ts1[i] ]] + 1
			TrueNumAll[[ ts2[i] ]] <- TrueNumAll[[ ts2[i] ]] + 1

			# probability cut-off
			if (is.null(prob))
				flag <- TRUE
			else
				flag <- (prob[i] >= call.threshold)
			if (flag)
			{
				# update TrueNum and PredNum
				TrueNum[[ ts1[i] ]] <- TrueNum[[ ts1[i] ]] + 1
				TrueNum[[ ts2[i] ]] <- TrueNum[[ ts2[i] ]] + 1
				PredNum[[ fn(ps1[i], allele) ]] <- PredNum[[ fn(ps1[i], allele) ]] + 1
				PredNum[[ fn(ps2[i], allele) ]] <- PredNum[[ fn(ps2[i], allele) ]] + 1

				# correct count of individuals
				if ( ((ts1[i]==ps1[i]) & (ts2[i]==ps2[i])) | ((ts2[i]==ps1[i]) & (ts1[i]==ps2[i])) )
				{
					cnt.ind <- cnt.ind + 1
				}

				# correct count of haplotypes
				s <- c(ts1[i], ts2[i]); p <- c(ps1[i], ps2[i])
				ind.truehla[i] <- paste(s[order(s)], collapse="/")
				ind.predhla[i] <- paste(p[order(p)], collapse="/")
				
				hnum <- 0
				if ((s[1]==p[1]) | (s[1]==p[2]))
				{
					if (s[1]==p[1]) { p[1] <- "" } else { p[2] <- "" }
					confusion[s[1], s[1]] <- confusion[s[1], s[1]] + 1
					cnt.haplo <- cnt.haplo + 1
					hnum <- hnum + 1
				}
				if ((s[2]==p[1]) | (s[2]==p[2]))
				{
					confusion[s[2], s[2]] <- confusion[s[2], s[2]] + 1
					cnt.haplo <- cnt.haplo + 1
					hnum <- hnum + 1
				}
				acc.array[i] <- 0.5*hnum

				# for confusion matrix
				s <- c(ts1[i], ts2[i]); p <- c(ps1[i], ps2[i])
				if (hnum == 1)
				{
					if ((s[1]==p[1]) | (s[1]==p[2]))
					{
						if (s[1]==p[1])
						{
							confusion[fn(p[2], allele), s[2]] <- confusion[fn(p[2], allele), s[2]] + 1
						} else {
							confusion[fn(p[1], allele), s[2]] <- confusion[fn(p[1], allele), s[2]] + 1
						}
					} else {
						if (s[2]==p[1])
						{
							confusion[fn(p[2], allele), s[1]] <- confusion[fn(p[2], allele), s[1]] + 1
						} else {
							confusion[fn(p[1], allele), s[1]] <- confusion[fn(p[1], allele), s[1]] + 1
						}
					}
				} else if (hnum == 0)
				{
					WrongTab <- cbind(WrongTab, c(s, fn(p[1], allele), fn(p[2], allele)))
				}

				# the number of calling
				cnt.call <- cnt.call + 1
			}
		}
	}

	# overall
	overall <- data.frame(total.num.ind = n,
		crt.num.ind = cnt.ind, crt.num.haplo = cnt.haplo,
		acc.ind = cnt.ind/cnt.call, acc.haplo = 0.5*cnt.haplo/cnt.call,
		call.threshold = call.threshold)
	if (is.finite(call.threshold))
	{
		overall$n.call <- cnt.call
		overall$call.rate <- cnt.call / n
	} else {
		overall$n.call <- n
		overall$call.rate <- 1.0
		overall$call.threshold <- 0
	}

	# confusion matrix
	if (is.null(WrongTab))
	{
		nw <- as.integer(0)
	} else {
		nw <- ncol(WrongTab)
	}
	rv <- .C("HIBAG_Confusion", as.integer(m), confusion,
		nw, match(WrongTab, names(PredNum)) - as.integer(1),
		out = matrix(0.0, nrow=m+1, ncol=m, dimnames=list(Predict=names(PredNum), True=names(TrueNum))),
		tmp = double((m+1)*m),
		err = integer(1), NAOK = TRUE, PACKAGE = "HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())
	confusion <- round(rv$out, 2)

	# detail -- sensitivity and specificity
	detail <- data.frame(allele = allele)
	if (!is.null(TrainFreq))
	{
		detail$train.num <- 2 * TrainFreq * allele.limit$n.samp
		detail$train.freq <- TrainFreq
	}
	detail$valid.num <- TrueNumAll
	detail$valid.freq <- TrueNumAll / sum(TrueNumAll)
	detail$call.rate <- TrueNum / TrueNumAll

	sens <- diag(confusion) / TrueNum
	spec <- 1 - (PredNum[1:m] - diag(confusion)) / (2*cnt.call - TrueNum)
	detail$accuracy <- (sens*TrueNum + spec*(2*cnt.call - TrueNum)) / (2*cnt.call)
	detail$sensitivity <- sens
	detail$specificity <- spec
	detail$ppv <- diag(confusion) / rowSums(confusion)[1:m]
	detail$npv <- 1 - (TrueNum - diag(confusion)) / (2*n - rowSums(confusion)[1:m])

	detail$call.rate[!is.finite(detail$call.rate)] <- 0
	detail[detail$call.rate<=0, c("sensitivity", "specificity", "ppv", "npv", "accuracy")] <- NaN

	# get miscall
	rv <- confusion; diag(rv) <- 0
	m.max <- apply(rv, 2, max); m.idx <- apply(rv, 2, which.max)
	s <- names(PredNum)[m.idx]; s[m.max<=0] <- NA
	p <- m.max / apply(rv, 2, sum)
	detail <- cbind(detail, miscall=s, miscall.prop=p, stringsAsFactors=FALSE)
	rownames(detail) <- NULL

	# output
	rv <- list(overall=overall, confusion=confusion, detail=detail)
	if (output.individual)
	{
		rv$individual <- data.frame(sample.id=samp.id,
			true.hla=ind.truehla, pred.hla=ind.predhla,
			accuracy=acc.array, stringsAsFactors=FALSE)
	}
	return(rv)
}


#######################################################################
# Return a sample list satisfying the filter conditions
#

hlaSampleAllele <- function(TrueHLA, allele.limit = NULL, max.resolution="")
{
	# check
	stopifnot(inherits(TrueHLA, "hlaAlleleClass"))
	stopifnot(is.null(allele.limit) | is.vector(allele.limit) |
		inherits(allele.limit, "hlaAttrBagClass") |
		inherits(allele.limit, "hlaAttrBagObj"))
	stopifnot(max.resolution %in% c("2-digit", "4-digit", "6-digit", "8-digit",
		"allele", "protein", "2", "4", "6", "8", "full", ""))

	# init
	flag <- !is.na(TrueHLA$value$allele1) & !is.na(TrueHLA$value$allele2)
	ts1 <- TrueHLA$value$allele1[flag]
	ts2 <- TrueHLA$value$allele2[flag]

	# max resolution
	if (!(max.resolution %in% c("full", "")))
	{
		ts1 <- hlaAlleleDigit(ts1, max.resolution)
		ts2 <- hlaAlleleDigit(ts2, max.resolution)
	}

	# allele limitation
	if (!is.null(allele.limit))
	{
		if (inherits(allele.limit, "hlaAttrBagClass") | inherits(allele.limit, "hlaAttrBagObj"))
		{
			allele <- levels(factor(allele.limit$hla.allele))
		} else {
			allele <- levels(factor(allele.limit))
		}
		if (!(max.resolution %in% c("full", "")))
		{
			allele <- hlaAlleleDigit(allele, max.resolution)
		}
		flag[flag] <- (ts1 %in% allele) & (ts2 %in% allele)
	}

	# return
	return(TrueHLA$value$sample.id[flag])
}


#######################################################################
# Divide the list of HLA types to the training and validation sets
#
# INPUT:
#   HLA -- the HLA types, a "hlaHLAAlleleClass" object
#   train.prop -- the proportion of training samples
#

hlaSplitAllele <- function(HLA, train.prop=0.5)
{
	# check
	stopifnot(inherits(HLA, "hlaAlleleClass"))

	train.set <- NULL
	H <- HLA
	while (dim(H$value)[1] > 0)
	{
		v <- summary(H, show=FALSE)
		if (dim(v)[1] > 1)
		{
			v <- v[order(v[, "count"]), ]
		}

		allele <- rownames(v)[1]
		samp.id <- H$value$sample.id[H$value$allele1==allele | H$value$allele2==allele]
		samp.id <- as.character(samp.id)

		n.train <- ceiling(length(samp.id) * train.prop)
		train.sampid <- sample(samp.id, n.train)
		train.set <- c(train.set, train.sampid)

		H <- hlaAlleleSubset(H, samp.sel=
			match(setdiff(H$value$sample.id, samp.id), H$value$sample.id))
	}

	train.set <- train.set[order(train.set)]
	list(
		training = hlaAlleleSubset(HLA, samp.sel=match(train.set, HLA$value$sample.id)),
		validation = hlaAlleleSubset(HLA, samp.sel=match(setdiff(HLA$value$sample.id,
			train.set), HLA$value$sample.id))
	)
}


#######################################################################
# To select SNPs in the flanking region of a specified HLA locus
#
# INPUT:
#   snp.id -- a vector of snp id
#   position -- a vector of positions
#   hla.id -- the name of HLA locus
#   flank.bp -- the distance in basepair
#

hlaFlankingSNP <- function(snp.id, position, hla.id, flank.bp=500*1000,
	assembly="auto")
{
	# init
	HLAInfo <- hlaLociInfo(assembly)
	ID <- HLAInfo$loci[-length(HLAInfo$loci)]

	# check
	stopifnot(length(snp.id) == length(position))
	stopifnot(is.character(hla.id))
	stopifnot(length(hla.id) == 1)
	if (!(hla.id %in% ID))
		stop(paste("`hla.id' should be one of", paste(ID, collapse=",")))

	pos.start <- HLAInfo$pos.HLA.start[hla.id] - flank.bp
	pos.end <- HLAInfo$pos.HLA.end[hla.id] + flank.bp
	flag <- (pos.start <= position) & (position <= pos.end)
	return(snp.id[flag])
}


#######################################################################
# Summary a "hlaAlleleClass" object
#
# INPUT:
#   hla -- a "hlaAlleleClass" object
#

summary.hlaAlleleClass <- function(object, show=TRUE, ...)
{
	# check
	stopifnot(inherits(object, "hlaAlleleClass"))
	hla <- object

	HUA <- hlaUniqueAllele(c(hla$value$allele1, hla$value$allele2))
	HLA <- factor(match(c(hla$value$allele1, hla$value$allele2), HUA))
	levels(HLA) <- HUA	
	count <- table(HLA)
	freq <- prop.table(count)
	rv <- cbind(count=count, freq=freq)

	# get the number of unique genotypes
	m <- data.frame(a1=hla$value$allele1, a2=hla$value$allele2, stringsAsFactors=FALSE)
	lst <- apply(m, 1, FUN=function(x) {
		if (!is.na(x[1]) & !is.na(x[2]))
		{
			if (x[1] <= x[2])
				paste(x[1], x[2], sep="/")
			else
				paste(x[2], x[1], sep="/")
		} else
			NA
	})
	unique.n.geno <- nlevels(factor(lst))

	if (show)
	{
		s <- hla$locus
		if (s %in% c("A", "B", "C", "DRB1", "DRB5", "DQA1", "DQB1", "DPB1"))
			s <- paste0("HLA-", s)
		cat("Gene: ", s, "\n", sep="")
		cat(sprintf("Range: [%dbp, %dbp]", hla$pos.start, hla$pos.end))
		if (!is.null(hla$assembly))
			cat(" on ", hla$assembly, "\n", sep="")
		else
			cat("\n")
		cat(sprintf("# of samples: %d\n", dim(hla$value)[1]))
		cat(sprintf("# of unique HLA alleles: %d\n", length(count)))
		cat(sprintf("# of unique HLA genotypes: %d\n", unique.n.geno))
	}

	# return
	return(rv)
}




##########################################################################
##########################################################################
#
# Attribute Bagging method -- HIBAG algorithm
#

##########################################################################
# To fit an attribute bagging model for predicting
#

hlaAttrBagging <- function(hla, genotype, nclassifier=100, mtry=c("sqrt", "all", "one"),
	prune=TRUE, rm.na=TRUE, verbose=TRUE, verbose.detail=FALSE)
{
	# check
	stopifnot(inherits(hla, "hlaAlleleClass"))
	stopifnot(inherits(genotype, "hlaSNPGenoClass"))
	stopifnot(is.character(mtry) | is.numeric(mtry))
	stopifnot(is.logical(verbose))
	stopifnot(is.logical(verbose.detail))
	if (verbose.detail) verbose <- TRUE

	# get the common samples
	samp.id <- intersect(hla$value$sample.id, genotype$sample.id)

	# hla types
	samp.flag <- match(samp.id, hla$value$sample.id)
	hla.allele1 <- hla$value$allele1[samp.flag]
	hla.allele2 <- hla$value$allele2[samp.flag]
	if (rm.na)
	{
		if (any(is.na(c(hla.allele1, hla.allele2))))
		{
			warning("There are missing HLA alleles, and the corresponding samples have been removed.")
			flag <- is.na(hla.allele1) | is.na(hla.allele2)
			samp.id <- setdiff(samp.id, hla$value$sample.id[samp.flag[flag]])
			samp.flag <- match(samp.id, hla$value$sample.id)
			hla.allele1 <- hla$value$allele1[samp.flag]
			hla.allele2 <- hla$value$allele2[samp.flag]
		}
	} else {
		if (any(is.na(c(hla.allele1, hla.allele2))))
		{
			stop("There are missing HLA alleles!")
		}
	}

	# SNP genotypes
	samp.flag <- match(samp.id, genotype$sample.id)
	snp.geno <- genotype$genotype[, samp.flag]
	storage.mode(snp.geno) <- "integer"

	tmp.snp.id <- genotype$snp.id
	tmp.snp.position <- genotype$snp.position
	tmp.snp.allele <- genotype$snp.allele

	# remove mono-SNPs
	snpsel <- rowMeans(snp.geno, na.rm=TRUE)
	snpsel[!is.finite(snpsel)] <- 0
	snpsel <- (0 < snpsel) & (snpsel < 2)
	if (sum(!snpsel) > 0)
	{
		snp.geno <- snp.geno[snpsel, ]
		if (verbose)
			cat(sprintf("%s monomorphic SNPs have been removed.\n", sum(!snpsel)))
		tmp.snp.id <- tmp.snp.id[snpsel]
		tmp.snp.position <- tmp.snp.position[snpsel]
		tmp.snp.allele <- tmp.snp.allele[snpsel]
	}

	if (length(samp.id) <= 0)
		stop("There is no common sample between `hla' and `genotype'.")
	if (length(dim(snp.geno)[1]) <= 0)
		stop("There is no valid SNP markers.")


	###################################################################
	# initialize ...

	n.snp <- dim(snp.geno)[1]      # Num. of SNPs
	n.samp <- dim(snp.geno)[2]     # Num. of samples
	HUA <- hlaUniqueAllele(c(hla.allele1, hla.allele2))
	H <- factor(match(c(hla.allele1, hla.allele2), HUA))
	levels(H) <- HUA
	n.hla <- nlevels(H)
	H1 <- as.integer(H[1:n.samp]) - as.integer(1)
	H2 <- as.integer(H[(n.samp+1):(2*n.samp)]) - as.integer(1)

	# create an attribute bagging object
	rv <- .C("HIBAG_Training", n.snp, n.samp, snp.geno, n.hla,
		H1, H2, AB=integer(1), err=integer(1),
		NAOK = TRUE, PACKAGE = "HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())
	ABmodel <- rv$AB

	# number of variables randomly sampled as candidates at each split
	mtry <- mtry[1]
	if (is.character(mtry))
	{
		if (mtry == "sqrt")
		{
			mtry <- ceiling(sqrt(n.snp))
		} else if (mtry == "all")
		{
			mtry <- n.snp
		} else if (mtry == "one")
		{
			mtry <- as.integer(1)
		} else {
			stop("Invalid mtry!")
		}
	} else if (is.numeric(mtry))
	{
		if (is.finite(mtry))
		{
			if ((0 < mtry) & (mtry < 1)) mtry <- n.snp*mtry
			mtry <- ceiling(mtry)
			if (mtry > n.snp) mtry <- n.snp
		} else {
			mtry <- ceiling(sqrt(n.snp))
		}
	} else {
		stop("Invalid mtry value!")
	}
	if (mtry <= 0) mtry <- as.integer(1)

	if (verbose)
	{
		cat("Build a HIBAG model with", nclassifier, "individual classifiers:\n")
		cat("# of SNPs randomly sampled as candidates for each selection: ", mtry, "\n", sep="")
		cat("# of SNPs: ", n.snp, ", # of samples: ", n.samp, "\n", sep="")
		cat("# of unique HLA alleles: ", n.hla, "\n", sep="")
	}


	###################################################################
	# training ...
	# add new individual classifers
	rv <- .C("HIBAG_NewClassifiers", ABmodel, as.integer(nclassifier),
		as.integer(mtry), as.logical(prune), verbose, verbose.detail, debug=FALSE,
		err=integer(1), NAOK = TRUE, PACKAGE = "HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())

	# output
	rv <- list(n.samp = n.samp, n.snp = n.snp, sample.id = samp.id,
		snp.id = tmp.snp.id, snp.position = tmp.snp.position,
		snp.allele = tmp.snp.allele,
		snp.allele.freq = 0.5*rowMeans(snp.geno, na.rm=TRUE),
		hla.locus = hla$locus, hla.allele = levels(H), hla.freq = prop.table(table(H)),
		model = ABmodel,
		appendix = list(platform = genotype$assembly))
	class(rv) <- "hlaAttrBagClass"
	return(rv)
}


##########################################################################
# To fit an attribute bagging model for predicting
#

hlaParallelAttrBagging <- function(cl, hla, genotype, auto.save="",
	nclassifier=100, mtry=c("sqrt", "all", "one"), prune=TRUE, rm.na=TRUE,
	verbose=TRUE)
{
    if (!require(parallel, warn.conflicts=FALSE))
	{
		stop("The `parallel' package should be installed.")
	}

	# check
    stopifnot(inherits(cl, "cluster"))
	stopifnot(inherits(hla, "hlaAlleleClass"))
	stopifnot(inherits(genotype, "hlaSNPGenoClass"))

	stopifnot(is.character(auto.save) & (length(auto.save)==1))
	stopifnot(is.numeric(nclassifier))
	stopifnot(is.character(mtry) | is.numeric(mtry))
	stopifnot(is.logical(prune))
	stopifnot(is.logical(rm.na))
	stopifnot(is.logical(verbose))

	if (verbose)
	{
		cat(sprintf("Build a HIBAG model of %d individual classifiers in parallel with %d nodes:\n",
			as.integer(nclassifier), length(cl)))
		if (auto.save != "")
			cat("The model is autosaved in '", auto.save, "'.\n", sep="")
	}


	##################################################################

	DynamicClusterCall <- function(cl, fun, combine.fun, msg.fn, n, ...)
	{
		# the functions are all defined in 'parallel/R/snow.R'

		postNode <- function(con, type, value = NULL, tag = NULL)
		{
			parallel:::sendData(con, list(type = type, data = value, tag = tag))
		}

		sendCall <- function(con, fun, args, return = TRUE, tag = NULL)
		{
			postNode(con, "EXEC",
				list(fun = fun, args = args, return = return, tag = tag))
			NULL
		}

		recvOneResult <- function(cl)
		{
			v <- parallel:::recvOneData(cl)
			list(value = v$value$value, node = v$node, tag = v$value$tag)
		}


		#########################################################################
		# check
		stopifnot(inherits(cl, "cluster"))
		stopifnot(is.function(fun))
		stopifnot(is.function(combine.fun))
		stopifnot(is.function(msg.fn))
		stopifnot(is.numeric(n))

		val <- NULL
		p <- length(cl)
		if (n > 0L && p)
		{
			## **** this closure is sending to all nodes
			argfun <- function(i) c(i, list(...))

			submit <- function(node, job)
				sendCall(cl[[node]], fun, argfun(job), tag = job)

			for (i in 1:min(n, p)) submit(i, i)
			for (i in 1:n)
			{
				d <- recvOneResult(cl)
				j <- i + min(n, p)
				if (j <= n) submit(d$node, j)

				dv <- d$value
				if (inherits(dv, "try-error"))
					stop("One node produced an error: ", as.character(dv))
				msg.fn(d$node, dv)
				val <- combine.fun(val, dv)
			}
		}

		val
	}


	# set random number
	RNGkind("L'Ecuyer-CMRG")
	rand <- .Random.seed
	clusterSetRNGStream(cl)

	ans <- local({
		total <- 0

		DynamicClusterCall(cl,
			fun = function(job, hla, genotype, mtry, prune, rm.na)
			{
				library(HIBAG)
				model <- hlaAttrBagging(hla=hla, genotype=genotype, nclassifier=1,
					mtry=mtry, prune=prune, rm.na=rm.na,
					verbose=FALSE, verbose.detail=FALSE)
				mobj <- hlaModelToObj(model)
				hlaClose(model)
				return(mobj)
			},
			combine.fun = function(obj1, obj2)
			{
				if (is.null(obj1))
					mobj <- obj2
				else if (is.null(obj2))
					mobj <- obj1
				else
					mobj <- hlaCombineModelObj(obj1, obj2)
				if (auto.save != "")
					save(mobj, file=auto.save)
				if (verbose & !is.null(mobj))
				{
					z <- summary(mobj, show=FALSE)
					cat(sprintf("  --  average out-of-bag accuracy: %0.2f%%, sd: %0.2f%%, min: %0.2f%%, max: %0.2f%%\n",
						z$info["accuracy", "Mean"], z$info["accuracy", "SD"],
						z$info["accuracy", "Min"], z$info["accuracy", "Max"]))
				}
				mobj
			},
			msg.fn = function(job, obj)
			{
				if (verbose)
				{
					z <- summary(obj, show=FALSE)
					total <<- total + 1
					cat(date(), sprintf(
						", %4d, job %3d, # of SNPs: %g, # of haplotypes: %g, accuracy: %0.1f%%\n",
						total, job, z$info["num.snp", "Mean"], z$info["num.haplo", "Mean"],
						z$info["accuracy", "Mean"]), sep="")
				}
			},
			n = nclassifier,
			hla=hla, genotype=genotype, mtry=mtry, prune=prune, rm.na=rm.na
		)
	})

	nextRNGStream(rand)
	nextRNGSubStream(rand)

	# return
	if (auto.save == "")
		return(hlaModelFromObj(ans))
	else
		return(invisible(NULL))
}


##########################################################################
# To fit an attribute bagging model for predicting
#

hlaClose <- function(model)
{
	# check
	stopifnot(inherits(model, "hlaAttrBagClass"))

	# class handler
	rv <- .C("HIBAG_Close", model$model, err=integer(1), NAOK = TRUE, PACKAGE = "HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())

	# output
	return(invisible(NULL))
}


#######################################################################
# Check missing SNP predictors
#

hlaCheckSNPs <- function(model, object, match.pos=TRUE, verbose=TRUE)
{
	# check
	stopifnot(inherits(model, "hlaAttrBagClass") | inherits(model, "hlaAttrBagObj"))
	stopifnot((is.vector(object) & is.character(object)) |
		inherits(object, "hlaSNPGenoClass"))

	# initialize
	if (inherits(model, "hlaAttrBagClass"))
		model <- hlaModelToObj(model)

	# show information
	if (verbose)
	{
		cat("The HIBAG model:\n")
		cat(sprintf("\tThere are %d SNP predictors in total.\n",
			length(model$snp.id)))
		cat(sprintf("\tThere are %d individual classifiers.\n",
			length(model$classifiers)))
	}

	if (is.vector(object))
	{
		target.snp <- as.character(object)
		src.snp <- hlaSNPID(model, match.pos)
	} else {
		target.snp <- hlaSNPID(object, match.pos)
		src.snp <- hlaSNPID(model, match.pos)
	}

	NumOfSNP <- integer(length(model$classifiers))
	NumOfValidSNP <- integer(length(model$classifiers))

	# enumerate each classifier
	for (i in 1:length(model$classifiers))
	{
		v <- model$classifiers[[i]]
		flag <- src.snp[v$snpidx] %in% target.snp
		NumOfSNP[i] <- length(v$snpidx)
		NumOfValidSNP[i] <- sum(flag)
	}

	rv <- data.frame(NumOfValidSNP = NumOfValidSNP, NumOfSNP = NumOfSNP,
		fraction = NumOfValidSNP/NumOfSNP)

	if (verbose)
	{
		cat("Summarize the missing fractions of SNP predictors per classifier:\n")
		print(summary(1 - rv$fraction))
	}

	# output
	invisible(rv)
}


#######################################################################
# Predict HLA types from unphased SNP data
#

predict.hlaAttrBagClass <- function(object, genotypes, type=c("response", "prob"),
	vote=c("prob", "majority"), allele.check=TRUE, match.pos=TRUE, verbose=TRUE, ...)
{
	# check
	stopifnot(inherits(object, "hlaAttrBagClass"))
	stopifnot(is.logical(allele.check))
	stopifnot(is.logical(match.pos))
	type <- match.arg(type)
	vote <- match.arg(vote)
	vote_method <- match(vote, c("prob", "majority"))

	# if warning
	if (!is.null(object$appendix$warning))
		message(object$appendix$warning)

	if (verbose)
	{
		# call, get the number of classifiers
		rv <- .C("HIBAG_GetNumClassifiers", object$model, CNum = integer(1),
			err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())

		if (rv$CNum > 1) { s <- "s" } else { s <- "" }
		cat(sprintf("HIBAG model: %d individual classifier%s, %d SNPs, %d unique HLA alleles\n",
			rv$CNum, s, length(object$snp.id), length(object$hla.allele)))

		if (vote_method == 1)
			cat("Predicting based on the averaged posterior probabilities from all individual classifiers\n")
		else
			cat("Predicting by class majority voting from all individual classifiers\n")
	}

	if (!inherits(genotypes, "hlaSNPGenoClass"))
	{
		# it should be a vector or a matrix
		stopifnot(is.numeric(genotypes))
		stopifnot(is.vector(genotypes) | is.matrix(genotypes))

		if (is.vector(genotypes))
		{
			stopifnot(length(genotypes) == object$n.snp)
			if (!is.null(names(genotypes)))
				stopifnot(all(names(genotypes) == object$snp.id))
			genotypes <- matrix(genotypes, ncol=1)
		} else {
			stopifnot(nrow(genotypes) == object$n.snp)
			if (!is.null(rownames(genotypes)))
				stopifnot(all(rownames(genotypes) == object$snp.id))
		}
		geno.sampid <- 1:ncol(genotypes)
		assembly <- "auto"

	} else {

		# a 'hlaSNPGenoClass' object
		geno.sampid <- genotypes$sample.id
		if (!is.null(genotypes$assembly))
			assembly <- genotypes$assembly
		else
			assembly <- "auto"

		obj.id <- hlaSNPID(object, match.pos)
		geno.id <- hlaSNPID(genotypes, match.pos)

		# flag boolean
		flag <- FALSE
		if (length(obj.id) == length(geno.id))
		{
			if (all(obj.id == geno.id))
				flag <- TRUE
		}

		# check and switch A/B alleles
		if (flag)
		{
			if (allele.check)
			{
				genotypes <- hlaGenoSwitchStrand(genotypes, object, match.pos, verbose)$genotype
			} else {
				genotypes <- genotypes$genotype
			}
		} else {

			# snp selection
			snp.sel <- match(obj.id, geno.id)

			# tmp variable
			tmp <- list(genotype = genotypes$genotype[snp.sel,],
				sample.id = genotypes$sample.id,
				snp.id = object$snp.id, snp.position = object$snp.position,
				snp.allele = genotypes$snp.allele[snp.sel])
			flag <- is.na(tmp$snp.allele)
			tmp$snp.allele[flag] <- object$snp.allele[match(tmp$snp.id[flag], object$snp.id)]
			if (is.vector(tmp$genotype))
				tmp$genotype <- matrix(tmp$genotype, ncol=1)
			class(tmp) <- "hlaSNPGenoClass"

			# total number of missing genotypes
			missing.cnt <- sum(flag)

			# verbose
			if (verbose)
			{
				if (missing.cnt > 0)
				{
					if (missing.cnt > 1)
					{
						s <- "are"; ss <- "s"
					} else {
						s <- "is"; ss <- ""
					}
					cat(sprintf("There %s %d missing SNP%s (%0.1f%%).\n",
						s, missing.cnt, ss, 100*missing.cnt/length(obj.id)))
				}
			}

			# try alternative matching if possible
			if (match.pos)
			{
				s1 <- hlaSNPID(object, FALSE)
				s2 <- hlaSNPID(genotypes, FALSE)
				mcnt <- length(s1) - length(intersect(s1, s2))
				if ((mcnt < missing.cnt) & verbose)
				{
					message("Hint:\n",
						"The current matching of SNPs requires both SNP ID and position, ",
						sprintf("and a lower missing fraction (%0.1f%%) ", 100*mcnt/length(s1)),
						"can be gained by matching reference SNP ID only.\n",
						"Call 'predict(, match.pos=FALSE)' for this purpose.\n",
						"Any concern about SNP mismatching should be emailed to the genotyping platform provider.")
					if (!is.null(object$appendix$assembly))
						message("The platform of the HIBAG model: ", object$appendix$assembly)
					if (!is.null(genotypes$assembly))
						message("The platform of SNP data: ", genotypes$assembly)
				}
			}

			if (missing.cnt == length(obj.id))
			{
				stop("There is no overlapping of SNPs!")
			} else if (missing.cnt > 0.5*length(obj.id))
			{
				warning("More than 50% of SNPs are missing!")
			}

			# switch
			if (allele.check)
			{
				genotypes <- hlaGenoSwitchStrand(tmp, object, match.pos, verbose)$genotype
			} else {
				genotypes <- genotypes$genotype
			}
		}
	}

	# initialize ...
	n.samp <- dim(genotypes)[2]
	n.hla <- length(object$hla.allele)

	# to predict HLA types
	if (type == "response")
	{
		rv <- .C("HIBAG_Predict", object$model, as.integer(genotypes), n.samp,
			as.integer(vote_method), as.logical(verbose),
			H1=integer(n.samp), H2=integer(n.samp),
			prob=double(n.samp), err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())

		res <- hlaAllele(geno.sampid,
			H1 = object$hla.allele[rv$H1 + 1], H2 = object$hla.allele[rv$H2 + 1],
			locus = object$hla.locus, prob = rv$prob, na.rm = FALSE,
			assembly = assembly)

		NA.cnt <- sum(is.na(res$value$allele1) | is.na(res$value$allele2))

	} else {
		rv <- .C("HIBAG_Predict_Prob", object$model, as.integer(genotypes),
			n.samp, as.integer(vote_method), as.logical(verbose),
			prob=matrix(NaN, nrow=n.hla*(n.hla+1)/2, ncol=n.samp),
			err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())

		res <- rv$prob
		colnames(res) <- geno.sampid
		m <- outer(object$hla.allele, object$hla.allele, function(x, y) paste(x, y, sep="."))
		rownames(res) <- m[lower.tri(m, diag=TRUE)]

		NA.cnt <- sum(colSums(res) <= 0)
	}

	if (NA.cnt > 0)
	{
		if (NA.cnt > 1) s <- "s" else s <- ""
		warning(sprintf(
			"No prediction output%s for %d individual%s (possibly due to missing SNPs.)",
			s, NA.cnt, s))
	}

	# return
	return(res)
}


#######################################################################
# summarize the "hlaAttrBagClass" object
#

summary.hlaAttrBagClass <- function(object, show=TRUE, ...)
{
	obj <- hlaModelToObj(object)
	summary(obj, show=show)
}


#######################################################################
# Save the parameters in a model of attribute bagging
#

hlaModelToObj <- function(model)
{
	# check
	stopifnot(inherits(model, "hlaAttrBagClass"))

	# call, get the number of classifiers
	rv <- .C("HIBAG_GetNumClassifiers", model$model, CNum = integer(1),
		err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())

	# for each tree
	res <- vector("list", rv$CNum)
	for (i in 1:length(res))
	{
		# call, get the number of haplotypes
		rv <- .C("HIBAG_Idv_GetNumHaplo", model$model, as.integer(i),
			NumHaplo = integer(1), NumSNP = integer(1),
			err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())

		# number of trios or samples
		if ("n.trio" %in% names(model))
			n.trio <- model$n.trio
		else
			n.trio <- model$n.samp

		# call, get freq. and haplotypes
		rv <- .C("HIBAG_Classifier_GetHaplos", model$model, as.integer(i),
			freq=double(rv$NumHaplo), hla=integer(rv$NumHaplo), haplo=character(rv$NumHaplo),
			snpidx = integer(rv$NumSNP), samp.num = integer(n.trio), acc = double(1),
			err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())

		res[[i]] <- list(
			samp.num = rv$samp.num,
			haplos = data.frame(freq=rv$freq, hla=model$hla.allele[rv$hla], haplo=rv$haplo,
				stringsAsFactors=FALSE),
			snpidx = rv$snpidx,
			outofbag.acc = rv$acc)
	}

	rv <- list(n.samp = model$n.samp, n.snp = model$n.snp)
	if ("n.trio" %in% names(model))
		rv$n.trio <- model$n.trio
	rv <- c(rv, list(
		sample.id = model$sample.id, snp.id = model$snp.id,
		snp.position = model$snp.position, snp.allele = model$snp.allele,
		snp.allele.freq = model$snp.allele.freq,
		hla.locus = model$hla.locus, hla.allele = model$hla.allele, hla.freq = model$hla.freq,
		classifiers = res))
	if (!is.null(model$appendix)) rv$appendix <- model$appendix

	class(rv) <- "hlaAttrBagObj"
	return(rv)
}


#######################################################################
# To combine two model objects of attribute bagging
#

hlaCombineModelObj <- function(obj1, obj2)
{
	# check
	stopifnot(inherits(obj1, "hlaAttrBagObj"))
	stopifnot(inherits(obj2, "hlaAttrBagObj"))
	stopifnot(obj1$hla.locus == obj2$hla.locus)
	stopifnot(length(obj1$snp.id) == length(obj2$snp.id))
	stopifnot(all(obj1$snp.id == obj2$snp.id))
	stopifnot(length(obj1$hla.allele) == length(obj2$hla.allele))
	stopifnot(all(obj1$hla.allele == obj2$hla.allele))

	samp.id <- unique(c(obj1$sample.id, obj2$sample.id))
	if (!is.null(obj1$appendix) | !is.null(obj2$appendix))
	{
		appendix <- list(
			platform = unique(c(obj1$appendix$platform, obj2$appendix$platform)),
			information = unique(c(obj1$appendix$information, obj2$appendix$information)),
			warning = unique(c(obj1$appendix$warning, obj2$appendix$warning))
		)
	} else {
		appendix <- NULL
	}

	rv <- list(n.samp = length(samp.id), n.snp = obj1$n.snp,
		sample.id = samp.id, snp.id = obj1$snp.id,
		snp.position = obj1$snp.position, snp.allele = obj1$snp.allele,
		snp.allele.freq = (obj1$snp.allele.freq + obj2$snp.allele.freq)*0.5,
		hla.locus = obj1$hla.locus,
		hla.allele = obj1$hla.allele, hla.freq = (obj1$hla.freq + obj2$hla.freq)*0.5,
		classifiers = c(obj1$classifiers, obj2$classifiers))
	if (!is.null(appendix))
		rv$appendix <- appendix

	class(rv) <- "hlaAttrBagObj"
	return(rv)
}


#######################################################################
# To get the top n individual classifiers
#

hlaSubModelObj <- function(obj, n)
{
	# check
	stopifnot(inherits(obj, "hlaAttrBagObj"))
	obj$classifiers <- obj$classifiers[1:n]
	return(obj)
}


#######################################################################
# To get a "hlaAttrBagClass" class
#

hlaModelFromObj <- function(obj)
{
	# check
	stopifnot(inherits(obj, "hlaAttrBagObj"))

	# create an attribute bagging object
	rv <- .C("HIBAG_New",
		as.integer(obj$n.samp), as.integer(obj$n.snp), length(obj$hla.allele),
		model = integer(1), err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
	if (rv$err != 0) stop(hlaErrMsg())
	ABmodel <- rv$model

	# add individual classifiers
	for (tree in obj$classifiers)
	{
		hla <- match(tree$haplos$hla, obj$hla.allele) - 1
		if (any(is.na(hla)))
			stop("Invalid HLA alleles in the individual classifier.")
		if (is.null(tree$samp.num))
			snum <- rep(as.integer(1), obj$n.samp)
		else
			snum <- tree$samp.num
		rv <- .C("HIBAG_NewClassifierHaplo", ABmodel, length(tree$snpidx),
			as.integer(tree$snpidx-1), as.integer(snum), dim(tree$haplos)[1],
			as.double(tree$haplos$freq), as.integer(hla), as.character(tree$haplos$haplo),
			as.double(tree$outofbag.acc), err=integer(1), NAOK=TRUE, PACKAGE="HIBAG")
		if (rv$err != 0) stop(hlaErrMsg())
	}

	# output
	rv <- list(n.samp = obj$n.samp, n.snp = obj$n.snp)
	if ("n.trio" %in% names(obj))
		rv$n.trio <- obj$n.trio
	rv <- c(rv, list(
		sample.id = obj$sample.id, snp.id = obj$snp.id,
		snp.position = obj$snp.position, snp.allele = obj$snp.allele,
		snp.allele.freq = obj$snp.allele.freq,
		hla.locus = obj$hla.locus, hla.allele = obj$hla.allele, hla.freq = obj$hla.freq,
		model = ABmodel))
	if (!is.null(obj$appendix)) rv$appendix <- obj$appendix

	class(rv) <- "hlaAttrBagClass"
	return(rv)
}


#######################################################################
# summarize the "hlaAttrBagObj" object
#

summary.hlaAttrBagObj <- function(object, show=TRUE, ...)
{
	# check
	stopifnot(inherits(object, "hlaAttrBagObj"))
	obj <- object

	if (show)
	{
		s <- obj$hla.locus
		if (s %in% c("A", "B", "C", "DRB1", "DRB5", "DQA1", "DQB1", "DPB1"))
			s <- paste0("HLA-", s)
		cat("Gene: ", s, "\n", sep="")
		cat("Training dataset:", obj$n.samp, "samples X",
			length(obj$snp.id), "SNPs\n")
		cat("\t# of HLA alleles: ", length(obj$hla.allele), "\n", sep="")
	}

	# summarize ...
	snpset <- NULL
	outofbag.acc <- rep(NaN, length(obj$classifiers))
	numsnp <- rep(NA, length(obj$classifiers))
	numhaplo <- rep(NA, length(obj$classifiers))
	snp.hist <- rep(0, length(obj$snp.id))
	for (i in 1:length(obj$classifiers))
	{
		outofbag.acc[i] <- obj$classifiers[[i]]$outofbag.acc
		numsnp[i] <- length(obj$classifiers[[i]]$snpidx)
		numhaplo[i] <- length(obj$classifiers[[i]]$haplos$hla)
		snp.hist[obj$classifiers[[i]]$snpidx] <- snp.hist[obj$classifiers[[i]]$snpidx] + 1
		snpset <- unique(c(snpset, obj$classifiers[[i]]$snpidx))
	}
	snpset <- snpset[order(snpset)]
	outofbag.acc <- outofbag.acc * 100

	info <- data.frame(
		Mean = c(mean(numsnp), mean(numhaplo), mean(outofbag.acc)),
		SD = c(sd(numsnp), sd(numhaplo), sd(outofbag.acc)),
		Min = c(min(numsnp), min(numhaplo), min(outofbag.acc)),
		Max = c(max(numsnp), max(numhaplo), max(outofbag.acc))
	)
	rownames(info) <- c("num.snp", "num.haplo", "accuracy")

	if (show)
	{
		cat("\t# of individual classifiers: ", length(obj$classifiers), "\n", sep="")
		cat("\tTotal # of SNPs used: ", length(snpset), "\n", sep="")
		cat(sprintf("\tAverage # of SNPs in an individual classifier: %0.2f, sd: %0.2f, min: %d, max: %d\n",
			mean(numsnp), sd(numsnp), min(numsnp), max(numsnp)))
		cat(sprintf("\tAverage # of haplotypes in an individual classifier: %0.2f, sd: %0.2f, min: %d, max: %d\n",
			mean(numhaplo), sd(numhaplo), min(numhaplo), max(numhaplo)))
		cat(sprintf("\tAverage out-of-bag accuracy in an individual classifier: %0.2f%%, sd: %0.2f%%, min: %0.2f%%, max: %0.2f%%\n",
			mean(outofbag.acc), sd(outofbag.acc), min(outofbag.acc), max(outofbag.acc)))

		if (!is.null(obj$appendix$platform))
			cat("Platform:", obj$appendix$platform, "\n")
		if (!is.null(obj$appendix$information))
			cat("Information:", obj$appendix$information, "\n")
		if (!is.null(obj$appendix$warning))
			message(obj$appendix$warning)
	}

	rv <- list(num.classifier = length(obj$classifiers), num.snp = length(snpset),
		snp.id = obj$snp.id, snp.position = obj$snp.position,
		snp.hist = snp.hist, info = info)
	return(invisible(rv))
}




##########################################################################
# to finalize the HIBAG model
#

hlaPublish <- function(mobj, platform=NULL, information=NULL, warning=NULL,
	rm.unused.snp=TRUE, anonymize=TRUE)
{
	# check
	stopifnot(inherits(mobj, "hlaAttrBagObj") | inherits(mobj, "hlaAttrBagClass"))
	stopifnot(is.null(platform) | is.character(platform))
	stopifnot(is.null(information) | is.character(information))
	stopifnot(is.null(warning) | is.character(warning))
	stopifnot(is.logical(rm.unused.snp) & (length(rm.unused.snp)==1))
	if (inherits(mobj, "hlaAttrBagClass"))
		mobj <- hlaModelToObj(mobj)

	# additional information
	if (is.null(platform))
		platform <- mobj$appendix$platform
	if (is.null(information))
		information <- mobj$appendix$information
	if (is.null(warning))
		warning <- mobj$appendix$warning
	mobj$appendix <- list(
		platform=platform, information=information, warning=warning)

	# remove unused SNPs
	if (rm.unused.snp)
	{
		# get frequency of use for SNPs
		snp.hist <- rep(0, length(mobj$snp.id))
		for (i in 1:length(mobj$classifiers))
		{
			idx <- mobj$classifiers[[i]]$snpidx
			snp.hist[idx] <- snp.hist[idx] + 1
		}

		flag <- (snp.hist > 0)
		mobj$n.snp <- sum(flag)
		mobj$snp.id <- mobj$snp.id[flag]
		mobj$snp.position <- mobj$snp.position[flag]
		mobj$snp.allele <- mobj$snp.allele[flag]
		mobj$snp.allele.freq <- mobj$snp.allele.freq[flag]

		idx.list <- rep(0, length(flag))
		idx.list[flag] <- 1:mobj$n.snp

		for (i in 1:length(mobj$classifiers))
		{
			print(mobj$classifiers[[i]]$snpidx)
			mobj$classifiers[[i]]$snpidx <- idx.list[ mobj$classifiers[[i]]$snpidx ]
			print(mobj$classifiers[[i]]$snpidx)
		}
	}

	# anonymize
	if (anonymize)
	{
		mobj$sample.id <- NULL
		for (i in 1:length(mobj$classifiers))
		{
			mobj$classifiers[[i]]$samp.num <- NULL
		}
	}

	# output
	return(mobj)
}


##########################################################################
# to get a model object of attribute bagging from a list of files
#

hlaModelFiles <- function(fn.list, action.missingfile=c("ignore", "stop"),
	verbose=TRUE)
{
	# check
	stopifnot(is.character(fn.list))
	stopifnot(is.logical(verbose))
	action.missingfile <- match.arg(action.missingfile)

	# for-loop
	rv <- NULL
	for (fn in fn.list)
	{
		if (file.exists(fn))
		{
			tmp <- get(load(fn))
			if (is.null(rv))
			{
				rv <- tmp
			} else {
				rv <- hlaCombineModelObj(rv, tmp)
			}
		} else {
			s <- sprintf("There is no '%s'.", fn)
			if (action.missingfile == "stop")
			{
				stop(s)
			} else {
				if (verbose) message(s)
			}
		}
	}
	rv
}



##########################################################################
##########################################################################
#
# Linkage Disequilibrium
#

##########################################################################
# To calculate linkage disequilibrium between HLA locus and SNP markers
#

hlaGenoLD <- function(hla, geno)
{
	# check
	stopifnot(inherits(hla, "hlaAlleleClass"))
	if (inherits(geno, "hlaSNPGenoClass"))
	{
		stopifnot(dim(hla$value)[1] == length(geno$sample.id))
		if (any(hla$value$sample.id != geno$sample.id))
		{
			hla <- hlaAlleleSubset(hla, samp.sel =
				match(geno$sample.id, hla$value$sample.id))
		}
		geno <- geno$genotype
	} else if (is.matrix(geno))
	{
		stopifnot(is.numeric(geno))
		stopifnot(dim(hla$value)[1] == dim(geno)[2])
	} else if (is.vector(geno))
	{
		stopifnot(is.numeric(geno))
		stopifnot(dim(hla$value)[1] == length(geno))
		geno <- matrix(geno, ncol=1)
	} else {
		stop("geno should be `hlaSNPGenoClass', a vector or a matrix.")
	}

	# HLA alleles indicators
	alleles <- unique(c(hla$value$allele1, hla$value$allele2))
	alleles <- alleles[order(alleles)]
	allele.mat <- matrix(as.integer(0),
		nrow=length(hla$value$allele1), ncol=length(alleles))
	for (i in 1:length(alleles))
	{
		allele.mat[, i] <- (hla$value$allele1==alleles[i]) +
			(hla$value$allele2==alleles[i])
	}

	apply(geno, 1,
		function(x, allele.mat) {
			suppressWarnings(mean(cor(x, allele.mat, use="pairwise.complete.obs")^2, na.rm=TRUE))
		},
		allele.mat=allele.mat)
}




##########################################################################
##########################################################################
#
# Visualization
#

##########################################################################
# To visualize an attribute bagging model
#

plot.hlaAttrBagClass <- function(x, ...)
{
	obj <- hlaModelToObj(x)
	plot(obj, ...)
}

print.hlaAttrBagClass <- function(x, ...)
{
	obj <- hlaModelToObj(x)
	print(obj)
	# output
	return(invisible(NULL))
}


##########################################################################
# To visualize an attribute bagging model
#

plot.hlaAttrBagObj <- function(x, xlab=NULL, ylab=NULL,
	locus.color="red", locus.lty=2, locus.cex=1.25, assembly="auto", ...)
{
	# check
	stopifnot(inherits(x, "hlaAttrBagObj"))

	# the starting and ending positions of HLA locus
	if (assembly == "auto")
	{
		if (!is.null(x$appendix$platform))
			assembly <- x$appendix$platform
	}
	info <- hlaLociInfo(assembly)
	pos.start <- info$pos.HLA.start[[x$hla.locus]]/1000
	pos.end <- info$pos.HLA.end[[x$hla.locus]]/1000

	# summary of the attribute bagging model
	desp <- summary(x, show=FALSE)

	# x - label, y - label
	if (is.null(xlab)) xlab <- "SNP Position (KB)"
	if (is.null(ylab)) ylab <- "Frequency of Use"

	# draw
	plot(x$snp.position/1000, desp$snp.hist, xlab=xlab, ylab=ylab, ...)
	abline(v=pos.start, col=locus.color, lty=locus.lty)
	abline(v=pos.end, col=locus.color, lty=locus.lty)
	text((pos.start + pos.end)/2, max(desp$snp.hist), paste("HLA", x$hla.locus, sep="-"),
		col=locus.color, cex=locus.cex)
}

print.hlaAttrBagObj <- function(x, ...)
{
	summary(x)
	# output
	return(invisible(NULL))
}



#######################################################################
# To get the error message
#

hlaErrMsg <- function()
{
	rv <- .C("HIBAG_ErrMsg", msg=character(1), NAOK=TRUE, PACKAGE="HIBAG")
	rv$msg
}



#######################################################################
# Internal R library functions
#######################################################################

.onAttach <- function(lib, pkg)
{
	# initialize HIBAG
	.C("HIBAG_Init", PACKAGE="HIBAG")
	TRUE
}

.Last.lib <- function(libpath)
{
	# finalize HIBAG
	rv <- .C("HIBAG_Done", PACKAGE="HIBAG")
	TRUE
}