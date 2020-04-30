*Modified 9/11/13 to allow variable list and to run without data in memory

capture program drop comparedata
program comparedata
version 11.0
syntax [anything], data1(string) data2(string) id(namelist) [listvars(namelist)] [outfile(string)]

capture clear

tempfile __d1
tempfile __d2


quietly {
	use "`data1'"
	
	if "`anything'"!=""{
		keep `anything' `id' `listvars'
		}
		
	*capture destring(`id'), replace


	ds, alpha
	local list1 "`r(varlist)'"
	
	save "`__d1'", replace
	
	clear

	use "`data2'"
	*use "`__d2'"
	
	if "`anything'"!=""{
		keep `anything' `id' `listvars'
		}

	
	ds, alpha
	local list2 "`r(varlist)'"

	save "`__d2'", replace
	
	clear

	local newlist:  list list1 & list2
	local alllist: list list1 | list2
	local droplist:  list alllist-newlist
	
	local dropind: list alllist===newlist

	if `dropind'==0 {
		noisily di in yellow "The following variables are not in both data sets and will not be compared: `droplist'"
		local newlist: subinstr local newlist "`droplist'" ""
	}


	*use "`data1'"
	use "`__d1'"
	local type1
	
	foreach var of varlist `newlist' {
		local type`var' : type `var'
		local type1 `type1' `type`var''
		}

	clear
	
	foreach type in byte int float double long {
		local type1: subinstr local type1 "`type'" "numeric", all
	}
	

	
	forvalues i  =1/50 {
		local type1: subinstr local type1 "str`i'" "string", all word
	}
	
	*use "`data2'"
	use "`__d2'"
	local type2
	
	foreach var of varlist `newlist' {
		local type`var' : type `var'
		local type2 `type2' `type`var''
	}

	foreach type in byte int float double long {
		local type2: subinstr local type2 "`type'" "numeric", all
		}
	
	forvalues i  =1/50 {
		local type2: subinstr local type2 "str`i'" "string", all word
	}
		
		
	local typematch: list type1==type2
	
	if `typematch'==0 {
		mata: diffs()
		noisily di in yellow "The following variables have different formats and will not be compared: `outvars'"
		local newlist: subinstr local newlist "`outvars'" ""
		capture clear
		use `__d1'
		drop `outvars'
		save `__d1', replace
		clear
		capture clear
		use `__d2'
		drop `outvars'
		save `__d2', replace
		clear
		}
	
	local finalvars: subinstr local newlist "`id'" "", all word
	

	*use `data2'
	use "`__d2'"

	foreach var of varlist `finalvars' {
		rename `var' `var'_data2
	}
	
	
	capture rename `id'_data2 `id'
	
	*save `data2', replace
	save "`__d2'", replace
	clear

	*use "`data1'"
	use "`__d1'"
	
	*merge 1:1 `id' using `data2'
	merge 1:1 `id' using "`__d2'"
	count if _merge==3
	local countm=r(N)
	
	noisily di "Number of matched observations=`countm'"
	count if _merge~=3
	local countnm=r(N)
	noisily di "Number of unmatched observations (will be dropped)=`countnm'"

	drop if _merge~=3
	drop _merge



	foreach var of varlist `finalvars' {
		gen `var'_diff=0
		replace `var'_diff=1 if `var'~=`var'_data2
	}

	gen vardiffs=""

	*local i=1
}
	
foreach var of varlist `finalvars' {
qui count if `var'_diff==1
local __count=r(N)
di in yellow "differences for `var'=`__count'"
list `id' `listvars' `var' `var'_data2 if `var'_diff==1, noobs abb(20)
*gen diff`i'="`var'" if `var'_diff==1
qui replace vardiffs=vardiffs+","+"`var'" if `var'_diff==1
*local i=`i'+1
}

if "`outfile'"~="" {
	keep `id' `listvars' vardiffs
	keep if vardiffs~=""
	outsheet using `outfile'diffs.txt, replace comma noquote
}



end




mata:
 function diffs()
{

	t1=st_local("type1")
	t2=st_local("type2")
	t1=tokens(t1)
	t2=tokens(t2)
	varn=st_local("newlist")
	varn=tokens(varn)
	not=indexnot(t1, t2)
	outs=select(varn, not[1,] :>0)
	outs=invtokens(outs)
	st_local("outvars", outs) 

}

end


