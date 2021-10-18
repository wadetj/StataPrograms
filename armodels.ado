/*confirmed for glm linear model, predict nl gives same results as margins with continuous set at 
zero and base for factors*/
/*1-19-2011 - allows no wade option to treat all unexposed as non swimmers*/
/*1/31/2011-corrected so glm saves a single record for each exposure, before was producing inconsistent results*/
/*10-14-2021-removed "xi" prefix and other changes*/


capture program drop armodels
program define armodels
version 11.1
syntax namelist [if] [in], outcome(varlist) model(string) swim(varlist) exposure(varlist)  [options(string)] [covar(string)] [save] [wade]

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



 
 qui levelsof(`exposure') if `touse', local(xexp)
 
 if "`model'"=="glmame" {
	tempname m1
	glm `outcome' `exp' `swimtemp' `covar' if `touse', `options' family(binomial) link(identity)
	estimates store `m1'
	*predictnl `namelist'=_b[`swimtemp']*`swimtemp'+_b[`exp']*`exp', ci(`namelist'lo `namelist'up) se(`namelist'se)
	tempfile `namelist'
	tempname xfile
	postfile `xfile' count ar arlo arup using ``namelist'', replace

	foreach num in `xexp' {
		qui estimates restore `m1'
		qui margins, at(`swimtemp'=(0 1) `exp'=(0 `num')) post coeflegend
		qui lincom _b[4._at]-_b[1bn._at]
		local up= r(estimate)+1.96*r(se)
		local lo= r(estimate)-1.96*r(se)
		post `xfile' (`num') (r(estimate)) (`lo') (`up')
		}
	postclose `xfile'

use ``namelist'', clear

if "`save'"~="" {
	outsheet using `namelist'.txt , replace
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
	outsheet using `namelist'.txt, replace
	}

}



 if "`model'"=="logit" {
	tempname m1
	logit `outcome' `exp' `swimtemp' `covar' if `touse', `options'
	estimates store `m1'
	tempfile `namelist'
	tempname xfile
	postfile `xfile' count ar arlo arup using ``namelist'', replace
	foreach num in `xexp' {
		qui estimates restore `m1'
		qui margins, at((means) _all `swimtemp'=(0 1) `exp'=(0 `num')) post coeflegend
		qui lincom _b[4._at]-_b[1bn._at]
		local up= r(estimate)+1.96*r(se)
		local lo= r(estimate)-1.96*r(se)
		post `xfile' (`num') (r(estimate)) (`lo') (`up')
		}
postclose `xfile'
use ``namelist'', clear

if "`save'"~="" {
	outsheet using `namelist'.txt, replace
	}

}

		

 if "`model'"=="logitame" {
	tempname m1
	logit `outcome' `exp' `swimtemp' `covar' if `touse', `options'
	estimates store `m1'
	tempfile `namelist'
	tempname xfile
	postfile `xfile' count ar arlo arup using ``namelist'', replace
	foreach num in `xexp' {
		qui estimates restore `m1'
		qui margins, at(`swimtemp'=(0 1) `exp'=(0 `num')) post coeflegend
		qui lincom _b[4._at]-_b[1bn._at]
		local up= r(estimate)+1.96*r(se)
		local lo= r(estimate)-1.96*r(se)
		post `xfile' (`num') (r(estimate)) (`lo') (`up')
		}
postclose `xfile'
use ``namelist'', clear

if "`save'"~="" {
	outsheet using `namelist'.txt, replace
	}

}


 if "`model'"=="xtmelogit" {
	tempname m1
	tempvar beachnum
	encode beach, gen(`beachnum')
	xtmelogit `outcome' `exp' `swimtemp' `covar' if `touse' || `beachnum': , `options'
	estimates store `m1'
	tempfile `namelist'
	tempname xfile
	postfile `xfile' count ar arlo arup using ``namelist'', replace
	foreach num in `xexp' {
		qui estimates restore `m1'
		qui margins, predict(mu fixedonly) at((means) _all `swimtemp'=(0 1) `exp'=(0 `num')) post coeflegend
		qui lincom _b[4._at]-_b[1bn._at]
		local up= r(estimate)+1.96*r(se)
		local lo= r(estimate)-1.96*r(se)
		post `xfile' (`num') (r(estimate)) (`lo') (`up')
		}
postclose `xfile'
use ``namelist'', clear

if "`save'"~="" {
	outsheet using `namelist'.txt, replace
	}

}

	
 end
 
 
 
