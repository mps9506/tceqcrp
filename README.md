
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tceqcrp

<!-- badges: start -->

[![R-CMD-check](https://github.com/mps9506/tceqcrp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mps9506/tceqcrp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Scripted downloads from the TCEQ Clean Rivers Program (CRP) water
quality data portal.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("mps9506/tceqcrp")
```

## Quick Start

### Concepts

- **Basin**: a major river basin (1-25), e.g. Brazos River.
- **Segment**: a subdivision within a basin (e.g. `1202`, “Brazos River
  Below Navasota River”). You select which segments to download.
- **Station**: an individual monitoring site (e.g. `11846`). Stations
  appear in the `Station ID` / `Station Description` columns of the
  downloaded data — they are not selected directly.

``` r
library(tceqcrp)

# See what's available
crp_basins()
#> # A tibble: 25 × 2
#>    value label                      
#>    <chr> <chr>                      
#>  1 1     CANADIAN RIVER             
#>  2 2     RED RIVER                  
#>  3 3     SULPHUR RIVER              
#>  4 4     CYPRESS RIVER              
#>  5 5     SABINE RIVER               
#>  6 6     NECHES RIVER               
#>  7 7     NECHES-TRINITY COASTAL     
#>  8 8     TRINITY RIVER              
#>  9 9     TRINITY-SAN JACINTO COASTAL
#> 10 10    SAN JACINTO RIVER          
#> # ℹ 15 more rows
crp_data_types()
#> # A tibble: 16 × 2
#>    value label                        
#>    <chr> <chr>                        
#>  1 16    24 hour                      
#>  2 4     CRP-Bacteria                 
#>  3 8     CRP-Metals in Water          
#>  4 5     Dissolved Minerals(mg/L)     
#>  5 3     Dissolved Solids             
#>  6 1     Field Water Quality          
#>  7 7     Flow                         
#>  8 9     Metals in Sediment(mg/kg)    
#>  9 2     Nutrients                    
#> 10 15    Organics in Sediment(ug/kg)  
#> 11 10    Organics in Water(ug/L)      
#> 12 13    PCBs in Sediment(ug/kg)      
#> 13 11    PCBs in Water(ug/L)          
#> 14 14    Pesticides in Sediment(ug/kg)
#> 15 12    Pesticides in Water(ug/L)    
#> 16 6     Sample Site Metadata

# List segments in the Brazos River basin
segments <- crp_list_segments(basin = 12)
head(segments)
#> # A tibble: 6 × 3
#>     row segment_id segment_desc                     
#>   <int> <chr>      <chr>                            
#> 1     0 1201       Brazos River Tidal               
#> 2     1 1202       Brazos River Below Navasota River
#> 3     2 1202A      Beason Creek                     
#> 4     3 1202B      Rabbs Bayou                      
#> 5     4 1202C      Hog Branch                       
#> 6     5 1202D      New Year Creek

# Download Field Water Quality data for two stations
brazos <- crp_query(
  basin       = 12,
  startdate   = "01/01/2020",
  enddate     = "12/31/2020",
  data_type   = 1,              # Field Water Quality
  segment_ids = c("1201", "1202"),
  clean_names = TRUE
)
#> POST returned status: 302
#> Location header: https://www80.tceq.texas.gov/SwqmisWeb/StreamServlet
#> StreamServlet status: 200
#> Downloaded 23782 bytes to C:\Users\MICHAE~1.SCH\AppData\Local\Temp\Rtmp6Z3je4\file5b28627e2777.txt
brazos
#> # A tibble: 180 × 20
#>    rfa_sample_set_id_tag…¹ segment station_id station_description parameter_code
#>    <chr>                   <chr>   <chr>      <chr>               <chr>         
#>  1 BR113540                1202    11846      BRAZOS RIVER AT US… 00010         
#>  2 BR114009                1202    11850      BRAZOS RIVER AT US… 00010         
#>  3 BR113714                1202    21816      BRAZOS RIVER AT FM… 00010         
#>  4 BR113755                1202    21816      BRAZOS RIVER AT FM… 00010         
#>  5 BR114460                1202    11850      BRAZOS RIVER AT US… 00300         
#>  6 BR113541                1202    11850      BRAZOS RIVER AT US… 00300         
#>  7 BR114457                1202    16355      BRAZOS RIVER AT FM… 00300         
#>  8 BR113756                1202    11846      BRAZOS RIVER AT US… 00094         
#>  9 BR113541                1202    11850      BRAZOS RIVER AT US… 00094         
#> 10 BR113716                1202    11850      BRAZOS RIVER AT US… 00094         
#> # ℹ 170 more rows
#> # ℹ abbreviated name: ¹​rfa_sample_set_id_tag_id
#> # ℹ 15 more variables: parameter_description <chr>,
#> #   greater_than_less_than <chr>, value <dbl>, end_date <date>,
#> #   end_time <time>, end_depth <dbl>, start_date <date>, start_time <time>,
#> #   start_depth <dbl>, composite_category <chr>, composite_type <chr>,
#> #   submitting_entity <chr>, collecting_entity <chr>, monitoring_type <chr>, …
```

## How it works

The CRP portal is a JavaServer Faces (JSF) application. This package:

- Opens a session and captures the JSF ViewState token.
- Selects a river basin (which repopulates the station list
  server-side).
- Submits the query and follows the redirect to StreamServlet, which
  streams a tab-delimited data file.

Session cookies are preserved across all requests so the server keeps
the query state consistent.

## Disclaimer

This package accesses a public TCEQ website by mimicking browser form
submissions. It is not affiliated with or endorsed by TCEQ. Please use
responsibly and review TCEQ’s terms of use.
