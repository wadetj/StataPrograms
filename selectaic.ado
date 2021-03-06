/*Author: Tim Wade wadetj@gmail.com*/
/*Purpose: Run model to use backward selection to select lowest aic or bic*/
/*renamed to selectaic 5/9/2011*/
/*modified to change the "show" option to only show final model and mata output*/
/*modified 8/17/16 to use egen, rowmiss instead of dropmiss as drop miss has been replaced without similar functionality)*/
/*modified 1/27/17 to correctly account when no variables meet critiria*/

capture program drop selectaic
program selectaic, rclass
version 11.1
syntax  namelist(max=1) [if] [in], outcome(string) [exposure(string)] stat(string) [keepvar(string)] [covar(varlist fv)] [options(string)] [show]
display in white "`outcome' `exposure' "

	clear mata
	set more off
	marksample touse
	
	preserve
	local covarlist=subinstr("`covar'", "i.", "" ,.)
	local keepvarlist=subinstr("`keepvar'", "i.", "" ,.)
	local expvarlist=subinstr("`exposure'", "i.", "" ,.)
	
	*dropmiss `outcome' `expvarlist' `keepvarlist'  `covarlist', obs any force
	
	tempvar missx
	egen `missx'=rowmiss(`outcome' `expvarlist' `keepvarlist'  `covarlist')
	drop if `missx'>0
	
	
	
	if "`stat'"~="AIC" & "`stat'"~="BIC" {
		di "`stat'" not supported at this time
		}
	
	
	*full model-all covariates

	`namelist' `outcome' `exposure' `keepvar' `covar' if `touse', `options'
	
	qui: estat ic
 	matrix XX=r(S)
 	
	if "`stat'"=="AIC" {
		local full=XX[1, 5]
		}
		
		
	if "`stat'"=="BIC" {
		local full=XX[1, 6]
		}
 	
 	
	di `full'
	local name=""
	local estimate=""
	mata: Name=st_local("name")
	mata: Est=st_local("estimate")
	
	local minest=`full'	
	
	
	while `minest'<=`full' {
		
		foreach var in `covar'{
			local varlist: subinstr local covar "`var'" ""
			*if varlist is null, show unadjusted model
			local qqq: word count `varlist'
			
			if `qqq'<1 {
				di in yellow "no variables selected -displaying unadjusted model"	
				`namelist' `outcome' `exposure' `keepvar' if `touse', `options'	
				exit
			}
			
			
			if "`show'"!=""{
				`namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
			}
			
			
			if "`show'"==""{
				qui: `namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
			}
		

			if "`show'"!=""{
				display in yellow "-`var'"
				`namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
				estat ic
			}

			if "`show'"==""{
				qui: `namelist' `outcome' `exposure' `keepvar' `varlist' if `touse', `options'
				qui: estat ic
			}

		
			matrix ZZ=r(S)
		
			if "`stat'"=="AIC" {
				local x=ZZ[1, 5]
			}
		
		
			if "`stat'"=="BIC" {
				local x=ZZ[1, 6]
			}
		

			local varfile=subinstr("`var'", "i.", "ii" ,.)
			local name="`var'"
			local estimate=`x'
		
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
	
		if "`show'"!="" {
			di "New full model is"
			`namelist' `outcome' `exposure' `keepvar' `covar' if `touse', `options'
		}
	
		if "`show'"=="" {
			qui: `namelist' `outcome' `exposure' `keepvar' `covar' if `touse', `options'
		}
	
		if `minest'>`full' {
			continue, break
		}
	
		if "`covar'"=="" {
			di in yellow "final model"	
			`namelist' `outcome' `exposure' `keepvar' `covar' if `touse', `options'
			exit
		}
	
	
		qui estat ic
 	
 		matrix YY=r(S)
		
		if "`stat'"=="AIC" {
			local full=YY[1, 5]
		}
		
		
		if "`stat'"=="BIC" {
			local full=YY[1, 6]
		}
 	
 	
		di "-""`minname'"   "  `stat'="`full'
		local name=""
		local estimate=""
		mata: Name=st_local("name")
		mata: Est=st_local("estimate")
	
	
	}


di "VARIABLES MEETING CRITERIA ARE:"  "`oldlist'"
di in yellow "final model-estimate on restricted data"
`namelist' `outcome' `exposure' `keepvar' `oldlist' if `touse', `options'
estat ic


if _rc~=0 {
	di "Cannot estimate exposure effect}
	exit
}


restore 
di "VARIABLES MEETING CRITERIA ARE:"  "`oldlist'"
di in yellow "final model-estimate on full data"
`namelist' `outcome' `exposure' `keepvar' `oldlist' if `touse', `options'
global covarlist="`oldlist'"
return local covarlist="`oldlist'"
estat ic



clear mata

end


