% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_stroop.R
\docType{data}
\name{stroop}
\alias{stroop}
\title{Stroop Task}
\format{
A data frame with 12500 rows and 5 variables:
\describe{
\item{sub_id}{Subject ID}
\item{word}{The text of the word}
\item{ink}{The ink colour of the word}
\item{response}{The subject's response (should equal the ink colour)}
\item{rt}{Reaction time (in ms)}
}
}
\source{
\url{https://psyteachr.github.io/reprores-v3/data/stroop.csv}
}
\usage{
stroop
}
\description{
50 simulated subject in a stroop task viewing all combinations of word and ink colours blue, purple, green, red, and brown, 5 times each. Subjects respond with the ink colour. Subjects who do not respond in time have NA for response and rt.
}
\keyword{datasets}
