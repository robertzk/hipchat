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
  stub(hipchat_topic, sanitize_room) <- function(...) ..1
  expect_error(hipchat_topic('a', 5), 'provide a single string')
  expect_error(hipchat_topic('a', c('a','b')), 'provide a single string')
  expect_error(hipchat_topic('a', paste(rep('a', 251), collapse = '')), 'must be < 250')
})

context('hipchat_create_room')

test_that('it errors when an invalid room or topic or user is given', {
  expect_error(hipchat_create_room(list(), 'a'), 'provide a room name or ID')
  expect_error(hipchat_create_room(c('a','b'), 'a'), 'Only one room')
  stub(hipchat_create_room, sanitize_room) <- function(...) ..1
  expect_error(hipchat_create_room('a', 5), 'provide a single string')
  expect_error(hipchat_create_room('a', c('a','b')), 'provide a single string')
  expect_error(hipchat_create_room('a', paste(rep('a', 251), collapse = '')), 'must be < 250')
  expect_error(hipchat_create_room(1, 'a'))
  expect_error(hipchat_create_room('a', 'a', owner_user = 'foo'), "must contain an '@'")
  expect_error(hipchat_create_room('a', 'a', owner_user = list()), "provide a user name or ID")
  expect_error(hipchat_create_room(paste(rep('a', 101), collapse = '')), 'at most 100')
})

context('hipchat_delete_room')

test_that('it prompts for confirmation before deleting a room', {
  stub(hipchat_delete_room, readline) <- function(...) "NO"
  tmp <- new.env(); tmp$x <- 0
  stub(hipchat_delete_room, hipchat_send) <- function(...) { tmp$x <- tmp$x + 1; tmp$args <- list(...) }
  hipchat_delete_room(99)
  expect_equal(tmp$x, 0, info = 'room should not have been deleted through hipchat_send')
  stub(hipchat_delete_room, readline) <- function(...) eval.parent(quote(confirm))
  hipchat_delete_room(99)
  expect_equal(tmp$x, 1, info = 'room should have been deleted through hipchat_send')
  expect_identical(tmp$args, list('room', 99, method = 'DELETE'),
                   info = 'correct hipchat room delete API path should have been called')
})

