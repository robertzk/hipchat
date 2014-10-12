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

# A temporary workaround until hadley fixes httr
# https://github.com/hadley/httr/issues/159
httr_with_json <- function(expr) {
  suppressPackageStartupMessages({ library(jsonlite); library(rjson) })
  testthatsomemore::package_stub('jsonlite', 'toJSON', function(...) rjson::toJSON(...), eval.parent(expr))
}

# Stolen from my testthatsomemore package
# https://github.com/robertzk/testthatsomemore/blob/master/R/stub.R#L51
package_stub <- function(package_name, function_name, stubbed_value, expr) {
  if (!is.element(package_name, installed.packages()[,1]))
    stop(gettextf("Could not find package %s for stubbing %s",
                  sQuote(package_name), dQuote(function_name)))
  stopifnot(is.character(function_name))
  if (!is.function(stubbed_value))
    warning(gettextf("Stubbing %s::%s with a %s instead of a function",
            package_name, function_name, sQuote(class(stubbed_value)[1])))

  namespaces <-
    list(as.environment(paste0('package:', package_name)),
         getNamespace(package_name))
  if (!exists(function_name, envir = namespaces[[1]], inherits = FALSE))
    namespaces <- namespaces[-1]
  if (!exists(function_name, envir = tail(namespaces,1)[[1]], inherits = FALSE))
    stop(gettextf("Cannot stub %s::%s because it must exist in the package",
         package_name, function_name))

  lapply(namespaces, unlockBinding, sym = function_name)

  # Clean up our stubbing on exit
  previous_object <- get(function_name, envir = tail(namespaces,1)[[1]])
  on.exit({
    lapply(namespaces, function(ns) {
      tryCatch(error = function(.) NULL, assign(function_name, previous_object, envir = ns))
      lockBinding(function_name, ns)
    })
  })

  lapply(namespaces, function(ns)
    assign(function_name, stubbed_value, envir = ns))
  eval.parent(substitute(expr))
}

