context('determine_method')

test_that('it warns when no methods were found and defaults to GET', {
  expect_warning(determine_method('nope'), 'defaulting to using GET')
  expect_equal(suppressWarnings(determine_method('nope')), 'GET')
})

test_that('it warns when multiple methods were found and defaults to the first', {
  expect_warning(determine_method('room/5'), 'Multiple HTTP methods \\(GET, PUT and DELETE)')
  expect_warning(determine_method('room/5'), 'would like to use PUT or DELETE')
  expect_equal(suppressWarnings(determine_method('room/5')), 'GET')
})

test_that('it can correctly determine a method that only has a PUT and DELETE', {
  expect_equal(suppressWarnings(determine_method('room/5/member/1')), 'PUT')
})

