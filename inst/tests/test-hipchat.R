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
