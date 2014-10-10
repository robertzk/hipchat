#' Send a message to the hipchat API v2.
#'
#' @param type character. One of the native Hipchat API domains:
#'    \code{c('addon', 'capabilities', 'emoticon', 'oauth', 'room' 'user')}.
#' @param var character. Whatever goes after the \code{type} in the
#'    hipchat API url, typically room ID, name, or user email.
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
  # TODO: (RK) Implement this.
}

