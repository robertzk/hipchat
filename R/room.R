# Unfortunately, v2 of the Hipchat API does not support giving the
# room name (although they claim it does). As a result, we need a 
# method of fetching the room ID for a given room name, and caching
# this if possible.

#' Get the list of all hipchat rooms.
#'
#' @inheritParams hipchat_send
#' @param max_results integer. Maximum number of rooms to return. Must be
#'   between 0 and 1000 -- the default is 1000.
#' @param include_archived logical. Whether or not to include archived rooms
#'   in the results. The default is \code{FALSE}.
#' @param full logical. Whether or not to return raw output from the Hipchat
#'   API. If \code{FALSE} (the default), only a named character vector of
#'   room IDs will be returned.
#' @param api_token character. By default, \code{\link{hipchat_api_token}()}.
#' @export
#' @references https://www.hipchat.com/docs/apiv2/method/get_all_rooms
#' @return an integer vector, with names being room names and values being room IDs
#'   if \code{full = TRUE}. Otherwise, return the full raw output from the Hipchat
#'   API.
hipchat_rooms <- function(max_results = 1000, include_archived = FALSE, full = FALSE, api_token = hipchat_api_token()) {
  stopifnot(is.numeric(max_results) && length(max_results) == 1 && max_results >= 0 && max_results <= 1000)
  stopifnot(identical(include_archived, TRUE) || identical(include_archived, FALSE))
  stopifnot(identical(full, TRUE) || identical(full, FALSE))

  rooms <- hipchat_send('room', method = 'GET', `max-results` = max_results,
                        include_archived = include_archived, api_token = api_token)
  parse <- function(item) if (full) item else setNames(item$id, item$name)
  do.call(c, lapply(rooms$items, parse))
}

#' Convert a Hipchat room name to an ID.
#' 
#' This function will call the \code{/v2/room} API route if necessary to 
#' fetch the room-id map. If a room has been found before, it will use
#' the cached value. Otherwise, if it is not found, it will refresh
#' the cache.
#'
#' @param room_name character. A character vector giving the room
#'   name. This is vectorized if you would like IDs for multiple rooms.
#' @param api_token character. By default, \code{\link{hipchat_api_token}()}.
#' @return A named integer vector, with the names being the room names
#'   and the values being the room IDs. If a room ID is not found, the
#'   value returned will be NA, so that if you pass in one room name
#'   and it does not exist, NA will be returned.
#' @note This will call the hipchat API at \code{https://api.hipchat.com/v2/room}
#'   to fetch the room-id map.
#' @export
hipchat_room_id <- function(room_name, api_token = hipchat_api_token()) {
  stopifnot(is.character(room_name))

  room_in_cache <- function(room_name) is.element(room_name, room_cache$getNames())
  if (any(!room_in_cache(room_name))) refresh_room_cache(api_token)

  setNames(room_cache$get(room_name) %||% NA_character_, room_name)
}

refresh_room_cache <- local({
  last_refreshed <- as.POSIXct(as.Date(0, origin = "1970-01-01"))
  function(api_token = hipchat_api_token()) {
    refresh_interval <- Sys.time() - last_refreshed
    units(refresh_interval) <- 'secs'
    if (as.integer(refresh_interval) > 5) { # Limit API refreshes to every 5 seconds
      last_refreshed <<- Sys.time()
      room_cache$set(hipchat_rooms(api_token = api_token))
    }
  }
})

room_cache <- local({
  .cache <- list()
  structure(list(
    get = function(key = NULL) {
      if (missing(key)) .cache
      else .cache[key]
    },
    getNames = function() names(.cache),
    set = function(value, key = NULL) {
      if (missing(key)) .cache <<- value
      else .cache[key] <<- value
    }
  ), class = 'room_cache')
})

#' Change the topic of a room.
#'
#' @param room_name_or_id character or integer.
#' @param topic character. Must be under 250 characters.
#' @export
#' @examples
#' \dontrun{
#'   hipchat_topic('Some room', 'This is the new topic')
#' }
hipchat_topic <- function(room_name_or_id, topic) {
  room_name_or_id <- sanitize_room(room_name_or_id)
  topic <- sanitize_topic(topic)

  hipchat_send('room', room_name_or_id, 'topic', topic = topic)
}

#' Create a new Hipchat room. (Must have privileges)
#'
#' @param room_name character. Room name. Maximum 100 characters.
#' @param topic character. Topic name (optional).
#' @param guest_access logical. Whether or not to enable guest access for this room.
#'   By default, \code{FALSE}.
#' @param owner_user character or logical. The id, email address, or mention name
#'   (beginning with an @@) of the room's owner. Defaults to the current user. (Optional)
#' @param privacy character. Whether the room is available for access by other users or not.
#'   Must be either \code{'public'} or \code{'private'} (default is \code{'public'}).
#' @return the id of the newly created room.
#' @export
#' @examples
#' \dontrun{
#'   hipchat_create_room('A new private room', 'With a new topic', privacy = 'private')
#' }
hipchat_create_room <- function(room_name, topic = NULL, guest_access = FALSE,
  owner_user, privacy = 'public') {
  room_name <- sanitize_room(room_name, convert_to_id = FALSE)
  stopifnot(is.character(room_name))
  if (nchar(room_name) > 100)
    stop("Hipchat rooms can be at most 100 characters, you provided ", nchar(room_name))
  stopifnot(identical(privacy, 'public') || identical(privacy, 'private'))

  guest_access <- isTRUE(guest_access)

  params <- list('room', guest_access = guest_access,
    name = room_name, privacy = privacy)
  if (!missing(owner_user)) params$owner_user <- sanitize_user(owner_user)
  if (!missing(topic)) params$topic <- sanitize_topic(topic)
  params$method <- 'POST'

  do.call(hipchat_send, params)$id
}

#' Delete a Hipchat room.
#'
#' @inheritParams hipchat_topic
#' @param confirm logical. Whether or not to ask for a confirmation message
#'   before deleting the room. By default, \code{TRUE}. (Deleting rooms
#'   is dangerous!)
#' @return \code{TRUE} or \code{FALSE} according as the room was deleted.
#' @examples
#' \dontrun{
#'    hipchat_create_room('Example room')
#'    hipchat_delete_room('Example room') # Will ask a confirmation message.
#'    hipchat_delete_room('Example room', confirm = FALSE) # Dangerous! No confirmation.
#' }
hipchat_delete_room <- function(room_name_or_id, confirm = TRUE) {
  room_id <- sanitize_room(room_name_or_id)

  if (isTRUE(confirm)) {
    confirm <- sample(c('OK', 'Yes', 'Y', 'Confirm'), 1)
    answer <- readline(gettextf(paste("Are you *sure* you wish to delete Hipchat room",
      "%s? If so, write %s: "), sQuote(room_name_or_id), sQuote(confirm)))
    if (!identical(answer, confirm)) return(FALSE)
  }
  hipchat_send('room', room_id, method = 'DELETE')
  TRUE
}

#' 
  

