#' Plot a Maxwell triangle
#'
#' Produces a Maxwell triangle plot.
#'
#' @param tridata (required) a data frame, possibly a result from the
#'   [colspace()] or [trispace()] function, containing values for the 'x' and
#'   'y' coordinates as columns (labeled as such).
#' @param achro should a point be plotted at the origin (defaults to `TRUE`)?
#' @param labels logical. Should the name of each cone be printed next to the
#'   corresponding vertex?
#' @param labels.cex  size of the arrow labels.
#' @param achrosize size of the point at the origin when `achro = TRUE`
#'   (defaults to `0.8`).
#' @param achrocol color of the point at the origin `achro = TRUE` (defaults to
#'   `'grey'`).
#' @param out.lwd,out.lcol,out.lty graphical parameters for the plot outline.
#' @param margins margins for the plot.
#' @param square logical. Should the aspect ratio of the plot be held to 1:1?
#'   (defaults to `TRUE`).
#' @param ... additional graphical options. See [par()].
#'
#' @examples
#' data(flowers)
#' vis.flowers <- vismodel(flowers, visual = "apis")
#' tri.flowers <- colspace(vis.flowers, space = "tri")
#' plot(tri.flowers)
#'
#' @author Thomas White \email{thomas.white026@@gmail.com}
#'
#' @export
#'
#' @keywords internal
#'
#' @inherit trispace references


triplot <- function(tridata, labels = TRUE, achro = TRUE, achrocol = "grey", achrosize = 0.8,
                    labels.cex = 1, out.lwd = 1, out.lcol = "black", out.lty = 1,
                    margins = c(1, 1, 2, 2), square = TRUE, ...) {
  par(mar = margins)

  if (square) {
    par(pty = "s")
  }

  arg <- list(...)

  # Set defaults
  if (is.null(arg$pch)) {
    arg$pch <- 19
  }
  if (is.null(arg$xlim)) {
    arg$xlim <- c(-1 / sqrt(2), 1 / sqrt(2))
  }
  if (is.null(arg$ylim)) {
    arg$ylim <- c(-sqrt(2) / (2 * (sqrt(3))), sqrt(2) / sqrt(3))
  }

  # Verticy coordinates
  vert <- data.frame(
    x = c(0, -1 / sqrt(2), 1 / sqrt(2)),
    y = c(sqrt(2) / sqrt(3), -sqrt(2) / (2 * (sqrt(3))), -sqrt(2) / (2 * (sqrt(3))))
  )

  # Plot
  arg$x <- tridata$x
  arg$y <- tridata$y
  arg$xlab <- ""
  arg$ylab <- ""
  arg$bty <- "n"
  arg$axes <- FALSE

  do.call(plot, c(arg, type = "n"))

  # Add lines
  polygon(vert, lwd = out.lwd, lty = out.lty, border = out.lcol)

  # Origin
  if (isTRUE(achro)) {
    points(x = 0, y = 0, pch = 15, col = achrocol, cex = achrosize)
  }

  # remove plot-specific args, add points after the stuff is drawn
  arg[c(
    "type", "xlim", "ylim", "log", "main", "sub", "xlab", "ylab",
    "ann", "axes", "frame.plot", "panel.first", "panel.last", "asp"
  )] <- NULL
  do.call(points, arg)


  # Add text (coloured points better as in tcsplot?)
  if (isTRUE(labels)) {
    text(vert,
         labels = c("S", "M", "L"),
         pos = c(3, 2, 4),
         xpd = TRUE,
         cex = labels.cex)
  }
}
