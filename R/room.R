# Unfortunately, v2 of the Hipchat API does not support giving the
# room name (although they claim it does). As a result, we need a 
# method of fetching the room ID for a given room name, and caching
# this if possible.

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

  room_in_cache <- function(room_name) is.element(room_name, names(room_cache))
  if (any(!room_in_cache(room_name))) refresh_room_cache()
}

refresh_room_cache <- function() {
  # room_cache$set(hipchat_send('rooms'))
}

room_cache <- local({
  .cache <- list()
  structure(list(
    get = function(key = NULL) {
      if (missing(key)) .cache
      else .cache[[key]]
    },
    getNames = function() names(.cache),
    set = function(value, key = NULL) {
      if (missing(key)) .cache <<- value
      else .cache[[key]] <<- value
    }
  ), class = 'room_cache')
})




