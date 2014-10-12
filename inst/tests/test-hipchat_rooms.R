context('hipchat_rooms')
library(testthatsomemore)

test_that('it fetches all rooms correctly', {
  stub(hipchat_rooms, hipchat_send) <- function(...)
    list(items = list(list(id = 1, name = 'first'), list(id = 2, name = 'second')))
  expect_identical(hipchat_rooms(), c(first = 1, second = 2))
})
