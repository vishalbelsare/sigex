% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sigex.lpfiltering.r
\name{sigex.lpfiltering}
\alias{sigex.lpfiltering}
\title{Compute signal extraction estimates with uncertainty
	for trend and cycle, by combining WK filter for trend-cycle
	(specified by trendcyclecomp) with LP filter of cutoff.}
\usage{
sigex.lpfiltering(
  mdl,
  data.ts,
  trendcyclecomp,
  sigcomps,
  psi,
  cutoff,
  grid,
  window,
  trunc,
  trendFlag
)
}
\arguments{
\item{mdl}{The specified sigex model, a list object}

\item{data.ts}{A T x N matrix ts object}

\item{trendcyclecomp}{The (single) index of the trend-cycle component}

\item{sigcomps}{Provides indices of a desired component that
    is disjoint from trend-cycle, so that MSEs of
trend+sigcomps and cycle+sigcomps are computed.
 (Pass in sigcomps = NULL to just get trend and cycle MSEs.)}

\item{psi}{A vector of all the real hyper-parameters}

\item{cutoff}{A number between 0 and pi, with all frequencies < cutoff preserved}

\item{grid}{Desired number of frequencies for spectrum calculations}

\item{window}{Maximum index of the filter coefficients}

\item{trunc}{Truncation index for LP filter}

\item{trendFlag}{Boolean flag, TRUE for trend+signal, else get cycle+signal}
}
\value{
list object with lp.signal, upp, and low
	lp.signal: T x N matrix of the signal estimates
	upp: as lp.signal, plus twice the standard error
	low: as lp.signal, minus twice the standard error
}
\description{
Compute signal extraction estimates with uncertainty
	for trend and cycle, by combining WK filter for trend-cycle
	(specified by trendcyclecomp) with LP filter of cutoff.
}
