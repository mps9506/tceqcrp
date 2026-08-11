#' @keywords internal
crp_base_url <- function() {
  "https://www80.tceq.texas.gov/SwqmisWeb/public/crpweb.faces"
}

#' @keywords internal
crp_stream_url <- function() {
  "https://www80.tceq.texas.gov/SwqmisWeb/StreamServlet"
}

#' @keywords internal
crp_cookie_path <- function() {
  path <- getOption("tceqcrp.cookiejar")
  if (is.null(path)) {
    path <- tempfile("crp_cookies_", fileext = ".txt")
    options(tceqcrp.cookiejar = path)
  }
  path
}

#' @keywords internal
crp_request <- function() {
  httr2::request(crp_base_url()) |>
    httr2::req_user_agent("tceqcrp R package (https://github.com/you/tceqcrp)") |>
    httr2::req_cookie_preserve(crp_cookie_path())
}

#' @keywords internal
crp_parse_form <- function(resp) {
  html <- rvest::read_html(httr2::resp_body_string(resp))
  vs <- html |>
    rvest::html_element("input[name='javax.faces.ViewState']") |>
    rvest::html_attr("value")
  if (is.na(vs)) {
    stop("No ViewState found - the site may be blocking automated requests.")
  }
  structure(
    list(view_state = vs, html = html, response = resp),
    class = "crp_form"
  )
}

#' Start a CRP session
#'
#' Fetches the CRP query page, establishes a session, and captures the
#' JSF ViewState token needed for subsequent requests.
#'
#' @return An object of class `crp_form`.
#' @export
#' @examples
#' \dontrun{
#' form <- crp_get_form()
#' }
crp_get_form <- function() {
  resp <- crp_request() |> httr2::req_perform()
  crp_parse_form(resp)
}
