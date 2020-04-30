/*Author: Tim Wade wadetj@gmail.com*/
/*Purpose: Run change in estimate procedure for simple regression models*/
/*Output: Exposure coefficient r(coef) and selected covariate list $covarlist*/
/*Modification History: April 25, 2008 to allow for options in regresison models*/
/* 2/13/2008 to save coefficient in scalar no longer reports unadjusted model*/
/*modify for mata*/
/*modified mata code--problem with sorting string/numeric matrices*/
*need to change so that variables dropped for collinearity are not retained in $covarlist

capture program drop ciereg
program ciereg, rclass
version 10.0
syntax  namelist(max=1) [if] [in], outcome(string) exposure(string) [keepvar(string)] [covar(string)] [criteria(real 0.10)] [options(string)] [show]
display in white "`outcome' `exposure' "

	clear mata
	set more off
	marksample touse

	local covar2 "`covar'"

	if index("`covar2'", "i.")~=0 {
		local covar2=subinstr("`covar2'", "i.", "", .) 
		}

	xi: `namelist' `outcome' `exposure' `keepvar' `covar' if `touse', `options'
	qui capture lincom `exposure'
	
	if _rc~=0 {
		di "Cannot estimate exposure effect"
		exit
	}
	
 	qui lincom `exposure'
	local full=r(estimate)
	di `full'

	local minest=0
	while `minest'<`criteria' {
		capture log off
		local name=""
		local estimate=""
		mata: Name=st_local("name")
		mata: Est=st_local("estimate")
	
	
		if ltrim("`covar'")=="" {

			capture log on

			display in yellow "no variables meet criteria displaying unadjusted model"

		di in yellow "unadjusted model"
		xi: `namelist' `outcome' `exposure' `keepvar'  if `touse', `options'
		qui lincom `exposure'
		return scalar coef=r(estimate)
		 
		global covarlist=""

		exit 
			
		}

		foreach var in `covar'{
		local varlist: subinstr local covar "`var'" ""

		if "`show'"!=""{
			display in yellow "-`var'"
			xi: `namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
		}

		if "`show'"==""{
			qui xi: `namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
		}

		qui capture lincom `exposure'
		
		if _rc~=0 {
			di "Cannot estimate exposure effect}
			continue, break
		}
		
		qui lincom `exposure'
		local x=r(estimate)
		local varfile=subinstr("`var'", "i.", "ii" ,.)
		local name="`var'"
		local estimate=abs((`full'-`x')/(`full'))

		if "`show'"!=""{
			di "`name'   " "`estimate'"
		}

		mata: Est=(Est\st_local("estimate"))
		mata: Est2=strtoreal(Est)
		mata: Name=(Name\st_local("name"))	
		}
	
		mata: ord=order(Est2, 1)
	mata: Est2=Est2[ord]
	mata: Est=Est[ord]
	mata: Name=Name[ord]
	mata: st_local("minest", Est[1])
	mata: st_local("minname", Name[1])
	qui capture log on

	if "`show'"!="" {
		mata: (Est,Name)
	}

	local minname=subinstr("`minname'", "ii", "i.", .)

	if "`show'"!="" {
	di in white "REMOVE `minname'"
	}
	local oldlist "`covar'"
	local covar: subinstr local covar "`minname'" ""
	
	if "`show'"!="" {
	di in white "new varlist is `covar'"
	}
	
	
	qui capture log off
	}

qui capture log on

di "VARIABLES MEETING CRITERIA ARE:"  "`oldlist'"
di in yellow "final model"
xi: `namelist' `outcome' `exposure' `keepvar' `oldlist' if `touse', `options'
qui capture lincom `exposure'
if _rc~=0 {
	di "Cannot estimate exposure effect}
	exit
}

qui lincom `exposure'

return scalar coef=r(estimate)
global covarlist="`oldlist'"
return local covarlist="`oldlist'"

clear mata

end


