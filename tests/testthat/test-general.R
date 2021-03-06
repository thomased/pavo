context("general")

test_that("Class assignment", {
  data(flowers)

  # Check rspec
  # See test-S3rspec.R

  # Check vismodel
  vis.flowers <- vismodel(flowers, visual = "apis")
  expect_is(vis.flowers, "vismodel")

  # Check a few colorspaces
  vis.cie <- vismodel(flowers, vonkries = TRUE, relative = FALSE, achro = "none", visual = "cie10")
  col.cie <- colspace(vis.cie, space = "cielab")
  expect_is(col.cie, "colspace")

  vis.tcs <- vismodel(flowers, visual = "bluetit")
  col.tcs <- colspace(vis.tcs, space = "tcs")
  expect_is(col.cie, "colspace")

  vis.hex <- vismodel(flowers, relative = FALSE, qcatch = "Ei", vonkries = TRUE, visual = "apis")
  col.hex <- colspace(vis.hex, space = "hex")
  expect_is(col.hex, "colspace")
})

test_that("sensdata", {
  library(digest)
  expect_true(all(names(as.data.frame(vissyst)) %in% names(sensdata("all", "all"))))
  expect_equal(digest::sha1(sensdata(illum = 'all', bkg = 'all', trans = 'all'), digits = 4),
               "4e25ee65b1a5d3a993baf4ba11b6ad7c15348704")
})

test_that("peakshape", {
  data(flowers)

  expect_equivalent(round(colSums(peakshape(flowers, select = 1:5, lim = c(300, 700), plot = FALSE)[2:3])), c(216, 2617))

  test <- read.csv("known_output/FWHM_lims.csv")
  expect_equal(peakshape(test, plot = FALSE)[, 4], c(144, 52))

  expect_warning(peakshape(flowers[, -1], plot = FALSE), "wl column missing")

  expect_equivalent(
    nrow(peakshape(flowers, grepl("^Hibbertia", colnames(flowers)), plot = FALSE)),
    6
  )

  # Double peak
  dblpkspec <- data.frame(wl = 300:700,
                          spec = dnorm(300:700, 400, 10) + dnorm(300:700, 600, 10))
  expect_warning(peakshape(dblpkspec), "Using first peak found")

  expect_null(peakshape(flowers, select = FALSE))

  expect_equivalent(
    digest::sha1(peakshape(flowers, absolute.min = TRUE), digits = 5),
    "d257957d21449f28fd24a9a0a33220dcd9a371bd"
  )

  expect_warning(
    peakshape(flowers, lim = c(300, 400), plot = FALSE),
    "incorporate all minima in spectral curves"
  )
})
