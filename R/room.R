# Unfortunately, v2 of the Hipchat API does not support giving the
# room name (although they claim it does). As a result, we need a 
# method of fetching the room ID for a given room name, and caching
# this if possible.

#' Get the list of all hipchat rooms.
#'
#' @inheritParams hipchat_send
#' @return an integer vector, with names being room names and values
#'    being room IDs.
hipchat_rooms <- function(api_token = hipchat_api_token()) {
  rooms <- hipchat_send('room', method = 'GET', api_token = api_token)
  do.call(c, lapply(rooms$items, function(item) setNames(item$id, item$name)))
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
#' @return A named integer vector, with the names being the room names
#'   and the values being the room IDs. If a room ID is not found, the
#'   value returned will be NA, so that if you pass in one room name
#'   and it does not exist, NA will be returned.
#' @note This will call the hipchat API at \code{https://api.hipchat.com/v2/room}
#'   to fetch the room-id map.
#' @export
hipchat_room_id <- function(room_name) {
  stopifnot(is.character(room_name))

  room_in_cache <- function(room_name) is.element(room_name, room_cache$getNames())
  if (any(!room_in_cache(room_name))) refresh_room_cache()

  setNames(room_cache$get(room_name), room_name)
}

refresh_room_cache <- local({
  last_refreshed <- as.POSIXct(as.Date(0, origin = "1970-01-01"))
  function(api_token = hipchat_api_token()) {
    refresh_interval <- Sys.time() - last_refreshed
    units(refresh_interval) <- 'secs'
    if (as.integer(refresh_interval) > 5) { # Limit API refreshes to every 5 seconds
      last_refreshed <<- Sys.time()
      room_cache$set(hipchat_rooms(api_token))
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
#' @param room_name character. Room name.
#' @param topic character. Topic name (optional).
#' @param guest_access logical. Whether or not to enable guest access for this room.
#'   By default, \code{FALSE}.
#' @param owner_user character or logical. The id, email address, or mention name
#'   (beginning with an @@) of the room's owner. Defaults to the current user. (Optional)
#' @param privacy character. Whether the room is available for access by other users or not.
#'   Must be either \code{'public'} or \code{'private} (default is \code{'public'}).
#' @return the id of the newly created room.
#' @export
#' @examples
#' \dontrun{
#'   hipchat_create_room('A new private room', 'With a new topic', privacy = 'private')
#' }
hipchat_create_room <- function(room_name, topic = NULL, guest_access = FALSE,
  owner_user, privacy = 'public') {
  room_name_or_id <- sanitize_room(room_name_or_id)

}
  

