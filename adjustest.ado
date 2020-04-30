capture program drop adjustest
program adjustest
version 11.1
syntax varlist [if] [in], [varname(string)] [ats(integer 10)]  [ame] [at2(string)] [alllevels]
marksample touse
capture drop bhat se ats

if "`alllevels'"=="" {
tempvar yy
pctile `yy'= `varlist', nq(`ats')
levelsof `yy', local(q)
}

if "`alllevels'"~="" {
levelsof `varlist', local(q)
}


if "`ame'"=="" {
qui margins if `touse', atmeans at(`varlist'=(`q') `at2')
}

if "`ame'"~="" {
qui margins if `touse', at(`varlist'=(`q') `at2')
}

sort `varlist'	
    	
	
matrix Z=r(at)
matrix ZZ=Z[1..., "`varlist'"]
	
clear mata
mata: getmargin()

if "`varname'"~="" {
	rename bhat `varname'_b
	rename se `varname'_se
	rename ats `varname'_ats
	}
end



mata:
 function getmargin()
{
b=st_matrix("r(b)")
b=b'
V=st_matrix("r(V)")
at=st_matrix("ZZ")
at=at[,1]
v=diagonal(V)
se=sqrt(v)
bindex= st_addvar("double", "bhat")
seindex= st_addvar("double", "se")
atindex= st_addvar("double", "ats")
st_store((1,rows(b)),bindex,b)
st_store((1,rows(se)),seindex,se)
st_store((1,rows(at)),atindex,at)
}

end

*at=st_matrix("r(at)")
*at=at[,1]
/*	
	if "`ame'"=="" {
		qui margins, atmeans at(`varlist'=(`ats'))
		}
	if "`ame'"~="" {
		qui margins, at(`varlist'=(`ats'))
		}
	sort `varlist'	
	}
*/	
