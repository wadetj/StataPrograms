
*creates histograms with distributions following fmm models
*can handle regression models with multiple variables (uses marginal means)

capture program drop fmmplot
program define fmmplot
version 17.0

syntax varlist(max=1), [levels(integer 2)] [plotoptions(string)] 

if `levels'==2 {
	
	matrix V=r(table)

	local cols colsof(V)
	local col1=`cols'-1
	
	local v1=V[1,`col1']
	local v2=V[1,`cols']
	
	local s1=sqrt(`v1')
	local s2=sqrt(`v2')
	
	qui estat lcmean
	return list
	matrix b=r(b)
	local m1=b[1,1]
	local m2=b[1,2]
	
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

	matrix V=r(table)

	local col3 colsof(V)
	local col2=`col3'-1
	local col1=`col3'-2
	
	local v1=V[1,`col1']
	local v2=V[1,`col2']
	local v3=V[1,`col3']
		
	*local v1=b[1,5]
	*local v2=b[1,6]

	local s1=sqrt(`v1')
	local s2=sqrt(`v2')
	local s3=sqrt(`v3')
	
	qui estat lcmean
	return list
	matrix b=r(b)
	local m1=b[1,1]
	local m2=b[1,2]
	local m3=b[1,3]
	
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
*fmm 3: regress lhev age
*fmmplot lhev, levels(3)

