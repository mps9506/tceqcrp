test_that("crp_basins returns all 25 basins", {
  b <- crp_basins()
  expect_s3_class(b, "tbl_df")
  expect_named(b, c("value", "label"))
  expect_equal(nrow(b), 25)
  expect_true("12" %in% b$value)
  expect_equal(b$label[b$value == "12"], "BRAZOS RIVER")
})

test_that("crp_data_types returns expected entries", {
  dt <- crp_data_types()
  expect_s3_class(dt, "tbl_df")
  expect_named(dt, c("value", "label"))
  expect_true("1" %in% dt$value)
  expect_equal(dt$label[dt$value == "1"], "Field Water Quality")
})

test_that("crp_formats returns three output formats", {
  f <- crp_formats()
  expect_equal(nrow(f), 3)
  expect_true(all(c("14", "15", "16") %in% f$value))
})
