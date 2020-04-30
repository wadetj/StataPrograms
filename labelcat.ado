/*
Author: Tim Wade
Date: April 16, 2008
Program name: labelcat
Version 2
Purpose: Assigns labels to a categorical variable based on cut point
Assumes categorical variable is ordinal, coded from i...j where i is the smallest and
j is the largest categories. Categories must be ordered by 1 unit increase (e.g., 0, 1, 2, 3, 4, etc.)
Description: Creates a new label based on the min and max of the cut points
of the categorical variable in relation to the original continuous variable. 
Assigns this label to the categorical variable
Example:
version 8
sysuse auto.dta
xtile agecat=age, nq(4)
labelcat age, catvar(agecat) ncats(4) format(%5.0f)
tabulate agecat
Modification History: 
	5/11/2011: version 2: Eliminated ncats, added locals min and max, allows categories other than those with min of 1

*/

version 8

capture program drop labelcat
program define labelcat
syntax varlist(max=1) [if] [in], catvar(varlist) [format(string)]

marksample touse

if "`format'"=="" {
	local format %9.2g
}

qui summ `catvar'
local min=r(min)
local max=r(max)

capture label drop `catvar'

forvalues i=`min'(1)`max'{
   qui summ `varlist' if `catvar'==`i' & `touse', detail
   local xmin`i': display `format' r(min)
   local xmax`i': display `format' r(max)
   local xmax`i'=`xmax`i''
  local text`i' `i' "`xmin`i''-`xmax`i''"
   }

local text=itrim(`"`text`min''"')
local min2=`min'+1

forvalues i=`min2'(1)`max' {
local text `text' `text`i''
	}

*di `text'
label define `catvar' `text'
label values `catvar' `catvar'

end




