context('hipchat_rooms')
library(testthatsomemore)

test_that('it fetches all rooms correctly', {
  stub(hipchat_rooms, hipchat_send) <- function(...)
    list(items = list(list(id = 1, name = 'first'), list(id = 2, name = 'second')))
  expect_identical(hipchat_rooms(), c(first = 1, second = 2))
})

context('hipchat_room_id')

test_that('it can fetch a room ID and cache the room cache', {
  tmp <- new.env(); tmp$x <- 0; tmp$r <- character(0)
  stub(hipchat_room_id, room_cache) <- list(getNames = function() names(tmp$r),
    get = function(n) tmp$r[n])
  stub(hipchat_room_id, refresh_room_cache) <- function(...) {
    tmp$x <- tmp$x + 1; tmp$r <- c(a = 1L) }

  expect_equal(c(a = 1), hipchat_room_id('a'))
  expect_equal(1, tmp$x, info = 'room_cache should have been refreshed')
  hipchat_room_id('a')
  expect_equal(1, tmp$x, info = 'room_cache should not have been refreshed')
})

test_that('it cannot find a non-existent room ID and refreshes the cache each time', {
  tmp <- new.env(); tmp$x <- 0; tmp$r <- character(0)
  stub(hipchat_room_id, room_cache) <- list(getNames = function() names(tmp$r),
    get = function(n) tmp$r[n])
  stub(hipchat_room_id, refresh_room_cache) <- function(...) {
    tmp$x <- tmp$x + 1; tmp$r <- c(a = 1L) }

  expect_equal(c(b = NA_integer_), hipchat_room_id('b'))
  expect_equal(1, tmp$x, info = 'room_cache should have been refreshed')
  hipchat_room_id('b')
  expect_equal(2, tmp$x, info = 'room_cache should have been refreshed again')
})

context('hipchat_topic')

test_that('it errors when an invalid room or topic is given', {
  expect_error(hipchat_topic(list(), 'a'), 'provide a room name or ID')
  expect_error(hipchat_topic(c('a','b'), 'a'), 'Only one room')
  stub(hipchat_topic, hipchat_room_id) <- function(...) NA_integer_
  expect_error(hipchat_topic('a', 'b'), 'No Hipchat room')
  stub(hipchat_topic, sanitize_room) <- function(...) ..1
  expect_error(hipchat_topic('a', 5), 'provide a single string')
  expect_error(hipchat_topic('a', c('a','b')), 'provide a single string')
  expect_error(hipchat_topic('a', paste(rep('a', 251), collapse = '')), 'must be < 250')
})



