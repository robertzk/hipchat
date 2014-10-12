#' Show the history for a given Hipchat room.
#'
#' @inheritParams hipchat_topic
#' @param date character or Date. Either the latest date to fetch history,
#'    or 'recent' to fetch the latest 75 messages. The default is \code{'recent'}.
#' @param timezone character. See note. By default, \code{'UTC'}.
#' @param start_index integer. The offset for messages to return. If \code{date = 'recent'},
#'    this parameter has no effect. The default is \code{0}.
#' @param max_results integer. Miaxmum number of messages to return. If \code{date = 'recent'},
#'    this parameter has no effect. By default, \code{100}, but can be any value
#'    between \code{0} and \code{1000}.
#' @param reverse logical. Reverse the output so that the olest message is first.
#'    The default is \code{TRUE}, but set this to \code{FALSE} for consistent paging.
#' @param full logical. Whether or not to display full history. By default, \code{FALSE},
#'   which will return a \code{data.frame} with columns \code{c('id', 'from', 'message', 'date')}.
#'   If \code{full = TRUE}, the raw output from the Hipchat API is provided as a list.
#' @return If \code{full = FALSE} (the default), a \code{data.frame}
#'   with columns \code{c('id', 'from', 'message', 'color', 'time')}. Otherwise, a full list
#'   of the JSON response from the Hipchat API. (see References section)
#' @references https://www.hipchat.com/docs/apiv2/method/view_room_history
#' @note for available timezones, see the tz database at: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#' @export
#' @examples
#' \dontrun{
#'   hipchat_history('some room', start_index = 100, max_results = 200, date = Sys.time())
#'   # A data.frame of the 200 most recent messages with an offset of 100
#'   hipchat_history('some room', full = TRUE)
#'   # Full Hipchat API output for the latest 75 messages.
#' }
hipchat_history <- function(room_name_or_id, date = 'recent', timezone = 'UTC', start_index = 0,
                            max_results = 100, reverse = TRUE, full = FALSE) {
  room_id <- sanitize_room(room_name_or_id)
  date <- sanitize_date(date)
  stopifnot(is.character(timezone) && length(timezone) == 1)
  stopifnot(is.numeric(start_index) && start_index >= 0)
  stopifnot(is.numeric(max_results) && max_results >= 0 && max_results <= 1000)
  stopifnot(identical(reverse, TRUE) || identical(reverse, FALSE))
  stopifnot(identical(full, TRUE) || identical(full, FALSE))

  history <- hipchat_send('room', room_id, 'history', date = date, timezone = timezone,
    `start-index` = start_index, `max-results` = max_results, reverse = reverse)

  if (full) history
  else abridged(history)
}

#' Convert a full history list from Hipchat to an abridged data.frame
#' 
#' @param history list. The raw output from the Hipchat API.
#' @seealso \code{\link{hipchat_history}}
#' @return A data.frame with columns \code{c('id', 'from', 'message', 'color', 'time')}
abridged <- function(history) {
  history <- history$items
  parse_time <- function(string)
    strptime(gsub(":([0-9]{2})$", "\\1", string), "%Y-%m-%dT%H:%M:%OS%z", tz = 'GMT')
  cols <- c('id', 'from', 'message', 'date', 'color')
  abridge <- function(item) {
    subset(within(data.frame(item[cols]), time <- parse_time(date)), select = -date)
  }
  do.call(rbind, lapply(history, abridge))
}



