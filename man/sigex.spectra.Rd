% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sigex.spectra.r
\name{sigex.spectra}
\alias{sigex.spectra}
\title{Computes scalar part of spectrum of a differenced latent
	multivariate component process}
\usage{
sigex.spectra(L.par, D.par, mdl, comp, mdlPar, delta, grid)
}
\arguments{
\item{L.par}{Unit lower triangular matrix in GCD of the component's
white noise covariance matrix.}

\item{D.par}{Vector of logged entries of diagonal matrix in GCD
of the component's white noise covariance matrix.}

\item{mdl}{The specified sigex model, a list object}

\item{comp}{Index of the latent component}

\item{mdlPar}{This is the portion of param
corresponding to mdl[[2]], cited as param[[3]]}

\item{delta}{Differencing polynomial written in format c(delta0,delta1,...,deltad)}

\item{grid}{Desired number of frequencies for output spectrum}
}
\value{
f.spec: array of dimension N x N x (grid+1), consisting of spectrum
		at frequencies pi*j/grid for 0 <= j <= grid
}
\description{
Computes scalar part of spectrum of a differenced latent
	multivariate component process
}
