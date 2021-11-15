
*generates histogram following fmm model
*no adjustment allowed

capture program drop fmmplot
program define fmmplot
version 17.0

syntax varlist(max=1), [levels(integer 2)] [plotoptions(string)] [adjust]

if `levels'==2 {
	if "`adjust'"=="" {
		matrix b=e(b)
		local m1=b[1,3]
		local m2=b[1,4]
		local v1=b[1,5]
		local v2=b[1,6]
	
	}
	
	if "`adjust'"~="" {
		qui estat lcmean
		matrix b=r(b)
		local m1=b[1,1]
		local m2=b[1,2]
		matrix V=r(V)
		local v1=V[1,1]
		local v2=V[2,2]
	}
	
	local s1=sqrt(`v1')
	local s2=sqrt(`v2')

	
	qui estat lcprob
	
	matrix p=r(b)
	local p1=p[1,1]
	local p2=p[1,2]
	
	qui summ `varlist'
	local up=r(max)+0.5*r(sd)
	local lo=r(min)-0.5*r(sd)
	
	
		hist `varlist', addplot(function `p1'*normalden(x, `m1', `s1'), range(`lo' `up') || function `p2'*normalden(x, `m2', `s2'), range(`lo' `up')) legend(off) `plotoptions'
}


if `levels'==3 {
	
	if "`adjust'"=="" {
		
		matrix b=e(b)
	
		local m1=b[1,4]
		local m2=b[1,5]
		local m3=b[1,6]
		local v1=b[1,7]
		local v2=b[1,8]
		local v3=b[1,9]
	}
	
	if "`adjust'"~="" {
		qui estat lcmean
		matrix b=r(b)
		local m1=b[1,1]
		local m2=b[1,2]
		local m3=b[1,3]
		
		matrix V=r(V)
		local v1=V[1,1]
		local v2=V[2,2]
		local v3=V[3,3]
		
	}
	
	
	local s1=sqrt(`v1')
	local s2=sqrt(`v2')
	local s3=sqrt(`v3')
	
	qui estat lcprob
	
	matrix p=r(b)
	local p1=p[1,1]
	local p2=p[1,2]
	local p3=p[1,3]
	
	qui summ `varlist'
	local up=r(max)+0.5*r(sd)
	local lo=r(min)-0.5*r(sd)
	
	hist `varlist', addplot(function `p1'*normalden(x, `m1', `s1'), range(`lo' `up') || function `p2'*normalden(x, `m2', `s2'), range(`lo' `up') || function `p3'*normalden(x, `m3', `s3'), range(`lo' `up'))  legend(off) `plotoptions'
	
}


end	

*fmm 2: regress lhev
*fmmplot lhev
*fmm 3: regress lhev
*fmmplot lhev, levels(3)
	