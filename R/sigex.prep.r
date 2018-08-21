#' applies some preliminary transformations to the data
#'
#' @param data.ts a T x N matrix ts object,
#'			corresponding to N time series of length T
#' @param transform a character indicating an instantaneous
#'			transformation to be applied; current options are
#'			"none", "log", and "logistic"
#' @param aggregate a boolean, set to TRUE if all subseries are to
#'			be aggregated into a total
#' @param subseries sequence of indices between 1 and N,
#'			indicating which series	to examine
#' @param range if set to NULL, take full span of data, otherwise
#'			subset the times corresponding to indices in range
#' @param plot boolean, whether to plot the series (max of N=10 allowed)
#'
#' @return data.ts: a T x N0 matrix ts object, where N0=1 if
#'			aggregate=TRUE, otherwise N0=N
#' @export
#'

sigex.prep <- function(data.ts,transform,aggregate,subseries,range=NULL,plot=FALSE)
{

	##########################################################################
	#
	#	sigex.prep
	# 	    Copyright (C) 2017  Tucker McElroy
	#
	#    This program is free software: you can redistribute it and/or modify
	#    it under the terms of the GNU General Public License as published by
	#    the Free Software Foundation, either version 3 of the License, or
	#    (at your option) any later version.
	#
	#    This program is distributed in the hope that it will be useful,
	#    but WITHOUT ANY WARRANTY; without even the implied warranty of
	#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	#    GNU General Public License for more details.
	#
	#    You should have received a copy of the GNU General Public License
	#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
	#
	############################################################################

	################# Documentation #####################################
	#
	#	Purpose: applies some preliminary transformations to the data
	#
	#	Inputs:
	#		data.ts: a T x N matrix ts object,
	#			corresponding to N time series of length T
	#		transform: a character indicating an instantaneous
	#			transformation to be applied; current options are
	#			"none", "log", and "logistic"
	#		aggregate: a boolean, set to TRUE if all subseries are to
	#			be aggregated into a total
	#		subseries: sequence of indices between 1 and N,
	#			indicating which series	to examine
	#		range: if set to NULL, take full span of data, otherwise
	#			subset the times corresponding to indices in range
	#		plot: boolean, whether to plot the series (max of N=10 allowed)
	#	Outputs:
	#		data.ts: a T x N0 matrix ts object, where N0=1 if
	#			aggregate=TRUE, otherwise N0=N
	#
	####################################################################

	if(length(range)==0) { range <- seq(1,dim(data.ts)[1]) }

 	data.ts <- sigex.transform(data.ts[range,subseries,drop=FALSE],transform,aggregate)
	if(plot) { plot(data.ts,xlab="Year") }

	return(data.ts)
}
