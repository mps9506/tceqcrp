test_that("crp_rows_for_segments matches IDs to rows", {
  segments <- tibble::tibble(
    row          = c(0L, 1L, 2L),
    segment_id   = c("1201", "1202", "1202A"),
    segment_desc = c("A", "B", "C")
  )

  expect_equal(crp_rows_for_segments(segments, "1202"), 1L)
  expect_equal(
    crp_rows_for_segments(segments, c("1201", "1202A")),
    c(0L, 2L)
  )
})

test_that("crp_rows_for_segments warns on missing IDs", {
  segments <- tibble::tibble(
    row          = 0L,
    segment_id   = "1201",
    segment_desc = "A"
  )
  expect_warning(
    crp_rows_for_segments(segments, c("1201", "9999")),
    "not found"
  )
})

test_that("crp_rows_for_segments handles numeric input", {
  segments <- tibble::tibble(
    row          = c(0L, 1L),
    segment_id   = c("1201", "1202"),
    segment_desc = c("A", "B")
  )
  # numeric IDs should be coerced to character and still match
  expect_equal(
    suppressWarnings(crp_rows_for_segments(segments, 1202)),
    1L
  )
})
