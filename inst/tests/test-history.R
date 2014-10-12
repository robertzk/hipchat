context('hipchat_history') 

test_that('validates its basic arguments', {
  expect_error(hipchat_history(1, 0))
  expect_error(hipchat_history(1, start_index = -1))
  expect_error(hipchat_history(1, max_results = list()))
  expect_error(hipchat_history(1, max_results = c(1,2)))
  expect_error(hipchat_history(1, reverse = NULL))
})

context('abridged')

test_that('it can abridge a simple example', {
  generate_item <- function(n, parse = FALSE)
    within(list(date = "2014-10-09T20:39:39.059515+00:00",
      from = 'foo', id = 'bar', message = 'woo'),
      color <- if (n %% 2 == 0) 'green' else if (parse) NA_character_ else NULL)
    
  history <- list(items = lapply(seq_len(10), generate_item))
  expected <- do.call(rbind, lapply(seq_len(10),
    function(x) {
      df <- data.frame(generate_item(x, TRUE), stringsAsFactors = FALSE)
      df$time <- parse_time(df$date)
      df$date <- NULL
      df$color <- as.color(df$color)
      df[c('id', 'from', 'message', 'time', 'color')]
    }))

  expect_identical(abridged(history), expected)
})
