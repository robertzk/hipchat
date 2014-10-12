context('hipchat_send')

test_that('it errors when an invalid method is given', {
  expect_error(hipchat_send('foo', method = 'bar'), 'HTTP method must be one of')
})
