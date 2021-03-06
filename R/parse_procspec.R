#' Import ProcSpec spectra file
#'
#' Internal function used by [getspec()] to parse ProcSpec files
#' generated by the OceanOptics software spectrasuite.
#'
#' @param path Path of the ProcSpec file
#'
#' @return A dataframe with 2 columns: first column contains the wavelengths and
#' second column contains the processed spectrum
#'
#' @keywords internal
#'
#' @author Hugo Gruson \email{hugo.gruson+R@@normalesup.org}
#'
#' @seealso [getspec()]
#'
parse_procspec <- function(path) {
  # We let R find the suitable tmp folder to extract files
  extracted_files <- utils::unzip(
    zipfile = path,
    exdir = tempdir()
  )

  # According to OceanOptics FAQ [1], each procspec archive will only contain
  # one XML spectra file.
  # [1] https://oceanoptics.com/faq/extract-data-procspec-file-without-spectrasuite/

  # Data files have the format ps_\d+.xml
  data_file <- grep(pattern = "ps_\\d+\\.xml", extracted_files, value = TRUE)

  # OceanOptics softwares produce badly encoded characters. The only fix is to
  # strip them before feeding the xml file to read_xml.
  plain_text <- scan(data_file, what = "character", sep = "\n")
  clean_text <- sapply(plain_text, function(line) {
    # Convert non-ASCII character to ""
    line <- iconv(line, to = "ASCII", sub = "")
    # Remove the extra malformed character
    line <- gsub("\\\001", "", line)

    return(line)
  }, USE.NAMES = FALSE)

  tmp_file <- tempfile(pattern = "clean_ps_", fileext = ".xml")
  writeLines(paste(clean_text, collapse = "\n"), tmp_file)

  # TODO: it should be possible to read clean_text directly without having to
  # add disk I/O (that may be critical for very large files collections).
  #
  # Because the file is non ASCII, we don't need to specify the encoding.
  xml_source <- xml2::read_xml(tmp_file)

  wl_node <- xml2::xml_find_all(xml_source, ".//channelWavelengths")
  wl_values <- xml2::xml_find_all(wl_node, ".//double")
  # Get rid of the XML tags.
  wl <- xml2::xml_text(wl_values)

  procspec_node <- xml2::xml_find_all(xml_source, ".//processedPixels")
  procspec_values <- xml2::xml_find_all(procspec_node, ".//double")
  # Get rid of the XML tags.
  procspec <- xml2::xml_text(procspec_values)

  spec_df <- cbind(wl, procspec)
  # The XML file was considered as text. So are "wl" and "procspec" columns.
  spec_df <- apply(X = spec_df, MARGIN = 2, FUN = as.numeric)
  spec_df <- as.data.frame(spec_df)

  return(spec_df)
}
