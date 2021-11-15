/*confirmed for glm linear model, predict nl gives same results as margins with continuous set at 
zero and base for factors*/
/*1-19-2011 - allows no wade option to treat all unexposed as non swimmers*/
/*1/31/2011-corrected so glm saves a single record for each exposure, before was producing inconsistent results*/
/*10-14-2021-removed xi prefix*/
/*armodels2- testing several major changes in the margins estimation - requires at least Stata 16*/
/*allows for optional specification of exposure values, now saves file as stata dataset*/

capture program drop armodels2
program define armodels2
version 16.0
syntax [namelist] [if] [in], outcome(varlist) model(string) swim(varlist) exposure(varlist)  [options(string)] [covar(string)] [save] [wade] [expvalues(numlist)]

if "`save'"~="" {
	preserve
}


tempfile data
save `data', replace

 marksample touse
 tempvar exp swimtemp
 
 if "`wade'"=="" {
 gen `exp'=`exposure'
 replace `exp'=0 if anycontact==0 
 replace `exp'=. if anycontact==1 & `swim'~=1
 gen `swimtemp'=`swim'
 replace `swimtemp'=. if anycontact==1 & `swim'~=1
}


 if "`wade'"~="" {
 gen `exp'=`exposure'
 replace `exp'=0 if `swim'==0 
  gen `swimtemp'=`swim'
}



 if "`expvalues'"=="" {
	qui levelsof(`exposure') if `touse', local(xexp)
 }
 
 if "`expvalues'" ~="" {
 	local xexp `expvalues'
 }
 
 
 if "`model'"=="glmame" {
	tempname m1
	glm `outcome' `exp' `swimtemp' `covar' if `touse', `options' family(binomial) link(identity)
	estimates store `m1'
	*predictnl `namelist'=_b[`swimtemp']*`swimtemp'+_b[`exp']*`exp', ci(`namelist'lo `namelist'up) se(`namelist'se)
	*tempfile `namelist'
	*tempname xfile
	*postfile `xfile' count ar arlo arup using ``namelist'', replace
	*qui margins, at(`swimtemp'=(0 1) `exp'=(0 `num')) post coeflegend
	qui margins, at(swimtemp=(0 1) exp=(0 `xexp')) contrast(atcontrast(r)) coeflegend post
	
	matrix A=r(table)
	matrix X=A'
	matrix B=r(at)
	clear
	svmat B
	drop in 1
	keep B1 B2
	tempfile at 
	save `at'

	clear

	svmat X
	merge 1:1 _n using `at'

	drop if B2==0
	drop _merge
	drop X7-X9
	drop B2

	rename (X1 X2 X3 X4 X5 X6 B1) (ar se z p arlo arup lent)
	

if "`save'"~="" {
	save `namelist'.dta , replace
	}

}

 if "`model'"=="glm" {
	tempname m1
	glm `outcome' `exp' `swimtemp' `covar' if `touse', `options' family(binomial) link(identity)
	estimates store `m1'
	predictnl ar =_b[`swimtemp']*`swimtemp'+_b[`exp']*`exp' if e(sample), ci(arlo arup) se(arse)
	keep if `swimtemp'==1
	qui bysort `exp' (ar): keep if _n==1
	rename `exp' count
	keep ar arlo arup arse count
	drop if ar>=.
	tempfile `namelist'

	

if "`save'"~="" {
	save `namelist'.dta , replace
	}
}



 if "`model'"=="logit" {
	tempname m1
	logit `outcome' `exp' `swimtemp' `covar' if `touse', `options'
	estimates store `m1'
	qui margins, at((means) _all `swimtemp'=(0 1) `exp'=(0 `xexp')) contrast(atcontrast(r)) coeflegend post
	matrix A=r(table)
	matrix X=A'
	matrix B=r(at)
	clear
	svmat B
	drop in 1
	keep B1 B2
	tempfile at 
	save `at'

	clear

	svmat X
	merge 1:1 _n using `at'

	drop if B2==0
	drop _merge
	drop X7-X9
	drop B2

	rename (X1 X2 X3 X4 X5 X6 B1) (ar se z p arlo arup lent)
	

if "`save'"~="" {
	save `namelist'.dta , replace
	}

}


	

 if "`model'"=="logitame" {
	tempname m1
	logit `outcome' `exp' `swimtemp' `covar' if `touse', `options'
	estimates store `m1'
	qui margins, at(`swimtemp'=(0 1) `exp'=(0 `xexp')) contrast(atcontrast(r)) coeflegend post
	
	matrix A=r(table)
	matrix X=A'
	matrix B=r(at)
	clear
	svmat B
	drop in 1
	keep B1 B2
	tempfile at 
	save `at'

	clear

	svmat X
	merge 1:1 _n using `at'

	drop if B2==0
	drop _merge
	drop X7-X9
	drop B2
 
 
	rename (X1 X2 X3 X4 X5 X6 B1) (ar se z p arlo arup lent)


if "`save'"~="" {
	save `namelist'.dta , replace
	}

}


 if "`model'"=="xtmelogit" {
	tempname m1
	tempvar beachnum
	encode beach, gen(`beachnum')
	xtmelogit `outcome' `exp' `swimtemp' `covar' if `touse' || `beachnum': , `options'
	estimates store `m1'
		qui margins, predict(mu fixedonly) at((means) _all `swimtemp'=(0 1) `exp'=(0 `xexp')) contrast(atcontrast(r)) post coeflegend
	
	matrix A=r(table)
	matrix X=A'
	matrix B=r(at)
	clear
	svmat B
	drop in 1
	keep B1 B2
	tempfile at 
	save `at'

	clear

	svmat X
	merge 1:1 _n using `at'

	drop if B2==0
	drop _merge
	drop X7-X9
	drop B2

	rename (X1 X2 X3 X4 X5 X6 B1) (ar se z p arlo arup lent)
	

if "`save'"~="" {
	save `namelist'.dta , replace
	}

}

	
 end
 
 
 

