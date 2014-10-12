#' Send a message to the hipchat API v2.
#'
#' @param type character. One of the native Hipchat API domains:
#'    \code{c('addon', 'capabilities', 'emoticon', 'oauth', 'room' 'user')}.
#' @param var character. Whatever goes after the \code{type} in the
#'    hipchat API url, typically room ID, or user email,
#'    depending on the API path you are calling.
#' @param ... HTTP arguments to send to the Hipchat API. Unnamed arguments
#'    will be passed in to the URL; named arguments will be assumed to be
#'    API parameters. See the examples section.
#' @param api_token character. By default, \code{\link{hipchat_api_token}()}.
#' @param method character. HTTP method. Either \code{"GET"}, \code{"POST"},
#'    \code{"PUT"}, or \code{"DELETE"}. By default, the API url will be
#'    inspected and matched with the appropriate method. Otherwise,
#'    \code{"GET"} will be used.
#' @references https://www.hipchat.com/docs/apiv2
#' @return the JSON output response from the Hipchat API.
#' @export
#' @examples
#' \dontrun{
#'   hipchat_send('room', 'My room', 'notification',
#'     color = 'green', message = 'Everything looks <b>green</b>',
#'     notify = FALSE, message_format = 'html')
#'   # posts to https://api.hipchat.com/v2/room/My room/notification
#'
#'   hipchat_send('room', 'My room', 'share', 'link',
#'      message = 'This looks like a cool package',
#'      link = 'http://github.com/robertzk/hipchat')
#'   # posts to https://api.hipchat.com/v2/room/My room/share/link
#'   # and shares a link with the room.
#'
#'   hipchat_send('user', 'your@@friend.org', 'message')
#'      message = "Hey buddy what's going on?", notify = TRUE,
#'      message_format = 'text')
#'   # posts to https://api.hipchat.com/v2/user/your@@friend.org/message
#'
#'   hipchat_send('room', 'My room', 'invite', 'your@@friend.org',
#'      reason = "Come join this room mang")
#'   # posts to https://api.hipchat.com/v2/room/My room/invite/your@@friend.org
#' }
hipchat_send <- function(type, var, ..., api_token = hipchat_api_token(), method = 'GET') {
  url <- if (missing(var)) hipchat_url(type, ...) else hipchat_url(type, var, ...)
  named <- function(x) nzchar(names(x) %||% rep("", length(x)))
  params <- list(...)
  params <- params[named(params)]
  method <- (if (missing(method)) determine_method(url)) %||% method
  if (!is.element(method, methods <- c('GET', 'POST', 'PUT', 'DELETE')))
    stop(gettextf("HTTP method must be one of %s, got %s", 
                  comma(methods, ' or '), sQuote(method)))
  method <- getFunction(method, where = getNamespace('httr'))
  httr::content(httr_with_json(method(url, body = params, encode = 'json')))
}

#' Hipchat API url.
#'
#' @param ... concatenate these arguments in to the hipchat URL.
#' @inheritParams hipchat_send
#' @return https://api.hipchat.com/v2/...
#' @examples
#' stopifnot(hipchat:::hipchat_url('oauth', 'token', use.auth_token = FALSE) == 
#'   paste(hipchat:::hipchat_api_url, 'oauth', 'token', sep = '/'))
hipchat_url <- function(..., api_token = hipchat:::hipchat_api_token()) {
  args <- list(...)
  unnamed <- function(x) !nzchar(names(x) %||% rep("", length(x)))
  url_elements <- unlist(args[unnamed(args)])
  url <- do.call(paste, as.list(c(hipchat:::hipchat_api_url, url_elements, sep = '/')))
  if (!is.null(api_token))
    paste(url, paste('auth_token', api_token, sep = '='), sep = '?')
  else url
}

#' Determine the correct HTTP method to use for a given API route.
#' 
#' If multiple methods are available (e.g., GET and DELETE), a warning will be issued
#' and only the first method will be used.
#' If no methods are available, it is probably an invalid API route.
#' In this case, a warning will be issued and GET will be used.
#'
#' @param url character. The HTTP URL.
#' @examples
#' stopifnot(hipchat:::determine_method('nonexistent') == 'GET') # Warns about no method
#' stopifnot(hipchat:::determine_method('room') == 'GET') # Warns about multiple methods
#' stopifnot(hipchat:::determine_method('user/some@@guy.com/message') == 'POST') # No warning
determine_method <- function(url) {
  method <- match_method(url)
  if (length(method) > 1) {
    warning(gettextf(
      paste("Multiple HTTP methods (%s) found for route %s, defaulting to %s.",
      "If you would like to use %s, specify it with",
      "hipchat_send(method = '%s', ...)"), comma(method), sQuote(url), method[1],
      comma(method[-1], ' or '), method[2]))
    method <- method[1]
  } else if (length(method) == 0) {
    warning(gettextf("No API route found for %s, defaulting to using GET HTTP method.",
      sQuote(url)))
    method <- 'GET'
  }
  method
}


