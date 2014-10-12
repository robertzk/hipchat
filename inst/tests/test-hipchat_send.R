context('hipchat_send')

test_that('it errors when an invalid method is given', {
  expect_error(hipchat_send('foo', method = 'bar'), 'HTTP method must be one of')
})

test_that('it correctly sends to a user', {
  stub(hipchat, hipchat_send) <- function(a, b, c, message, ...) c(a, b, c, message)
  expect_equal(hipchat('user@here.com', 'hey'),
               c('user', 'user@here.com', 'message', 'hey'))
  expect_equal(hipchat('@user', 'hey'),
               c('user', '@user', 'message', 'hey'))
})

test_that('it correctly sends to a room', {
  stub(hipchat, hipchat_send) <- function(a, b, c, message, ...) c(a, b, c, message)
  stub(hipchat, determine_target) <- function(...) list(type = 'room', target = 'room')
  expect_equal(hipchat('room', 'hey'),
               c('room', 'room', 'notification', 'hey'))
  expect_equal(hipchat('room', 'hey'),
               c('room', 'room', 'notification', 'hey'))
})

