% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_cache.R
\name{download_cache}
\alias{download_cache}
\title{download files needed to run the mdoel}
\usage{
download_cache(
  url = "https://www.dropbox.com/s/m4ojnotd2pev46u/weights_family_cpu.pth?raw=1",
  redownload = FALSE
)
}
\arguments{
\item{url}{location of file to download}

\item{redownload}{boolean. Re-download the file?}
}
\description{
This function will download necessary files and store them in the package space
}
