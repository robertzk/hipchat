#' Send a message to the hipchat API v2.
#'
#' @param type character. One of the native Hipchat API domains:
#'    \code{c('addon', 'capabilities', 'emoticon', 'oauth', 'room' 'user')}.
#' @param var character. Whatever goes after the \code{type} in the
#'    hipchat API url, typically room ID, name, or user email,
#'    depending on the API path you are calling.
#' @param ... HTTP arguments to send to the Hipchat API. Unnamed arguments
#'    will be passed in to the URL; named arguments will be assumed to be
#'    API parameters. See the examples section.
#' @param api_token character. By default, \code{\link{hipchat_api_token}()}.
#' @references https://www.hipchat.com/docs/apiv2
#' @return the JSON output response from the Hipchat API.
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
hipchat_send <- function(type, var, ..., api_token = hipchat_api_token()) {
  url <- hipchat_url(type, var, ...)

  # httr::POST(url, 
  url
}

#' Hipchat API url.
#'
#' @param ... concatenate these arguments in to the hipchat URL.
#' @param use.auth_token logical. Whether or not to provide an auth_token
#'    GET query parameter, by default \code{TRUE}.
#' @return https://api.hipchat.com/v2/...
#' @examples
#' stopifnot(hipchat_url('oauth', 'token', use.auth_token = FALSE) == 
#'   paste(hipchat:::hipchat_api_url, 'oauth', 'token', sep = '/'))
hipchat_url <- function(..., use.auth_token = TRUE) {
  args <- list(...)
  unnamed <- function(x) (names(x) %||% rep("", length(x))) == ''
  url_elements <- unlist(args[unnamed(args)])
  url <- do.call(paste, as.list(c(hipchat:::hipchat_api_url, url_elements, sep = '/')))
  if (isTRUE(use.auth_token))
    paste(url, paste('auth_token', hipchat_api_token(), sep = '='), sep = '?')
  else url
}

