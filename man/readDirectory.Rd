% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/readDirectory.R
\name{readDirectory}
\alias{readDirectory}
\title{Read all of the plate files from a specific directory}
\usage{
readDirectory(directory, tofmin = 60, tofmax = 2000, extmin = 0,
  extmax = 10000, SVM = TRUE)
}
\arguments{
\item{directory}{The directory to be read}

\item{tofmin}{The minimum time of flight value allowed. Defaults to 60.}

\item{extmin}{The minimum extinction value allowed. Defaults to 0.}

\item{SVM}{Boolean specifying whether or not to use the support vector machine to separate worms and bubbles.}

\item{tofmin}{The minimum time of flight value allowed. Defaults to 2000.}

\item{extmin}{The maximum extinction value allowed. Defaults to 10000.}
}
\value{
A single data frame with all of the plates from the read directory.
}
\description{
This function reads in all of the plates within a single directory.
}

