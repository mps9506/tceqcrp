test_that("crp_get_form establishes a session", {
  skip_on_cran()
  skip_if_offline("www80.tceq.texas.gov")

  form <- crp_get_form()
  expect_s3_class(form, "crp_form")
  expect_true(nzchar(form$view_state))
})

test_that("crp_select_basin populates segments", {
  skip_on_cran()
  skip_if_offline("www80.tceq.texas.gov")

  form  <- crp_get_form()
  form2 <- crp_select_basin(form, 12)   # Brazos

  seg <- crp_segments(form2)
  expect_s3_class(seg, "tbl_df")
  expect_named(seg, c("row", "segment_id", "segment_desc"))
  expect_gt(nrow(seg), 100)
  expect_true("1202" %in% seg$segment_id)
})

test_that("full query downloads and parses data", {
  skip_on_cran()
  skip_if_offline("www80.tceq.texas.gov")

  df <- crp_query(
    basin       = 12,
    startdate   = "01/01/2020",
    enddate     = "12/31/2020",
    data_type   = 1,          # Field Water Quality
    segment_ids = "1202"
  )

  expect_s3_class(df, "tbl_df")
  expect_gt(nrow(df), 0)

  # Column type expectations
  expect_type(df[["Segment"]], "character")
  expect_type(df[["Station ID"]], "character")
  expect_type(df[["Greater Than/Less Than"]], "character")
  expect_s3_class(df[["End Date"]], "Date")
  expect_type(df[["Value"]], "double")
})


test_that("crp_query cleans column names when requested", {
  skip_on_cran()
  skip_if_offline("www80.tceq.texas.gov")
  skip_if_not_installed("janitor")

  df <- crp_query(
    basin       = 12,
    startdate   = "01/01/2020",
    enddate     = "12/31/2020",
    data_type   = 1,
    segment_ids = "1202",
    clean_names = TRUE
  )

  # snake_case names: lowercase, underscores, no spaces/parens
  expect_true(all(grepl("^[a-z0-9_]+$", names(df))))
  expect_true("station_id" %in% names(df))
})
