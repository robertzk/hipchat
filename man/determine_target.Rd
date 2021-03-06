% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/message.R
\name{determine_target}
\alias{determine_target}
\title{Determine whether we are sending to a room or user.}
\usage{
determine_target(room_or_user, api_token = hipchat_api_token())
}
\arguments{
\item{room_or_user}{character or integer}

\item{api_token}{character. Optional API token. The default is 
\code{hipchat:::hipchat_api_token()}, which uses
 the environment variable \code{HIPCHAT_API_TOKEN} or the 
 R option \code{getOption('hipchat.api_token')} if they are present.}
}
\value{
a list with two keys, \code{target} and \code{type}.
  The former will be an attempt to coerce the value to an ID (so that
  room IDs are preferred to room names). The \code{type} key will
  contain one of \code{c("room", "user")} according as \code{room_or_user}
  is determined to be a room or user.
}
\description{
If there is a \code{@} character, we assume it is a user. Otherwise,
we assume it is a room. If it consists of all numbers, we assume it is
an ID. If it exists in the list of room IDs accessible to this user,
(see \code{\link{hipchat_rooms}}) it is assumed to be a room ID. Otherwise,
it is assumed to be a user ID.
}
\examples{
stopifnot(hipchat:::determine_target('some@guy.com')$type == 'user')

\dontrun{
  stopifnot(is.numeric(hipchat:::determine_target('Some room')$target))
  # Will be a room ID, assuming "Some room" exists.
}
}

