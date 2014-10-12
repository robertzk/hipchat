context('hipchat_history') 

test_that('validates its basic arguments', {
  expect_error(hipchat_history(1, 0))
})

