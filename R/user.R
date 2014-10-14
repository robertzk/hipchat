#' Create a new Hipchat user.
#'
#' @param name character. User's full name (1-50 characters). (Required)
#' @param password character. User's password. (Required)
#' @param email character. User's email. (Required)
#' @param title character. User's title. (Optional)
#' @param mention_name character. User's mention name. (Optional)
#' @param is_group_admin logical. Whether or not this user is an admin. (Optional)
#'    The default is \code{FALSE}.
#' @param timezone character. A supported timezone (see note). (Optional)
#'    The default is \code{'UTC'}.
#' @note for available time zones, see the third column in the table
#'   given at http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#' @references https://www.hipchat.com/docs/apiv2/method/create_user
#' @return the id for the newly created user, or NA if creation failed.
#' @export
#' @examples
#' \dontrun{
#'   hipchat_create_user('My name', 'mypassword', 'my.email@@org.com',
#'     'my title', 'MyName')
#' }
hipchat_create_user <- function(name, password, email, title, mention_name,
                                is_group_admin = FALSE, timezone = 'UTC') {
  stopifnot(is.character(name) && length(name) == 1 && nchar(name) >= 1 && nchar(name <= 50))
  stopifnot(is.character(password) && length(password) == 1)
  stopifnot(is.character(email) && length(email) == 1)
  if (!grepl(fixed = TRUE, '@', email)) stop("Emails need an '@'")
  stopifnot(is.character(timezone) && length(timezone) == 1)
  stopifnot(identical(is_group_admin, TRUE) || identical(is_group_admin, FALSE))
  if (!missing(title)) stopifnot(is.character(title) && length(title) == 1)
  if (!missing(mention_name)) stopifnot(is.character(mention_name) && length(mention_name) == 1)
  
  params <- list('user', name = name, password = password, email = email,
                 is_group_admin = is_group_admin, timezone = timezone, method = 'POST')
  if (!missing(title)) params$title <- title
  if (!missing(mention_name)) params$mention_name <- mention_name
  browser()
  do.call(hipchat_send, params)
}

