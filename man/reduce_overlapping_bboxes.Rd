% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reduce_overlapping_bboxes.R
\name{reduce_overlapping_bboxes}
\alias{reduce_overlapping_bboxes}
\title{Find overlapping bounding boxes and return classification with maximum confidence}
\usage{
reduce_overlapping_bboxes(df, overlap_threshold = 0.8)
}
\arguments{
\item{df}{The data frame containing bounding box values and predictions}

\item{overlap_threshold}{The threshold (proportion) used in determining which bounding boxes are considered unique detections}
}
\value{

}
\description{
Evaluates overlapping bounding boxes using user specified threshold that determines overlap and returns
bounding boxes and classification with maximum confidence
}
