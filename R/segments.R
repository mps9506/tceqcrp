#' Select a river basin and retrieve its segment list
#'
#' @param form A `crp_form` from [crp_get_form()].
#' @param basin Basin number (1-25). See [crp_basins()].
#' @return A new `crp_form` with the segment table populated and a fresh
#'   ViewState. Pass this to [crp_segments()] and [crp_download()].
#' @export
crp_select_basin <- function(form, basin) {
  resp <- crp_request() |>
    httr2::req_headers(
      Referer = crp_base_url(),
      Origin  = "https://www80.tceq.texas.gov"
    ) |>
    httr2::req_body_form(
      "form1"                 = "form1",
      "form1:menu23"          = as.character(basin),
      "javax.faces.ViewState" = form$view_state
    ) |>
    httr2::req_perform()
  crp_parse_form(resp)
}

#' Extract the segment table for the selected basin
#'
#' @param form A `crp_form` from [crp_select_basin()].
#' @return A tibble with columns `row`, `segment_id`, `segment_desc`.
#' @export
crp_segments <- function(form) {
  checks <- rvest::html_elements(
    form$html,
    "input[name*='table3'][type='checkbox']"
  )
  names_attr <- rvest::html_attr(checks, "name")
  row_match <- stringr::str_match(names_attr, "table3:(\\d+):checkbox1a")
  keep <- !is.na(row_match[, 2])
  rows <- as.integer(row_match[keep, 2])
  segment_checks <- checks[keep]

  cell_list <- lapply(segment_checks, function(cb) {
    tr <- rvest::html_element(cb, xpath = "ancestor::tr[1]")
    tds <- rvest::html_elements(tr, "td")
    rvest::html_text(tds, trim = TRUE)
  })

  segment_id <- vapply(
    cell_list,
    function(x) if (length(x) >= 2) x[[2]] else NA_character_,
    character(1)
  )
  segment_desc <- vapply(
    cell_list,
    function(x) if (length(x) >= 3) x[[3]] else NA_character_,
    character(1)
  )

  tibble::tibble(
    row          = rows,
    segment_id   = segment_id,
    segment_desc = segment_desc
  )
}

#' Find segment table rows by segment ID
#'
#' @param segments A tibble from [crp_segments()].
#' @param ids Character vector of segment IDs (e.g. `c("1202", "1202A")`).
#' @return Integer vector of `row` values for [crp_download()].
#' @export
crp_rows_for_segments <- function(segments, ids) {
  matched <- segments$row[segments$segment_id %in% as.character(ids)]
  missing <- setdiff(as.character(ids), segments$segment_id)
  if (length(missing) > 0) {
    warning("Segment IDs not found in this basin: ",
            paste(missing, collapse = ", "))
  }
  matched
}
