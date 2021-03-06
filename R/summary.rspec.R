#' Colourimetric variables
#'
#' Calculates all 23 colourimetric variables reviewed in Montgomerie (2006).
#'
#' @param object (required) a data frame, possibly an object of class `rspec`,
#' with a column with wavelength data, named 'wl', and the remaining column containing
#' spectra to process.
#' @param subset Either `FALSE` (the default), `TRUE`, or a character vector.
#' If `FALSE`, all variables calculated are returned. If `TRUE`, only a subset
#' of the complete output (composed of B2, S8 and H1; the variables described in
#' Andersson and Prager 2006) are returned. Finally, a user-specified string of variable
#' names can be used in order to filter and show only those variables.
#' @param wlmin,wlmax minimum and maximum used to define the range of wavelengths used in
#' calculations (default is to use entire range in the `rspec` object).
#' @param ... class consistency (ignored)
#'
#' @return A data frame containing either 23 or 5 (`subset = TRUE`) variables described
#' in Montgomerie (2006) with spectra name as row names.
#' The colorimetric variables calculated by this function are
#' described in Montgomerie (2006) with corrections included in the README CLR
#' file from the May 2008 distribution of the CLR software. Authors should reference
#' both this package,Montgomerie (2006), and the original reference(s).
#' Description and notes on the measures:
#'
#' B1 (Total brightness): Sum of the relative reflectance over the entire spectral
#' range (area under the curve). Frequently used but should be discouraged because
#' values are difficult to compare across studies (B2 is preferred). REF 1-3, 7, 9-11,
#' 13
#'
#' B2 (Mean brightness): Mean relative reflectance over the entire spectral range.
#' This is preferred to B1 since values are easier to compare across studies. REF 4, 12
#'
#' B3 (Intensity): Maximum relative reflectance (Reflectance at wavelength of maximum
#' reflectance). Note that may be sensitive to noise near the peak. REF 1, 5, 6
#'
#' S1 (Chroma): Relative contribution of a spectral range to the total brightness (B1)
#' S1 is arbitrarily divided in 6 measures of chroma based on the wavelength ranges
#' normally associated with specific hues. The values are calculated using the
#' following ranges: S1U (UV, if applicable): lambda min-400nm;
#' S1V (Violet) lambda min-415nm; S1B (Blue) 400nm-510nm; S1G (Green) 510nm-605nm;
#' S1Y (Yellow) 550nm-625nm; S1R (Red) 605nm-lambda max. REF 2, 7, 8, 11-13
#'
#' S2 (Spectral saturation): Rmax/Rmin This measure is sensitive to spectral noise.
#' Proper interpretation of this value may be difficult for spectra with multiple
#' peaks in the range of interest. REF 1
#'
#' S3 (Chroma): Reflectance over the Rmax +- 50nm range divided by B1. Values for peaks
#' within 50nm of either the minimum or maximum range of the data will not be comparable
#' since the area under the curve for the area of interest will not always
#' be based on the same wavelength range. Therefore, S3 should be interpreted
#' with caution for peaks in the UV or Red range. REF 11
#'
#' S4 (Spectral purity): |bmaxneg| , calculated by approximating the derivative
#' of the spectral curve. As such, it is very sensitive to noise and should only
#' be considered when data is adequately smoothed. NAs are returned for curves which
#' do not, at any range of wavelength, decrease in intensity. Therefore, reflectance
#' curves for brown and red surfaces, for example, should not generate a values. REF 1
#'
#' S5 (Chroma): Similar in design to segment classification measures (see Montgomerie 2006
#' for details). REF 10
#'
#' S6 (Contrast): Rmax - Rmin. Because it uses both Rmin and Rmax, this measure may be
#' sensitive to spectral noise. REF 5, 6
#'
#' S7 (Spectral saturation): Difference between the relative reflectance before and after
#' the wavelength at which reflectance is halfway between its minimum (Rmin)
#' and its maximum (Rmax). Somewhat sensitive
#' to noise and can be misleading when more than one maxima and/or minima are present.
#' REF 3, 9
#'
#' S8 (Chroma): (Rmax - Rmin)/B2. Because it uses both Rmin and Rmax, this measure may be
#' sensitive to spectral noise. REF 3, 13
#'
#' S9 (Carotenoid chroma): (R700 - R450)/R700. Should only be used when the colour
#' of the surface is clearly due to carotenoid pigmentation and R450 is lower than
#' R700. Could be sensitive to noise. REF 8
#'
#' S10 (Peaky chroma): (Rmax - Rmin)/B2 x |bmaxneg|. Should be used with properly
#' smoothed curves. REF 7
#'
#' H1 (Peak wavelength, hue): Wavelength of maximum reflectance. May be sensitive to noise
#' and may be variable if there is more than one maxima. REF 1, 2, 4, 6, 7, 10-13
#'
#' H2 (Hue): Wavelength at bmaxneg. Should be calculated using smoothed data. REF 2, 13
#'
#' H3 (Hue): Wavelength at Rmid. Sensitive to noisy spectra and may be variable if there are
#' more than one maxima and minima. REF 3, 9, 13
#'
#' H4 (Hue): Similar in design to segment classification measures see Montgomerie
#' (2006) for details. REF 10
#'
#' H5 (Hue): Wavelength at bmax. Sensitive to noise and may be variable if there is
#' more than one maxima and minima. REF 5
#' @note If minimum wavelength is over 400, UV chroma is not computed.
#' @note Variables which compute bmax and bmaxneg should be used with caution, for they
#' rely on smoothed curves to remove noise, which would otherwise result in spurious
#' results. Make sure chosen smoothing parameters are adequate.
#' @note Smoothing affects only B3, S2, S4, S6, S10, H2, and H5 calculation. All other
#' variables can be reliably extracted using non-smoothed data.
#' 
#' @importFrom stats quantile
#'
#' @export
#'
#' @examples
#' data(sicalis)
#' summary(sicalis)
#' summary(sicalis, subset = TRUE)
#' summary(sicalis, subset = c("B1", "H4"))
#' @author Pierre-Paul Bitton \email{bittonp@@windsor.ca}, Rafael Maia \email{rm72@@zips.uakron.edu}
#'
#' @references Montgomerie R. 2006. Analyzing colors. In Hill, G.E, and McGraw, K.J., eds.
#' Bird Coloration. Volume 1 Mechanisms and measurements. Harvard University Press, Cambridge, Massachusetts.
#' @references References describing variables:
#'
#' 1- Andersson, S. 1999. Morphology of uv reflectance in a whistling-thrush: Implications for the study
#' of structural colour signalling in birds. Journal of Avian Biology 30:193-204.
#'
#' 2- Andersson, S., J. Ornborg, and M. Andersson. 1998. Ultraviolet sexual dimorphism and assortative
#' mating in blue tits. Proceedings of the Royal Society B 265:445-450.
#'
#' 3- Andersson, S., S. Pryke, J. Ornborg, M. Lawes, and M. Andersson. 2002. Multiple receivers, multiple
#' ornaments, and a trade-off between agonistic and epigamic signaling in a widowbird. American
#' Naturalist 160:683-691.
#'
#' 4- Delhey, K., A. Johnsen, A. Peters, S. Andersson, and B. Kempenaers. 2003. Paternity analysis reveals
#' opposing selection pressures on crown coloration in the blue tit (Parus caeruleus). Proceedings
#' of the Royal Society B 270:2057-2063.
#'
#' 5- Keyser, A. and G. Hill. 1999. Condition-dependent variation in the blue-ultraviolet coloration of a
#' structurally based plumage ornament. Proceedings of the Royal Society B 266:771-777.
#'
#' 6- Keyser, A.J. and G. Hill. 2000. Structurally based plumage coloration is an honest signal of quality in
#' male blue grosbeaks. Behavioural Ecology 11:202-209.
#'
#' 7- Ornborg, J., S. Andersson, S. Griffith, and B. Sheldon. 2002. Seasonal changes in a ultraviolet
#' structural colour signal in blue tits, Parus caeruleus. Biological Journal of the Linnean Society
#' 76:237-245.
#'
#' 8- Peters, A., A. Denk, K. Delhey, and B. Kempenaers. 2004. Carotenoid-based bill colour as an
#' indicator of immunocompetence and sperm performance in male mallards. Journal of
#' Evolutionary Biology 17:1111-1120.
#'
#' 9- Pryke, S., M. Lawes, and S. Andersson. 2001. Agonistic carotenoid signalling in male red-collared
#' widowbirds: Aggression related to the colour signal of both the territory owner and model
#' intruder. Animal Behaviour 62:695-704.
#'
#' 10- Saks, L., K. Mcgraw, and P. Horak. 2003. How feather colour reflects its carotenoid content.
#' Functional Ecology 17:555-561.
#'
#' 11- Shawkey, M., A. Estes, L. Siefferman, and G. Hill. 2003. Nanostructure predicts intraspecific
#' variation in ultraviolet-blue plumage colour. Proceedings of the Royal Society B
#' 270:1455-1460.
#'
#' 12- Siefferman, L. and G. Hill. 2005. UV-blue structural coloration and competition for nestboxes in male
#' eastern bluebirds. Animal Behaviour 69:67-72.
#'
#' 13- Smiseth, P., J. Ornborg, S. Andersson, and T. Amundsen. 2001. Is male plumage reflectance
#' correlated with paternal care in bluethroats? Behavioural Ecology 12:164-170.
#'
summary.rspec <- function(object, subset = FALSE, wlmin = NULL, wlmax = NULL, ...) {
  chkDots(...)

  wl <- isolate_wl(object, keep = "wl")

  # Set WL min & max
  lambdamin <- max(wlmin, min(wl))
  lambdamax <- min(wlmax, max(wl))

  if (!is.null(wlmin) && lambdamin > wlmin) {
    stop("wlmin is smaller than the range of spectral data")
  }
  if (!is.null(wlmax) && lambdamax < wlmax) {
    stop("wlmax is larger than the range of spectral data")
  }

  # Restrict to range of wlmin:wlmax
  object <- object[which(wl == lambdamin):which(wl == lambdamax), ]

  wl <- isolate_wl(object, keep = "wl")
  object <- isolate_wl(object, keep = "spec")

  output.mat <- matrix(nrow = ncol(object), ncol = 23)

  # Three measures of brightness
  B1 <- colSums(object)

  B2 <- colMeans(object)

  B3 <- vapply(object, max, numeric(1))

  Rmin <- vapply(object, min, numeric(1))

  Rmid <- (B3 + Rmin) / 2

  # Chromas

  # Red
  if (lambdamin <= 605 & lambdamax >= 700) {
    Redchromamat <- object[wl >= 605 & wl <= 700, , drop = FALSE] # red 605-700nm inclusive
    Redchroma <- colSums(Redchromamat) / B1 # S1 red
    output.mat[, 9] <- Redchroma
  } else {
    warning("cannot calculate red chroma; wavelength range not between 605 and 700 nm", call. = FALSE)
  }

  # Yellow
  if (lambdamin <= 550 & lambdamax >= 625) {
    Yellowchromamat <- object[wl >= 550 & wl <= 625, , drop = FALSE] # yellow 550-625nm
    Yellowchroma <- colSums(Yellowchromamat) / B1 # S1 yellow
    output.mat[, 8] <- Yellowchroma
  } else {
    warning("cannot calculate yellow chroma; wavelength range not between 550 and 625 nm", call. = FALSE)
  }

  # Green
  if (lambdamin <= 510 & lambdamax >= 605) {
    Greenchromamat <- object[wl >= 510 & wl <= 605, , drop = FALSE] # green 510-605nm inlusive
    Greenchroma <- colSums(Greenchromamat) / B1 # S1 green
    output.mat[, 7] <- Greenchroma
  } else {
    warning("cannot calculate green chroma; wavelength range not between 510 and 605 nm", call. = FALSE)
  }

  # Blue
  if (lambdamin <= 400 & lambdamax >= 510) {
    Bluechromamat <- object[wl >= 400 & wl <= 510, , drop = FALSE] # blue 400-510nm inclusive
    Bluechroma <- colSums(Bluechromamat) / B1 # S1 blue
    output.mat[, 6] <- Bluechroma
  } else {
    warning("cannot calculate blue chroma; wavelength range not between 400 and 510 nm", call. = FALSE)
  }

  # UV
  if (lambdamin <= 400 & lambdamax >= 400) {
    UVchromamat <- object[wl >= lambdamin & wl <= 400, , drop = FALSE]
    UVchroma <- colSums(UVchromamat) / B1 # S1 UV
    output.mat [, 4] <- UVchroma
  } else {
    warning("cannot calculate UV chroma; wavelength range not below 400 nm", call. = FALSE)
  }

  if (lambdamin > 300 & lambdamin < 400) {
    warning("Minimum wavelength is ", lambdamin, "; UV-related variables may not be meaningful", call. = FALSE)
  }

  # Violet
  if (lambdamin <= 415 & lambdamax >= 415) {
    Vchromamat <- object[wl >= lambdamin & wl <= 415, , drop = FALSE]
    Vchroma <- colSums(Vchromamat) / B1 # S1 Violet
    output.mat[, 5] <- Vchroma
  } else {
    warning("cannot calculate violet chroma; wavelength below 415 nm", call. = FALSE)
  }

  # lambda Rmax hue
  H1 <- wl[max.col(t(object), ties.method = "first")]

  # Segment-based variables

  segmts <- trunc(quantile(lambdamin:lambdamax, names = FALSE))

  Q1 <- wl >= segmts[1] & wl <= segmts[2]
  Q2 <- wl >= segmts[2] & wl <= segmts[3]
  Q3 <- wl >= segmts[3] & wl <= segmts[4]
  Q4 <- wl >= segmts[4] & wl <= segmts[5]

  S5R <- colSums(object[Q4, , drop = FALSE])
  S5Y <- colSums(object[Q3, , drop = FALSE])
  S5G <- colSums(object[Q2, , drop = FALSE])
  S5B <- colSums(object[Q1, , drop = FALSE])

  S5 <- sqrt((S5R - S5G)^2 + (S5Y - S5B)^2)

  H4 <- atan2(S5Y - S5B, S5R - S5G)

  # Carotenoid chroma

  R450 <- as.numeric(object[which(wl == 450), , drop = FALSE])
  R700 <- as.numeric(object[which(wl == 700), , drop = FALSE])
  Carotchroma <- (R700 - R450) / R700

  # H3
  index_Rmid <- vapply(seq_len(ncol(object)), function(x) {
    which.min(abs(object[, x] - Rmid[x]))
  }, numeric(1))
  H3 <- wl[index_Rmid]

  # S7

  S7 <- vapply(seq_len(ncol(object)), function(col) {
    spec <- object[, col]
    index_Rmid_spec <- index_Rmid[col]
    spec_low <- spec[seq_len(index_Rmid_spec)]
    spec_high <- spec[index_Rmid_spec:length(spec)]

    return(sum(spec_low) - sum(spec_high))
  }, numeric(1))

  S7 <- S7 / B1


  # S3
  S3 <- vapply(seq_len(ncol(object)), function(col) {
    spec <- object[, col]
    H1_spec <- H1[col]
    sum(spec[wl >= (H1_spec - 50) & wl <= (H1_spec + 50)])
  }, numeric(1))
  S3 <- S3 / B1

  # Spectral saturation
  S2 <- B3 / Rmin # S2

  S6 <- B3 - Rmin # S6

  S8 <- S6 / B2 # S8

  # H2
  diffsmooth <- apply(object, 2, diff)

  # Spectra that are monotically increasing or decreasing
  incr <- apply(diffsmooth, 2, min) > 0
  decr <- apply(diffsmooth, 2, max) < 0

  lambdabmaxneg <- wl[apply(diffsmooth, 2, which.min)] # H2
  lambdabmaxneg[incr] <- NA

  # S4
  bmaxneg <- abs(apply(diffsmooth, 2, min)) # S4
  bmaxneg[incr] <- NA

  # S10
  S10 <- S8 * bmaxneg # S10

  # H5
  lambdabmax <- wl[apply(diffsmooth, 2, which.max)] # H5
  lambdabmax[decr] <- NA


  # Add remaining variables to output

  output.mat[, 1] <- B1
  output.mat[, 2] <- B2
  output.mat[, 3] <- B3
  output.mat[, 10] <- S2
  output.mat[, 11] <- S3
  output.mat[, 12] <- bmaxneg
  output.mat[, 13] <- S5
  output.mat[, 14] <- S6
  output.mat[, 15] <- S7
  output.mat[, 16] <- S8
  output.mat[, 17] <- Carotchroma
  output.mat[, 18] <- S10
  output.mat[, 19] <- H1
  output.mat[, 20] <- lambdabmaxneg
  output.mat[, 21] <- H3 # Rmid
  output.mat[, 22] <- H4
  output.mat[, 23] <- lambdabmax

  # PPB added S1v and S1Y


  color.var <- data.frame(output.mat, row.names = names(object))

  colvarnames <- c(
    "B1", "B2", "B3", "S1U", "S1V", "S1B", "S1G",
    "S1Y", "S1R", "S2", "S3", "S4", "S5", "S6", "S7", "S8",
    "S9", "S10", "H1", "H2", "H3", "H4", "H5"
  )

  names(color.var) <- colvarnames

  if (is.logical(subset)) {
    if (subset) {
      color.var <- color.var[c("B2", "S8", "H1")]
    }
  } else {
    # check if any color variables selected don't exist
    if (all(subset %in% colvarnames)) {
      color.var <- color.var[subset]
    } else {
      stop("Names in ", dQuote("subset"), " do not match color variable names")
    }
  }

  color.var
}
