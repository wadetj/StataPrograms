/*date created: 1/2/2008*/
/*author: Timothy J. Wade*/
/*Purpose: ceate final models from comma delimited final models for beaches analysis*/
/*Creates program saving exposure, swimming variable and covariates in a datafile*/
/*can be used for further analysis using selected covariates for each model*/
/*creates new data set with variables: swim, exposure and covars*/
/*modification history:
12/17/2008: modified to add negative sign "-" so numerical strings are located and replaced
6/15/2009: modified to capture if selected models do not have any covars so that covars is still generated containing "" 

*/




capture program drop makefinalmodels
program makefinalmodels
syntax [if] [in], file(string)[models(string) saving(string)]


set more off
insheet using "`file'", clear
keep idstr
count
local tot=r(N)

gen count=_n

forvalues i=1/50 {
	qui gen v`i'=""
	}


forvalues i=1/`tot' {
	local words=wordcount(idstr[`i'])
	forvalues j=1/`words' {
		qui replace v`j'=word(idstr[`i'], `j') if `i'==count
}
}


foreach var of varlist v1-v50 {
	qui replace `var'="" if inlist(substr(`var', 1, 1), "1", "2", "3", "4", "5", "6", "7", "8", "9")==1
	qui replace `var'="" if inlist(substr(`var', 1, 1), ".", "0", "-")==1
	}

drop idstr count
drop if v2=="unadjusted"
drop if v2=="beach"

duplicates drop
if inlist(v2, "anycontact", "bodycontact", "headunder", "mouthwater", "swallwater")==0 {
qui gen swim=""
qui replace swim="anycontact" if strmatch(v1, "any")==1
qui replace swim="anycontact" if strpos(v1, "any")~=0
qui replace swim="bodycontact" if strpos(v1, "body")~=0
qui replace swim="headunder" if strpos(v1, "head")~=0
qui replace swim="mouthwater" if strpos(v1, "mouth")~=0
qui replace swim="swallwater" if strpos(v1, "swall")~=0
qui gen exposure=""
qui replace exposure=subinstr(v1, "anycontact", "", .) if swim=="anycontact"
qui replace exposure=subinstr(v1, "bodycontact", "", .) if swim=="bodycontact"
qui replace exposure=subinstr(v1, "headunder", "", .) if swim=="headunder"
qui replace exposure=subinstr(v1, "mouthwater", "", .) if swim=="mouthwater"
qui replace exposure=subinstr(v1, "swallwater", "", .) if swim=="swallwater"

drop v1

	}


if inlist(v2, "anycontact", "bodycontact", "headunder", "mouthwater", "swallwater")~=0 {
rename v1 exposure
rename v2 swim
	}



if "`models'"~="" {
	tempvar flag
	gen `flag'=0
	local keepnum=wordcount("`models'")
	forvalues i=1/`keepnum' {
		local modelnum=word("`models'", `i')
		replace `flag'=1 if exposure=="`modelnum'"
	}
	keep if `flag'==1
}


dropmiss, force
drop if swim==""


capture egen covars=concat(v*), punct(" ")
capture drop v*

capture confirm var covars
if _rc~=0 {
	gen covars=""
}

	
*count
*local count=r(N)

if "`saving'"~="" {
	save "`saving'", replace
}

end





