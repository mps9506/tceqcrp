#' Download CRP water quality data
#'
#' @param form A `crp_form` from [crp_select_basin()] (must be the
#'   basin-selected form, which carries the correct ViewState).
#' @param startdate,enddate Date strings in `"MM/DD/YYYY"` format.
#' @param data_type Data type code. See [crp_data_types()].
#' @param basin Basin number. See [crp_basins()].
#' @param format Output format code (default `"14"`, combined). See
#'   [crp_formats()].
#' @param segment_rows Integer vector of table rows. See
#'   [crp_rows_for_segments()].
#' @param param_code Optional parameter code filter.
#' @param path File path to write the downloaded data to.
#' @param quiet Suppress progress messages.
#' @return Invisibly, a list with `path`, `post_resp`, and `stream_resp`.
#' @export
#' @examples
#' \dontrun{
#' form  <- crp_get_form()
#' form2 <- crp_select_basin(form, 12)
#' st    <- crp_stations(form2)
#' rows  <- crp_rows_for_ids(st, c("1201", "1202"))
#' crp_download(form2, "01/01/2020", "12/31/2020",
#'              data_type = 1, basin = 12, station_rows = rows,
#'              path = "brazos.txt")
#' }
crp_download <- function(form,
                         startdate,
                         enddate,
                         data_type,
                         basin,
                         format       = "14",
                         segment_rows,          # <- renamed
                         param_code   = "",
                         path         = tempfile(fileext = ".txt"),
                         quiet        = FALSE) {

  if (!inherits(form, "crp_form")) {
    stop("`form` must be a crp_form object from crp_select_basin().")
  }
  if (length(segment_rows) == 0) {                        # <- renamed
    stop("No segment_rows supplied - nothing to download.")
  }

  msg <- function(...) if (!quiet) message(...)

  body <- list(
    "form1"                 = "form1",
    "startdate"             = startdate,
    "enddate"               = enddate,
    "form1:param_code"      = param_code,
    "form1:menu2"           = as.character(data_type),
    "form1:menu23"          = as.character(basin),
    "form1:menu1"           = as.character(format),
    "form1:button2"         = "Generate",
    "javax.faces.ViewState" = form$view_state
  )
  for (r in segment_rows) {                                # <- renamed
    body[[sprintf("form1:table3:%d:checkbox1a", r)]] <- "on"
  }
  # Step A: POST the query. Do NOT follow the redirect automatically -
  # httr2 would otherwise loop (the servlet redirect confuses libcurl's
  # follower against the JSF session).
  post_resp <- crp_request() |>
    httr2::req_headers(
      Referer = crp_base_url(),
      Origin  = "https://www80.tceq.texas.gov"
    ) |>
    httr2::req_body_form(!!!body) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  status <- httr2::resp_status(post_resp)
  msg("POST returned status: ", status)

  if (status != 302) {
    # Not a redirect - likely an error page or expired session
    ctype <- httr2::resp_content_type(post_resp)
    if (grepl("html", ctype, ignore.case = TRUE)) {
      txt <- httr2::resp_body_string(post_resp)
      if (grepl("ViewExpired|exception", txt, ignore.case = TRUE)) {
        stop("Session expired. Re-run crp_get_form() and crp_select_basin().")
      }
    }
    stop("Expected a 302 redirect but got status ", status,
         ". The query may have returned no data.")
  }

  loc <- httr2::resp_header(post_resp, "location")
  msg("Location header: ", if (is.null(loc)) "<none>" else loc)

  stream_target <- if (!is.null(loc)) {
    xml2::url_absolute(loc, crp_base_url())
  } else {
    crp_stream_url()
  }

  # Step B: GET the StreamServlet with the SAME session cookies.
  stream_resp <- httr2::request(stream_target) |>
    httr2::req_user_agent("tceqcrp R package") |>
    httr2::req_cookie_preserve(crp_cookie_path()) |>
    httr2::req_headers(Referer = crp_base_url()) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform(path = path)

  msg("StreamServlet status: ", httr2::resp_status(stream_resp))

  size <- file.info(path)$size
  if (is.na(size) || size == 0) {
    warning("Downloaded file is empty - check your query parameters ",
            "(date range, data type, stations).")
  } else {
    msg("Downloaded ", size, " bytes to ", path)
  }

  invisible(list(
    path        = path,
    post_resp   = post_resp,
    stream_resp = stream_resp
  ))
}

#' Read a downloaded CRP data file
#'
#' @param path Path to a file written by [crp_download()].
#' @param ... Passed on to [readr::read_delim()].
#' @param clean_names If `TRUE`, convert column names to snake_case
#'   (requires the janitor package).
#' @return A tibble.
#' @export
crp_read <- function(path, clean_names = FALSE, ...) {

  col_types <- readr::cols(
    .default                   = readr::col_character(),
    `Value`                    = readr::col_double(),
    `End Date`                 = readr::col_date(format = "%m/%d/%Y"),
    `Start Date`               = readr::col_date(format = "%m/%d/%Y"),
    `End Depth`                = readr::col_double(),
    `Start Depth`              = readr::col_double(),
    `End Time`                 = readr::col_time(),
    `Start Time`               = readr::col_time(),
    `Start Depth`              = readr::col_double(),
    `Composite Category`       = readr::col_character(),
    `Composite Type`           = readr::col_character()

  )

  df <- readr::read_delim(
    path,
    delim          = "|",
    col_types      = col_types,
    show_col_types = FALSE,
    ...
  )
  if (clean_names) {
    if (!requireNamespace("janitor", quietly = TRUE)) {
      stop("`clean_names = TRUE` requires the 'janitor' package.")
    }
    df <- janitor::clean_names(df)
  }
  df
}
