% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{iso_expand_paths}
\alias{iso_expand_paths}
\title{Expand file paths}
\usage{
iso_expand_paths(path, extensions = c(), root = ".")
}
\arguments{
\item{path}{vector of file/folder paths, mixed relative and absolute paths are allowed.}

\item{extensions}{which extensions to look for? (with or without leading .) - this is typically one or more of the extensions listed by \code{\link{iso_get_supported_file_types}}}

\item{root}{root directory for the isofiles. Can be relative to the current working directory (e.g. \code{"data"}) or an absolute path on the file system (e.g. \code{"/Users/..."} or \code{"C:/Data/.."}). The default is the current working directory (\code{"."}). Can be supplied as a vector of same length as the provided paths if the paths have different roots.}
}
\value{
data frame with columns \code{root} (\code{root} as provided) and \code{path} of all the found files.
}
\description{
Helper function to expand the provided paths to find data files in folders and subfolders that match any of the specified extensions. Filepaths will be kept as is, only folders will be expanded. Note that this function is rarely called directly. It is used automatically by \code{\link{iso_read_dual_inlet}} and \code{\link{iso_read_continuous_flow}} to identify files of interest based on the file paths provided.
}
\seealso{
Other file system functions: 
\code{\link{iso_find_absolute_path_roots}()},
\code{\link{iso_root_paths}()},
\code{\link{iso_shorten_relative_paths}()}
}
\concept{file system functions}
