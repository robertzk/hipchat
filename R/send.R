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
#'   # posts to http://
#hipchat_message('Room name or email', "I'm in a hipchat!")
#hipchat_topic('Room name', "This is the new topic")
#hipchat_create_room('Room name')
#hipchat_delete_room('Room name') # Will prompt a confirmation
#hipchat_history('Room name')
#hipchat_list_rooms('Group name')
#hichat_create_user(...)
#hipchat_update_user(...)
#hipchat_delete_user('terrible@employee.com')
#hipchat_list_users()
#' }
hipchat_send <- function(type, var, ..., api_token = hipchat_api_token()) {
  # TODO: (RK) Implement this.
}

