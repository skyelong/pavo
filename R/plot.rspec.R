#' Plot spectra
#'
#' Plots reflectance spectra in different arrangements.
#'
#' @param x (required) a data frame, possibly an object of class `rspec`, with a
#'   column with wavelength data, named 'wl', and the remaining column
#'   containing spectra to plot.
#' @param select specification of which spectra to plot. Can be a numeric vector
#'   or factor (e.g., `sex=="male"`)
#' @param type what type of plot should be drawn. Possibilities are:
#'    * `overlay` (default) for plotting multiple spectra in a single panel with
#'      a common y-axis.
#'    * `stack` for plotting multiple spectra in a vertical arrangement.
#'    * `heatmap` for plotting reflectance values by wavelength and a third
#'      variable (`varying`).
#' @param varying a numeric vector giving values for y-axis in
#' `type = "heatmap"`.
#' @param n number of bins with which to interpolate colors and `varying` for
#'   the heatplot.
#' @param labels.stack a vector of labels for the stacked spectra when using
#'   `type = "stack"`. Defaults to the numeric column ID's.
#' @param wl.guide logical determining whether visible light spectrum should be
#'   added to the x-axis.
#' @param ... additional arguments passed to [plot()] (or [image()] for
#'   `"heatmap"`).
#'
#' @export
#'
#' @examples
#' data(teal)
#' plot(teal, type = "overlay")
#' plot(teal, type = "stack")
#' plot(teal, type = "heatmap")
#' @author Chad Eliason \email{cme16@@zips.uakron.edu}
#' @author Thomas White \email{thomas.white026@@gmail.com}
#'
#' @seealso [spec2rgb()], [image()], [plot()]
#'
#' @importFrom magick image_read
#' @importFrom graphics axis image lines
#' @importFrom grDevices colorRampPalette
#' @importFrom stats approx
#' @importFrom utils tail

# TODO: add argument for padding region between x in stack plot

plot.rspec <- function(x, select = NULL, type = c("overlay", "stack", "heatmap"),
                       varying = NULL, n = 100, labels.stack = NULL,
                       wl.guide = TRUE, ...) {
  type <- match.arg(type)

  # make wavelength vector
  wl <- isolate_wl(x, keep = "wl")

  if (is.null(select)) {
    x <- isolate_wl(x, keep = "spec")
  } else {
    x <- isolate_wl(x[, select, drop = FALSE], keep = "spec")
  }

  # This line is needed for later because cols and lty are dropped depending on
  # select and if it remains NULL, everything is dropped.
  if (is.null(select)) {
    select <- seq_along(x)
  }

  arg <- list(...)

  # Set defaults
  if (is.null(arg$xlab)) {
    arg$xlab <- "Wavelength (nm)"
  }
  arg$x <- wl

  # heat plot
  if (type == "heatmap") {
    if (is.null(arg$ylab)) {
      arg$ylab <- "Index"
    }
    if (is.null(varying)) {
      varying <- seq_along(x)
      message("No varying vector supplied; using arbitrary values")
    }
    if (is.null(arg$ylim)) {
      arg$ylim <- range(varying, na.rm = TRUE)
    }
    if (is.null(arg$col)) {
      arg$col <- viridisLite::cividis(n)
    } else {
      jc <- colorRampPalette(arg$col)
      arg$col <- jc(n)
    }
    if (is.null(arg$lty)) {
      arg$lty <- 1
    }

    Index <- approx(varying, n = n)$y

    dat <- apply(x, 1, function(z) {
      approx(
        x = varying,
        y = z,
        n = n
      )$y
    })

    arg$y <- Index
    arg$z <- t(dat)

    do.call(image, arg)

  } else {

    # coloring for overlay plot & others
    if (length(arg$col) < ncol(x)) {
      arg$col <- rep(arg$col, ncol(x))
      arg$col <- arg$col[seq_along(x)]
    }

    if (any(names(arg$col) %in% names(x))) {
      arg$col <- arg$col[select - 1]
    }

    # line types for overlay plot & others
    if (length(arg$lty) < ncol(x)) {
      arg$lty <- rep(arg$lty, ncol(x))
      arg$lty <- arg$lty[seq_along(x)]
    }

    if (any(names(arg$lty) %in% names(x))) {
      arg$col <- arg$lty[select - 1]
    }
    arg$type <- "l"


    # overlay different spec curves
    if (type == "overlay") {
      if (is.null(arg$ylim)) {
        arg$ylim <- range(x, na.rm = TRUE)
      }
      if (is.null(arg$ylab)) {
        arg$ylab <- "Reflectance (%)"
      }
      arg$y <- x[, 1]
      col <- arg$col
      arg$col <- col[1]
      lty <- arg$lty
      arg$lty <- lty[1]


      do.call(plot, arg)

      if (ncol(x) > 1) {
        for (i in 2:ncol(x)) {
          arg$col <- col[i]
          arg$lty <- lty[i]
          arg$y <- x[, i]
          do.call(lines, arg)
        }
      }
    }

    # Stack curves along y-axis
    if (type == "stack") {
      if (is.null(arg$ylab)) {
        arg$ylab <- "Cumulative reflectance (arb. units)"
      }

      x2 <- as.data.frame(x[, c(rev(seq_along(x)))])
      if (length(select) == 1) {
        y <- max(x2)
      } else {
        y <- apply(x2, 2, max)
      }
      ym <- cumsum(y)
      ymins <- c(0, ym[-length(ym)])

      arg$y <- x2[, 1]
      if (is.null(arg$ylim)) {
        arg$ylim <- c(0, sum(y))
      }

      col <- rev(arg$col)
      arg$col <- col[1]
      do.call(plot, arg)
      if (ncol(x2) > 1) {
        for (i in 2:ncol(x2)) {
          arg$y <- x2[, i] + ymins[i]
          arg$col <- col[i]
          do.call(lines, arg)
        }
      }

      yend <- tail(x2, 1)
      yloc <- ymins + yend

      if (is.null(labels.stack)) {
        labels.stack <- rev(select)
      }

      axis(side = 4, at = yloc, labels = labels.stack, las = 1)
    }

    if (wl.guide) {
      vislight <- image_read(system.file("linear_visible_spectrum.png", package = "pavo"))
      rasterImage(
        vislight,
        380,
        grconvertY(0, from = "npc", to = "user"),
        750,
        grconvertY(0.03, from = "npc", to = "user")
      )
    }
  }
}
