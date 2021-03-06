% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/settings.R
\name{iso_info_messages}
\alias{iso_info_messages}
\alias{iso_turn_info_messages_on}
\alias{iso_turn_info_messages_off}
\alias{iso_turn_datetime_warnings_on}
\alias{iso_turn_datetime_warnings_off}
\title{Control information messages}
\usage{
iso_turn_info_messages_on(data = NULL)

iso_turn_info_messages_off(data = NULL)

iso_turn_datetime_warnings_on(data = NULL)

iso_turn_datetime_warnings_off(data = NULL)
}
\arguments{
\item{data}{a data frame - returned invisibly as is if provided (e.g. in the middle of a pipeline)}
}
\description{
These functions control the global settings for information messages.
}
\details{
\code{iso_turn_info_messages_on()} and \code{iso_turn_info_messages_off()} turn information messages on/off in all subsequent function calls by changing the global settings for the \code{quiet} parameter of most isoreader functions. These functions can be called stand alone or within a pipeline to turn messages on/off at a certain point during the pipeline.

\code{iso_turn_datetime_warnings_on()} and \code{iso_turn_datetime_warnings_off()} turn datetime warnings that occur on some platforms (mostly linux distributions) on/off for all subsequent isoreader functions. These warnings inform the user that file creation dates are not available from the operating system.
}
\seealso{
Other settings functions: 
\code{\link{iso_caching}},
\code{\link{iso_get_default_reader_parameters}()},
\code{\link{iso_set_default_read_parameters}()}
}
\concept{settings functions}
