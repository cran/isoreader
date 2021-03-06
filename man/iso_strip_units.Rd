% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/units.R
\name{iso_strip_units}
\alias{iso_strip_units}
\title{Strip units from variables}
\usage{
iso_strip_units(x)
}
\arguments{
\item{x}{variable to strip units from (vector or data frame)}
}
\description{
This function converts numbers with units back into unitless numbers both for single variables and data frames / tibbles. For single variables, this is equivalent to the \code{as.numeric} function.
}
\seealso{
Other functions for values with units: 
\code{\link{iso_get_units}()},
\code{\link{iso_is_double_with_units}()},
\code{\link{iso_make_units_explicit}()},
\code{\link{iso_make_units_implicit}()},
\code{\link{iso_with_units}()}
}
\concept{functions for values with units}
