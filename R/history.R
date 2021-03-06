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
#' @param api_token character. By default, \code{\link{hipchat_api_token}()}.
#' @return If \code{full = FALSE} (the default), a \code{data.frame}
#'   with columns \code{c('id', 'from', 'message', 'time', 'color')}. Otherwise, a full list
#'   of the JSON response from the Hipchat API. (see References section)
#' @references https://www.hipchat.com/docs/apiv2/method/view_room_history
#' @note for available timezones, see the tz database at: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#' @export
#' @examples
#' \dontrun{
#'   hipchat_history('some room')
#'   hipchat_history('some room', start_index = 100, max_results = 200, date = Sys.time())
#'   # A data.frame of the 200 most recent messages with an offset of 100
#'   hipchat_history('some room', full = TRUE)
#'   # Full Hipchat API output for the latest 75 messages.
#' }
hipchat_history <- function(room_name_or_id, date = 'recent', timezone = 'UTC', start_index = 0,
                            max_results = 100, reverse = TRUE, full = FALSE, api_token = hipchat_api_token()) {
  room_id <- sanitize_room(room_name_or_id, api_token = api_token)
  date <- sanitize_date(date)
  stopifnot(is.character(timezone) && length(timezone) == 1)
  stopifnot(is.numeric(start_index) &&  length(start_index) == 1 && start_index >= 0)
  stopifnot(is.numeric(max_results) && length(max_results) == 1 && max_results >= 0 && max_results <= 1000)
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
#' @return A data.frame with columns \code{c('id', 'from', 'message', 'time', 'color')}
abridged <- function(history) {
  history <- history$items
  cols <- c('id', 'from', 'message', 'date', 'color')
  abridge <- function(item) {
    if (is.list(item$from)) item$from <- item$from$name %||% item$from$id
    for (col in cols) if (!is.element(col, names(item))) item[[col]] <- NA
    df <- subset(within(data.frame(item[cols], stringsAsFactors = FALSE),
                        time <- parse_time(date)), select = -date)
    df[gsub('^date$', 'time', cols)]
  }
  
  history <- do.call(rbind, lapply(history, abridge))
  history$color <- as.color(history$color)
  history
}



