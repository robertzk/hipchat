context("hipchat_send")

test_that("it errors when an invalid method is given", {
  expect_error(hipchat_send("foo", method = "bar"), "HTTP method must be one of")
})

test_that("it correctly sends to a user", {
  stub(hipchat, hipchat_send) <- function(a, b, c, message, ...) c(a, b, c, message)
  expect_equal(hipchat("user@here.com", "hey"),
               c("user", "user@here.com", "message", "hey"))
  expect_equal(hipchat("@user", "hey"),
               c("user", "@user", "message", "hey"))
})

test_that("it correctly sends to a room", {
  stub(hipchat, hipchat_send) <- function(a, b, c, message, ...) c(a, b, c, message)
  stub(hipchat, determine_target) <- function(...) list(type = "room", target = "room")
  expect_equal(hipchat("room", "hey"),
               c("room", "room", "notification", "hey"))
  expect_equal(hipchat("room", "hey"),
               c("room", "room", "notification", "hey"))
})

test_that("it can handle an error", {
  with_mock(
    `httr::GET` = function(a, b, c, message, ...) list(error = "API ERROR LOL"),
    `httr::POST` = function(a, b, c, message, ...) list(error = "API ERROR LOL"),
    `hipchat:::determine_target` = function(...) list(type = "room", target = "room"),
    expect_error(hipchat("room", "hey"))
  )
})

test_that("it can handle an httr error", {
  mocked_httr_error <- structure(list(url = "blah", status_code = 500L), class = "response")
  with_mock(
    `httr::GET` = function(...) mocked_httr_error,
    `httr::POST` = function(...) mocked_httr_error, 
    `hipchat:::determine_target` = function(...) list(type = "room", target = "room"),
    expect_error(hipchat_send("room", "room", "message"), "status code was 500")
  )
})

test_that("it works if it does not return a list", {
  with_mock(
    `httr::content` = function(...) "message",
    `httr::status_code` = function(...) 200L,
    `httr::GET` = function(...) "message",
    `httr::POST` = function(...) "message",
    `hipchat:::hipchat_url` = function(...) "whocares.com",
    expect_equal("message", hipchat_send("room", "room", "message"))
  )
})
