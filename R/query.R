#' Download CRP data in a single call
#'
#' @param basin Basin number (1-25). See [crp_basins()].
#' @param startdate,enddate Date strings `"MM/DD/YYYY"`.
#' @param data_type Data type code. See [crp_data_types()].
#' @param segment_ids Character vector of segment IDs.
#' @param format Output format code (default combined).
#' @param param_code Optional parameter code filter.
#' @param path File path to write to.
#' @param read If `TRUE` (default), return the parsed tibble; otherwise the
#'   file path.
#' @param clean_names If `TRUE`, convert column names to snake_case (requires
#'   the janitor package). Ignored when `read = FALSE`.
#' @param quiet Suppress messages.
#' @return A tibble (if `read = TRUE`) or the file path (invisibly).
#' @export
#' @examples
#' \dontrun{
#' brazos <- crp_query(
#'   basin       = 12,
#'   startdate   = "01/01/2020",
#'   enddate     = "12/31/2020",
#'   data_type   = 1,
#'   segment_ids = "1202",
#'   clean_names = TRUE
#' )
#' }
crp_query <- function(basin,
                      startdate,
                      enddate,
                      data_type,
                      segment_ids,
                      format      = "14",
                      param_code  = "",
                      path        = tempfile(fileext = ".txt"),
                      read        = TRUE,
                      clean_names = FALSE,
                      quiet       = FALSE) {

  if (missing(segment_ids) || length(segment_ids) == 0) {
    stop("Please supply `segment_ids`. Use crp_list_segments(basin) to ",
         "see available segments.")
  }

  form  <- crp_get_form()
  form2 <- crp_select_basin(form, basin)
  seg   <- crp_segments(form2)
  rows  <- crp_rows_for_segments(seg, segment_ids)

  if (length(rows) == 0) {
    stop("None of the requested segment IDs were found in basin ", basin, ".")
  }

  res <- crp_download(
    form         = form2,
    startdate    = startdate,
    enddate      = enddate,
    data_type    = data_type,
    basin        = basin,
    format       = format,
    segment_rows = rows,
    param_code   = param_code,
    path         = path,
    quiet        = quiet
  )

  if (read) {
    crp_read(res$path, clean_names = clean_names)
  } else {
    invisible(res$path)
  }
}
#' List segments available in a basin
#'
#' @param basin Basin number (1-25). See [crp_basins()].
#' @return A tibble with `row`, `segment_id`, `segment_desc`.
#' @export
crp_list_segments <- function(basin) {
  form  <- crp_get_form()
  form2 <- crp_select_basin(form, basin)
  crp_segments(form2)
}
