context('hipchat')
# Sending hipchat messages

test_that('it errors when no room or message is given', {
  expect_error(hipchat(character(0), ''), 'Please specify')
  expect_error(hipchat('', c()), 'Please specify')
})

test_that('it errors when a non-character is passed', {
  expect_error(hipchat(TRUE, TRUE))
  expect_error(hipchat('a', TRUE))
  expect_error(hipchat(TRUE, 'a'))
})

test_that('it complains when an invalid color is given', {
  expect_error(hipchat('x', 'm', color = 0L), 'something of class')
  expect_error(hipchat('x', 'm', color = 'blue'), paste('you provided', sQuote('blue')))
})

test_that('it errors when notify parameter is not of type logical', {
  expect_error(hipchat('x', 'm', notify = 'blue'))
})

test_that("it errors when the message_format is not 'text' or 'html'", {
  expect_error(hipchat('x', 'm', message_format = 'yo'))
  expect_error(hipchat('x', 'm', message_format = FALSE))
})
