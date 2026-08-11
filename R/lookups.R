#' CRP data type codes
#'
#' @return A tibble mapping menu values to data type labels.
#' @export
crp_data_types <- function() {
  tibble::tribble(
    ~value, ~label,
    "16", "24 hour",
    "4",  "CRP-Bacteria",
    "8",  "CRP-Metals in Water",
    "5",  "Dissolved Minerals(mg/L)",
    "3",  "Dissolved Solids",
    "1",  "Field Water Quality",
    "7",  "Flow",
    "9",  "Metals in Sediment(mg/kg)",
    "2",  "Nutrients",
    "15", "Organics in Sediment(ug/kg)",
    "10", "Organics in Water(ug/L)",
    "13", "PCBs in Sediment(ug/kg)",
    "11", "PCBs in Water(ug/L)",
    "14", "Pesticides in Sediment(ug/kg)",
    "12", "Pesticides in Water(ug/L)",
    "6",  "Sample Site Metadata"
  )
}

#' CRP output format codes
#'
#' @return A tibble mapping menu values to output-format labels.
#' @export
crp_formats <- function() {
  tibble::tribble(
    ~value, ~label,
    "14", "Combined Event/Result Data File",
    "15", "Event Data File",
    "16", "Result Data File"
  )
}

#' CRP river basin codes
#'
#' @return A tibble mapping basin numbers to basin names.
#' @export
crp_basins <- function() {
  tibble::tribble(
    ~value, ~label,
    "1",  "CANADIAN RIVER",
    "2",  "RED RIVER",
    "3",  "SULPHUR RIVER",
    "4",  "CYPRESS RIVER",
    "5",  "SABINE RIVER",
    "6",  "NECHES RIVER",
    "7",  "NECHES-TRINITY COASTAL",
    "8",  "TRINITY RIVER",
    "9",  "TRINITY-SAN JACINTO COASTAL",
    "10", "SAN JACINTO RIVER",
    "11", "SAN JACINTO-BRAZOS COASTAL",
    "12", "BRAZOS RIVER",
    "13", "BRAZOS-COLORADO COASTAL",
    "14", "COLORADO RIVER",
    "15", "COLORADO-LAVACA COASTAL",
    "16", "LAVACA RIVER",
    "17", "LAVACA-GUADALUPE COASTAL",
    "18", "GUADALUPE RIVER",
    "19", "SAN ANTONIO RIVER",
    "20", "SAN ANTONIO-NUECES COASTAL",
    "21", "NUECES RIVER",
    "22", "NUECES-RIO GRANDE COASTAL",
    "23", "RIO GRANDE RIVER",
    "24", "BAYS AND ESTUARIES",
    "25", "GULF OF MEXICO"
  )
}
