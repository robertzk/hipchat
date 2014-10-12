context('determine_target')

test_that('it can determine a user target', {
  expect_equal(determine_target('john@here.com')$type, 'user')
  expect_equal(determine_target('@John')$type, 'user')
})

