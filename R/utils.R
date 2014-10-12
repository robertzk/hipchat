`%||%` <- function(x, y) if (is.null(x)) y else x

#' Hipchat API token.
#' 
#' @return the Hipchat API token in the environment variable \code{HIPCHAT_API_TOKEN}
#'    or the R option \code{getOption('hipchat.api_token')}.
hipchat_api_token <- function()
  getOption('hipchat.api_token') %||% Sys.getenv('HIPCHAT_API_TOKEN')


#' Find appropriate HTTP method for a given Hipchat URL.
#'
#' @param url character. The URL to analyze.
#' @return character vector of applicable methods, from
#'    \code{c("GET", "POST", "PUT", "DELETE"}.
match_method <- function(url) {
  url <- gsub(fixed = TRUE, paste0(hipchat_api_url, '/'), '', url)
  url <- strsplit(url, '?', fixed = TRUE)[[1]]

  has_method <- function(method) {
    routes <- paste0("^", gsub("*", "[^/]+", http_methods[[method]], fixed = TRUE), "$")
    any(sapply(routes, function(route) grepl(route, url)))
  }

  names(which(vapply(names(http_methods), has_method, logical(1))))
}

# comma(c('a', 'b', 'c')) == 'a, b, and c'
comma <- function(x, sep = ' and ') {
  if (length(x) < 2) x
  else paste(paste(head(x, -1), collapse = ', '), tail(x, 1), sep = sep)
}

sanitize_room <- function(room_name_or_id, convert_to_id = TRUE) {
  if (!is.numeric(room_name_or_id) && !is.character(room_name_or_id))
    stop("Please provide a room name or ID to set a room; got something ",
         "of class ", class(room_name_or_id)[1])
  if (length(room_name_or_id) != 1) stop("Only one room can be processed at a time.")

  if (!isTRUE(convert_to_id)) return(room_name_or_id)
  if (is.character(room_name_or_id)) room_name_or_id <- local({
    out <- hipchat_room_id(room_name_or_id)
    if (is.na(out)) stop("No Hipchat room ", sQuote(room_name_or_id), " found.")
    out
  }) else room_name_or_id
}

sanitize_user <- function(user_name_or_id) {
  if (!is.numeric(user_name_or_id) && !is.character(user_name_or_id))
    stop("Please provide a user name or ID to set a room; got something ",
         "of class ", class(user_name_or_id)[1])
  if (length(user_name_or_id) != 1) stop("Only one user can be processed at a time.")

  if (is.character(user_name_or_id) && !grepl(fixed = TRUE, '@', user_name_or_id))
    stop("Hipchat user references must contain an '@' (e.g. @SomeUser or ",
         "some@user.org)")

  user_name_or_id
}

sanitize_topic <- function(topic) {
  if (!(is.character(topic) && length(topic) == 1))
    stop("Please provide a single string for the room topic.")
  if (nchar(topic) > 250) stop("Hipchat room topics must be < 250 characters ",
    "you provided something ", nchar(topic), " characters long.")
  topic
}

