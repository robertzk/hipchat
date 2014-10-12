#' Send a message to a Hipchat room or user.
#'
#' @param room_or_user character or integer. The room(s) and/or user(s) to send a
#'   message to. Room and/or user IDs will also work, but you will first
#'   have to obtain the correct ID, so it is easier to user the former.
#'   Rooms can be specified by full name (e.g., \code{"This room"}) and users
#'   can be specified by email (e.g., \code{"some@@user.org"}) or mention
#'   name (e.g., \code{"@@SomeUser"}).
#'
#'   If IDs are provided, they will be checked against the list of available
#'   room IDs. If the ID is present, a room ID will be assumed; otherwise,
#'   a user ID will be assumed.
#' @param message character. The message(s) to send. If a message is over
#'   10,000 characters, it will be split up into multiple messages, as
#'   the Hipchat API only allows up to 10,000 characters per message.
#' @param notify logical. Whether or not to notify the target recipient.
#'   The default is \code{TRUE}, although \code{FALSE} is less invasive
#'   and useful for non-critical messages.
#' @param color character. Available options are: yellow, red, green,
#'   purple, gray, or random. Defaults to yellow. If this is a message
#'   sent to a user, this option will be ignored.
#' @param message_format character. Available options are: text or html.
#'   The default is text.
#' @param api_token character. Optional API token. The default is 
#'   \code{hipchat:::hipchat_api_token()}, which uses
#'    the environment variable \code{HIPCHAT_API_TOKEN} or the 
#'    R option \code{getOption('hipchat.api_token')} if they are present.
#' @seealso \code{\link{hipchat_send}}
#' @return \code{TRUE} if the message was successfull, or an error otherwise.
#' @examples
#' \dontrun{
#'   hipchat('Some room', 'Hey guys!')
#'   hipchat('some@@user.org', "Hey buddy how's it going?")
#'   hipchat('Some room', 'Server is down!', color = 'red')
#'   hipchat('Some room', 'Look at this picture: <img src="https://www.google.com/images/srpr/logo11w.png">', message_format = 'html')
#'  
#'   # A more comprehensive example
#'   hipchat(c("This room", 'and.this@@user.org'), "Really important stuff", notify = TRUE,
#'     color = 'red', message_format = 'text', api_token = 'my_api_token')
#' }
#' @export
hipchat <- function(room_or_user, message, notify = TRUE, color = 'yellow',
                    message_format = 'text', api_token = hipchat_api_token()) {
  stopifnot(is.character(room_or_user) || is.numeric(room_or_user))

  rerun <- function(room_or_user, message)
    hipchat(room_or_user, message = message, notify = notify, color = color,
            message_format = message_format, api_token = api_token)

  if (length(room_or_user) > 1) return(all(sapply(room_or_user, rerun, message = message)))
  if (length(message) > 1) return(all(sapply(message, rerun, room_or_user = room_or_user)))
  if (length(room_or_user) == 0 || length(message) == 0)
    stop("Please specify a room/user and a message.")

  stopifnot(is.character(message))

  if (nchar(message) >= 10000) {
    first_part <- substring(message, 1, 9999)
    second_part <- substring(message, 10000, nchar(message))
    return(all(sapply(c(first_part, second_part), rerun, message = message)))
  }

  # We are sending a message to one room/user that is under 10,000 characters.


}

#' Determine whether we are sending to a room or user.
#' 
#' If there is a \code{@@} character, we assume it is a user. Otherwise,
#' we assume it is a room. If it consists of all numbers, we assume it is
#' an ID. If it exists in the list of room IDs accessible to this user,
#' (see \code{\link{hipchat_rooms}}) it is assumed to be a room ID. Otherwise,
#' it is assumed to be a user ID.
#'
#' @param room_or_user character or integer
#' @return a list with two keys, \code{target} and \code{type}.
#'   The former will be an attempt to coerce the value to an ID (so that
#'   room IDs are preferred to room names). The \code{type} key will
#'   contain one of \code{c("room", "user")} according as \code{room_or_user}
#'   is determined to be a room or user.
#' @examples
#' stopifnot(determine_target('some@@guy.com')$type == 'user')
#'
#' \dontrun{
#'   stopifnot(is.numeric(determine_target('Some room')$target))
#'   # Will be a room ID, assuming "Some room" exists.
#' }
determine_target <- function(room_or_user) {
 stopifnot(is.character(room_or_user) || is.numeric(room_or_user)) 
 stopifnot(length(room_or_user) == 1)

 hipchat_room_id(room_or_user)
}

