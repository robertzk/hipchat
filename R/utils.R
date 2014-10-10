`%||%` <- function(x, y) if (is.null(x)) y else x

#' Hipchat API token.
#' 
#' @return the Hipchat API token in the environment variable \code{HIPCHAT_API_TOKEN}
#'    or the R option \code{getOption('hipchat.api_token')}.
hipchat_api_token <- function()
  getOption('hipchat.api_token') %||% Sys.getenv('HIPCHAT_API_TOKEN')

