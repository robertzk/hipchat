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

